"""Normalize and validate the user-supplied target without modifying its source."""

import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def normalize(data):
    if len(data) < 64 or len(data) % 4:
        raise ValueError("ROM must contain a header and complete 32-bit words")
    magic = data[:4].hex()
    if magic == "80371240":
        return data
    if magic == "37804012":
        out = bytearray(data)
        out[0::2], out[1::2] = data[1::2], data[0::2]
        return bytes(out)
    if magic == "40123780":
        out = bytearray(data)
        for i in range(4):
            out[i::4] = data[3 - i::4]
        return bytes(out)
    raise ValueError(f"Unknown N64 byte order: {magic}")


def validate(data):
    target = json.loads((ROOT / "config/target.json").read_text())
    if len(data) != target["size"]:
        raise ValueError(f"Wrong ROM size: {len(data)}")
    for algorithm in ("sha1", "sha256", "md5"):
        actual = hashlib.new(algorithm, data).hexdigest()
        if actual != target[algorithm]:
            raise ValueError(f"Target {algorithm} mismatch: {actual}")
    return target


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    data = normalize(args.input.read_bytes())
    target = validate(data)
    if args.output:
        if args.output.resolve() == args.input.resolve():
            parser.error("Output must differ from the original ROM")
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_bytes(data)
    print(json.dumps(target, indent=2))


if __name__ == "__main__":
    main()
