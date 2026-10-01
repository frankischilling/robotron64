# Controller input mapping

`func_8003C1A8` maps one controller's stick and button state into game input
bits. The complete 800-byte function matches with the established IDO 5.3
game profile. It polls the controllers, tests the selected port against the
returned connection mask, and returns zero for an absent port.

Before mapping the stick, it clears either axis when the other axis's
absolute value exceeds eight times its magnitude. The comparisons happen
in sequence and update the shared arrays. A threshold strictly above 20 or
below -20 then produces direction bits. Mode zero uses bits 0 through 3;
other modes use bits 4 through 7. The D-pad and C buttons map into those
same direction groups. Start, A, and B contribute `0x100`, `0x800`, and
`0x1000` respectively.

New L/R presses use the changed-to-pressed array. When both bits are set,
the function toggles `D_8007CCA0`. Either individual press calls
`func_8001276C(1, 0)`; the identical arguments in these two branches follow
the target instructions.

## Legacy polling call

The target calls `func_8004F330` without preparing its first argument
register. The incoming port is still in `a0`. A call with an explicit
`port` argument made IDO schedule register moves differently and left
nineteen differing words, despite producing the correct size. The legacy
declaration `int func_8004F330();` and call `func_8004F330()` reproduce all
800 bytes, including this register flow.

The empty parameter list deliberately means unspecified arguments in the
project's C dialect. It must not be changed to `(void)`: the polling callee
does inspect its incoming first argument. This reconstruction depends on
the pinned compiler and ABI and is not a portable calling convention.
The binary cannot establish a unique original spelling, but the selected
source reproduces the complete observed caller. The polling function itself
remains fallback and receives no matching credit from this result.

The existing SDK pad layout and button definitions were checked against the
local [libreultra headers](https://github.com/n64decomp/libreultra/tree/master/include).
Robotron's own instructions establish the mappings and call behavior; no
reference implementation was copied. The complete reference collection is
credited in [CREDITS.md](../CREDITS.md).
