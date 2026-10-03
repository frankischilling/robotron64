"""Independently compile and link source-owned C units that contain only data."""

from collections import defaultdict
import hashlib
import json
from pathlib import Path
import subprocess

from compare_startup import (SymbolLayoutSnapshot, comparison_input_hashes,
                             external_assignments)
from compiler import compile_source, profile_for_source
from manifest import load_manifest
from owned_sections import (elf_sections_and_symbols, linker_placements,
                            load_owned_sections, trim_owned_sections,
                            verify_owned_binary)
from rom import ROOT, validate
from toolchain import install, installed_identity


def data_only_sources(functions, owned):
    executable = {item["source"] for item in functions}
    groups = defaultdict(list)
    for item in owned:
        if item["source"] not in executable:
            groups[item["source"]].append(item)
    return dict(groups)


def verify_data_sections(sections, symbols, records):
    """Reject executable content and initialized sections outside ownership."""
    allowed = {record["input_section"] for record in records}
    allowed.update((".reginfo", ".MIPS.abiflags"))
    for name, section in sections.items():
        if section["size"] and section["flags"] & 2 and name not in allowed:
            raise ValueError(f"Data-only source has an unowned allocated section: {name}")
        if section["size"] and section["flags"] & 4:
            raise ValueError(f"Data-only source contains executable bytes: {name}")
    # A typed dispatch table can reference undefined STT_FUNC symbols without
    # defining any code. Only SHN_UNDEF (index zero) is an external reference;
    # absolute and section-defined procedure symbols remain forbidden here.
    if any(symbol["type"] == 2 and symbol.get("index") != 0 for symbol in symbols.values()):
        raise ValueError("Data-only source contains a procedure")


def comparison_directory(source, root=ROOT):
    return root / "build/data-comparison" / Path(source).with_suffix("")


def data_input_hashes(source, root=ROOT):
    hashes = comparison_input_hashes(source, root)
    hashes["tools/compare_data.py"] = hashlib.sha256((root / "tools/compare_data.py").read_bytes()).hexdigest()
    return hashes


def data_linker_script(undefined, addresses, records):
    # ABI metadata must not become an orphan between adjacent owned sections.
    return (external_assignments(undefined, addresses) +
            "SECTIONS { " + linker_placements(records) +
            "\n/DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n")


def compare_unit(source, records, target, layout):
    directory = comparison_directory(source)
    directory.mkdir(parents=True, exist_ok=True)
    raw, obj, elf = [directory / name for name in ("raw.o", "compiled.o", "compiled.elf")]
    inputs = data_input_hashes(source)
    layout.verify()
    compile_source(source, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    verify_data_sections(sections, symbols, records)
    obj.write_bytes(trim_owned_sections(raw.read_bytes(), records))
    verify_owned_binary(obj, records, linked=False)
    undefined = {line.split()[-1] for line in subprocess.check_output(
        ["mips-linux-gnu-nm", "-u", str(obj)], text=True).splitlines() if line.strip()}
    script = directory / "source.ld"
    script.write_text(data_linker_script(undefined, layout.addresses, records))
    subprocess.run(["mips-linux-gnu-ld", "-T", str(script), "-e", "0", "-o", str(elf), str(obj)],
                   check=True, cwd=ROOT)
    verify_owned_binary(elf, records, target)
    sections, _ = elf_sections_and_symbols(elf)
    blocks = []
    for record in records:
        data = sections[record["section"]]["bytes"]
        blocks.append({"ownership": record, "bytes_sha256": None if data is None else
                       hashlib.sha256(data).hexdigest()})
    layout.verify()
    if data_input_hashes(source) != inputs:
        raise ValueError("Data comparison inputs changed during compilation")
    profile = profile_for_source(source)
    return {"source": source, "matches": True, "sections": blocks,
            "compiler_profile": profile, "toolchain_identity": installed_identity(profile["version"]),
            "inputs_sha256": inputs}


def main():
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    groups = data_only_sources(load_manifest(), load_owned_sections())
    for version in {profile_for_source(source)["version"] for source in groups}:
        install(version)
    layout = SymbolLayoutSnapshot()
    blocks = {source: compare_unit(source, records, target, layout)
              for source, records in sorted(groups.items())}
    report = {"matches": True, "blocks": blocks}
    path = ROOT / "build/data-comparison/report.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2) + "\n")
    for source, records in groups.items():
        print(f"{source}: {sum(r['size'] for r in records)} complete owned bytes; no executable code")
    print(f"Report: {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
