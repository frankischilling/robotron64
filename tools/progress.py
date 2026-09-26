"""Measure compiled function bytes; unknown totals remain unknown."""

import json
import subprocess
import tempfile
from pathlib import Path
from rom import ROOT, validate
from verify import compare


def measure():
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    rebuilt = (ROOT / "build/us/robotron64.z64").read_bytes()
    compare(target, rebuilt)
    elf = ROOT / "build/us/robotron64.elf"
    symbols = {}
    for line in subprocess.check_output(["mips-linux-gnu-nm", "-S", str(elf)], text=True).splitlines():
        parts = line.split()
        if len(parts) == 4:
            symbols[parts[3]] = (int(parts[0], 16), int(parts[1], 16))
    functions = json.loads((ROOT / "config/functions.json").read_text())
    matches = []
    ranges = []
    for function in functions:
        if function.get("language", "C") not in {"C", "assembly"}:
            raise ValueError(f"Unsupported source language: {function['name']}")
        name, start, size = function["name"], function["rom"], function["size"]
        if symbols.get(name) != (function["vram"], size):
            raise ValueError(f"Linked symbol address/size mismatch: {name}")
        end = start + size
        if start < 0 or size <= 0 or end > len(target) or any(start < b and a < end for a, b in ranges):
            raise ValueError(f"Invalid/overlapping function range: {name}")
        ranges.append((start, end))
        with tempfile.TemporaryDirectory() as directory:
            section = Path(directory) / "function.bin"
            subprocess.run(["mips-linux-gnu-objcopy", "-O", "binary", "-j", function["section"],
                            str(elf), str(section)], check=True)
            offset = function["vram"] - function["section_vram"]
            compare(target[start:end], section.read_bytes()[offset:offset + size])
            object_symbols = subprocess.check_output(
                ["mips-linux-gnu-nm", "-S", str(ROOT / function["object"])], text=True)
            expected_symbol = (offset, size, "T", name)
            parsed = [line.split() for line in object_symbols.splitlines()]
            if not any((int(p[0], 16), int(p[1], 16), p[2], p[3]) == expected_symbol
                       for p in parsed if len(p) == 4):
                raise ValueError(f"Compiled object symbol mismatch: {name}")
        matches.append({"name": name, "bytes": size, "language": function.get("language", "C")})
    c_matches = [item for item in matches if item["language"] == "C"]
    asm_matches = [item for item in matches if item["language"] == "assembly"]
    return {
        "matched_c_functions": len(c_matches),
        "matched_c_bytes": sum(item["bytes"] for item in c_matches),
        "matched_assembly_functions": len(asm_matches),
        "matched_assembly_bytes": sum(item["bytes"] for item in asm_matches),
        "total_code_bytes": None,
        "total_functions": None,
        "matching_code_percent": None,
        "unmeasured_rom_bytes": len(target) - sum(item["bytes"] for item in matches),
        "whole_rom_matches": True,
        "functions": matches,
        "note": "Unmeasured bytes include padding, header, boot, fallback code, data and assets; ROM equality is not source completion.",
    }


if __name__ == "__main__":
    report = json.dumps(measure(), indent=2) + "\n"
    (ROOT / "build/us/progress.json").write_text(report)
    print(report, end="")
