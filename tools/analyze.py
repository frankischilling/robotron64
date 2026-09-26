"""Generate a local disassembly and explicitly provisional function inventory."""

import csv
from importlib.metadata import version
import json
from pathlib import Path
import subprocess
import sys
from rom import ROOT, validate


def seed_symbols():
    integrated = {item["name"]: item for item in json.loads((ROOT / "config/functions.json").read_text())}
    lines = []
    for symbol in json.loads((ROOT / "config/symbols.json").read_text()):
        name = symbol["name"]
        attributes = []
        if not name.startswith("D_"):
            attributes.append("type:func")
        if name in integrated:
            attributes.append(f"size:0x{integrated[name]['size']:X}")
        if "rom" in symbol:
            attributes.append(f"rom:{symbol['rom']}")
        lines.append(f"{name} = {symbol['vram']}; // {' '.join(attributes)}")
    return "\n".join(lines) + "\n"


def run():
    pinned = {"spimdisasm": "1.42.4", "rabbitizer": "1.16.2"}
    for package, expected in pinned.items():
        if version(package) != expected:
            raise SystemExit(f"Install requirements-analysis.txt: {package} must be {expected}")
    target = ROOT / "baseroms/us/baserom.z64"
    data = target.read_bytes()
    validate(data)
    layout = json.loads((ROOT / "config/analysis.json").read_text())
    output = ROOT / "build/analysis"
    output.mkdir(parents=True, exist_ok=True)
    symbols = output / "symbols.txt"
    symbols.write_text(seed_symbols())
    cpu = layout["cpu"]
    subprocess.run([sys.executable, "-m", "spimdisasm", "singleFileDisasm", str(target),
                    str(output / "cpu"), "--start", hex(cpu["rom_start"]),
                    "--end", hex(cpu["rom_end"]), "--vram", hex(cpu["vram_start"]),
                    "--function-info", str(output / "functions.csv"),
                    "--save-context", str(output / "context.csv"),
                    "--symbol-addrs", str(symbols), "--no-ique-syms", "--no-libultra-syms",
                    "--quiet"], check=True)
    rsp = layout["rsp_boot"]
    binary = output / "rspboot.bin"
    binary.write_bytes(data[rsp["rom_start"]:rsp["rom_end"]])
    subprocess.run([sys.executable, "-m", "spimdisasm", "rspDisasm", str(binary),
                    str(output / "rspboot"), "--vram", hex(rsp["vram_start"]), "--quiet"], check=True)
    with (output / "functions.csv").open(newline="") as stream:
        candidates = list(csv.DictReader(stream))
    report = {
        "tools": pinned,
        "cpu_rom_start": hex(cpu["rom_start"]),
        "cpu_rom_end": hex(cpu["rom_end"]),
        "candidate_cpu_region_bytes": cpu["rom_end"] - cpu["rom_start"],
        "candidate_function_records": len(candidates),
        "sum_candidate_record_lengths": sum(int(item["length"], 16) for item in candidates),
        "counts_are_provisional": True,
        "used_for_matching_percentage": False,
        "note": "Records may include padding, merged functions, or unrecognized data. This is not a verified code/function total.",
    }
    encoded = json.dumps(report, indent=2) + "\n"
    (output / "summary.json").write_text(encoded)
    print(encoded, end="")


if __name__ == "__main__":
    run()
