"""Independently compile and verify the startup and scheduler source blocks."""

import hashlib
import json
import subprocess
from rom import ROOT, validate
from toolchain import install


def compare_block(name, source, vram, start, end, target, extra_symbols=""):
    directory = ROOT / "build/startup-comparison" / name
    directory.mkdir(parents=True, exist_ok=True)
    object_path = directory / f"{name}.o"
    elf_path = directory / f"{name}.elf"
    binary_path = directory / f"{name}.bin"
    subprocess.run([str(ROOT / ".local/toolchain/5.3/cc"), "-c", "-O2", "-G", "0",
                    "-non_shared", "-mips1", "-32", "-o", str(object_path), source],
                   check=True, cwd=ROOT)
    script = directory / "candidate.ld"
    script.write_text('INCLUDE config/startup_symbols.ld\n' + extra_symbols +
                      f'SECTIONS {{ .text 0x{vram:X} : SUBALIGN(16) {{ *(.text) }} }}\n')
    subprocess.run(["mips-linux-gnu-ld", "-T", str(script), "-e", f"func_{vram:08X}",
                    "-o", str(elf_path), str(object_path)],
                   check=True, cwd=ROOT)
    subprocess.run(["mips-linux-gnu-objcopy", "-O", "binary", "-j", ".text",
                    str(elf_path), str(binary_path)], check=True)
    actual = binary_path.read_bytes()
    expected = target[start:end]
    return {"source": source,
            "inputs_sha256": {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
                              for path in (source, "include/scheduler.h", "config/startup_symbols.ld")},
            "expected_size": len(expected), "actual_size": len(actual),
            "matches": actual == expected,
            "different_words": [{"vram": hex(vram + i),
                                 "expected": expected[i:i + 4].hex(),
                                 "actual": actual[i:i + 4].hex()}
                                for i in range(0, max(len(actual), len(expected)), 4)
                                if expected[i:i + 4] != actual[i:i + 4]]}


def run():
    install("5.3")
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    blocks = {
        "startup": compare_block("startup", "src/boot/startup.c", 0x80048170,
                                 0x48d70, 0x49110, target,
                                 "func_80050440 = 0x80050440;\n"),
        "scheduler": compare_block("scheduler", "src/boot/scheduler.c", 0x80050440,
                                   0x51040, 0x51230, target),
    }
    report = {"matches": all(block["matches"] for block in blocks.values()), "blocks": blocks}
    encoded = json.dumps(report, indent=2) + "\n"
    (ROOT / "build/startup-comparison/report.json").write_text(encoded)
    print(encoded, end="")
    if not report["matches"]:
        raise SystemExit("Startup comparison failed; see build/startup-comparison/report.json")


if __name__ == "__main__":
    run()
