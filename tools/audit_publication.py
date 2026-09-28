"""Check a public checkpoint against its current manifest, inputs, and ROM proofs."""

import argparse
from collections import defaultdict
import hashlib
import json
from pathlib import Path

from compare_runtime import MATCHING_BLOCKS
from compare_startup import MATCHING_BLOCKS as STARTUP_BLOCKS, SymbolLayoutSnapshot
from compiler import profile_for_source
from manifest import load_manifest, project_path
from owned_sections import load_owned_sections, validate_function_ranges
from provenance import local_headers
from rom import ROOT
from toolchain import installed_identity


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected_progress(functions, owned):
    c = [item for item in functions if item.get("language", "C") == "C"]
    assembly = [item for item in functions if item.get("language", "C") == "assembly"]
    return {
        "matched_c_functions": len(c),
        "matched_c_bytes": sum(item["size"] for item in c),
        "matched_assembly_functions": len(assembly),
        "matched_assembly_bytes": sum(item["size"] for item in assembly),
        "source_owned_initialized_bytes": sum(item["size"] for item in owned if item["rom"] is not None),
        "source_owned_bss_bytes": sum(item["size"] for item in owned if item["rom"] is None),
        "whole_rom_matches": True,
    }


def check_progress(progress, functions, owned):
    for name, expected in expected_progress(functions, owned).items():
        if type(progress.get(name)) is not type(expected) or progress[name] != expected:
            raise ValueError(f"Progress disagrees with current manifest: {name}")
    expected_functions = {
        item["name"]: (item["size"], item.get("language", "C")) for item in functions
    }
    recorded = progress.get("functions")
    if not isinstance(recorded, list):
        raise ValueError("Progress has no complete function inventory")
    actual = {}
    for item in recorded:
        if not isinstance(item, dict) or item.get("name") in actual:
            raise ValueError("Malformed or duplicate progress function")
        actual[item.get("name")] = (item.get("bytes"), item.get("language"))
    if actual != expected_functions:
        raise ValueError("Progress function inventory is stale")


def check_inputs(root, hashes, required):
    if not isinstance(hashes, dict) or not set(required).issubset(hashes):
        raise ValueError("Comparison omits current source/header metadata")
    for filename, digest in hashes.items():
        path = project_path(root, filename, "comparison input")
        if not path.is_file() or sha256(path) != digest:
            raise ValueError(f"Stale comparison input: {filename}")


def check_report(root, family, report, expected):
    if report.get("matches") is not True or not isinstance(report.get("blocks"), dict):
        raise ValueError(f"Incomplete comparison: {family}")
    if set(report["blocks"]) != set(expected):
        raise ValueError(f"Comparison source inventory is stale: {family}")
    for name, metadata in expected.items():
        block = report["blocks"][name]
        source, start, end = metadata
        if block.get("source") != source:
            raise ValueError(f"Comparison source disagrees with current metadata: {family}/{name}")
        if (block.get("matches") is not True or block.get("different_words") != [] or
                block.get("actual_size") != end - start or block.get("expected_size") != end - start):
            raise ValueError(f"Incomplete target extent: {family}/{name}")
        required = {source, *local_headers(root / source, root)}
        if family != "assembly-comparison":
            required.update(SymbolLayoutSnapshot.files)
            required.update(("tools/compiler.py", "tools/owned_sections.py", "config/toolchain_files.json"))
            required.update(path.relative_to(root).as_posix() for path in (root / "include").glob("*.h"))
        check_inputs(root, block.get("inputs_sha256"), required)


def current_comparisons(functions):
    groups = defaultdict(list)
    for item in functions:
        groups[item["source"]].append(item)
    families = {}
    for family, definitions in (("runtime-comparison", MATCHING_BLOCKS),
                                ("startup-comparison", STARTUP_BLOCKS)):
        expected = {}
        for name, source, start, end in definitions:
            if name in expected or source not in groups:
                raise ValueError(f"Comparison refers to stale source metadata: {source}")
            records = groups[source]
            bounds = (min(item["section_vram"] for item in records),
                      max(item["vram"] + item["size"] for item in records))
            if (start != bounds[0] or end < bounds[1] or
                    any(item.get("language", "C") != "C" for item in records)):
                raise ValueError(f"Comparison extent disagrees with manifest: {source}")
            if any(item["source"] != source and start < item["vram"] + item["size"] and
                   item["vram"] < end for item in functions):
                raise ValueError(f"Comparison extent overlaps another source: {source}")
            expected[name] = (source, start, end)
        families[family] = expected
    return families, groups


def check_public_files(root, files, functions, owned):
    if not isinstance(files, list) or not files or len(set(files)) != len(files):
        raise ValueError("Provide a complete, unique public file inventory")
    required = {item[field] for item in functions for field in ("source", "evidence")}
    required.update(item["source"] for item in owned)
    required.update(item["evidence"] for item in owned)
    for source in {item["source"] for item in functions}:
        required.update(local_headers(root / source, root))
    required.update(("Makefile", "config/functions.json", "config/owned_sections.json",
                     "config/target.json", "config/startup_symbols.ld", "config/runtime_symbols.ld",
                     "linker_scripts/us.ld"))
    if not required.issubset(files):
        raise ValueError("Public file inventory omits current source, headers, evidence, or build metadata")
    hashes = {}
    for filename in files:
        path = project_path(root, filename, "public file")
        if (filename.startswith(("src/libultra/", "baseroms/", "build/", ".local/")) or
                path.suffix.lower() in {".n64", ".v64", ".z64", ".bin", ".o", ".elf", ".a"}):
            raise ValueError(f"Research implementation or generated binary in public inventory: {filename}")
        if not path.is_file():
            raise ValueError(f"Public file is missing: {filename}")
        payload = path.read_bytes()
        if payload[:4].hex() in {"80371240", "37804012", "40123780"}:
            raise ValueError(f"ROM signature in public inventory: {filename}")
        hashes[filename] = hashlib.sha256(payload).hexdigest()
    return hashes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--files", type=Path, required=True,
                        help="JSON array of paths selected for this public checkpoint")
    parser.add_argument("--output", type=Path, default=ROOT / "build/publication-audit.json")
    args = parser.parse_args()
    functions = load_manifest()
    owned = load_owned_sections()
    validate_function_ranges(owned, functions)
    files = json.loads(args.files.read_text())
    hashes = check_public_files(ROOT, files, functions, owned)
    reports, groups = current_comparisons(functions)
    from compare_assembly import verify_procedures, verify_text_coverage
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    results = {}
    compared_sources = set()
    for family, expected in reports.items():
        path = ROOT / "build" / family / "report.json"
        report = json.loads(path.read_text())
        check_report(ROOT, family, report, expected)
        alignment_bytes = 0
        for name, block in report["blocks"].items():
            profile = profile_for_source(block["source"])
            if (block.get("compiler_profile") != profile or
                    block.get("toolchain_identity") != installed_identity(profile["version"])):
                raise ValueError(f"Stale compiler identity: {block['source']}")
            records = sorted(groups[block["source"]], key=lambda item: item["vram"])
            data = (ROOT / "build" / family / name / f"{name}.bin").read_bytes()
            start = records[0]["rom"] - (records[0]["vram"] - records[0]["section_vram"])
            if len(data) != block["actual_size"] or data != target[start:start + len(data)]:
                raise ValueError(f"Independent linked bytes changed: {family}/{name}")
            alignment_bytes += verify_text_coverage(data, records)
            compared_sources.add(block["source"])
        results[family] = {"units": len(expected), "text_bytes": sum(end-start for _, start, end in expected.values()),
                           "alignment_bytes": alignment_bytes,
                           "report_sha256": sha256(path)}

    from owned_sections import elf_sections_and_symbols
    family = "assembly-comparison"
    path = ROOT / "build" / family / "report.json"
    report = json.loads(path.read_text())
    expected = {}
    for source, records in groups.items():
        if records[0].get("language", "C") != "assembly":
            continue
        records.sort(key=lambda item: item["vram"])
        obj = ROOT / "build" / family / Path(source).stem / "compiled.o"
        sections, _ = elf_sections_and_symbols(obj)
        text = sections[".text"]["bytes"]
        padding = verify_text_coverage(text, records)
        verify_procedures(obj, records)
        block = report.get("blocks", {}).get(source, {})
        if (block.get("live_bytes") != sum(item["size"] for item in records) or
                block.get("function_count") != len(records) or block.get("alignment_bytes") != padding):
            raise ValueError(f"Assembly procedure metadata is stale: {source}")
        start = records[0]["section_vram"]
        data = (obj.parent / "compiled.bin").read_bytes()
        rom_start = records[0]["rom"] - (records[0]["vram"] - start)
        if len(data) != len(text) or data != target[rom_start:rom_start + len(data)]:
            raise ValueError(f"Independent assembly bytes changed: {source}")
        expected[source] = (source, start, start + len(text))
    check_report(ROOT, family, report, expected)
    results[family] = {"units": len(expected), "text_bytes": sum(end-start for _, start, end in expected.values()),
                       "report_sha256": sha256(path)}

    from progress import measure
    saved = json.loads((ROOT / "build/us/progress.json").read_text())
    check_progress(saved, functions, owned)
    measured = measure()
    check_progress(measured, functions, owned)
    if measured != saved:
        raise ValueError("Saved progress no longer describes the current build")
    if check_public_files(ROOT, files, functions, owned) != hashes:
        raise ValueError("Public inputs changed during the audit")
    summary = {
        "progress": expected_progress(functions, owned),
        "rom_sha256": sha256(ROOT / "build/us/robotron64.z64"),
        "independent_comparisons": results,
        "additional_sources_verified_by_build": sorted(source for source, records in groups.items()
            if records[0].get("language", "C") == "C" and source not in compared_sources),
        "public_file_count": len(files),
        "public_files_sha256": hashes,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps({key: value for key, value in summary.items() if key != "public_files_sha256"}, indent=2))


if __name__ == "__main__":
    main()
