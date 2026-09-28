# Object math and filename helpers

The following complete functions match the target with IDO 5.3 and the game's
`-O2 -G 0 -non_shared -mips1 -32` profile. Their addresses are evidence labels;
they are not claims about the original developers' names.

| Source | Runtime range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `object_recovery_path_extension.c` | `0x8003CBEC..0x8003CC30` | 1 | 68 |
| `object_recovery_fixed_trig.c` | `0x8003CC58..0x8003CCE8` | 3 | 144 |
| `object_recovery_integer_sqrt.c` | `0x8003CCE8..0x8003CD4C` | 1 | 100 |
| `object_recovery_angle_scale.c` | `0x8003CD4C..0x8003CD70` | 1 | 36 |
| `object_recovery_direction_angle.c` | `0x8003CD70..0x8003CEF4` | 1 | 388 |
| `object_recovery_angle_table.c` | `0x8003CEF4..0x8003CF88` | 1 | 148 |

The filename helper searches the destination for a period, terminates the
string there when one is found, and calls the existing concatenation routine
with the supplied suffix. It preserves the original unchecked buffer handling.
The search and concatenation callees remain independently identified functions;
recovering this wrapper does not count their bytes again.

The three fixed-angle wrappers call the routines at `0x8005FBB0`, `0x8005FC20`
and `0x8004DC18`, then divide the signed result by eight. The first two shift
the input left by four before the call. Signed division retains rounding
toward zero, including the correction instructions for negative results.
The wrapper at `0x8003CD4C` multiplies the direction-angle result by eight.

The integer square-root helper tries result bits from `0x8000` downward and
compares each candidate's square with the input. An exact square returns
immediately. Inputs at or above `0x40000000` return `0x8000`. The source retains
the target's signed comparisons and bit-clearing sequence.

The lookup at `0x8003CEF4` compares the input with entries 1 and 63 of the
table at `0x8007C338`, returning 0 or 64 outside those bounds. Otherwise it
starts at index 32 with step 16 and halves the step after each adjustment,
returning an index whose adjacent table entries bracket the input. The table
remains extracted data; these functions do not claim ownership of its bytes.

The direction-angle routine handles both coordinate axes before dividing.
For other inputs it remembers the signs, takes both absolute values, and
looks up the smaller magnitude multiplied by 32767 and divided by the larger.
It then applies the original quadrant mapping in units of 1/512 of a turn.
Multiplication by 32767 lets the original assembler choose its shift/subtract
expansion; spelling out that expansion in C introduced extra temporary
registers. The multiplication form matches all 388 bytes.

Fresh complete-function comparisons use the current shared headers and contain
zero differing instruction words. The build records each source, header and
object hash, and checks the linked function symbols and full ROM independently.
Alignment gaps between these functions remain separate fallback ranges.

The neighboring DAT relocation/scaling routine remains a research candidate.
Its existence in `src/game/` does not make it part of the matching build or
the measured C total.
