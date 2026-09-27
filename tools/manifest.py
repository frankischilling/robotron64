"""Check function metadata and evidence paths without requiring a ROM."""

import json
from pathlib import Path, PurePosixPath

from rom import ROOT


def project_path(root, value, field):
    if not isinstance(value, str) or not value or "\\" in value:
        raise ValueError(f"Invalid {field} path: {value!r}")
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts or ":" in value:
        raise ValueError(f"Expected a project-relative {field} path: {value!r}")
    resolved = (root / path).resolve()
    if not resolved.is_relative_to(root.resolve()):
        raise ValueError(f"{field} path leaves the project: {value}")
    return resolved


def validate_manifest(functions, rom_size, root=ROOT):
    if not isinstance(functions, list) or not functions:
        raise ValueError("Function manifest must be a nonempty list")
    names = set()
    ranges = []
    sections = {}
    object_sources = {}
    for index, function in enumerate(functions):
        if not isinstance(function, dict):
            raise ValueError(f"Function record {index} must be an object")
        for field in ("name", "source", "object", "section", "evidence"):
            if not isinstance(function.get(field), str) or not function[field]:
                raise ValueError(f"Function record {index} has no valid {field}")
        name = function["name"]
        if name in names:
            raise ValueError(f"Duplicate function name: {name}")
        names.add(name)
        language = function.get("language", "C")
        if language not in {"C", "assembly"}:
            raise ValueError(f"Unsupported source language for {name}: {language}")
        for field in ("rom", "vram", "size", "section_vram"):
            if type(function.get(field)) is not int:
                raise ValueError(f"{name}: {field} must be an integer")
        start, size = function["rom"], function["size"]
        end = start + size
        vram, section_vram = function["vram"], function["section_vram"]
        if start < 0 or size <= 0 or end > rom_size:
            raise ValueError(f"Invalid ROM range: {name}")
        if not 0 <= section_vram <= vram or vram + size > 0x100000000:
            raise ValueError(f"Invalid runtime range: {name}")
        if any(value % 4 for value in (start, size, vram, section_vram)):
            raise ValueError(f"Unaligned MIPS function range: {name}")
        if any(start < previous_end and previous_start < end
               for previous_start, previous_end in ranges):
            raise ValueError(f"Overlapping function ROM range: {name}")
        ranges.append((start, end))
        placement = (section_vram, start - (vram - section_vram))
        section = function["section"]
        if placement[1] < 0 or sections.setdefault(section, placement) != placement:
            raise ValueError(f"Inconsistent section placement: {name}")
        for field in ("source", "evidence"):
            path = project_path(root, function[field], field)
            if not path.is_file():
                raise ValueError(f"Missing {field} for {name}: {function[field]}")
        source_suffix = Path(function["source"]).suffix
        expected_suffixes = {".c"} if language == "C" else {".s", ".S"}
        if source_suffix not in expected_suffixes:
            raise ValueError(f"Source language and file extension disagree: {name}")
        object_path = project_path(root, function["object"], "object")
        if object_path.suffix != ".o":
            raise ValueError(f"Expected an object file for {name}")
        source_path = project_path(root, function["source"], "source")
        if object_sources.setdefault(object_path, source_path) != source_path:
            raise ValueError(f"Conflicting source files for object: {function['object']}")
    return functions


def load_manifest(root=ROOT):
    functions = json.loads((root / "config/functions.json").read_text())
    target = json.loads((root / "config/target.json").read_text())
    return validate_manifest(functions, target["size"], root)


if __name__ == "__main__":
    records = load_manifest()
    print(f"Validated {len(records)} function records and their source/evidence paths; "
          "binary matching requires the local ROM build")
