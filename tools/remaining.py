"""Inventory unresolved CPU-region bytes without treating them all as code."""

import argparse
import json
from pathlib import Path

from extract import REGIONS
from manifest import load_manifest
from owned_sections import load_owned_sections, validate_function_ranges
from rom import ROOT


NOTE = ("This is a layout inventory, not binary matching evidence or a source "
        "completion percentage. The candidate CPU range and fallback spans may "
        "contain data or padding. Function and executable-byte denominators "
        "remain unknown. BSS consumes no ROM bytes and is excluded.")


def partition(cpu, records):
    """Clip disjoint ownership intervals to the candidate range and find gaps."""
    for key in ("rom_start", "rom_end", "vram_start"):
        if type(cpu.get(key)) is not int:
            raise ValueError(f"CPU {key} must be an integer")
    start, end, vram = cpu["rom_start"], cpu["rom_end"], cpu["vram_start"]
    if start < 0 or end <= start or vram < 0 or vram + end - start > 0x100000000:
        raise ValueError("Invalid candidate CPU range")
    intervals = []
    for item in records:
        first, last = item["rom_start"], item["rom_end"]
        if type(first) is not int or type(last) is not int or first < 0 or last <= first:
            raise ValueError(f"Invalid interval: {item['name']}")
        if last <= start or first >= end:
            continue
        first, last = max(first, start), min(last, end)
        intervals.append(dict(item, rom_start=first, rom_end=last,
                              vram_start=vram + first - start,
                              vram_end=vram + last - start, bytes=last - first))
    intervals.sort(key=lambda item: (item["rom_start"], item["rom_end"], item["name"]))
    cursor = start
    gaps = []
    previous = "candidate start"
    for item in intervals:
        first, last = item["rom_start"], item["rom_end"]
        if first < cursor:
            raise ValueError(f"Overlapping CPU ownership: {previous} and {item['name']}")
        if first > cursor:
            gaps.append({"rom_start": cursor, "rom_end": first,
                         "vram_start": vram + cursor - start,
                         "vram_end": vram + first - start, "bytes": first - cursor})
        cursor, previous = last, item["name"]
    if cursor < end:
        gaps.append({"rom_start": cursor, "rom_end": end,
                     "vram_start": vram + cursor - start,
                     "vram_end": vram + end - start, "bytes": end - cursor})
    return intervals, gaps


def inventory(cpu, functions, owned, regions):
    records = []
    for function in functions:
        language = function.get("language", "C")
        if language not in {"C", "assembly"}:
            raise ValueError(f"Unsupported function language: {language}")
        records.append({"name": function["name"], "kind": language,
                        "rom_start": function["rom"],
                        "rom_end": function["rom"] + function["size"],
                        "source": function["source"]})
    for section in owned:
        if section["rom"] is not None:
            records.append({"name": section["section"], "kind": "initialized_data",
                            "rom_start": section["rom"],
                            "rom_end": section["rom"] + section["size"],
                            "source": section["source"]})
    records.extend({"name": name, "kind": "fallback", "rom_start": start,
                    "rom_end": end} for name, start, end in regions)
    intervals, gaps = partition(cpu, records)
    totals = {kind: sum(item["bytes"] for item in intervals if item["kind"] == kind)
              for kind in ("C", "assembly", "initialized_data", "fallback")}
    totals["unclassified"] = sum(item["bytes"] for item in gaps)
    totals["candidate_range"] = cpu["rom_end"] - cpu["rom_start"]
    if sum(totals[kind] for kind in ("C", "assembly", "initialized_data",
                                    "fallback", "unclassified")) != totals["candidate_range"]:
        raise ValueError("CPU ownership does not account for the candidate range")
    fallback = [item for item in intervals if item["kind"] == "fallback"]
    return {"candidate_cpu": cpu, "declared_bytes": totals,
            "fallback_range_count": len(fallback),
            "fallback_ranges": sorted(fallback, key=lambda item: (-item["bytes"], item["rom_start"])),
            "unclassified_ranges": gaps, "total_code_bytes": None,
            "total_functions": None, "matching_code_percent": None, "note": NOTE}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "build/us/remaining.json")
    parser.add_argument("--limit", type=int, default=20,
                        help="number of largest fallback ranges to display")
    args = parser.parse_args()
    if args.limit < 0:
        parser.error("--limit must be nonnegative")
    cpu = json.loads((ROOT / "config/analysis.json").read_text())["cpu"]
    functions, owned = load_manifest(), load_owned_sections()
    validate_function_ranges(owned, functions)
    report = inventory(cpu, functions, owned, REGIONS)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    totals = report["declared_bytes"]
    print(f"Candidate CPU range: {totals['candidate_range']:,} bytes")
    print(f"Declared C: {totals['C']:,}; assembly: {totals['assembly']:,}; "
          f"initialized data: {totals['initialized_data']:,}")
    print(f"Fallback: {totals['fallback']:,} bytes in {report['fallback_range_count']} ranges; "
          f"unclassified: {totals['unclassified']:,} bytes")
    print("Bytes     ROM range          VRAM range                  Fallback")
    for item in report["fallback_ranges"][:args.limit]:
        print(f"{item['bytes']:7d}   {item['rom_start']:06X}..{item['rom_end']:06X}   "
              f"{item['vram_start']:08X}..{item['vram_end']:08X}   {item['name']}")
    print(NOTE)


if __name__ == "__main__":
    main()
