# SDK angle functions

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

The routines at `0x8005FBB0` and `0x8005FC20` implement a 16-bit turn-angle
sine and cosine interface. The target masks the sine argument to 16 bits,
reduces it to a 12-bit table index, reflects the second quadrant, and negates
the signed table value in the lower half-turn. Cosine adds `0x4000` before
calling sine. The table at `0x8008DBB0` remains extracted data.

| Source | Runtime range | Bytes | Matching profile |
| --- | --- | ---: | --- |
| `gu_sine.c` | `0x8005FBB0..0x8005FC20` | 112 | IDO 5.3, `-O2 -G 0 -non_shared -mips2 -32` |
| `gu_cosine.c` | `0x8005FC20..0x8005FC50` | 48 | IDO 5.3, `-O2 -G 0 -non_shared -mips2 -32` |

The complete O2 comparisons contain no differing words. O1 produces 144 bytes
for sine instead of 112. Its 48-byte cosine candidate has nine differing
words. The SDK function identification and narrow interface are supported by
the `src/libultra/gu/sins.c` and `coss.c` references in Ocarina of Time, and
`src/gu/sins.c` and `coss.c` in decompals/ultralib. The reconstructed code was
checked against Robotron's instructions and table references.

## Two original calling forms

`src/game/fixed_math.c` now uses the signed-16-bit return and unsigned-16-bit
argument declarations in `sdk_math.h`. Its complete 308-byte block still
matches, including caller-side angle masks.

The older wrappers at `0x8003CC58` and `0x8003CC88` pass the full shifted word
without those masks. Their recovered word-sized declarations are intentionally
local to `object_recovery_fixed_trig.c`. On the target, the callee narrows the
argument and returns an already sign-extended sample in the integer return
register. Applying the narrow header to these wrappers produces 160 bytes
instead of the target's 144-byte block, with 38 differing words.

This is a retained legacy C declaration mismatch across translation units.
It relies on the measured IDO/o32 calling behavior and is unsuitable as an
assumption for a portable rewrite or link-time type optimization. A promoted
argument with an old-style definition was also tested: it generated 128 bytes
for sine and a nonmatching cosine. Those rejected sources and comparisons are
retained locally. The matching tree keeps the observed call instructions and
documents the exception rather than inserting casts, padding, or instructions.

## Floating-point sine and cosine

`gu_sine_float.c` reconstructs `0x80063230..0x800633F0` (448 bytes), and
`gu_cosine_float.c` reconstructs `0x800633F0..0x80063558` (360 bytes). Both
match IDO 5.3 with `-O2 -G 0 -non_shared -mips2 -32 -Wab,-r4300_mul`.

The routines inspect the input exponent, reduce the argument using separate
high and low parts of pi, and evaluate a double-precision polynomial before
rounding the result to float. Sine returns the input directly for sufficiently
small arguments. The target returns its stored quiet NaN for NaN input and
stored zero for the remaining large-input case. These edge cases and the
order of the floating-point operations are preserved.

The polynomial arrays, reciprocal pi, split pi constants, zero and NaN remain
extracted data at the target addresses. The implementation's integer access to
the float input reproduces the original IDO representation inspection; it is
not a claim of portable strict-aliasing behavior.

The first O2 comparison omitted the assembler's R4300 multiply workaround and
produced 432 bytes for sine and 352 bytes for cosine. Inspection showed missing
spacing between floating-point multiplies. The same source with
`-Wab,-r4300_mul` gives the target sizes and zero differing instruction words.
The flag is present in both the inspected OOT and SM64 Makefiles. No source
padding or instruction replacement is used. The OOT `src/libultra/gu/sinf.c`
and `cosf.c` implementations supplied algorithm and SDK-family comparisons;
the target supplied the exact constants, ranges and instruction checks.

## Random-number generator

`gu_random.c` matches `0x800631F0..0x8006321C` (44 bytes) with IDO 5.3
`-O2 -G 0 -non_shared -mips2 -32`. A private unsigned seed starts at
174823885, forms `x = (seed << 2) + 2`, multiplies `x` by `x + 1` with
32-bit unsigned wraparound, and shifts the result right by two. That result
becomes both the next seed and the return value.

The source owns the four initialized seed bytes at `0x8008F120`, ROM offset
`0x8FD20`. The definition remains local to the function, as in the SDK
`gu/random.c` reference. Giving it external linkage changed address allocation
and left nine instruction differences; the local definition produces zero.
Its compiler-recorded name and offset are checked through the private-data
support described in [static-function verification](ido-static-functions.md).
The code and seed bytes are compared independently against the target, and
the surrounding alignment bytes remain separate fallback ranges.
