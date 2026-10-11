"""Verify the complete matching selector with real callees and an integer model."""

from concurrent.futures import ThreadPoolExecutor
import hashlib, json, random, struct
from elftools.elf.elffile import ELFFile
from rom import ROOT, validate

n = ROOT
from compare_runtime import MATCHING_BLOCKS
from compare_startup import compare_block, SymbolLayoutSnapshot, comparison_input_hashes
from resource_literal_execution import (
    literal_machine,
    verify_fpu,
    FP_INIT,
    FP_RETURN,
    FP_SEED,
    FP_RESULT,
)
from check_actor_group_path import word, SENTINEL
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE
from unicorn import mips_const as regs


def audit():
    family = "scene-arrival-selector"
    out = n / "build" / family
    out.mkdir(parents=True, exist_ok=True)
    source = "src/game/scene_arrivals/select.c"
    inputs = comparison_input_hashes(source)

    def verify():
        assert (
            comparison_input_hashes(source) == inputs
        ), "Selector build inputs changed"

    verify()
    rom = (n / "baseroms/us/baserom.z64").read_bytes()
    validate(rom)
    layout = SymbolLayoutSnapshot()
    support_blocks = [
        b
        for b in MATCHING_BLOCKS
        if b[0] in ("game_memory", "object_model_access", "save_menu_conditional_copy")
    ]
    assert len(support_blocks) == 3

    def compile_support(b):
        name, source, start, end = b
        record = compare_block(
            name,
            source,
            start,
            start - 0x7FFFF400,
            end - 0x7FFFF400,
            rom,
            family=family,
            layout=layout,
        )
        assert record["matches"], name
        return (
            name,
            record,
            (start, (n / "build" / family / name / (name + ".bin")).read_bytes()),
            (start, rom[start - 0x7FFFF400 : end - 0x7FFFF400]),
        )

    with ThreadPoolExecutor(max_workers=2) as pool:
        support = list(pool.map(compile_support, support_blocks))
    retail = rom[0x2283C:0x22C44]
    table = rom[0x92608:0x92620]
    candidate = compare_block(
        "scene_arrival_select",
        source,
        0x80021C3C,
        0x2283C,
        0x22C44,
        rom,
        family=family,
        layout=layout,
    )
    assert candidate["matches"], "Complete selector instructions differ"
    with (out / "scene_arrival_select/scene_arrival_select.raw.o").open("rb") as stream:
        elf = ELFFile(stream)
        symbols = elf.get_section_by_name(".symtab").get_symbol_by_name("func_80021C3C")
        assert (
            len(symbols) == 1 and symbols[0]["st_size"] == 1032
        ), "Natural function extent"
        assert not any(elf.get_section_by_name(".text").data()[1032:]), "Live text tail"
        assert not any(
            elf.get_section_by_name(".rodata").data()[24:]
        ), "Live table tail"
    actual = (
        n / "build" / family / "scene_arrival_select/scene_arrival_select.bin"
    ).read_bytes()
    images = {
        "retail": ([(0x80021C3C, retail)] + [x[3] for x in support], 1536, 0x50, 0x5F8),
        "source": ([(0x80021C3C, actual)] + [x[2] for x in support], 1536, 0x50, 0x5F8),
    }
    STACK, OUTPUT, ANIMATIONS = 0x80300000, 0x80220010, 0x80200010
    SCENE, COUNT = 0x800B9A78, 0x800BA740
    GROUPS = ((0, 0x800AF1F0, 104, 36), (3, 0x800ACE58, 88, 8), (1, 0x8009F560, 88, 16))

    def signed(value):
        value &= 0xFFFFFFFF
        return value - 0x100000000 if value & 0x80000000 else value

    def model(case):
        counts = [0] * 360
        for trigger, state, index, category, delay, count in case["arrivals"]:
            if not state or category not in (0, 1, 3):
                continue
            slot = category * 36 + index
            if trigger == 0:
                counts[slot] = max(counts[slot], delay + count)
            elif trigger == 2:
                counts[slot] = max(counts[slot], delay)
            else:
                counts[slot] = signed(counts[slot] + count)
        before = counts[:]
        if signed(case["flag"]) < 0:
            for index in range(4):
                counts[108 + index + 4] = signed(counts[108 + index] * 3)
        for first, last, multiplier in (
            (17, 21, case["scale_a"]),
            (9, 13, case["scale_b"]),
        ):
            for index in range(first, last):
                counts[index + 4] = signed(
                    counts[index + 4] + counts[index] * multiplier
                )
        calls = [("copy", 0x800AC998)]
        global_index = 0
        last = case["default_kind"]
        for category, address, stride, size in GROUPS:
            for index in range(size):
                amount = counts[category * 36 + index]
                if amount:
                    length = case["lengths"][global_index + index]
                    calls.append(("length", global_index + index))
                    half = abs(length) // 2 * (-1 if length < 0 else 1)
                    if half <= amount:
                        calls.append(("copy", address + index * stride))
                        last = case["kinds"][global_index + index]
            global_index += size
        home = last if case["enabled"] else OUTPUT
        return before, counts, calls, home

    def inside(address, size, ranges):
        address = (address & 0x1FFFFFFF) | 0x80000000
        return any(a <= address and address + size <= b for a, b in ranges)

    def run(image, case, fault=None):
        code, frame, array_offset, selected_offset = images[image]
        code = [(a, bytes(data)) for a, data in code]
        if fault and fault[0] == "saved_fpu":
            for index, (address, data) in enumerate(code):
                if address == 0x80021C14:
                    changed = bytearray(data)
                    changed[4:8] = word(0xC4003080 | (fault[1] << 16))
                    code[index] = (address, bytes(changed))
        if fault and fault[0] == "enabled":
            for index, (address, data) in enumerate(code):
                if address == 0x80021C14:
                    changed = bytearray(data)
                    changed[:4] = word(0x240E0001)
                    code[index] = (address, bytes(changed))
        uc, write, execute, loaded = literal_machine(code, 0x80021C3C)
        if fault and fault[0] == "read_guard":
            write(FP_RETURN, word(0x8C022FF0))
        if fault and fault[0] == "write_guard":
            write(FP_RETURN, word(0xAC0230F0))
        if fault and fault[0] == "code_guard":
            write(FP_RETURN, word(0x08000420))
        before, after, wanted, home = model(case)
        panels = []

        def panel(address, data):
            panels.append((address, bytes(data)))
            write(address - 16, b"\xA7" * 16 + data + b"\xB9" * 16)

        scene = bytearray([0x79] * 0xCCC)
        for index, arrival in enumerate(case["arrivals"]):
            trigger, state, resource, category, delay, count = arrival
            scene[0x44 + index * 12 : 0x50 + index * 12] = struct.pack(
                ">BBBBhhhh",
                trigger,
                state,
                resource,
                category,
                delay,
                count,
                index,
                -index,
            )
        scene[0xCC8:0xCCC] = word(len(case["arrivals"]))
        panel(SCENE, scene)
        panel(0x800B8F78, word(case["flag"]))
        panel(0x800B14A4, word(case["scale_a"]))
        panel(0x800B00B0, word(case["scale_b"]))
        panel(0x800AC998, bytes([0x5E, case["default_kind"]]))
        panel(OUTPUT, bytes(range(64)))
        panel(0x80091A08, table)
        animations = bytearray(16 * 60)
        global_index = 0
        for category, address, stride, size in GROUPS:
            data = bytearray([0x45] * (stride * size))
            for index in range(size):
                slot = global_index + index
                data[index * stride + 1] = case["kinds"][slot]
                data[index * stride + 40 : index * stride + 44] = word(
                    ANIMATIONS + slot * 16
                )
                animations[slot * 16 + 10 : slot * 16 + 12] = struct.pack(">h", slot)
            panel(address, data)
            global_index += size
        panel(ANIMATIONS, animations)
        lengths = b"".join(
            word(length) + word(0x19A) + word(0x37B) + word(0x5CD)
            for length in case["lengths"]
        )
        panel(0x8007A1CC, lengths)
        stack_base = STACK - frame
        array = stack_base + array_offset
        stack_initial = b"\xC9" * (frame + 32)
        write(stack_base - 16, b"\xA7" * 16 + stack_initial + b"\xB9" * 16)
        readable = [(a, a + len(data)) for a, data in panels] + [
            (stack_base, STACK + 32),
            (FP_SEED, FP_SEED + 132),
        ]
        writable = [(stack_base, STACK + 32), (FP_RESULT, FP_RESULT + 48)]
        executable = [(a, a + len(data)) for a, data in loaded]
        saved = {
            getattr(regs, "UC_MIPS_REG_" + name): uc.reg_read(
                getattr(regs, "UC_MIPS_REG_" + name)
            )
            for name in ("S0", "S1", "S2", "S3", "S4", "S5", "S6", "S7", "FP", "GP")
        }
        uc.reg_write(regs.UC_MIPS_REG_A0, OUTPUT)
        uc.reg_write(regs.UC_MIPS_REG_A1, case["enabled"] & 0xFFFFFFFF)
        calls = []
        clears = []
        initial_checked = False

        def read(address, size):
            return bytes(uc.mem_read(address & 0x1FFFFFFF, size))

        def instruction(uc, address, size, user):
            nonlocal initial_checked
            assert address == SENTINEL or inside(address, size, executable), (
                "Code bounds",
                hex(address),
            )
            if address == 0x8003B694:
                clears.append(
                    tuple(
                        uc.reg_read(getattr(regs, "UC_MIPS_REG_" + r))
                        for r in ("A0", "A1", "A2")
                    )
                )
                assert clears[-1] == (array, 0, 1440), "Exact clear extent"
            elif address == 0x8003941C:
                calls.append(("length", signed(uc.reg_read(regs.UC_MIPS_REG_A0))))
            elif address == 0x80021C14:
                a0 = uc.reg_read(regs.UC_MIPS_REG_A0)
                a1 = uc.reg_read(regs.UC_MIPS_REG_A1)
                a2 = uc.reg_read(regs.UC_MIPS_REG_A2)
                assert (a0, a1) == (
                    stack_base + selected_offset,
                    STACK + 4,
                ), "Original helper pointer ABI"
                assert read(a0, 4) == word(
                    STACK
                ), "Copy points to incoming argument home"
                if not initial_checked:
                    assert read(array, 1440) == b"".join(
                        word(x) for x in before
                    ), "Arrival aggregation"
                    initial_checked = True
                calls.append(("copy", a2))

        def access(uc, kind, address, size, value, user):
            ranges = writable if kind == 17 else readable
            assert inside(address, size, ranges), (
                "Write bounds" if kind == 17 else "Read bounds",
                hex(address),
                size,
            )

        uc.hook_add(UC_HOOK_CODE, instruction)
        uc.hook_add(UC_HOOK_MEM_READ, access)
        uc.hook_add(UC_HOOK_MEM_WRITE, access)
        execute(FP_INIT)
        assert initial_checked and clears == [(array, 0, 1440)]
        assert calls == wanted, ("Selection calls", calls, wanted)
        assert read(array, 1440) == b"".join(
            word(x) for x in after
        ), "Full 360-word table"
        assert read(STACK, 8) == word(home) + word(case["enabled"]), "Argument homes"
        for address, data in panels:
            assert (
                read(address - 16, len(data) + 32) == b"\xA7" * 16 + data + b"\xB9" * 16
            ), ("Input panel changed", hex(address))
        assert (
            read(stack_base - 16, 16) == b"\xA7" * 16
            and read(STACK + 32, 16) == b"\xB9" * 16
        ), "Stack guard"
        assert all(
            uc.reg_read(reg) == value for reg, value in saved.items()
        ), "Saved integer ABI"
        verify_fpu(uc)
        return dict(
            calls=calls,
            table_sha256=hashlib.sha256(read(array, 1440)).hexdigest(),
            home=home,
            external_pointee_unchanged=True,
        )

    def make(arrivals=(), enabled=1, flag=0, scale_a=1, scale_b=1, seed=0):
        rng = random.Random(seed)
        lengths = [
            rng.choice((-2147483648, -101, -3, -1, 0, 1, 3, 100, 2147483647))
            for _ in range(60)
        ]
        kinds = [(index * 31 + seed * 17) & 255 for index in range(60)]
        return dict(
            arrivals=list(arrivals),
            enabled=enabled,
            flag=flag,
            scale_a=scale_a,
            scale_b=scale_b,
            lengths=lengths,
            kinds=kinds,
            default_kind=(seed * 29 + 251) & 255,
        )

    cases = [
        make(enabled=x, seed=i)
        for i, x in enumerate((0, 1, -1, 100, 0x7FFFFFFF, -2147483648))
    ]
    # Every switch arm, ignored category/state, and both ends of each selected group.
    for category, indexes in (
        (0, (0, 9, 12, 17, 20, 35)),
        (1, (0, 15, 35)),
        (3, (0, 3, 4, 7, 35)),
        (2, (0, 255)),
        (255, (0, 255)),
    ):
        for index in indexes:
            for trigger in (0, 1, 2, 3, 4, 5, 6, 255):
                cases.append(
                    make([(trigger, 1, index, category, -7, 11)], seed=len(cases))
                )
    cases.append(make([(255, 0, 255, 0, 32767, -32768)], seed=91))
    # Max arms must accumulate correctly when followed by smaller or larger values.
    for category in (0, 1, 3):
        for trigger in (0, 2):
            cases.append(
                make(
                    [
                        (1, 1, 0, category, 0, 14),
                        (trigger, 1, 0, category, -5, 3),
                        (trigger, 1, 0, category, 31, 4),
                    ],
                    seed=len(cases),
                )
            )
    for flag, scale_a, scale_b in (
        (0, 0, 0),
        (-1, 3, -2),
        (0x80000000, -2147483648, 2147483647),
        (0x7FFFFFFF, -1, 2),
    ):
        arrivals = [
            (1, 1, index, category, 0, (-32768 if index % 2 else 32767))
            for category, index in (
                (0, 9),
                (0, 10),
                (0, 12),
                (0, 13),
                (0, 17),
                (0, 20),
                (0, 21),
                (3, 0),
                (3, 1),
                (3, 2),
                (3, 3),
                (3, 4),
            )
        ]
        cases.append(
            make(arrivals, flag=flag, scale_a=scale_a, scale_b=scale_b, seed=len(cases))
        )
    for seed in range(30):
        rng = random.Random(9107 + seed)
        count = (0, 1, 2, 8, 64, 256)[seed % 6]
        arrivals = [
            (
                rng.choice((0, 1, 2, 3, 4, 5, 6, 255)),
                rng.choice((0, 1, 255)),
                rng.randrange(36),
                rng.choice((0, 1, 3, 2, 255)),
                rng.randrange(-32768, 32768),
                rng.randrange(-32768, 32768),
            )
            for _ in range(count)
        ]
        cases.append(
            make(
                arrivals,
                enabled=(0, 1, 100, -1)[seed % 4],
                flag=(0, 0x80000000)[seed % 2],
                scale_a=seed - 17,
                scale_b=13 - seed,
                seed=seed + 101,
            )
        )
    results = []
    for i, case in enumerate(cases):
        original_result = run("retail", case)
        assert run("source", case) == original_result
        results.append(original_result)
        if i % 40 == 0:
            print("selector cases", i + 1, "/", len(cases), flush=True)
    # Faults execute in guest instructions; bracket each rejection with positives.
    negative = []
    control = make(enabled=0, seed=193)
    for fault in [("saved_fpu", i) for i in range(20, 32)] + [
        ("read_guard", 0),
        ("write_guard", 0),
        ("code_guard", 0),
        ("enabled", 0),
    ]:
        run("source", control)
        try:
            run("source", control, fault)
        except (AssertionError, ValueError) as error:
            negative.append(dict(fault=fault, detected=str(error)))
        else:
            raise AssertionError(("Undetected guest fault", fault))
        run("source", control)
    layout.verify()
    verify()
    receipt = dict(
        cases=len(cases),
        executions=len(cases) * 2,
        images=list(images),
        selector=candidate,
        support={x[0]: x[1] for x in support},
        negative_controls=negative,
        positive_brackets=32,
        actual_call_boundaries=0,
        retail_instruction_bytes=1032,
        following_zero_bytes_excluded=12,
        generated_table_bytes=24,
        full_count_words=360,
        verified_public_files=len(inputs),
        source_instruction_bytes=1032,
        source_initialized_bytes=24,
        cases_sha256=hashlib.sha256(
            json.dumps(cases, sort_keys=True).encode()
        ).hexdigest(),
        results_sha256=hashlib.sha256(
            json.dumps(results, sort_keys=True).encode()
        ).hexdigest(),
        limits=[
            "Finite synthetic scene and resource fixtures do not prove all game behavior.",
            "Retail and source execute all three freshly matched supporting C units; no simulated returning services.",
            "Complete selector instructions and its generated table match retail bytes.",
        ],
    )
    (out / "cases.json").write_text(json.dumps(cases, indent=2) + "\n")
    (out / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(
        json.dumps(
            {
                k: receipt[k]
                for k in (
                    "cases",
                    "executions",
                    "source_instruction_bytes",
                    "source_initialized_bytes",
                )
            }
        ),
        flush=True,
    )


if __name__ == "__main__":
    audit()
