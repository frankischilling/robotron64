"""Reconstruct SDK video modes from confirmed timing and pixel-format parameters."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VARIANTS = ("LPN1", "LPF1", "LAN1", "LAF1", "LPN2", "LPF2", "LAN2", "LAF2",
            "HPN1", "HPF1", "HAN1", "HAF1", "HPN2", "HPF2")
REGIONS = {
    "NTSC": {"burst": (57, 34, 5, 62), "lines": 525, "h_sync": (3093, 0),
             "leap": (3093, 3093), "h_start": (108, 748), "v_start": (37, 511),
             "field_burst": (4, 2, 14, 0)},
    "PAL": {"burst": (58, 30, 4, 69), "lines": 625, "h_sync": (3177, 23),
            "leap": (3183, 3181), "h_start": (128, 768), "v_start": (95, 569),
            "field_burst": (107, 2, 9, 0)},
    "MPAL": {"burst": (57, 30, 5, 70), "lines": 525, "h_sync": (3089, 4),
             "leap": (3097, 3098), "h_start": (108, 748), "v_start": (37, 511),
             "field_burst": (4, 2, 14, 0)},
}


def pair(first, second):
    return first << 16 | second


def burst(width, color, sync, start):
    return width | color << 8 | sync << 16 | start << 20


def mode_words(region, variant):
    """Return the nineteen register words following the byte-sized mode type."""
    timing = REGIONS[region]
    name = VARIANTS[variant]
    high = name[0] == "H"
    filtered = name[2] == "F"
    antialias = name[1] == "A"
    bytes_per_pixel = 2 if name[-1] == "1" else 4
    interlaced = high or filtered
    aa_mode = 0 if antialias and (filtered or high or bytes_per_pixel == 4) else (
        0x100 if antialias else 0x300 if bytes_per_pixel == 4 and not filtered else 0x200)
    control = (0x3000 | (2 if bytes_per_pixel == 2 else 3) | 4 | 8 | aa_mode
               | (0x10 if antialias else 0) | (0x40 if interlaced else 0))
    width = (640 if filtered else 1280) if high else 320
    h_sync = timing["h_sync"]
    leap = timing["leap"]
    if region == "MPAL" and interlaced:
        h_sync = (3088, 0)
        leap = (3100, 3100)
    common = [control, width, burst(*timing["burst"]), timing["lines"] - interlaced,
              h_sync[0] | h_sync[1] << 16, pair(*leap), pair(*timing["h_start"]),
              1024 if high else 512, 0]
    fields = []
    for field in range(2):
        origin = (640 if high else 320) * bytes_per_pixel
        if high:
            origin *= field + 1
        scale = 0x02000800 if high and filtered else (
            ((1 if field == 0 else 3) << 24 | 1024) if filtered else 1024)
        start, end = timing["v_start"]
        if interlaced and field == 0:
            start -= 2
            end -= 2
        field_burst = timing["field_burst"]
        if interlaced and region == "PAL" and field == 1:
            field_burst = (105, 2, 13, 0)
        if interlaced and region == "MPAL" and field == 0:
            field_burst = (2, 2, 11, 0)
        fields += [origin, scale, pair(start, end), burst(*field_burst), 2]
    return common + fields


def initializer(region, variant):
    index = list(REGIONS).index(region) * 14 + variant
    words = mode_words(region, variant)
    common = ", ".join(f"0x{word:08X}" for word in words[:9])
    first = ", ".join(f"0x{word:08X}" for word in words[9:14])
    second = ", ".join(f"0x{word:08X}" for word in words[14:19])
    return (f"    /* {region}_{VARIANTS[variant]} */\n"
            f"    {{{index}, {common},\n"
            f"     {{{{{first}}}, {{{second}}}}}}}")


def render_modes(defaults=False):
    heading = ('/* Generated from verified SDK timing parameters; check with tools/generate_video_modes.py. */\n'
               '#include "../../include/scheduler.h"\n\n')
    if defaults:
        return heading + "\n\n".join(
            "VideoMode " + symbol + " =\n" + initializer(region, 2).strip() + ";"
            for symbol, region in [("D_8008F530", "PAL"), ("D_8008F580", "MPAL"),
                                   ("D_8008F5D0", "NTSC")]) + "\n"
    rows = [initializer(region, variant) + "," for region in REGIONS for variant in range(14)]
    return heading + "VideoMode D_8008E400[42] = {\n" + "\n".join(rows) + "\n};\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--defaults", action="store_true")
    args = parser.parse_args()
    if args.check:
        for filename, defaults in [("video_modes.c", False), ("video_default_modes.c", True)]:
            if (ROOT / "src/sdk" / filename).read_text() != render_modes(defaults):
                raise SystemExit(f"Video timing declaration differs: {filename}")
        print("Verified 42 table modes and all three default modes")
    else:
        print(render_modes(args.defaults), end="")


if __name__ == "__main__":
    main()
