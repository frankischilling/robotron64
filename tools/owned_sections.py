"""Validate and place data/BSS emitted by recovered C translation units."""

import json
from pathlib import Path
import re
import struct

from rom import ROOT
from trim_padding import trim
from manifest import project_path


IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z_0-9]*$")
SECTION = re.compile(r"\.[A-Za-z_][A-Za-z_0-9]*$")
ENCODED_ADDRESS = re.compile(r"D_(?:FLT_|DBL_)?([0-9A-Fa-f]{8})$")


def load_owned_sections(path=None, root=ROOT):
    root = Path(root).resolve()
    path = Path(path) if path is not None else root / "config/owned_sections.json"
    records = json.loads(path.read_text())
    if not isinstance(records, list):
        raise ValueError("Owned sections must be a list")
    names, inputs, symbols, static_symbols = set(), set(), set(), set()
    vram_ranges, rom_ranges = [], []
    for record in records:
        if not isinstance(record, dict):
            raise ValueError("Invalid owned section record")
        for key in ("source", "object", "evidence"):
            value = record.get(key)
            resolved = project_path(root, value, key)
            if key != "object" and not resolved.is_file():
                raise ValueError(f"Missing owned section {key}: {value}")
        if not record["source"].startswith("src/") or not record["source"].endswith(".c"):
            raise ValueError("Owned section source must be reconstructed C")
        if not record["object"].startswith("build/us/") or not record["object"].endswith(".o"):
            raise ValueError("Invalid owned section object path")
        name = record.get("section")
        if not isinstance(name, str) or not SECTION.fullmatch(name) or name in names:
            raise ValueError("Invalid or duplicate owned output section")
        names.add(name)
        input_section = record.get("input_section")
        if input_section not in (".data", ".rodata", ".bss"):
            raise ValueError("Invalid owned input section")
        key = (record["source"], input_section)
        if key in inputs:
            raise ValueError("Duplicate source input section")
        inputs.add(key)
        start, size = record.get("vram"), record.get("size")
        if type(start) is not int or type(size) is not int or size <= 0 or not (
                0 <= start < start + size <= 0x100000000):
            raise ValueError("Invalid owned section runtime range")
        vram_ranges.append((start, start + size, name))
        rom = record.get("rom")
        if input_section == ".bss":
            if rom is not None:
                raise ValueError("BSS must not claim ROM bytes")
        else:
            if type(rom) is not int or rom < 0 or rom + size > 0x800000:
                raise ValueError("Invalid owned section ROM range")
            rom_ranges.append((rom, rom + size, name))
        definitions = record.get("symbols")
        static_definitions = record.get("static_symbols", {})
        if (not isinstance(definitions, dict) or not isinstance(static_definitions, dict)
                or (not definitions and not static_definitions and input_section != ".rodata")):
            raise ValueError("Owned sections must record their source definitions")
        for symbol, offset in definitions.items():
            if not IDENTIFIER.fullmatch(symbol) or symbol in symbols:
                raise ValueError("Invalid or duplicate owned symbol")
            symbols.add(symbol)
            if type(offset) is not int or not 0 <= offset < size:
                raise ValueError("Owned symbol lies outside its section")
            encoded = ENCODED_ADDRESS.fullmatch(symbol)
            if encoded and int(encoded[1], 16) != start + offset:
                raise ValueError("Owned symbol address disagrees with its name")
        for symbol, offset in static_definitions.items():
            key = (record["source"], symbol)
            if not IDENTIFIER.fullmatch(symbol) or key in static_symbols or symbol in definitions:
                raise ValueError("Invalid or ambiguous source-private symbol")
            static_symbols.add(key)
            if type(offset) is not int or not 0 <= offset < size:
                raise ValueError("Source-private symbol lies outside its section")
            encoded = ENCODED_ADDRESS.fullmatch(symbol)
            if encoded and int(encoded[1], 16) != start + offset:
                raise ValueError("Source-private symbol address disagrees with its name")
    for ranges in (vram_ranges, rom_ranges):
        ranges.sort()
        for previous, current in zip(ranges, ranges[1:]):
            if previous[1] > current[0]:
                raise ValueError("Owned section ranges overlap")
    return records


def source_sections(source):
    return [record for record in load_owned_sections() if record["source"] == source]


def trim_owned_sections(contents, records):
    for record in records:
        contents = trim(contents, record["input_section"], record["size"])
    return contents


def linker_placements(records):
    declarations = []
    for record in records:
        if record["rom"] is None:
            location = " (NOLOAD) :"
        else:
            location = f' : AT(0x{record["rom"]:X})'
        declarations.append(
            f'{record["section"]} 0x{record["vram"]:X}{location} '
            f'SUBALIGN(4) {{ *({record["input_section"]}) }}')
    return "\n".join(declarations)


def elf_sections_and_symbols(path):
    data = Path(path).read_bytes()
    if len(data) < 52 or data[:6] != b"\x7fELF\x01\x02":
        raise ValueError("Expected ELF32 big-endian input")
    offset = struct.unpack_from(">I", data, 32)[0]
    stride, count, names_index = struct.unpack_from(">HHH", data, 46)
    if stride != 40 or offset + count * stride > len(data) or names_index >= count:
        raise ValueError("Invalid ELF section table")
    raw_sections = [struct.unpack_from(">10I", data, offset + i * stride)
                    for i in range(count)]

    def payload(section):
        start, length = section[4:6]
        if start + length > len(data):
            raise ValueError("Truncated ELF section")
        return data[start:start + length]

    names = payload(raw_sections[names_index])

    def string(table, start):
        if start >= len(table) or b"\0" not in table[start:]:
            raise ValueError("Invalid ELF string offset")
        return table[start:].split(b"\0", 1)[0].decode("ascii")

    sections = {}
    by_index = {}
    for index, section in enumerate(raw_sections):
        name = string(names, section[0])
        if name in sections:
            raise ValueError("Duplicate ELF section name")
        sections[name] = {"index": index, "type": section[1], "flags": section[2],
                          "address": section[3], "offset": section[4], "size": section[5],
                          "bytes": None if section[1] == 8 else payload(section)}
        by_index[index] = name
    symbols = {}
    for section in raw_sections:
        if section[1] != 2:
            continue
        if section[6] >= count or section[5] % 16:
            raise ValueError("Malformed ELF symbol table")
        strings = payload(raw_sections[section[6]])
        entries = payload(section)
        for position in range(0, len(entries), 16):
            name, value, size, info, other, index = struct.unpack_from(
                ">IIIBBH", entries, position)
            if info >> 4 == 0:
                continue
            name = string(strings, name)
            if name in symbols:
                raise ValueError("Duplicate global ELF symbol")
            symbols[name] = {"value": value, "size": size, "type": info & 15,
                             "section": by_index.get(index), "index": index}
    return sections, symbols


def verify_owned_section(record, sections, symbols, target=None, linked=True, local_definitions=None):
    section_name = record["section"] if linked else record["input_section"]
    section = sections.get(section_name)
    expected_type = 8 if record["rom"] is None else 1
    if section is None or section["type"] != expected_type or section["size"] != record["size"]:
        raise ValueError(f"Owned section type/size mismatch: {section_name}")
    if record["input_section"] == ".rodata" and section["flags"] & 1:
        raise ValueError(f"Owned read-only section is writable: {section_name}")
    base = record["vram"] if linked else 0
    if section["address"] != base:
        raise ValueError(f"Owned section runtime address mismatch: {section_name}")
    definitions = {name for name, symbol in symbols.items()
                   if symbol["section"] == section_name and symbol["type"] == 1}
    if definitions != set(record["symbols"]):
        raise ValueError(f"Unrecorded or missing source-owned definitions: {section_name}")
    for name, offset in record["symbols"].items():
        symbol = symbols.get(name)
        if symbol is None or symbol["type"] != 1 or symbol["section"] != section_name or (
                symbol["value"] != base + offset):
            raise ValueError(f"Source-owned symbol was displaced or overridden: {name}")
    if not linked:
        expected_private = record.get("static_symbols", {})
        actual_private = {name: offset for name, (section, offset) in (local_definitions or {}).items()
                          if section == record["input_section"]}
        if actual_private != expected_private:
            raise ValueError(f"Unrecorded or displaced source-private definitions: {section_name}")
    if linked and target is not None and record["rom"] is not None:
        start = record["rom"]
        if section["bytes"] != target[start:start + record["size"]]:
            raise ValueError(f"Owned data bytes differ: {section_name}")


def verify_owned_binary(path, records, target=None, linked=True):
    if not records:
        return
    sections, symbols = elf_sections_and_symbols(path)
    private = {}
    if not linked and ".mdebug" in sections:
        from ido_symbols import local_data
        private = local_data(path)
    for record in records:
        verify_owned_section(record, sections, symbols, target, linked, private)


def validate_function_ranges(records, functions):
    """Data ownership may not overlap code or disagree about a source object."""
    for record in records:
        for function in functions:
            if record["source"] == function["source"] and record["object"] != function["object"]:
                raise ValueError("Source has conflicting function/data object ownership")
            if record["object"] == function["object"] and record["source"] != function["source"]:
                raise ValueError("Object has conflicting function/data source ownership")
            if (record["vram"] < function["vram"] + function["size"] and
                    function["vram"] < record["vram"] + record["size"]):
                raise ValueError("Owned data/BSS overlaps a function runtime range")
            if record["rom"] is not None and (
                    record["rom"] < function["rom"] + function["size"] and
                    function["rom"] < record["rom"] + record["size"]):
                raise ValueError("Owned data overlaps a function ROM range")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    records = source_sections(args.source)
    args.output.write_bytes(trim_owned_sections(args.input.read_bytes(), records))
    verify_owned_binary(args.output, records, linked=False)
