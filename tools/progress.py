"""Measure compiled function bytes; unknown totals remain unknown."""

import json
import subprocess
import tempfile
from pathlib import Path
from manifest import load_manifest
from provenance import verify_record
from rom import ROOT, validate
from verify import compare
from ido_symbols import local_functions
from owned_sections import (load_owned_sections, validate_function_ranges,
                            verify_owned_binary)


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
    owned = load_owned_sections()
    validate_function_ranges(owned, functions)
    sections = parse_sections(subprocess.check_output(
        ["mips-linux-gnu-objdump", "-h", str(elf)], text=True))
    matches = []
    verified_objects = set()
    static_symbols = {}
    for function in functions:
        name, start, size = function["name"], function["rom"], function["size"]
        verify_section(function, sections)
        if function["object"] not in verified_objects:
            verify_record(function["source"], function["object"])
            verified_objects.add(function["object"])
        is_static = function.get("linkage", "external") == "static"
        if not is_static and symbols.get(name) != (function["vram"], size):
            raise ValueError(f"Linked symbol address/size mismatch: {name}")
        end = start + size
        with tempfile.TemporaryDirectory() as directory:
            section = Path(directory) / "function.bin"
            subprocess.run(["mips-linux-gnu-objcopy", "-O", "binary", "-j", function["section"],
                            str(elf), str(section)], check=True)
            offset = function["vram"] - function["section_vram"]
            compare(target[start:end], section.read_bytes()[offset:offset + size])
            if is_static:
                object_name = function["object"]
                if object_name not in static_symbols:
                    static_symbols[object_name] = local_functions(ROOT / object_name)
                if static_symbols[object_name].get(name) != (offset, size):
                    raise ValueError(f"Compiled static procedure mismatch: {name}")
            else:
                object_symbols = subprocess.check_output(
                    ["mips-linux-gnu-nm", "-S", str(ROOT / function["object"])], text=True)
                expected_symbol = (offset, size, "T", name)
                parsed = [line.split() for line in object_symbols.splitlines()]
                if not any((int(p[0], 16), int(p[1], 16), p[2], p[3]) == expected_symbol
                           for p in parsed if len(p) == 4):
                    raise ValueError(f"Compiled object symbol mismatch: {name}")
        matches.append({"name": name, "bytes": size, "language": function.get("language", "C")})
    for record in owned:
        if record["object"] not in verified_objects:
            verify_record(record["source"], record["object"])
            verified_objects.add(record["object"])
        verify_owned_binary(ROOT / record["object"], [record], linked=False)
        if record["rom"] is not None and sections.get(record["section"], (None, None, None))[2] != record["rom"]:
            raise ValueError(f"Owned data load address mismatch: {record['section']}")
    verify_owned_binary(elf, owned, target)
    data_bytes = sum(record["size"] for record in owned if record["rom"] is not None)
    bss_bytes = sum(record["size"] for record in owned if record["rom"] is None)
    c_matches = [item for item in matches if item["language"] == "C"]
    asm_matches = [item for item in matches if item["language"] == "assembly"]
    return {
        "matched_c_functions": len(c_matches),
        "matched_c_bytes": sum(item["bytes"] for item in c_matches),
        "matched_assembly_functions": len(asm_matches),
        "matched_assembly_bytes": sum(item["bytes"] for item in asm_matches),
        "source_owned_initialized_bytes": data_bytes,
        "source_owned_bss_bytes": bss_bytes,
        "total_code_bytes": None,
        "total_functions": None,
        "matching_code_percent": None,
        "unmeasured_rom_bytes": len(target) - sum(item["bytes"] for item in matches) - data_bytes,
        "whole_rom_matches": True,
        "functions": matches,
        "note": "Unmeasured bytes include padding, header, boot, fallback code/data and assets; ROM equality is not source completion. Source-owned BSS consumes no ROM bytes.",
    }


if __name__ == "__main__":
    report = json.dumps(measure(), indent=2) + "\n"
    (ROOT / "build/us/progress.json").write_text(report)
    print(report, end="")
