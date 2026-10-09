"""Audit the complete excluded game initializer and its source-owned data.

Resource loading, copying and level lookup execute freshly matching C.
Other startup services use recorded O32 boundary stubs. Stack differences
remain nonmatching and grant no instruction ownership.
"""

import argparse
import hashlib
import itertools
import json
from pathlib import Path
import random
import subprocess
from importlib.metadata import version

from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE, UcError
from unicorn import mips_const as regs
from check_actor_boundary_boss import environment, CLOBBER, divide, signed
from check_actor_group_path import SENTINEL, word
from check_movie_storage import pattern
from compare_data import compare_unit, comparison_directory
from compare_runtime import MATCHING_BLOCKS
from compare_startup import (
    SymbolLayoutSnapshot, compare_block, comparison_input_hashes,
    external_assignments,
)
from compiler import compile_source, profile_for_source
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate
from toolchain import installed_identity
from trim_padding import trim

SOURCE = "src/game/session_initialization/initialize.c"
BUILD = ROOT / "build/game-initialization-audit"
ENTRY, END = 0x8002205C, 0x80022528
LITERALS, TABLE = 0x8009224C, 0x800BA7A8
STACK, FILE_DATA, SCRIPT = 0x80300000, 0x80210010, 0x80220010
SESSION, SCENE, LABELS = 0x800AD138, 0x800B9A78, 0x800770A8
DEFAULTS, ACTORS, ANIMATIONS = 0x800AC998, 0x8009AA00, 0x800AF1F0
FLAGS, PAK_STATUS = 0x8007C334, 0x80075FC4
SUPPORT = ("game_memory", "platform_io", "platform_empty", "save_level_lookup")
DATA_SOURCES = (
    "src/game/session_initialization/literals.c",
    "src/game/session_initialization/levels.c",
    "src/game/save_menus/control_setup/labels.c",
    "src/game/save_menus/control_setup/text.c",
    "src/game/save_menus/control_setup/text_details.c",
)
STRINGS = {
    0x80092250: b"SHELL\\BFFSCR.BFF",
    0x80092264: b"LEVELNOS.DAT",
    0x80092274: b"SHELL\\BFFSHELL.LST",
    0x80092288: b"robo64",
    0x80092290: b"rb",
    0x80092294: b"PALETTES\\GAMEPAL.BMP",
}
BOUNDARIES = (
    0x800256C0, 0x80002EE0, 0x8002818C, 0x80031564,
    0x8001DE60, 0x80019E40, 0x80025D5C, 0x800360B0,
    0x800387C8, 0x800361FC, 0x8003CC30, 0x8001288C,
    0x8001F2CC, 0x8001B870, 0x8004EF6C, 0x8004DD6C,
    0x8004EE9C, 0x8004DC70, 0x80032540, 0x8001CD60,
    0x8001CD1C, 0x8002FD44, 0x800301A4, 0x80037A20,
    0x8001A1F0, 0x8004FC98, 0x8004C3AC, 0x8004F990,
    0x8004F9D4, 0x8001DE54, 0x8001CE68, 0x8001D3F0,
    0x800314FC, 0x80031C10,
)


def compare_candidate_block(name, source, target, layout):
    """Compare the natural complete function and all emitted literal bytes."""
    directory = ROOT / "build/runtime-candidates" / name
    directory.mkdir(parents=True, exist_ok=True)
    inputs = comparison_input_hashes(source)
    raw, obj, elf = (directory / leaf for leaf in ("raw.o", "compiled.o", "compiled.elf"))
    layout.verify()
    compile_source(source, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    function = symbols.get("func_8002205C")
    if (function is None or function["type"] != 2 or
            function["section"] != ".text" or function["value"] != 0):
        raise ValueError("Initializer candidate must define its complete procedure")
    if any(name != "func_8002205C" and symbol["type"] == 2 and symbol.get("index") != 0
           for name, symbol in symbols.items()):
        raise ValueError("Initializer candidate defines an additional procedure")
    for section, info in sections.items():
        if info["size"] and info["flags"] & 2 and section not in (
                ".text", ".rodata", ".reginfo", ".MIPS.abiflags"):
            raise ValueError("Unowned initializer allocation: " + section)
    contents = trim(raw.read_bytes(), ".text", function["size"])
    if ".rodata" in sections:
        try:
            contents = trim(contents, ".rodata", 96)
        except ValueError:
            pass
    obj.write_bytes(contents)
    undefined = {
        line.split()[-1] for line in subprocess.check_output(
            ["mips-linux-gnu-nm", "-u", str(obj)], text=True).splitlines()
        if line.strip()
    }
    script = directory / "candidate.ld"
    script.write_text(
        external_assignments(undefined, layout.addresses) +
        "SECTIONS { .text 0x8002205C : SUBALIGN(4) { *(.text) } "
        ".rodata 0x8009224C : SUBALIGN(4) { *(.rodata) } "
        "/DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n")
    subprocess.run(["mips-linux-gnu-ld", "-EB", "-T", str(script),
                    "-e", "func_8002205C", "-o", str(elf), str(obj)], check=True)
    sections, _ = elf_sections_and_symbols(elf)
    actual = sections[".text"]["bytes"]
    literals = sections.get(".rodata", {}).get("bytes", b"")
    expected, expected_literals = target[0x22C5C:0x23128], target[0x92E4C:0x92EAC]
    (directory / (name + ".bin")).write_bytes(actual)
    (directory / "literals.bin").write_bytes(literals)
    layout.verify()
    if comparison_input_hashes(source) != inputs:
        raise ValueError("Initializer comparison inputs changed")
    profile = profile_for_source(source)
    return {
        "source": source, "compiler_profile": profile,
        "toolchain_identity": installed_identity(profile["version"]),
        "inputs_sha256": inputs, "expected_size": len(expected),
        "actual_size": len(actual), "natural_function_size": function["size"],
        "matches": actual == expected and literals == expected_literals,
        "different_words": [
            {"vram": hex(ENTRY + i), "expected": expected[i:i + 4].hex(),
             "actual": actual[i:i + 4].hex()}
            for i in range(0, max(len(actual), len(expected)), 4)
            if expected[i:i + 4] != actual[i:i + 4]
        ],
        "literals": {
            "expected_size": len(expected_literals), "actual_size": len(literals),
            "matches": literals == expected_literals,
            "sha256": hashlib.sha256(literals).hexdigest(),
        },
        "matching_source_claim": False,
    }


def fixtures(case, target):
    panels = {}

    def add(address, data):
        panels[address] = bytearray(data)

    add(ACTORS, pattern(11 * 92, 37))
    add(DEFAULTS, pattern(11 * 92, 91))
    add(ANIMATIONS, pattern(36 * 104, 117))
    add(0x8009EA18, pattern(88, 173))
    add(0x800AD118, pattern(32, 19) + pattern(416, 177))
    add(SCENE, pattern(3348, 131))
    for address in (FLAGS, PAK_STATUS, 0x8007CCA0, 0x800AC970, 0x800BAE90, 0x800736A8):
        add(address, pattern(4, 43))
    add(0x800AE4F4, pattern(8, 83))
    add(TABLE, pattern(880, 179))
    payload = b"".join(
        word((0x80230010 + i * 32) ^ (case["seed"] << 4)) for i in range(220))
    add(FILE_DATA, payload + bytes(pattern(case["file_size"] - 880, 73)))
    add(SCRIPT, b"fixture.scr\0")
    for address, size in ((LITERALS, 96), (LABELS, 320), (0x80093398, 184)):
        offset = address - 0x80000000 + 0xC00
        add(address, target[offset:offset + size])

    def put(address, data):
        for base, blob in panels.items():
            if base <= address and address + len(data) <= base + len(blob):
                blob[address - base:address - base + len(data)] = data
                return
        raise AssertionError(("Fixture escaped object", hex(address), len(data)))

    put(FLAGS, word(case["flags"]))
    put(PAK_STATUS, word(case["initial_status"]))
    put(SESSION + 0x1C, word(case["saved_flags"]))
    put(DEFAULTS + 2 * 92 + 8, word(case["speed"]))
    put(DEFAULTS + 2 * 92 + 0x18, (case["short_speed"] & 0xFFFF).to_bytes(2, "big"))
    put(DEFAULTS + 4 * 92 + 0x58, word(case["lives"]))
    put(ANIMATIONS + 5 * 104 + 0x26, (case["blood"] & 0xFFFF).to_bytes(2, "big"))
    put(0x8009EA18 + 0x54, (case["other_short"] & 0xFFFF).to_bytes(2, "big"))
    for i, value in enumerate(case["scene_values"]):
        put(0x800AD12C + i * 4, word(value))
    return panels, payload


def oracle(case, panels, payload):
    expected = {address: bytearray(blob) for address, blob in panels.items()}

    def put(address, data):
        for base, blob in expected.items():
            if base <= address and address + len(data) <= base + len(blob):
                blob[address - base:address - base + len(data)] = data
                return
        raise AssertionError(("Oracle escaped object", hex(address)))

    for i in range(11):
        put(ACTORS + i * 92 + 0x58, word(1))
    for address in (0x8007CCA0, 0x800AD128, 0x800AE4F8,
                    0x800AC970, SESSION + 0x30, 0x800AD120, 0x800AE4F4):
        put(address, word(0))
    put(TABLE, payload)
    put(DEFAULTS + 2 * 92 + 8, word(divide(case["speed"], 5)))
    put(DEFAULTS + 2 * 92 + 0x18,
        (divide(case["short_speed"], 5) & 0xFFFF).to_bytes(2, "big"))
    for offset, value in zip((0xCDC, 0xCE0, 0xCE4), reversed(case["scene_values"])):
        put(SCENE + offset, word(value))
    put(0x800BAE90, word(1))
    status = case["initial_status"]
    if case["pak_status"] in (0, -2, -1):
        status = {0: 4, -2: 6, -1: 5}[case["pak_status"]]
    elif case["pak_status"] == 1:
        if (case["directory_count"] & 0xFFFFFFFF) < 16 and case["handle"] == 0:
            status = 2
        if case["free_pages"] == 16 and case["handle"] == 0:
            status = 2
        if case["saved_flags"] & 0x100:
            status = 1
    if case["flags"] & 1 and status == 0:
        status = 3
    put(PAK_STATUS, word(status))
    for offset, value in ((0x24, 0xFFFF), (0x148, 5), (0x154, 0), (0xA0, 5), (0x9C, 4)):
        put(SESSION + offset, word(value))
    put(DEFAULTS + 4 * 92 + 0x58, word(divide(case["lives"], 3)))
    for i in (0, 1, 6, 10):
        put(ACTORS + i * 92 + 0x26, (case["blood"] & 0xFFFF).to_bytes(2, "big"))
    put(0x800736A8, word(case["other_short"]))
    if not case["flags"] & 2:
        put(LABELS + 6 * 40 + 24, word(LABELS + 4 * 40))
    if not case["flags"] & 4:
        if not case["flags"] & 2:
            put(LABELS + 3 * 40 + 24, word(LABELS + 40))
        put(0x800933E8 + 15, b"1")
        put(0x800933D0 + 15, b"2")
    elif not case["flags"] & 8:
        put(LABELS + 3 * 40 + 24, word(LABELS + 40))
    return expected


def expected_trace(case):
    trace = [[address, []] for address in (
        0x800256C0, 0x80002EE0, 0x8002818C, 0x80031564)]
    trace += [[0x8001DE60, [0]]]
    trace += [[address, []] for address in (
        0x80019E40, 0x80025D5C, 0x800360B0, 0x800387C8,
        0x800361FC, 0x8003CC30)]
    trace += [
        [0x8001288C, [1]], [0x8003C5CC, [1]],
        [0x8001F2CC, [0x80092250, 0]], [0x8001B870, []],
        [0x8004EF6C, [0x80092264]],
        [0x8004DD6C, [case["file_size"]]],
        [0x8004EE9C, [0x80092264, FILE_DATA]],
        [0x8003B520, [TABLE, FILE_DATA, 880]],
        [0x8004DC70, [FILE_DATA]],
        [0x80032540, []], [0x8001CD60, []],
        [0x8001CD1C, [SCRIPT]], [0x8002FD44, [0]],
        [0x800301A4, [0, 1]], [0x80037A20, []],
        [0x8001F2CC, [0x80092274, 1]], [0x8003C5D4, []],
        [0x8001A1F0, [SESSION]], [0x8004FC98, [0]],
    ]
    if case["pak_status"] == 1:
        trace += [[0x8004C3AC, [0x80092288, 0x80092290]],
                  [0x8004F990, []], [0x8004F9D4, []]]
    trace += [[0x8001DE54, []], [0x8001CE68, []],
              [0x8001D3F0, [1]], [0x8003BF6C, []],
              [0x800314FC, [0x80092294]], [0x80031C10, []]]
    return trace


def run(image, literal_image, support, data_image, target, case, lookup_indices=()):
    panels, payload = fixtures(case, target)
    expected = oracle(case, panels, payload)
    uc, write, execute, read, finish_call = environment([(ENTRY, image)], support)
    guards = {}
    for address, blob in panels.items():
        before = b"\xA5" * 8 + bytes(blob) + b"\xB6" * 8
        guards[address - 8] = before
        write(address - 8, before)
    for address, blob in data_image + [(LITERALS, literal_image)]:
        write(address, blob)
    frame = -int.from_bytes(image[2:4], "big", signed=True)
    mode_offset = int.from_bytes(image[0x1E:0x20], "big")
    low = STACK - frame - 64
    write(low - 16, b"\xC7" * (frame + 128))
    uc.reg_write(regs.UC_MIPS_REG_A0, SCRIPT)
    uc.reg_write(regs.UC_MIPS_REG_GP, 0xA57281D9)
    trace = []
    want_trace = expected_trace(case)
    argument_counts = {address: len(arguments) for address, arguments in want_trace}
    code_ranges = [(ENTRY, ENTRY + len(image)), (CLOBBER, CLOBBER + 92)]
    code_ranges += [(address, address + len(blob)) for address, blob in support]
    readable = [(address, address + len(blob)) for address, blob in panels.items()]
    readable.append((low, STACK + 4))
    writable = [(TABLE, TABLE + 880), (low, STACK + 4)]
    writable += [(ACTORS + i * 92 + 0x58, ACTORS + i * 92 + 0x5C) for i in range(11)]
    writable += [(ACTORS + i * 92 + 0x26, ACTORS + i * 92 + 0x28) for i in (0, 1, 6, 10)]
    writable += [(DEFAULTS + 192, DEFAULTS + 196), (DEFAULTS + 208, DEFAULTS + 210),
                 (DEFAULTS + 456, DEFAULTS + 460)]
    writable += [(SESSION + offset, SESSION + offset + 4)
                 for offset in (0x24, 0x30, 0x148, 0x154, 0x9C, 0xA0)]
    writable += [(SCENE + offset, SCENE + offset + 4) for offset in (0xCDC, 0xCE0, 0xCE4)]
    writable += [(address, address + 4) for address in (
        0x8007CCA0, 0x800AD128, 0x800AE4F8, 0x800AC970, 0x800AD120,
        0x800AE4F4, 0x800BAE90, PAK_STATUS, 0x800736A8,
        LABELS + 6 * 40 + 24, LABELS + 3 * 40 + 24)]
    writable += [(address, address + 1) for address in (0x800933E8 + 15, 0x800933D0 + 15)]
    scalar_reads = {
        DEFAULTS + 192: 4, DEFAULTS + 208: 2, DEFAULTS + 456: 4,
        ANIMATIONS + 5 * 104 + 0x26: 2, 0x8009EA18 + 0x54: 2,
        FLAGS: 4, PAK_STATUS: 4, SESSION + 0x1C: 4,
        0x800AD12C: 4, 0x800AD130: 4, 0x800AD134: 4,
        LABELS + 3 * 40 + 8: 4, LABELS + 2 * 40 + 8: 4,
    }
    counts = {}
    phase = {"lookup": None}

    def norm(address):
        return address & 0x1FFFFFFF | 0x80000000

    def inside(address, size, ranges):
        return any(first <= address and address + size <= last for first, last in ranges)

    def guard_read(uc, access, address, size, value, user):
        address = norm(address)
        assert inside(address, size, readable), ("Read escaped object", hex(address), size)
        if address in scalar_reads:
            assert size == scalar_reads[address], ("Scalar width", hex(address), size)
            counts[address] = counts.get(address, 0) + 1
        if phase["lookup"] is not None and TABLE <= address < TABLE + 880:
            assert address == TABLE + 4 * phase["lookup"] and size == 4
            phase["lookup_read"] += 1

    def guard_write(uc, access, address, size, value, user):
        address = norm(address)
        assert inside(address, size, writable), ("Write escaped field", hex(address), size)

    def instruction(uc, address, size, user):
        address = norm(address)
        assert address in BOUNDARIES + (SENTINEL,) or inside(
            address, size, code_ranges), ("Execution escaped range", hex(address))
        if phase["lookup"] is not None:
            return
        if address in argument_counts:
            arguments = [
                uc.reg_read(register) for register in (
                    regs.UC_MIPS_REG_A0, regs.UC_MIPS_REG_A1, regs.UC_MIPS_REG_A2
                )[:argument_counts[address]]
            ]
            trace.append([address, arguments])
            assert len(trace) <= len(want_trace) and trace[-1] == want_trace[len(trace) - 1], (
                "Call order or arguments", trace[-1], want_trace[len(trace) - 1])
        if address not in BOUNDARIES:
            return
        if address in (0x8001F2CC, 0x8004EF6C, 0x8004EE9C, 0x8004C3AC, 0x800314FC):
            pointer = uc.reg_read(regs.UC_MIPS_REG_A0)
            text = STRINGS[pointer]
            assert read(pointer, len(text) + 1) == text + b"\0", ("Startup string", hex(pointer))
            if address == 0x8004C3AC:
                assert read(0x80092290, 3) == b"rb\0"
        result = {
            0x8004EF6C: case["file_size"], 0x8004DD6C: FILE_DATA,
            0x8004FC98: case["pak_status"], 0x8004C3AC: case["handle"],
            0x8004F990: case["directory_count"], 0x8004F9D4: case["free_pages"],
        }.get(address)
        finish_call(None if result is None else result & 0xFFFFFFFF)

    uc.hook_add(UC_HOOK_MEM_READ, guard_read)
    uc.hook_add(UC_HOOK_MEM_WRITE, guard_write)
    uc.hook_add(UC_HOOK_CODE, instruction)
    execute(ENTRY)
    assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
    assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA57281D9
    assert trace == want_trace, ("Complete call trace", trace, want_trace)
    assert read(STACK, 4) == word(SCRIPT), "O32 input argument spill"
    assert read(STACK - frame + mode_offset, 3) == b"AM\0", "Three-byte local initialization"
    assert read(low - 16, 16) == b"\xC7" * 16
    assert read(STACK + 4, 44) == b"\xC7" * 44
    for address, blob in expected.items():
        assert read(address, len(blob)) == bytes(blob), ("Complete object effect", hex(address), case)
        guard = guards[address - 8]
        assert read(address - 8, 8) == guard[:8]
        assert read(address + len(blob), 8) == guard[-8:]
    for address in (DEFAULTS + 192, DEFAULTS + 208, DEFAULTS + 456,
                    ANIMATIONS + 5 * 104 + 0x26, 0x8009EA18 + 0x54):
        assert counts.get(address, 0) == 1, ("Required scalar read", hex(address), counts)
    lookup_values = []
    for index in lookup_indices:
        phase["lookup"], phase["lookup_read"] = index, 0
        uc.reg_write(regs.UC_MIPS_REG_A0, index)
        uc.reg_write(regs.UC_MIPS_REG_RA, SENTINEL)
        execute(0x80021B20)
        assert uc.reg_read(regs.UC_MIPS_REG_PC) == SENTINEL
        assert uc.reg_read(regs.UC_MIPS_REG_GP) == 0xA57281D9
        value = uc.reg_read(regs.UC_MIPS_REG_V0)
        assert value == int.from_bytes(payload[index * 4:index * 4 + 4], "big")
        assert phase["lookup_read"] == 1
        lookup_values.append(value)
    digest = hashlib.sha256()
    for address, blob in sorted(expected.items()):
        digest.update(word(address) + bytes(blob))
    return {"trace": trace, "memory_sha256": digest.hexdigest(), "lookup_values": lookup_values}


def cases():
    base = {
        "flags": 0, "pak_status": 0, "initial_status": 0, "handle": 0,
        "directory_count": 0, "free_pages": 0, "saved_flags": 0,
        "speed": 123456789, "short_speed": -12345, "lives": -987654321,
        "blood": -1234, "other_short": -32768,
        "scene_values": [0x12345678, -1, -0x80000000], "file_size": 880, "seed": 17,
    }
    result = [
        dict(base, flags=flags, pak_status=status, initial_status=initial)
        for flags, status, initial in itertools.product(
            range(16), (0, -2, -1, 1, 2, -3), (0, 7))
    ]
    result += [
        dict(base, pak_status=1, directory_count=count, free_pages=pages,
             handle=handle, saved_flags=flags)
        for count, pages, handle, flags in itertools.product(
            (-1, 0, 15, 16, 17), (-1, 0, 15, 16, 17), (0, 1, -1), (0, 0x100))
    ]
    result += [
        dict(base, speed=integer, lives=integer, short_speed=short_value,
             blood=short_value, other_short=short_value)
        for integer, short_value in itertools.product(
            (-0x80000000, -16, -5, -4, -1, 0, 1, 4, 5, 16, 0x7FFFFFFF),
            (-32768, -6, -1, 0, 1, 6, 32767))
    ]
    rng = random.Random(0x2205C)
    for _ in range(500):
        result.append(dict(
            base, flags=rng.getrandbits(32), pak_status=rng.choice((0, -2, -1, 1, 2, -3)),
            initial_status=rng.choice((0, 1, 2, 7, -1)), handle=rng.choice((0, 1, -1)),
            directory_count=rng.choice((-1, 0, 15, 16, 17)),
            free_pages=rng.choice((-1, 0, 15, 16, 17)),
            saved_flags=rng.getrandbits(32), speed=signed(rng.getrandbits(32)),
            short_speed=rng.randint(-32768, 32767), lives=signed(rng.getrandbits(32)),
            blood=rng.randint(-32768, 32767), other_short=rng.randint(-32768, 32767),
            scene_values=[signed(rng.getrandbits(32)) for _ in range(3)],
            file_size=rng.choice((880, 896, 1024)), seed=rng.randrange(65536),
        ))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default=SOURCE)
    parser.add_argument("--limit", type=int, default=0)
    args = parser.parse_args()
    if args.limit < 0:
        parser.error("--limit must be nonnegative")
    BUILD.mkdir(parents=True, exist_ok=True)
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    sources = [args.source] + list(DATA_SOURCES)
    sources += [source for name, source, _, _ in MATCHING_BLOCKS if name in SUPPORT]
    audit_inputs = {}
    for source in sources:
        audit_inputs.update(comparison_input_hashes(source))
    for name in (
            "tools/check_game_initialization.py", "tools/check_actor_boundary_boss.py",
            "tools/check_actor_group_path.py", "tools/check_movie_storage.py",
            "tools/compare_startup.py", "tools/compare_runtime.py", "tools/compare_data.py",
            "tools/trim_padding.py", "tools/rom.py", "tools/toolchain.py"):
        audit_inputs[name] = hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
    candidate = compare_candidate_block("game_initialize", args.source, target, layout)
    path = ROOT / "build/runtime-candidates/game_initialize"
    actual, literal_image = (path / "game_initialize.bin").read_bytes(), (path / "literals.bin").read_bytes()
    code, original_code, comparisons = [], [], {}
    for name, source, first, last in MATCHING_BLOCKS:
        if name not in SUPPORT:
            continue
        offset = first - 0x80000000 + 0xC00
        comparison = compare_block(name, source, first, offset, offset + last - first,
                                   target, "game-initialization-support", layout)
        assert comparison["matches"], (name, comparison["different_words"])
        comparisons[name] = comparison
        image = (ROOT / "build/game-initialization-support" / name / (name + ".bin")).read_bytes()
        code.append((first, image))
        original_code.append((first, target[offset:offset + last - first]))
    assert set(comparisons) == set(SUPPORT)
    image, data_comparisons = [], {}
    for source in DATA_SOURCES:
        records = source_sections(source)
        data_comparisons[source] = compare_unit(source, records, target, layout)
        sections, symbols = elf_sections_and_symbols(comparison_directory(source) / "compiled.elf")
        if source.endswith("/levels.c"):
            section = sections[".game_level_filenames"]
            assert section["type"] == 8 and section["size"] == 880 and section["flags"] & 1
            assert symbols["D_800BA7A8"]["size"] == 880
        if source.endswith("/control_setup/text.c"):
            assert sections[".menu_control_setup_mutable_text"]["flags"] & 1
            assert sections[".menu_control_setup_mutable_text"]["size"] == 44
        image += [(record["vram"], sections[record["section"]]["bytes"])
                  for record in records if record["rom"] is not None]
    all_cases = cases()
    if args.limit:
        all_cases = all_cases[:args.limit]
    digest = hashlib.sha256()
    original, original_literals = target[0x22C5C:0x23128], target[0x92E4C:0x92EAC]
    lookups = 0
    for i, case in enumerate(all_cases):
        indices = tuple(range(220)) if i == 0 else (i % 220, 219)
        a = run(actual, literal_image, code, image, target, case, indices)
        b = run(original, original_literals, original_code, [], target, case, indices)
        assert a == b, ("Paired initializer", case)
        lookups += len(indices) * 2
        digest.update(json.dumps([case, a], sort_keys=True).encode())
        if i and i % 200 == 0:
            print("Checked complete game initializer pairs:", i, flush=True)
    # Exercise branch, argument, memory-width and owned-data guards.
    mutations = []
    mutation_case = dict(all_cases[0], pak_status=1, handle=0)
    alterations = (
        ("controller branch", 0x800224CC - ENTRY, word(0x308C0002), None),
        ("copy length", 0x800221A0 - ENTRY, word(0x2406036C), None),
        ("script argument", 0x800221C0 - ENTRY, word(0x00002025), None),
        ("pak status", 0x800222D8 - ENTRY, word(0xAC400000), None),
        ("short division width", 0x800221FC - ENTRY, word(0x8C6F00D0), None),
        ("control digit", 0x80022478 - ENTRY, word(0x24190033), None),
        ("local initializer", None, None, (LITERALS, b"X")),
        ("filename literal", None, None, (0x80092264, b"X")),
        ("control text pointer", None, None, (LABELS + 3 * 40 + 8, word(0))),
    )
    for label, offset, replacement, data_change in alterations:
        altered = bytearray(actual)
        changed_data = list(image)
        changed_literals = literal_image
        if offset is not None:
            altered[offset:offset + 4] = replacement
        if data_change is not None:
            address, replacement = data_change
            changed = False
            for j, (base, blob) in enumerate(changed_data):
                if base <= address and address + len(replacement) <= base + len(blob):
                    modified = bytearray(blob)
                    modified[address - base:address - base + len(replacement)] = replacement
                    changed_data[j] = (base, bytes(modified))
                    changed = True
            if LITERALS <= address and address + len(replacement) <= LITERALS + 96:
                modified = bytearray(changed_literals)
                modified[address - LITERALS:address - LITERALS + len(replacement)] = replacement
                changed_literals = bytes(modified)
                changed = True
            assert changed, label
        try:
            run(bytes(altered), changed_literals, code, changed_data, target,
                dict(mutation_case, flags=4) if label == "controller branch" else
                dict(mutation_case, pak_status=0) if label == "pak status" else
                mutation_case, (0, 219))
        except (AssertionError, ValueError, UcError):
            mutations.append(label)
        else:
            raise AssertionError(("Undetected initializer mutation", label))
    layout.verify()
    for name, expected_hash in audit_inputs.items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != expected_hash:
            raise ValueError("Initializer audit input changed: " + name)
    report = {
        "inputs_sha256": audit_inputs,
        "matches_behavior": True, "matching_source_claim": False,
        "source_instruction_bytes_added": 0, "initialized_bytes_added": 96,
        "bss_bytes_added": 880, "pairs": len(all_cases),
        "initializer_executions": len(all_cases) * 2,
        "level_lookup_executions": lookups, "mutations_detected": mutations,
        "trace_and_effects_sha256": digest.hexdigest(),
        "case_corpus_sha256": hashlib.sha256(
            json.dumps(all_cases, sort_keys=True).encode()).hexdigest(),
        "candidate": candidate, "support": comparisons, "data": data_comparisons,
        "versions": {tool: version(tool) for tool in ("unicorn", "capstone", "pyelftools")},
        "checker_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "limits": [
            "The initializer remains excluded because its complete code differs in eleven stack-offset words.",
            "Matching platform adapters, copying, empty leaves and level lookup execute as real MIPS code.",
            "Other startup services, resource queries, allocation, resource transfer, heap release and pak services use O32 boundary stubs.",
            "All fixture bytes, exact fields, scalar widths, startup call order and arguments, code bounds, stack guards and O32 integer preservation are checked.",
            "The full 220-pointer table is copied; every index executes in the first pair, and two indices execute in each subsequent pair.",
            "The two mutable control labels retain all 44 retail bytes and only their observed digit bytes may change.",
            "The retail 272-byte frame is unexplained by current source; the natural candidate frame is 64 bytes.",
            "Ghidra's older read-only fallback blocks and unmapped filename BSS remain analysis limitations.",
        ],
    }
    (BUILD / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print("Complete game initialization:", len(all_cases), "pairs,", lookups,
          "level lookup executions and", len(mutations), "detected mutations.", flush=True)


if __name__ == "__main__":
    main()
