"""Reconstruct SDK CPU priority offsets and MI clear/set interrupt masks."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INTERRUPT_LABELS = (
    ("D_80066F18", "redispatch"),
    ("D_80066EE0", "software one"),
    ("D_80066EC0", "software two"),
    ("D_80066D24", "RCP"),
    ("D_80066CD0", "cartridge"),
    ("D_80066E64", "pre-NMI"),
    ("D_80066C98", "CPU interrupt six"),
    ("D_80066CA4", "CPU interrupt seven"),
    ("D_80066CB0", "counter"),
)


def cpu_offsets():
    high = [0 if bits == 0 else 20 + 4 * (bits.bit_length() - 1)
            for bits in range(16)]
    low = [0 if bits == 0 else 4 * bits.bit_length() for bits in range(16)]
    return high + low


def rcp_mask(bits):
    if not 0 <= bits < 64:
        raise ValueError("An RCP interrupt mask has six bits")
    return sum((2 if bits & (1 << index) else 1) << (2 * index)
               for index in range(6))


def render_cpu_tables():
    offsets = cpu_offsets()
    lines = ["/* Generated from CPU interrupt priority; check tools/generate_interrupt_tables.py. */",
             "const unsigned char D_80095E60[32] = {"]
    lines.extend("    " + ", ".join(map(str, offsets[index:index + 8])) + ","
                 for index in range(0, 32, 8))
    lines.extend(["};", ""])
    lines.extend(f"extern unsigned char {name}[]; /* {role} */"
                 for name, role in INTERRUPT_LABELS)
    lines.extend(["", "unsigned char *const D_80095E80[9] = {"])
    lines.extend("    " + ", ".join(name for name, _ in INTERRUPT_LABELS[index:index + 3]) + ","
                 for index in range(0, 9, 3))
    return "\n".join(lines + ["};", ""])


def render_rcp_masks():
    lines = ["/* Generated from adjacent MI clear/set bits; check tools/generate_interrupt_tables.py. */",
             "const unsigned short D_80095DD0[64] = {"]
    lines.extend("    " + ", ".join(f"0x{rcp_mask(bits):04X}" for bits in range(index, index + 8)) + ","
                 for index in range(0, 64, 8))
    return "\n".join(lines + ["};", ""])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--cpu", action="store_true")
    args = parser.parse_args()
    if args.check:
        for filename, render in [("cpu_interrupt_tables.c", render_cpu_tables),
                                 ("rcp_interrupt_masks.c", render_rcp_masks)]:
            if (ROOT / "src/sdk" / filename).read_text() != render():
                raise SystemExit(f"Interrupt declaration differs: {filename}")
        print("Verified all 32 CPU offsets, nine handler references and 64 RCP masks")
    else:
        print(render_cpu_tables() if args.cpu else render_rcp_masks(), end="")


if __name__ == "__main__":
    main()
