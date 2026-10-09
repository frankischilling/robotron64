"""Independently compile and verify the startup and scheduler source blocks."""

import hashlib
import json
import re
import subprocess
from manifest import load_manifest
from rom import ROOT, validate
from toolchain import install, installed_identity
from trim_padding import trim
from compiler import compile_source, profile_for_source, compiler_support_files
from provenance import local_headers
from owned_sections import (load_owned_sections, source_sections, trim_owned_sections,
                            linker_placements, verify_owned_binary)


ADDRESS_NAME = re.compile(r"(?:func_|D_(?:FLT_|DBL_)?)([0-9A-Fa-f]{8})$")

MATCHING_BLOCKS = (
    ("startup", "src/boot/startup.c", 0x80048170, 0x80048510),
    ("scheduler", "src/boot/scheduler.c", 0x80050440, 0x80050FB0),
)


def external_assignments(undefined, known):
    """Bind only unresolved references, never the functions being compared."""
    assignments = []
    for name in sorted(undefined):
        literal = ADDRESS_NAME.fullmatch(name)
        encoded = int(literal[1], 16) if literal else None
        address = known.get(name, encoded)
        if address is None:
            raise ValueError(f"No recorded address for external symbol: {name}")
        if encoded is not None and address != encoded:
            raise ValueError(f"Recorded address disagrees with symbol name: {name}")
        assignments.append(f"{name} = 0x{address:X};\n")
    return "".join(assignments)


def symbol_addresses(root=ROOT):
    addresses = {}
    for filename in ("config/startup_symbols.ld", "config/runtime_symbols.ld"):
        for name, value in re.findall(r"^([\w]+)\s*=\s*(0x[\da-fA-F]+);",
                                      (root / filename).read_text(), re.MULTILINE):
            address = int(value, 16)
            if addresses.setdefault(name, address) != address:
                raise ValueError(f"Conflicting recorded address: {name}")
    for function in load_manifest(root):
        name, address = function["name"], function["vram"]
        if name in addresses:
            raise ValueError(f"Source-owned function has an absolute binding: {name}")
        addresses[name] = address
    for record in load_owned_sections(root=root):
        for name, offset in record["symbols"].items():
            if name in addresses:
                raise ValueError(f"Source-owned data has an absolute or function alias: {name}")
            addresses[name] = record["vram"] + offset
    return addresses


class SymbolLayoutSnapshot:
    """Validate one layout and reject changes before any subsequent comparison."""

    files = ("config/startup_symbols.ld", "config/runtime_symbols.ld",
             "config/functions.json", "config/owned_sections.json")

    def __init__(self, root=ROOT):
        self.root = root
        self.hashes = self.current_hashes()
        self.addresses = symbol_addresses(root)
        self.verify()

    def current_hashes(self):
        return {name: hashlib.sha256((self.root / name).read_bytes()).hexdigest()
                for name in self.files}

    def verify(self):
        if self.current_hashes() != self.hashes:
            raise ValueError("Symbol layout changed during comparison; restart from the current inputs")


def comparison_input_hashes(source, root=ROOT):
    inputs = {source, "config/startup_symbols.ld", "config/runtime_symbols.ld",
              "config/functions.json", "tools/compiler.py", "config/toolchain_files.json",
              "config/owned_sections.json", "tools/owned_sections.py"}
    inputs.update(compiler_support_files(source))
    inputs.update(local_headers(root / source, root))
    inputs.update(path.relative_to(root).as_posix() for path in (root / "include").glob("*.h"))
    return {path: hashlib.sha256((root / path).read_bytes()).hexdigest()
            for path in sorted(inputs)}


def compare_block(name, source, vram, start, end, target, family="startup-comparison", layout=None):
    if source == "src/game/scene_resources/setup.c":
        if (vram, start, end) != (0x8001D3F0, 0x1DFF0, 0x1EA54):
            raise ValueError("Scene setup comparison must cover its complete retail range")
        from check_scene_resource_setup import compare_candidate_block
        layout = layout if layout is not None else SymbolLayoutSnapshot()
        return compare_candidate_block(name, source, target, layout, family)
    layout = layout if layout is not None else SymbolLayoutSnapshot()
    layout.verify()
    toolchain_identity = installed_identity(profile_for_source(source)["version"])
    directory = ROOT / "build" / family / name
    directory.mkdir(parents=True, exist_ok=True)
    raw_path = directory / f"{name}.raw.o"
    object_path = directory / f"{name}.o"
    elf_path = directory / f"{name}.elf"
    binary_path = directory / f"{name}.bin"
    input_hashes = comparison_input_hashes(source)
    compile_source(source, raw_path)
    raw = raw_path.read_bytes()
    owned = source_sections(source)
    raw = trim_owned_sections(raw, owned)
    try:
        compiled = trim(raw, ".text", end - start)
    except ValueError:
        # A candidate with live code beyond the range must remain a mismatch.
        compiled = raw
    object_path.write_bytes(compiled)
    verify_owned_binary(object_path, owned, linked=False)
    undefined = {line.split()[-1] for line in subprocess.check_output(
        ["mips-linux-gnu-nm", "-u", str(object_path)], text=True).splitlines() if line.strip()}
    script = directory / "candidate.ld"
    layout.verify()
    script.write_text(external_assignments(undefined, layout.addresses) +
                      f'SECTIONS {{ .text 0x{vram:X} : SUBALIGN(4) {{ *(.text) }} '
                      f'{linker_placements(owned)} }}\n')
    subprocess.run(["mips-linux-gnu-ld", "-T", str(script), "-e", f"func_{vram:08X}",
                    "-o", str(elf_path), str(object_path)],
                   check=True, cwd=ROOT)
    verify_owned_binary(elf_path, owned, target)
    subprocess.run(["mips-linux-gnu-objcopy", "-O", "binary", "-j", ".text",
                    str(elf_path), str(binary_path)], check=True)
    actual = binary_path.read_bytes()
    expected = target[start:end]
    layout.verify()
    for path, expected_hash in input_hashes.items():
        if hashlib.sha256((ROOT / path).read_bytes()).hexdigest() != expected_hash:
            raise ValueError(f"Build input changed during comparison: {path}")
    return {"source": source,
            "compiler_profile": profile_for_source(source),
            "toolchain_identity": toolchain_identity,
            "inputs_sha256": input_hashes,
            "expected_size": len(expected), "actual_size": len(actual),
            "matches": actual == expected,
            "different_words": [{"vram": hex(vram + i),
                                 "expected": expected[i:i + 4].hex(),
                                 "actual": actual[i:i + 4].hex()}
                                for i in range(0, max(len(actual), len(expected)), 4)
                                if expected[i:i + 4] != actual[i:i + 4]]}


def run():
    install("5.3")
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    blocks = {
        name: compare_block(name, source, start,
                            start - 0x80000000 + 0xC00,
                            end - 0x80000000 + 0xC00, target, layout=layout)
        for name, source, start, end in MATCHING_BLOCKS
    }
    report = {"matches": all(block["matches"] for block in blocks.values()), "blocks": blocks}
    encoded = json.dumps(report, indent=2) + "\n"
    (ROOT / "build/startup-comparison/report.json").write_text(encoded)
    print(encoded, end="")
    if not report["matches"]:
        raise SystemExit("Startup comparison failed; see build/startup-comparison/report.json")


if __name__ == "__main__":
    run()
