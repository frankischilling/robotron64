"""Independently compile and verify the two matching startup routines."""

import hashlib
import json
import subprocess
from rom import ROOT, validate
from toolchain import install
from verify import compare


def run():
    install("5.3")
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    directory = ROOT / "build/startup-comparison"
    directory.mkdir(parents=True, exist_ok=True)
    subprocess.run([str(ROOT / ".local/toolchain/5.3/cc"), "-c", "-O2", "-G", "0",
                    "-non_shared", "-mips1", "-32", "-o", str(directory / "startup.o"),
                    "src/boot/startup.c"], check=True, cwd=ROOT)
    script = directory / "candidate.ld"
    script.write_text('INCLUDE config/startup_symbols.ld\n'
                      'SECTIONS { .text 0x80048170 : SUBALIGN(16) { *(.text) } }\n')
    subprocess.run(["mips-linux-gnu-ld", "-T", str(script), "-e", "func_80048170",
                    "-o", str(directory / "startup.elf"), str(directory / "startup.o")],
                   check=True, cwd=ROOT)
    subprocess.run(["mips-linux-gnu-objcopy", "-O", "binary", "-j", ".text",
                    str(directory / "startup.elf"), str(directory / "startup.bin")], check=True)
    actual = (directory / "startup.bin").read_bytes()
    expected = target[0x48d70:0x48ea0]
    report = {"source_sha256": hashlib.sha256((ROOT / "src/boot/startup.c").read_bytes()).hexdigest(),
              "expected_size": len(expected), "actual_size": len(actual),
              "matches": actual == expected,
              "different_words": [{"vram": hex(0x80048170 + i),
                                   "expected": expected[i:i + 4].hex(),
                                   "actual": actual[i:i + 4].hex()}
                                  for i in range(0, max(len(actual), len(expected)), 4)
                                  if expected[i:i + 4] != actual[i:i + 4]]}
    encoded = json.dumps(report, indent=2) + "\n"
    (directory / "report.json").write_text(encoded)
    print(encoded, end="")
    compare(expected, actual)


if __name__ == "__main__":
    run()
