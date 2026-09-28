"""Inspect, extract and rebuild the named resources in a user-provided ROM."""

import argparse
from collections import Counter
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path, PurePosixPath
import struct

from rom import ROOT, normalize, validate

DIRECTORY_OFFSET = 0x97E90
ENTRY_SIZE = 32


@dataclass(frozen=True)
class Resource:
    index: int
    name: str
    metadata: int
    offset: int
    size: int


def resource_path(name):
    """Convert a retail name to a relative, portable extraction path."""
    parts = name.replace("\\", "/").split("/")
    if not name or any(part in ("", ".", "..") for part in parts):
        raise ValueError(f"Invalid resource name: {name!r}")
    for part in parts:
        if any(ord(char) < 32 or char in ':*?"<>|' for char in part):
            raise ValueError(f"Invalid resource name: {name!r}")
        if part.endswith((".", " ")):
            raise ValueError(f"Invalid resource name: {name!r}")
        if part.split(".", 1)[0].upper() in {
            "CON", "PRN", "AUX", "NUL",
            *(f"COM{i}" for i in range(1, 10)),
            *(f"LPT{i}" for i in range(1, 10)),
        }:
            raise ValueError(f"Invalid resource name: {name!r}")
    return PurePosixPath(*parts)


def parse_directory(data, base=DIRECTORY_OFFSET):
    if base < 0 or base + 4 > len(data):
        raise ValueError("Resource directory header is outside the ROM")
    count = struct.unpack_from("<I", data, base)[0]
    if count > (len(data) - base - 4) // ENTRY_SIZE:
        raise ValueError("Resource directory entries extend beyond the ROM")
    end = base + 4 + count * ENTRY_SIZE
    resources = []
    paths = set()
    for index in range(count):
        entry = base + 4 + index * ENTRY_SIZE
        raw_name = data[entry + 1:entry + 24]
        if b"\0" not in raw_name:
            raise ValueError(f"Resource {index} has no name terminator")
        try:
            name = raw_name.split(b"\0", 1)[0].decode("ascii")
        except UnicodeDecodeError as error:
            raise ValueError(f"Resource {index} has a non-ASCII name") from error
        path = resource_path(name).as_posix().casefold()
        if path in paths:
            raise ValueError(f"Resource path occurs more than once: {name}")
        paths.add(path)
        relative, size = struct.unpack_from("<II", data, entry + 24)
        offset = base + relative
        if offset < end or offset + size > len(data):
            raise ValueError(f"Resource {index} payload is outside the data area")
        resources.append(Resource(index, name, data[entry], offset, size))
    for path in paths:
        if any(parent.as_posix() in paths for parent in PurePosixPath(path).parents):
            raise ValueError(f"Resource file conflicts with a directory: {path}")
    previous_end = end
    for resource in sorted(resources, key=lambda value: value.offset):
        if resource.offset < previous_end:
            raise ValueError(f"Resource payloads overlap at {resource.name}")
        previous_end = resource.offset + resource.size
    return resources


def inventory(data, resources, base=DIRECTORY_OFFSET):
    extensions = Counter(resource_path(item.name).suffix for item in resources)
    directories = Counter(resource_path(item.name).parts[0]
                          if len(resource_path(item.name).parts) > 1 else "/"
                          for item in resources)
    entries = []
    for item in resources:
        payload = data[item.offset:item.offset + item.size]
        entries.append({
            "index": item.index,
            "name": item.name,
            "path": resource_path(item.name).as_posix(),
            "metadata": item.metadata,
            "rom_start": item.offset,
            "rom_end": item.offset + item.size,
            "size": item.size,
            "sha256": hashlib.sha256(payload).hexdigest(),
        })
    return {
        "rom_sha256": hashlib.sha256(data).hexdigest(),
        "directory_start": base,
        "directory_end": base + 4 + len(resources) * ENTRY_SIZE,
        "resource_count": len(resources),
        "payload_bytes": sum(item.size for item in resources),
        "directories": dict(sorted(directories.items())),
        "extensions": dict(sorted(extensions.items())),
        "resources": entries,
    }


def payload_path(directory, name):
    root = Path(directory).resolve()
    path = root.joinpath(*resource_path(name).parts)
    if not path.resolve().is_relative_to(root):
        raise ValueError(f"Resource path leaves the output directory: {name}")
    return path


def extract(data, resources, directory):
    """Write original payloads; preserve a conflicting existing extraction."""
    destinations = []
    for item in resources:
        path = payload_path(directory, item.name)
        payload = data[item.offset:item.offset + item.size]
        if path.exists() and (not path.is_file() or path.read_bytes() != payload):
            raise ValueError(f"Existing extracted resource differs: {item.name}")
        destinations.append((path, payload))
    for path, payload in destinations:
        if not path.exists():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(payload)


def rebuild(data, resources, directory):
    """Replace fixed-size payloads while preserving directory and padding bytes."""
    output = bytearray(data)
    for item in resources:
        path = payload_path(directory, item.name)
        if not path.is_file():
            raise ValueError(f"Missing extracted resource: {item.name}")
        payload = path.read_bytes()
        if len(payload) != item.size:
            raise ValueError(f"Resource size changed: {item.name}")
        output[item.offset:item.offset + item.size] = payload
    return bytes(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", nargs="?", type=Path,
                        default=ROOT / "baseroms/us/baserom.z64")
    parser.add_argument("--report", type=Path,
                        default=ROOT / "build/analysis/resources.json")
    parser.add_argument("--extract", dest="extract_directory", type=Path)
    parser.add_argument("--rebuild-from", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if bool(args.rebuild_from) != bool(args.output):
        parser.error("--rebuild-from and --output must be used together")
    if args.output and args.output.resolve() == args.rom.resolve():
        parser.error("The rebuilt ROM must differ from the original ROM path")
    if args.report.resolve() == args.rom.resolve():
        parser.error("The report must differ from the original ROM path")
    if args.output and args.report.resolve() == args.output.resolve():
        parser.error("The report and rebuilt ROM need separate output paths")
    data = normalize(args.rom.read_bytes())
    validate(data)
    resources = parse_directory(data)
    report = inventory(data, resources)
    if args.extract_directory:
        extract(data, resources, args.extract_directory)
    if args.rebuild_from:
        output = rebuild(data, resources, args.rebuild_from)
        if args.output.exists():
            if args.output.read_bytes() != output:
                raise ValueError("The rebuilt ROM output already contains different data")
        else:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_bytes(output)
        report["rebuilt_sha256"] = hashlib.sha256(output).hexdigest()
        report["rebuilt_matches"] = output == data
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(f"Resources: {len(resources)}; payload bytes: {report['payload_bytes']}")
    if "rebuilt_matches" in report:
        print(f"Rebuilt ROM matches: {report['rebuilt_matches']}")
    print(f"Report: {args.report}")


if __name__ == "__main__":
    main()
