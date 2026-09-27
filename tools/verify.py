"""Compare complete ROMs or an explicitly selected byte range."""

import argparse
import hashlib
from pathlib import Path
from rom import normalize, validate


def compare(expected, actual):
    if expected == actual:
        return
    first = next((i for i, (a, b) in enumerate(zip(expected, actual)) if a != b),
                 min(len(expected), len(actual)))
    raise ValueError(f"Mismatch at relative offset 0x{first:X}; "
                     f"expected size {len(expected)}, actual size {len(actual)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baserom", type=Path)
    parser.add_argument("rebuilt", type=Path)
    parser.add_argument("--offset", type=lambda value: int(value, 0), default=0)
    parser.add_argument("--size", type=lambda value: int(value, 0))
    args = parser.parse_args()
    expected = normalize(args.baserom.read_bytes())
    validate(expected)
    actual = args.rebuilt.read_bytes()
    if args.size is not None:
        if args.offset < 0 or args.size <= 0 or args.offset + args.size > len(expected):
            parser.error("Range must be nonempty and within the target ROM")
        end = args.offset + args.size
        compare(expected[args.offset:end], actual[args.offset:end])
        print(f"Matched ROM range 0x{args.offset:X}..0x{end:X}")
    else:
        if args.offset:
            parser.error("--offset requires --size")
        compare(expected, actual)
        print(f"Matched all {len(actual)} bytes; SHA-256 {hashlib.sha256(actual).hexdigest()}")


if __name__ == "__main__":
    main()
