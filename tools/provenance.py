"""Record build inputs and reject stale or misattributed matching objects."""

import argparse
import hashlib
import json

from manifest import project_path
from rom import ROOT


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def object_record(path):
    return path.with_name(path.name + ".provenance.json")


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
    if metadata.get("object") != expected_object:
        raise ValueError(f"Build provenance belongs to a different object: {object_name}")
    if metadata.get("object_sha256") != digest(object_path):
        raise ValueError(f"Object changed after its build was recorded: {object_name}")
    inputs = metadata.get("inputs", {})
    if not isinstance(inputs, dict) or expected_source not in inputs:
        raise ValueError(f"Build provenance omits the source input: {object_name}")
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
