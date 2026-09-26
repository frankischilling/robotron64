"""Repeat the compiler/ISA comparison for the first reconstructed source block."""

import hashlib
import json
import subprocess
from rom import ROOT, validate
from toolchain import install


def run():
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    expected = target[0x1050:0x11e0]
    directory = ROOT / "build/compiler-comparison"
    directory.mkdir(parents=True, exist_ok=True)
    rows = []
    for version in ("5.3", "7.1"):
        install(version)
        for isa in ("1", "2"):
            stem = directory / f"ido-{version.replace('.', '_')}-mips{isa}"
            flags = ["-O2", "-G", "0", "-non_shared", f"-mips{isa}", "-32"]
            subprocess.run([str(ROOT / ".local/toolchain" / version / "cc"), "-c", *flags,
                            "-o", str(stem.with_suffix(".o")), "src/game/text.c"], check=True, cwd=ROOT)
            subprocess.run(["mips-linux-gnu-ld", "-Ttext=0x80000450",
                            "--defsym=D_80072B40=0x80072b40", "--defsym=D_80072BA8=0x80072ba8",
                            "-e", "func_80000450", "-o", str(stem.with_suffix(".elf")),
                            str(stem.with_suffix(".o"))], check=True)
            subprocess.run(["mips-linux-gnu-objcopy", "-O", "binary", "-j", ".text",
                            str(stem.with_suffix(".elf")), str(stem.with_suffix(".bin"))], check=True)
            actual = stem.with_suffix(".bin").read_bytes()
            rows.append({"compiler": version, "flags": flags, "expected_size": len(expected),
                         "actual_size": len(actual), "matches": actual == expected,
                         "different_bytes": sum(a != b for a, b in zip(actual, expected))
                         + abs(len(actual) - len(expected)),
                         "sha256": hashlib.sha256(actual).hexdigest()})
    report = {"source_sha256": hashlib.sha256((ROOT / "src/game/text.c").read_bytes()).hexdigest(),
              "rom_range": ["0x1050", "0x11e0"], "candidates": rows}
    encoded = json.dumps(report, indent=2) + "\n"
    (directory / "report.json").write_text(encoded)
    print(encoded, end="")


if __name__ == "__main__":
    run()
