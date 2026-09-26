"""Extract bootstrap fallback regions from the validated target."""

import argparse
from pathlib import Path
from rom import ROOT, normalize, validate

REGIONS = (
    ("header", 0, 0x40),
    ("ipl3", 0x40, 0x1000),
    ("cpu_fallback", 0x11e0, 0x70040),
    ("rsp_boot", 0x70040, 0x70110),
    ("remainder", 0x70110, 0x800000),
)


def extract(path):
    data = normalize(path.read_bytes())
    validate(data)
    output = ROOT / "build/us/extracted"
    output.mkdir(parents=True, exist_ok=True)
    lines = []
    for name, start, end in REGIONS:
        (output / f"{name}.bin").write_bytes(data[start:end])
        lines.extend((f'.section .rom_{name}, "a", @progbits',
                      f'.incbin "build/us/extracted/{name}.bin"'))
    (output / "fallback.s").write_text("\n".join(lines) + "\n")
    (output / ".stamp").write_text("validated target extracted\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baserom", type=Path)
    extract(parser.parse_args().baserom)
