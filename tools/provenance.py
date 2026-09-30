"""Record build inputs and reject stale or misattributed matching objects."""

import argparse
import hashlib
import json
import re

from manifest import project_path
from rom import ROOT
from compiler import profile_for_source
from toolchain import installed_identity


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def object_record(path):
    return path.with_name(path.name + ".provenance.json")


def local_headers(source_path, root):
    """Find the transitive quoted includes used by this project's C sources."""
    headers = set()
    pending = [source_path]
    while pending:
        current = pending.pop()
        for include in re.findall(r'^\s*#\s*include\s*"([^"\n]+)"',
                                  current.read_text(), re.MULTILINE):
            header = (current.parent / include).resolve()
            if not header.is_relative_to(root):
                raise ValueError(f"Local include leaves the project: {include}")
            if not header.is_file():
                raise ValueError(f"Missing local header: {header.relative_to(root)}")
            name = header.relative_to(root).as_posix()
            if name not in headers:
                headers.add(name)
                pending.append(header)
    return headers


def require_local_headers(source_path, inputs, root):
    missing = local_headers(source_path, root) - set(inputs)
    if missing:
        raise ValueError(f"Build provenance omits local header: {', '.join(sorted(missing))}")


def record(source, object_name, headers=(), root=ROOT):
    root = root.resolve()
    source_path = project_path(root, source, "source")
    object_path = project_path(root, object_name, "object")
    inputs = [source_path] + [project_path(root, header, "header") for header in headers]
    metadata = {
        "source": source_path.relative_to(root).as_posix(),
        "object": object_path.relative_to(root).as_posix(),
        "object_sha256": digest(object_path),
        "inputs": {path.relative_to(root).as_posix(): digest(path) for path in inputs},
    }
    if source_path.suffix == ".c":
        metadata["compiler_profile"] = profile_for_source(metadata["source"])
        metadata["toolchain_identity"] = installed_identity(metadata["compiler_profile"]["version"])
    require_local_headers(source_path, metadata["inputs"], root)
    object_record(object_path).write_text(json.dumps(metadata, indent=2) + "\n")


def verify_record(source, object_name, root=ROOT):
    root = root.resolve()
    source_path = project_path(root, source, "source")
    object_path = project_path(root, object_name, "object")
    metadata_path = object_record(object_path)
    if not metadata_path.is_file():
        raise ValueError(f"Missing build provenance for {object_name}; rebuild the object")
    metadata = json.loads(metadata_path.read_text())
    expected_source = source_path.relative_to(root).as_posix()
    expected_object = object_path.relative_to(root).as_posix()
    if metadata.get("source") != expected_source:
        raise ValueError(f"Compiled source does not match the manifest for {object_name}")
    if source_path.suffix == ".c" and metadata.get("compiler_profile") != profile_for_source(expected_source):
        raise ValueError(f"Compiler profile changed; rebuild {object_name}")
    if source_path.suffix == ".c":
        identity = installed_identity(metadata["compiler_profile"]["version"])
        if metadata.get("toolchain_identity") != identity:
            raise ValueError(f"Compiler identity changed; rebuild {object_name}")
    if metadata.get("object") != expected_object:
        raise ValueError(f"Build provenance belongs to a different object: {object_name}")
    if metadata.get("object_sha256") != digest(object_path):
        raise ValueError(f"Object changed after its build was recorded: {object_name}")
    inputs = metadata.get("inputs", {})
    if not isinstance(inputs, dict) or expected_source not in inputs:
        raise ValueError(f"Build provenance omits the source input: {object_name}")
    require_local_headers(source_path, inputs, root)
    for name, expected_hash in inputs.items():
        path = project_path(root, name, "input")
        if not path.is_file() or digest(path) != expected_hash:
            raise ValueError(f"Build input changed: {name}; rebuild {object_name}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source")
    parser.add_argument("object")
    parser.add_argument("headers", nargs="*")
    args = parser.parse_args()
    record(args.source, args.object, args.headers)
