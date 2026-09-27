"""Measure compiled function bytes; unknown totals remain unknown."""

import json
import subprocess
import tempfile
from pathlib import Path
from manifest import load_manifest
from provenance import verify_record
from rom import ROOT, validate
from verify import compare


def parse_sections(output):
    sections = {}
    for line in output.splitlines():
        parts = line.split()
        if len(parts) >= 7 and parts[0].isdigit():
            name = parts[1]
            if name in sections:
                raise ValueError(f"Duplicate ELF section: {name}")
            sections[name] = tuple(int(value, 16) for value in parts[2:5])
    if not sections:
        raise ValueError("No ELF section headers reported")
    return sections


def verify_section(function, sections):
    name = function["name"]
    section = sections.get(function["section"])
    if section is None:
        raise ValueError(f"Missing linked section for {name}")
    section_size, vma, lma = section
    offset = function["vram"] - function["section_vram"]
    if vma != function["section_vram"] or lma + offset != function["rom"]:
        raise ValueError(f"Linked section VMA/LMA mismatch: {name}")
    if offset < 0 or offset + function["size"] > section_size:
        raise ValueError(f"Function extends outside linked section: {name}")


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
    functions = load_manifest()
    sections = parse_sections(subprocess.check_output(
        ["mips-linux-gnu-objdump", "-h", str(elf)], text=True))
    matches = []
    verified_objects = set()
    for function in functions:
        name, start, size = function["name"], function["rom"], function["size"]
        verify_section(function, sections)
        if function["object"] not in verified_objects:
            verify_record(function["source"], function["object"])
            verified_objects.add(function["object"])
        if symbols.get(name) != (function["vram"], size):
            raise ValueError(f"Linked symbol address/size mismatch: {name}")
        end = start + size
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
