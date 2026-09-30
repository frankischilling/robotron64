"""Reconstruct the SDK quarter-wave table from its verified mathematical rule."""

import argparse
from decimal import Decimal, localcontext
from pathlib import Path


PI = Decimal("3.141592653589793238462643383279502884197169399375105820974944592")
ROOT = Path(__file__).resolve().parents[1]


def sine(angle):
    term = result = angle
    square = angle * angle
    index = 1
    while abs(term) >= Decimal("1e-70"):
        term *= -square / ((2 * index) * (2 * index + 1))
        result += term
        index += 1
    return result


def table_values():
    with localcontext() as context:
        context.prec = 80
        values = [0]
        values.extend(int(Decimal(32767) * sine(PI * index / 2046))
                      for index in range(1, 1023))
        values.append(32767)
    return values


def render_table():
    values = table_values()
    rows = ["    " + ", ".join(str(value) for value in values[index:index + 16]) + ","
            for index in range(0, len(values), 16)]
    return ("/* floor(32767 * sin(index * pi / 2046)), including both endpoints. */\n"
            "short D_8008DBB0[1024] = {\n" + "\n".join(rows) + "\n};\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="check the declaration committed in src/sdk/short_sine.c")
    args = parser.parse_args()
    rendered = render_table()
    if args.check:
        if not (ROOT / "src/sdk/short_sine.c").read_text().endswith(rendered):
            raise SystemExit("Short sine table differs from its mathematical reconstruction")
        print("Verified all 1024 generated short sine entries")
    else:
        print(rendered, end="")


if __name__ == "__main__":
    main()
