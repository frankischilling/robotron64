"""Execute the complete source-owned decoder against retail and stream oracles.

The cartridge transfer service is a recorded ABI boundary. All fourteen decoder
procedures and their shared tables are independently compiled before execution.
Fixtures are generated here; no extracted compressed assets are required.
"""

from pathlib import Path
import hashlib, json, random, struct, zlib
from importlib.metadata import version
from compare_startup import compare_block, SymbolLayoutSnapshot
from owned_sections import elf_sections_and_symbols
from compare_runtime import MATCHING_BLOCKS, CANDIDATE_BLOCKS
from rom import ROOT, validate
from unicorn import (
    Uc,
    UC_ARCH_MIPS,
    UC_MODE_MIPS32,
    UC_MODE_BIG_ENDIAN,
    UC_HOOK_CODE,
    UC_HOOK_MEM_READ,
    UC_HOOK_MEM_WRITE,
)
from unicorn import mips_const as regs
from check_audio_instance_allocate import CALLER_SAVED

START, END, DYNAMIC, DMA, STOP = (
    0x8005DA20,
    0x8005FBB0,
    0x8005EEE0,
    0x80051924,
    0x80000080,
)
INPUT, OUTPUT, SCRATCH, STACK = 0x80200010, 0x80220010, 0x80280017, 0x803E0000
GLOBALS, TABLES = 0x80192BD0, 0x8008DA40
RESULTS = 0x80270010
CODE_TABLES = 0x80260010
OUTPUT_SIZE, SCRATCH_SIZE = 0x20000, 0x100000
GUARD = bytes(range(16))


def word(n):
    return struct.pack(">I", n & 0xFFFFFFFF)


def stream(data, strategy):
    c = zlib.compressobj(6, zlib.DEFLATED, -15, 8, strategy)
    return c.compress(data) + c.flush()


def bits(parts):
    value = count = 0
    out = bytearray()
    for x, n in parts:
        value |= x << count
        count += n
        while count >= 8:
            out.append(value & 255)
            value >>= 8
            count -= 8
    if count:
        out.append(value & 255)
    return bytes(out)


def malformed(lengths, payload=()):
    return bits(
        [(1, 1), (2, 2), (0, 5), (0, 5), (15, 4)]
        + [(x, 3) for x in lengths]
        + list(payload)
    )


def fixtures():
    rng = random.Random(20261004)
    samples = [
        b"",
        b"A",
        b"AB",
        bytes(range(256)),
        b"abracadabra" * 100,
        b"Robotron64\x00" * 500,
        bytes(rng.randrange(8) for _ in range(4096)),
        bytes(rng.randrange(256) for _ in range(4096)),
        (bytes(range(256)) * 150),
        b"Q" * 40000,
    ]
    for n in (3, 15, 127, 257, 1024):
        samples.append(bytes(rng.randrange(16) for _ in range(n)))
    for idx, data in enumerate(samples):
        for strategy in (
            zlib.Z_DEFAULT_STRATEGY,
            zlib.Z_FIXED,
            zlib.Z_HUFFMAN_ONLY,
            zlib.Z_RLE,
        ):
            packed = stream(data, strategy)
            assert zlib.decompress(packed, -15) == data
            for mode in ("memory", "cartridge"):
                yield dict(
                    name=f"{idx}/{strategy}/{mode}",
                    packed=packed.hex(),
                    expected=data.hex(),
                    mode=mode,
                    error=0,
                )
            # With Huffman-only streams, each output step is a literal. Its limit oracle
            # is an exact prefix, independent of the decoder's match-copy behavior.
            if strategy == zlib.Z_HUFFMAN_ONLY:
                for limit in sorted(
                    {0, 1, max(1, len(data) // 2), len(data), len(data) + 1}
                ):
                    if len(data) == 0 and limit:
                        continue
                    yield dict(
                        name=f"{idx}/{strategy}/bounded/{limit}",
                        packed=packed.hex(),
                        expected=data[:limit].hex(),
                        mode="bounded",
                        limit=limit,
                        error=0,
                    )
    # Incompressible input forces a second 65,536-byte cartridge refill and
    # crosses the output window twice.
    large = bytes(rng.randrange(256) for _ in range(70000))
    packed = stream(large, zlib.Z_DEFAULT_STRATEGY)
    assert len(packed) > 65536 and zlib.decompress(packed, -15) == large
    for mode in ("memory", "cartridge"):
        yield dict(
            name="multiple-refills/" + mode,
            packed=packed.hex(),
            expected=large.hex(),
            mode=mode,
            error=0,
        )
    for name, packed, error in [
        ("reserved", b"\x07", 5),
        ("stored-complement", b"\x01\x01\x00\x01\x00", 3),
        ("oversubscribed", malformed([1, 1, 1] + [0] * 16), 6),
        ("incomplete", malformed([2] + [0] * 18), 2),
        (
            "repeat-overflow",
            malformed([1, 0, 1] + [0] * 16, [(1, 1), (127, 7), (1, 1), (127, 7)]),
            8,
        ),
    ]:
        for mode in ("memory", "cartridge"):
            yield dict(
                name=name + "/" + mode,
                packed=packed.hex(),
                expected="",
                mode=mode,
                error=error,
            )
    for width in (1, 2, 5, 7, 9, 16):
        yield dict(
            name=f"builder/allocation-failure/{width}",
            mode="builder",
            lengths=[1, 1],
            width=width,
            distance=False,
            allocation_failure=True,
            packed="",
            expected="",
            error=1,
        )
    for kind, error in (("literal-invalid", 7), ("distance-invalid", 7), ("end", 0)):
        yield dict(
            name="codes/" + kind,
            mode="codes",
            kind=kind,
            packed="00",
            expected="",
            error=error,
        )
    for lengths, error in [
        ([0] * 19, 0),
        ([1], 0),
        ([2], 2),
        ([1, 1], 0),
        ([1, 1, 1], 6),
        (list(range(1, 16)) + [16, 16], 0),
        ([8] * 256, 0),
        ([8] * 144 + [9] * 112 + [7] * 24 + [8] * 8, 0),
        ([5] * 30, 2),
    ]:
        for width in (1, 2, 5, 7, 9, 16):
            distance = lengths == [5] * 30
            yield dict(
                name=f"builder/{len(lengths)}/{width}/{error}",
                mode="builder",
                lengths=lengths,
                width=width,
                distance=distance,
                packed="",
                expected="",
                error=error,
            )


def verify_tree(read, case):
    """Read the produced table using independently assigned canonical codes."""
    lengths = case["lengths"]
    root = int.from_bytes(read(RESULTS, 4), "big")
    width = int.from_bytes(read(RESULTS + 4, 4), "big")
    if not any(lengths):
        assert root == 0 and width == 0
        return
    if case["error"] in (1, 6):
        return
    assert SCRATCH <= root < SCRATCH + SCRATCH_SIZE and 1 <= width <= 16
    counts = [lengths.count(i) for i in range(17)]
    next_code = [0] * 17
    # Zero-length symbols have no code and do not contribute to the recurrence.
    code = 0
    for size in range(1, 17):
        code = (code + (counts[size - 1] if size > 1 else 0)) << 1
        next_code[size] = code
    for symbol, length in enumerate(lengths):
        if not length:
            continue
        canonical = next_code[length]
        next_code[length] += 1
        value = int(f"{canonical:0{length}b}"[::-1], 2)
        table = root
        lookup = width
        consumed = 0
        for _ in range(17):
            slot = table + 8 * (value & ((1 << lookup) - 1))
            assert SCRATCH <= slot and slot + 8 <= SCRATCH + SCRATCH_SIZE
            entry = read(slot, 8)
            operation, bits_used = entry[:2]
            value >>= bits_used
            consumed += bits_used
            if operation <= 16 or operation == 99:
                break
            lookup = operation - 16
            table = int.from_bytes(entry[4:8], "big")
            assert SCRATCH <= table < SCRATCH + SCRATCH_SIZE
        else:
            raise AssertionError("Table traversal exceeded maximum code length")
        assert consumed == length, (
            case["name"],
            symbol,
            "code length",
            consumed,
            length,
        )
        actual = int.from_bytes(entry[4:6], "big")
        if case["distance"]:
            base = int.from_bytes(read(0x8008DB14 + symbol * 2, 2), "big")
            extra = int.from_bytes(read(0x8008DB50 + symbol * 2, 2), "big")
            assert (operation, actual) == (extra, base)
        elif symbol < 256:
            assert (operation, actual) == (16, symbol)
        elif symbol == 256:
            assert (operation, actual) == (15, 256)
        else:
            base = int.from_bytes(read(0x8008DA94 + (symbol - 257) * 2, 2), "big")
            extra = int.from_bytes(read(0x8008DAD4 + (symbol - 257) * 2, 2), "big")
            assert (operation, actual) == (extra, base)


def execute(code, tables, case):
    uc = Uc(UC_ARCH_MIPS, UC_MODE_MIPS32 | UC_MODE_BIG_ENDIAN)
    uc.mem_map(0, 0x400000)
    uc.mem_map(0x80000000, 0x400000)

    def write(a, b):
        uc.mem_write(a & 0x1FFFFFFF, b)
        uc.mem_write(a | 0x80000000, b)

    def read(a, n):
        return bytes(uc.mem_read(a & 0x1FFFFFFF, n))

    def mirror(uc, access, a, n, v, user):
        uc.mem_write(a ^ 0x80000000, (v & ((1 << (n * 8)) - 1)).to_bytes(n, "big"))

    uc.hook_add(UC_HOOK_MEM_WRITE, mirror)
    packed = bytes.fromhex(case["packed"])
    expected = bytes.fromhex(case["expected"])
    input_image = (
        b"".join(word(n) for n in case["lengths"])
        if case["mode"] == "builder"
        else b"RT64" + packed
    ) + bytes(32)
    write(START, code)
    write(TABLES - 16, GUARD + tables + GUARD)
    write(GLOBALS - 16, GUARD + bytes(3928) + GUARD)
    write(INPUT - 16, GUARD + input_image + GUARD)
    write(OUTPUT - 16, GUARD + b"\xcd" * OUTPUT_SIZE + GUARD)
    write(SCRATCH - 16, GUARD + b"\xa7" * SCRATCH_SIZE + GUARD)
    write(RESULTS - 16, GUARD + bytes(8) + GUARD)
    write(CODE_TABLES - 16, GUARD + bytes(32) + GUARD)
    write(STACK - 0x810, b"\xd6" * 16 + b"\xcc" * 0x810 + b"\xc9" * 32)
    saved = {
        getattr(regs, "UC_MIPS_REG_" + name): 0xA2340000 + i * 256
        for i, name in enumerate(("S0", "S1", "S2", "S3", "S4", "S5", "S6", "S7", "FP"))
    }
    for r, v in saved.items():
        uc.reg_write(r, v)
    uc.reg_write(regs.UC_MIPS_REG_SP, STACK)
    uc.reg_write(regs.UC_MIPS_REG_RA, STOP)
    mode = case["mode"]
    size = 24000 if mode == "memory" else 24000 + 65536
    entry = {
        "memory": 0x8005FAB0,
        "cartridge": 0x8005FB08,
        "bounded": 0x8005FB58,
        "builder": START,
        "codes": 0x8005E1EC,
    }[mode]
    args = [INPUT if mode == "memory" else 0x10203040, OUTPUT, SCRATCH, size]
    if mode == "bounded":
        args = [0x10203040, OUTPUT, case["limit"], SCRATCH]
        write(STACK + 16, word(size))
    if mode == "builder":
        simple = 0 if case["distance"] else min(len(case["lengths"]), 257)
        args = [
            INPUT,
            len(case["lengths"]),
            simple,
            0x8008DB14 if case["distance"] else 0x8008DA94,
        ]
        write(
            STACK + 16,
            word(0x8008DB50 if case["distance"] else 0x8008DAD4)
            + word(RESULTS)
            + word(RESULTS + 4),
        )
        write(RESULTS + 4, word(case["width"]))
        write(
            0x80192BFC,
            word(0 if case.get("allocation_failure") else (SCRATCH + 7) & ~7),
        )
    if mode == "codes":
        # Two one-bit root entries select the same deliberately constructed
        # leaf, independently of the table builder under test.
        operation, value = {
            "literal-invalid": (99, 0),
            "distance-invalid": (0, 3),
            "end": (15, 256),
        }[case["kind"]]
        literal = bytes((operation, 1, 0, 0)) + struct.pack(">H", value) + bytes(2)
        invalid_distance = bytes((99, 1)) + bytes(6)
        write(CODE_TABLES, literal * 2 + invalid_distance * 2)
        write(0x80192BD0, word(INPUT + 4))
        write(0x80192BD4, word(OUTPUT))
        write(0x80192BE4, word(1))
        write(0x80192BEC, word(10))
        write(0x80192BF0, word(OUTPUT))
        args = [CODE_TABLES, CODE_TABLES + 16, 1, 1]
    for r, v in zip(
        (
            regs.UC_MIPS_REG_A0,
            regs.UC_MIPS_REG_A1,
            regs.UC_MIPS_REG_A2,
            regs.UC_MIPS_REG_A3,
        ),
        args,
    ):
        uc.reg_write(r, v)
    bounds = [
        (TABLES, TABLES + len(tables)),
        (GLOBALS, GLOBALS + 3928),
        (INPUT, INPUT + len(input_image)),
        (OUTPUT, OUTPUT + OUTPUT_SIZE),
        (SCRATCH, SCRATCH + SCRATCH_SIZE),
        (RESULTS, RESULTS + 8),
        (CODE_TABLES, CODE_TABLES + 32),
        (STACK - 0x800, STACK + 32),
    ]
    trace = []
    stopped = [False]
    visits = {DYNAMIC: 0, 0x8005DA20: 0, 0x8005E1EC: 0}

    def memory(uc, access, a, n, v, user):
        a |= 0x80000000
        assert any(lo <= a and a + n <= hi for lo, hi in bounds), (
            case["name"],
            "memory bounds",
            hex(a),
            n,
            hex(uc.reg_read(regs.UC_MIPS_REG_PC)),
        )

    uc.hook_add(UC_HOOK_MEM_READ, memory)
    uc.hook_add(UC_HOOK_MEM_WRITE, memory)

    def boundary(uc, a, n, user):
        if a == STOP:
            stopped[0] = True
            uc.emu_stop()
            return
        if a in visits:
            visits[a] += 1
        assert START <= a < END or a == DMA, (case["name"], "code bounds", hex(a))
        if a != DMA:
            return
        source = uc.reg_read(regs.UC_MIPS_REG_A0)
        destination = uc.reg_read(regs.UC_MIPS_REG_A1)
        amount = uc.reg_read(regs.UC_MIPS_REG_A2)
        assert amount == 65536 and destination == (SCRATCH + 7) & ~7
        offset = source - 0x10203040
        assert 0 <= offset < len(packed) + 65536
        trace.append([source, destination, amount, read(GLOBALS, 64).hex()])
        write(destination, packed[offset : offset + amount].ljust(amount, b"\x00"))
        for i, r in enumerate(CALLER_SAVED):
            uc.reg_write(r, 0xD1350000 + i * 256)
        uc.reg_write(regs.UC_MIPS_REG_PC, uc.reg_read(regs.UC_MIPS_REG_RA))

    uc.hook_add(UC_HOOK_CODE, boundary)
    uc.emu_start(entry, 0, count=10000000)
    assert stopped[0], (case["name"], "instruction budget")
    assert uc.reg_read(regs.UC_MIPS_REG_SP) == STACK
    assert all(uc.reg_read(r) == v for r, v in saved.items())
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == case["error"], (
        case["name"],
        "result",
        uc.reg_read(regs.UC_MIPS_REG_V0),
    )
    assert read(OUTPUT, len(expected)) == expected, (case["name"], "output")
    assert read(OUTPUT + len(expected), OUTPUT_SIZE - len(expected)) == b"\xcd" * (
        OUTPUT_SIZE - len(expected)
    ), (case["name"], "unexpected output")
    for a, size in (
        (TABLES, len(tables)),
        (GLOBALS, 3928),
        (INPUT, len(input_image)),
        (OUTPUT, OUTPUT_SIZE),
        (SCRATCH, SCRATCH_SIZE),
        (RESULTS, 8),
        (CODE_TABLES, 32),
    ):
        assert read(a - 16, 16) == GUARD and read(a + size, 16) == GUARD, (
            case["name"],
            "guard",
            hex(a),
        )
    assert read(INPUT, len(input_image)) == input_image
    assert read(STACK - 0x810, 16) == b"\xd6" * 16
    assert read(STACK + 32, 16) == b"\xc9" * 16
    if mode == "builder":
        verify_tree(read, case)
    # Bound fixtures can return before workspace setup when the limit is zero.
    return [
        trace,
        visits,
        read(TABLES, len(tables)).hex(),
        read(GLOBALS, 3928).hex(),
        read(RESULTS, 8).hex(),
        read(CODE_TABLES, 32).hex(),
        hashlib.sha256(read(SCRATCH, SCRATCH_SIZE)).hexdigest(),
        hashlib.sha256(read(OUTPUT, OUTPUT_SIZE)).hexdigest(),
    ]


def main():
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    family = "compression-execution"
    output = ROOT / "build" / family
    specs = sorted(
        [
            s
            for s in MATCHING_BLOCKS + CANDIDATE_BLOCKS
            if s[0].startswith("compression_")
        ],
        key=lambda s: s[2],
    )
    assert len(specs) == 14 and specs[0][2] == START and specs[-1][3] == END
    assert all(a[3] == b[2] for a, b in zip(specs, specs[1:])), specs
    rebuilt = bytearray()
    comparisons = {}
    for name, source, start, end in specs:
        rom = start - 0x80000000 + 0xC00
        comparisons[name] = compare_block(
            name,
            source,
            start,
            rom,
            rom + end - start,
            target,
            family=family,
            layout=layout,
        )
        assert comparisons[name]["matches"], comparisons[name]
        rebuilt += (output / name / (name + ".bin")).read_bytes()
    assert len(rebuilt) == END - START
    original = target[START - 0x80000000 + 0xC00 : END - 0x80000000 + 0xC00]
    data_comparison = comparisons["compression_workspace"]
    sections, _ = elf_sections_and_symbols(
        output / "compression_workspace/compression_workspace.elf"
    )
    tables = sections[".compression_workspace_data"]["bytes"]
    assert len(tables) == 368
    original_tables = target[
        TABLES - 0x80000000 + 0xC00 : TABLES - 0x80000000 + 0xC00 + 368
    ]
    digest = hashlib.sha256()
    count = 0
    dynamic = 0
    counts = {}
    for case in fixtures():
        a = execute(original, original_tables, case)
        b = execute(bytes(rebuilt), tables, case)
        assert a == b, (case["name"], "retail versus candidate")
        digest.update(json.dumps([case, b], sort_keys=True).encode())
        count += 1
        dynamic += int(b[1][DYNAMIC] > 0)
        counts[case["mode"]] = counts.get(case["mode"], 0) + 1
        if count % 25 == 0:
            print("Passed", count, "fixtures;", dynamic, "dynamic entries", flush=True)
    layout.verify()
    report = dict(
        matches=True,
        cases=count,
        cases_by_mode=counts,
        dynamic_cases=dynamic,
        trace_sha256=digest.hexdigest(),
        comparisons=comparisons,
        data_comparison=data_comparison,
        source_code_bytes=len(rebuilt),
        source_initialized_bytes=368,
        source_bss_bytes=3928,
        emulator=version("unicorn"),
        zlib_version=zlib.ZLIB_VERSION,
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        execution_inputs_sha256={
            name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
            for name in (
                "tools/check_compression_runtime.py",
                "tools/check_audio_instance_allocate.py",
            )
        },
        limits=[
            "All fourteen decoder procedures execute freshly matched source.",
            "Cartridge DMA is a recorded stub that poisons caller-saved registers.",
            "Generated streams and canonical codes independently check decoded output and table entries.",
            "Memory and instruction bounds, shared-state snapshots, table allocations, output guards, stack and saved integer registers are checked.",
            "Bounded prefix oracles cover Huffman-only streams; retail match-copy output-limit quirks are preserved.",
            "Arbitrary malformed pointers, zero-length match copies and hardware DMA timing are outside scope.",
        ],
    )
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(
        "Passed",
        count,
        "fixtures;",
        dynamic,
        "dynamic entries;",
        digest.hexdigest(),
        flush=True,
    )


if __name__ == "__main__":
    main()
