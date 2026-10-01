# Scene frame timing

`func_80038598` covers `0x80038598..0x800387C8`. All 560 instruction bytes
match the USA target with IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`.
The source also supplies the eight-byte double constant `1000.0` at
`0x80094BE0`, ROM offset `0x957E0`. No BSS is claimed.

The routine calls the palette update and clears scene state `D_800AD284`
when it is outside zero through ten. It captures the platform timer into
`D_8009EFA4`, clears the frame delta, and computes
`(currentTime - previousTime) * 75 / 100` with signed integer arithmetic.
It preserves the existing memory-copy call with a zero byte count and
stores the result in the history array's first word. The history array's
complete extent remains unresolved; its storage stays in fallback.

A local count holds the previous history count plus one. A nonpositive
result is retained; a positive result becomes one. The weighted history
loop starts at weight one, subtracts one per iteration, accumulates an
unsigned delta, and divides by the total weight. The source retains the
signed count and denominator and the target's unsigned division.

The calculated delta is stored before computing `1000.0 / delta` as a
double expression converted to float at `D_FLT_800C8DF4`. A second double
division computes `30.0 / rate` and converts it to float at
`D_FLT_800C8DF8`. The original delta is recorded at `D_8009EF9C`; values
above 100 are then clamped to 100 for the current frame. The previous
timestamp and recorded frame delta are updated. Active scene state zero
adds the delta to `D_8009EFA0`; other scene states clear the current delta.
No new guard changes the original arithmetic or divide behavior.

## Timer return interface

`func_8003BFA4` calls `func_800495BC` with a null timestamp pointer. The
matching helper returns milliseconds derived from the hardware count and
clock frequency. Scene timer capture, initialization, and this update all
consume that integer result. The shared platform declaration now returns
`int`, and the adapter explicitly returns its callee's value. This preserves
all 32 adapter instruction bytes and the entire 144-byte adapter unit.

## Complete comparison

The update reproduces the target's 24-byte stack frame without added
workspace or unused arguments. A local counter, the weighted multiplication
order, and chained delta assignment preserve the original branch and
register scheduling. IDO emits eight live constant bytes followed by eight
zero alignment bytes. The existing padding tool trims only that trailing
alignment; the complete live constant matches `408f400000000000`.

Acceptance checks full function bounds, symbol type, linked placement,
every instruction word, the complete live constant, current compiler and
source inputs, all shared platform-header users, and whole-ROM equality.
The provenance ledger includes the new update and all fifteen existing
adapter procedures, without counting those existing functions as new
progress: [scene-frame-tick-provenance.json](scene-frame-tick-provenance.json).

A clean archive of `97f2e8d` passes fresh extraction and build, all 137
tooling tests, 794 complete runtime comparisons, both startup units,
eighteen assembly units, and eight data-only units. Linked progress records
1,311 matching C procedures and 221,912 instruction bytes, with 9,555
initialized and 30,353 BSS bytes owned by source. The full 8 MiB ROM matches
the supplied USA target, SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The publication audit checks all 1,289 public files.

Robotron's matching timing helper, callers, and instructions establish the
behavior. The pinned IDO and all thirteen requested N64 projects remain
credited for local and online use in [CREDITS.md](../CREDITS.md). Further
frame and scene recovery is tracked by
[issue #32](https://github.com/frankischilling/robotron64/issues/32) and
[issue #45](https://github.com/frankischilling/robotron64/issues/45).
