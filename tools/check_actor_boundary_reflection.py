"""Check actor boundary reflection against retail and an arithmetic model."""

from pathlib import Path
import sys, json, struct, hashlib, itertools, math
from importlib.metadata import version
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs

from rom import ROOT as R

D = R / "build/actor-boundary-reflection"
sys.path.insert(0, str(R / "tools"))
from check_actor_group_path import machine, word, SENTINEL
from actor_path_model import TANGENT, tangent_bucket
from compare_startup import SymbolLayoutSnapshot, compare_block
from compare_runtime import MATCHING_BLOCKS
from compare_data import compare_unit
from owned_sections import source_sections, elf_sections_and_symbols
from rom import validate

ENTRY = 0x800186D8
ACTOR = 0x80201010
OBJECTS = 0x800BF918
TRANSFORM = 0x80203010
FP_INIT, FP_PROBE, FP_RESULT = 0x80000100, 0x80000200, 0x80204000
SUPPORT = (
    "object_recovery_angle_scale",
    "object_recovery_direction_angle",
    "object_recovery_angle_table",
    "fixed_geometry_setup",
    "actor_position_submit",
    "object_transforms",
)


def signed(value):
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def divide(numerator, denominator):
    assert denominator and (numerator, denominator) != (-0x80000000, -1)
    return (
        abs(numerator)
        // abs(denominator)
        * (-1 if (numerator < 0) != (denominator < 0) else 1)
    )


def absolute(value):
    return signed(-value) if value < 0 else value


def sign(value):
    return -1 if value < 0 else int(value > 0)


def f32(value):
    return struct.unpack(">f", struct.pack(">f", value))[0]


def float_bytes(value):
    return struct.pack(">f", value)


def heading(x, y):
    if not x:
        return (256 if y < 0 else 0) * 8
    if not y:
        return (384 if x < 0 else 128) * 8
    quadrant = (1 if x < 0 else 0) | (2 if y < 0 else 0)
    x, y = absolute(x), absolute(y)
    if x < y:
        angle = tangent_bucket(divide(signed(x * 32767), y))
    else:
        angle = 128 - tangent_bucket(divide(signed(y * 32767), x))
    return (angle, 512 - angle, 256 - angle, angle + 256)[quadrant] * 8


def oracle(case, actor, record, transform, pi):
    margin, x, y, vx, vy, diagonal, index, z = case[:8]
    mutation = case[8] if len(case) > 8 else None
    actor, record, transform = bytearray(actor), bytearray(record), bytearray(transform)
    trace = []
    changed = 0
    quadrant = None
    position_calls = 0

    def sync():
        actor[0x60:0x74] = word(x) + word(y) + word(z) + word(vx) + word(vy)

    def angle_call(first, second):
        result = heading(first, second)
        trace.append(["angle", [first & 0xFFFFFFFF, second & 0xFFFFFFFF], actor.hex()])
        return result

    def submit_angle(angle):
        trace.append(
            ["object_angle", [index & 0xFFFFFFFF, angle & 0xFFFFFFFF], actor.hex()]
        )
        transform[8:12] = float_bytes(f32(f32(f32(signed(angle - 1024)) * pi) / 2048.0))
        record[0x4C:0x50] = word((1024 - angle) & 0xFFD)

    def submit_position():
        nonlocal x, y, position_calls
        trace.append(["position", [index & 0xFFFFFFFF, ACTOR + 0x60], actor.hex()])
        if mutation and position_calls == mutation[0]:
            x, y = mutation[1:]
            sync()
        position_calls += 1
        for axis, value in enumerate((x, z, y)):
            output = f32(f32(f32(value) * 1400.0) / 60000.0)
            transform[0x10 + axis * 4 : 0x14 + axis * 4] = float_bytes(output)
            record[0x54 + axis * 4 : 0x58 + axis * 4] = word(int(f32(output * 12.0)))

    lower = margin - 30000
    if y <= lower:
        y = lower
        vy = absolute(vy)
        sync()
        if vx or absolute(vy):
            submit_angle(angle_call(absolute(vy), vx))
        submit_position()
        changed = 1
    upper = 30000 - margin
    if y >= upper:
        y = upper
        vy = signed(-absolute(vy))
        changed = 1
        sync()
        if vx or absolute(vy):
            submit_angle(angle_call(signed(-absolute(vy)), vx))
        submit_position()
    if x <= lower:
        x = lower
        vx = absolute(vx)
        changed = 1
        sync()
        if absolute(vx) or vy:
            submit_angle(angle_call(vy, absolute(vx)))
        submit_position()
    if x >= upper:
        x = upper
        vx = signed(-absolute(vx))
        changed = 1
        sync()
        if signed(-absolute(vx)) or vy:
            submit_angle(angle_call(vy, signed(-absolute(vx))))
        submit_position()
    if diagonal:
        limit = 42000 - margin
        if signed(absolute(x) + absolute(y)) > limit:
            limit -= margin
            ratio = absolute(divide(signed(y << 12), x))
            changed = 1
            x = signed(sign(x) * divide(signed(limit << 12), signed(ratio + 4096)))
            y = signed(sign(y) * signed(limit - absolute(x)))
            sync()
            submit_position()
            angle = angle_call(divide(y, 2), divide(x, 2)) & 4095
            if angle < 1024:
                vx, vy = signed(-vy), signed(-vx)
                quadrant = 0
            elif angle < 2048:
                vx, vy = signed(-vy), vx
                quadrant = 1
            elif angle < 3096:
                vx, vy = signed(-vy), signed(-vx)
                quadrant = 2
            else:
                vx, vy = vy, signed(-vx)
                quadrant = 3
            sync()
            if vx or vy:
                submit_angle(angle_call(vy, vx))
    if changed:
        actor[8:10] = struct.pack(">H", angle_call(vy, vx) & 65535)
    return dict(
        actor=actor.hex(),
        record=record.hex(),
        transform=transform.hex(),
        trace=trace,
        result=changed,
        quadrant=quadrant,
    )


def run(code, support, code_ranges, data_ranges, case, pi):
    margin, x, y, vx, vy, diagonal, index, z = case[:8]
    mutation = case[8] if len(case) > 8 else None
    initial_actor = bytearray((i * 37 + 19) & 255 for i in range(124))
    initial_actor[6:8] = struct.pack(">h", margin)
    initial_actor[12:14] = struct.pack(">h", index)
    initial_actor[0x60:0x74] = word(x) + word(y) + word(z) + word(vx) + word(vy)
    initial_record = bytearray((i * 29 + 37) & 255 for i in range(120))
    initial_record[0x18:0x1C] = word(TRANSFORM)
    initial_transform = bytearray((i * 17 + 13) & 255 for i in range(28))
    expected = oracle(case, initial_actor, initial_record, initial_transform, pi)
    saved_fpu = [0x3F800101 + (i - 20) * 257 for i in range(20, 32)]
    init = (
        b"".join(
            word(0x3C013F80)
            + word(0x34210000 | (value & 65535))
            + word(0x44810000 | (i << 11))
            for i, value in zip(range(20, 32), saved_fpu)
        )
        + word(0x03E00008)
        + word(0)
    )
    assert FP_INIT + len(init) <= FP_PROBE
    probe = (
        word(0x3C018020)
        + word(0x34214000)
        + b"".join(word(0xE4200000 | (i << 16) | ((i - 20) * 4)) for i in range(20, 32))
        + word(0x03E00008)
        + word(0)
    )
    uc, write, execute = machine(
        [(ENTRY, code), (FP_INIT, init), (FP_PROBE, probe)], support
    )
    uc.reg_write(
        regs.UC_MIPS_REG_CP0_STATUS,
        uc.reg_read(regs.UC_MIPS_REG_CP0_STATUS) | (1 << 29),
    )
    uc.emu_start(FP_INIT, 0, count=50)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL

    def read(address, size):
        return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

    record_address = OBJECTS + index * 120
    state = [
        (ACTOR, ACTOR + 124),
        (record_address, record_address + 120),
        (TRANSFORM, TRANSFORM + 28),
    ]
    stack = (0x802FFC00, 0x80300010)
    canaries = []
    for start, end in state + [stack]:
        for address, data in [(start - 16, b"\xd7" * 16), (end, b"\xe9" * 16)]:
            write(address, data)
            canaries.append((address, data))
    write(ACTOR, bytes(initial_actor))
    write(record_address, bytes(initial_record))
    write(TRANSFORM, bytes(initial_transform))
    global_bytes = b"\xc9" * 16 + word(diagonal) + b"\xdb" * 16
    write(0x800BA774, global_bytes)
    write(FP_RESULT, b"\xa7" * 48)
    trace = []
    position_calls = 0
    entries = {0x8003CD4C: "angle", 0x80039514: "object_angle", 0x800290B0: "position"}

    def record_call(uc, address, size, user):
        nonlocal position_calls
        args = [uc.reg_read(reg) for reg in (regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1)]
        event = [entries[address], args, read(ACTOR, 124).hex()]
        assert (
            len(trace) < len(expected["trace"])
            and event == expected["trace"][len(trace)]
        ), ("Reflection call oracle", case, event, expected["trace"])
        trace.append(event)
        if address == 0x800290B0:
            if mutation and position_calls == mutation[0]:
                write(ACTOR + 0x60, word(mutation[1]) + word(mutation[2]))
            position_calls += 1

    for address in entries:
        uc.hook_add(UC_HOOK_CODE, record_call, begin=address, end=address)

    def inside(address, size, ranges):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(start <= address and address + size <= end for start, end in ranges)

    def instruction(uc, address, size, user):
        assert not address & 3 and inside(
            address,
            4,
            code_ranges + [(ENTRY, ENTRY + len(code)), (SENTINEL, SENTINEL + 4)],
        ), ("Reflection instruction bounds", case, hex(address))

    def load(uc, access, address, size, value, user):
        assert inside(
            address, size, state + [stack, (0x800BA784, 0x800BA788)] + data_ranges
        ), ("Reflection read bounds", case, hex(address), size)

    writable = [
        (ACTOR + 8, ACTOR + 10),
        (ACTOR + 0x60, ACTOR + 0x68),
        (ACTOR + 0x6C, ACTOR + 0x74),
        (record_address + 0x4C, record_address + 0x50),
        (record_address + 0x54, record_address + 0x60),
        (TRANSFORM + 8, TRANSFORM + 12),
        (TRANSFORM + 0x10, TRANSFORM + 0x1C),
        stack,
    ]

    def store(uc, access, address, size, value, user):
        assert inside(address, size, writable), (
            "Reflection write bounds",
            case,
            hex(address),
            size,
        )

    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA578ABCD)
    uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
    uc.reg_write(regs.UC_MIPS_REG_A0, ACTOR)
    handles = [
        uc.hook_add(UC_HOOK_CODE, instruction),
        uc.hook_add(UC_HOOK_MEM_READ, load),
        uc.hook_add(UC_HOOK_MEM_WRITE, store),
    ]
    try:
        execute(ENTRY)
    finally:
        for handle in handles:
            uc.hook_del(handle)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA578ABCD
    assert uc.reg_read(regs.UC_MIPS_REG_V0) == expected["result"]
    assert read(ACTOR, 124).hex() == expected["actor"], (
        "Reflection actor oracle",
        case,
    )
    assert read(record_address, 120).hex() == expected["record"], (
        "Reflection record oracle",
        case,
        read(record_address, 120).hex(),
        expected["record"],
    )
    assert read(TRANSFORM, 28).hex() == expected["transform"], (
        "Reflection transform oracle",
        case,
        read(TRANSFORM, 28).hex(),
        expected["transform"],
    )
    assert trace == expected["trace"]
    assert read(0x800BA774, len(global_bytes)) == global_bytes
    for address, data in canaries:
        assert read(address, len(data)) == data, (
            "Reflection canary",
            case,
            hex(address),
        )
    uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
    uc.emu_start(FP_PROBE, 0, count=50)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert read(FP_RESULT, 48) == b"".join(word(value) for value in saved_fpu), (
        "Reflection saved FPU registers",
        case,
    )
    return expected


def main():
    D.mkdir(parents=True, exist_ok=True)
    target = (R / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    support = []
    code_ranges = []
    data_ranges = []
    comparisons = {}
    tables = {}
    for name in SUPPORT:
        _, source, start, end = next(row for row in MATCHING_BLOCKS if row[0] == name)
        report = compare_block(
            name,
            source,
            start,
            start - 0x80000000 + 0xC00,
            end - 0x80000000 + 0xC00,
            target,
            family="boundary-reflection-near-execution",
            layout=layout,
        )
        assert report["matches"], name
        comparisons[name] = report
        directory = R / "build/boundary-reflection-near-execution" / name
        support.append((start, (directory / (name + ".bin")).read_bytes()))
        code_ranges.append((start, end))
        sections, _ = elf_sections_and_symbols(directory / (name + ".elf"))
        for owned in source_sections(source):
            if owned["rom"] is not None:
                data = sections[owned["section"]]["bytes"]
                support.append((owned["vram"], data))
                data_ranges.append((owned["vram"], owned["vram"] + len(data)))
                tables[owned["section"]] = hashlib.sha256(data).hexdigest()
    source = "src/game/actor_groups/direction_table.c"
    table = compare_unit(source, source_sections(source), target, layout)
    assert table["matches"]
    sections, _ = elf_sections_and_symbols(
        R / "build/data-comparison" / Path(source).with_suffix("") / "compiled.elf"
    )
    data = sections[".actor_direction_table"]["bytes"]
    assert data == struct.pack(">65i", *TANGENT)
    support.append((0x8007C338, data))
    data_ranges.append((0x8007C338, 0x8007C338 + len(data)))
    constant_source = "src/game/object_angle_setter_constants.c"
    constants = compare_unit(
        constant_source, source_sections(constant_source), target, layout
    )
    assert constants["matches"]
    constant_sections, _ = elf_sections_and_symbols(
        R
        / "build/data-comparison"
        / Path(constant_source).with_suffix("")
        / "compiled.elf"
    )
    constant_data = constant_sections[".object_angle_setter_constants"]["bytes"]
    support.append((0x80094C20, constant_data))
    data_ranges.append((0x80094C20, 0x80094C20 + len(constant_data)))
    pi = struct.unpack(">f", constant_data[:4])[0]
    assert pi == f32(3.141592)
    candidate_path = R / (
        sys.argv[1]
        if len(sys.argv) > 1 and not sys.argv[1].startswith("--")
        else "src/game/actor_contacts/reflection.c"
    )
    assert candidate_path.resolve().is_relative_to(R.resolve())
    candidate = compare_block(
        "reflection",
        str(candidate_path.relative_to(R)),
        ENTRY,
        0x192D8,
        0x198C8,
        target,
        family="boundary-reflection-near-execution",
        layout=layout,
    )
    if candidate_path == R / "src/game/actor_contacts/reflection.c":
        assert candidate["matches"], candidate["different_words"]
    candidate_bytes = (
        R / "build/boundary-reflection-near-execution/reflection/reflection.bin"
    ).read_bytes()
    assert candidate["actual_size"] == 1520
    from elftools.elf.elffile import ELFFile

    with (
        R / "build/boundary-reflection-near-execution/reflection/reflection.raw.o"
    ).open("rb") as stream:
        e = ELFFile(stream)
        assert (
            e.get_section_by_name(".symtab").get_symbol_by_name("func_800186D8")[0][
                "st_size"
            ]
            == 1520
        )
        raw_text = e.get_section_by_name(".text").data()
        assert (
            len(raw_text) == 1520
            and -int.from_bytes(raw_text[2:4], "big", signed=True) == 88
        )
        assert not any(
            s["sh_size"]
            for s in e.iter_sections()
            if s.name in (".data", ".rodata", ".rdata", ".bss", ".sdata", ".sbss")
        )
    cases = []
    velocities = [
        (0, 0),
        (1, -1),
        (-17, 29),
        (0, -65000),
        (-65000, 0),
        (0x7FFFFFFF, -0x80000000),
        (-0x80000000, -0x80000000),
        (-30001, 30001),
    ]
    coordinates = (-0x80000000, -65000, -30000, -1, 0, 1, 30000, 65000, 0x7FFFFFFF)
    for i, (margin, x, y, diagonal) in enumerate(
        itertools.product(
            (-32768, -1, 0, 1, 29999, 30000, 32767), coordinates, coordinates, (0, 1)
        )
    ):
        cases.append(
            (
                margin,
                x,
                y,
                *velocities[i % len(velocities)],
                diagonal,
                (-2, 0, 17)[i % 3],
                (-65000, 0, 65000)[i % 3],
            )
        )
    for vx, vy, (x, y) in itertools.product(
        coordinates,
        coordinates,
        [
            (-30000, -30000),
            (30000, -30000),
            (-30000, 30000),
            (30000, 30000),
            (0, 0),
            (1, -1),
            (-1, 1),
            (29999, 30000),
        ],
    ):
        cases.append((0, x, y, vx, vy, 1, 17, 65000))
    for x, y in [
        (x, y)
        for x in (-1500, -1200, -1000, -1, 0, 1, 1000, 1200, 1500)
        for y in (-30000, 30000)
    ] + [
        (x, y)
        for x in (-30000, 30000)
        for y in (-1500, -1200, -1000, -1, 0, 1, 1000, 1200, 1500)
    ]:
        cases.append((0, 25000, 25000, -17, 29, 1, 17, 65000, (0, x, y)))
    controls_only = "--controls-only" in sys.argv
    if controls_only:
        cases = [(0, -30000, 30000, 17, -29, 1, 17, 65000)]
    digest = hashlib.sha256()
    counts = {
        "cases": 0,
        "callback_mutations": 0,
        "diagonal_quadrants": {str(i): 0 for i in range(4)},
    }
    for case in cases:
        expected = run(
            target[0x192D8:0x198C8], support, code_ranges, data_ranges, case, pi
        )
        actual = run(candidate_bytes, support, code_ranges, data_ranges, case, pi)
        assert actual == expected, case
        digest.update(json.dumps([case, actual], sort_keys=True).encode())
        counts["cases"] += 1
        counts["callback_mutations"] += int(len(case) > 8)
        if actual["quadrant"] is not None:
            counts["diagonal_quadrants"][str(actual["quadrant"])] += 1
        if counts["cases"] % 500 == 0:
            print("Reflection real-helper pairs:", counts, flush=True)
    layout.verify()
    receipt = dict(
        behavior_matches=True,
        instruction_matches=candidate["matches"],
        source_ownership_added=0,
        counts=counts,
        candidate_comparison=candidate,
        support_comparisons=comparisons,
        table_comparison=table,
        constant_comparison=constants,
        candidate_code_sha256=hashlib.sha256(candidate_bytes).hexdigest(),
        retail_code_sha256=hashlib.sha256(target[0x192D8:0x198C8]).hexdigest(),
        target_rom_sha256=hashlib.sha256(target).hexdigest(),
        candidate_source_sha256=hashlib.sha256(candidate_path.read_bytes()).hexdigest(),
        trace_sha256=digest.hexdigest(),
        table_sha256=tables,
        checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        emulator_version=version("unicorn"),
        saved_fpu_initial_bits=[hex(0x3F800101 + i * 257) for i in range(12)],
        limits=[
            "The default source must match the complete retail instructions; alternate source paths remain research comparisons.",
            "Six complete matching support units and their initialized data are freshly compiled; only the reached arithmetic, position and angle helpers execute.",
            "Actor, object record, transform, callback arguments and snapshots are checked against a separate wrapped-integer and rounded-float model.",
            "Every guest instruction and memory access is bounded; canaries, GP, SP, integer saved registers and F20 through F31 are checked.",
            "Negative object indices use a specifically mapped synthetic record, not a claim that invalid gameplay indices are valid.",
            "Listed callback-mutation cases inject a checked host-side position change at a position-submit boundary, then run the real helper; they model possible callback effects rather than asserting the helper normally changes the actor.",
            "Division exception delivery and arbitrary gameplay callers remain unverified.",
        ],
    )
    output = (
        "report.json"
        if candidate_path.name == "reflection.c"
        else "report-" + candidate_path.stem + ".json"
    )
    if controls_only:
        output = output.removesuffix(".json") + "-controls-only.json"
    (D / output).write_text(json.dumps(receipt, indent=2) + "\n")
    controls = []
    for name, word_, message in [
        ("instruction", 0x08000010, "Reflection instruction bounds"),
        ("read", 0x8C82FFEC, "Reflection read bounds"),
        ("write", 0xAC82FFEC, "Reflection write bounds"),
    ]:
        positive = run(
            candidate_bytes,
            support,
            code_ranges,
            data_ranges,
            (0, -30000, 30000, 17, -29, 1, 17, 65000),
            pi,
        )
        control = word(word_) + (
            word(0) + candidate_bytes[8:]
            if name == "instruction"
            else candidate_bytes[4:]
        )
        try:
            run(
                control,
                support,
                code_ranges,
                data_ranges,
                (0, -30000, 30000, 17, -29, 1, 17, 65000),
                pi,
            )
        except AssertionError as error:
            assert error.args and error.args[0][0] == message, (name, error)
            controls.append(
                dict(
                    name=name,
                    rejected=True,
                    positive_result=positive["result"],
                    reason=str(error),
                )
            )
        else:
            raise AssertionError(("Guard failed to reject control", name))
    (D / (output.removesuffix(".json") + "-guard-controls.json")).write_text(
        json.dumps(dict(controls=controls, source_ownership_added=0), indent=2) + "\n"
    )
    print(
        "Reflection research execution result:",
        counts,
        "instruction match:",
        candidate["matches"],
        flush=True,
    )


if __name__ == "__main__":
    main()
