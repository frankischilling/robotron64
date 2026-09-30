# Frame begin

`func_80048510` occupies VRAM `0x80048510..0x800489F4`, corresponding to ROM `0x049110..0x0495F4`. Its exact target size is `0x4E4` bytes. The next function begins at `0x800489F4`.

The routine selects the next frame command buffer, initializes the display-list head, emits the frame-start RSP/RDP command sequence, selects a temporary fill color from `D_80138250`, clears the frame, and restores the three color components to 255 before returning.

## Frame and display-list setup

The routine first stores `D_80137F58` in `D_8013823C`, toggles `D_8007D910`, and calls `func_8004717C` with the new value. The toggle selects `0x803CE000` or `0x803E7000` for `D_80138278`; that pointer is copied to `D_80138254` as the display-list cursor.

The following commands then reproduce the target setup through the second color-image command. `FRAME_COMMAND` uses a separate block-local packet pointer, which preserves the IDO store ordering required by the target. The final color-image address is the current `D_80138260[D_8007D914]` pointer converted from KSEG0 by subtracting `0x80000000`.

## Temporary fill color

The target computes `(D_80138250 + 6) / 10` with signed division and checks cases in the emitted order `2`, `3`, `6`, `7`, with the default body laid out first. The corresponding source order remains `default`, `6/7`, `3`, `2`.

The three component globals must be treated as volatile. The ROM contains repeated stores whose intermediate value is overwritten before any ordinary C read:

| Case | Stores visible in the target |
| --- | --- |
| default | red = 48, red = 0, green = 0, blue = 0 |
| 6 or 7 | green = 48, blue = 48, red = 0, blue = 0, green = 0 |
| 3 | red = 48, blue = 48, green = 0, blue = 0, red = 0 |
| 2 | red = 48, green = 48, blue = 0, green = 0, red = 0 |

With nonvolatile declarations, IDO removes the overwritten `48` stores and emits a `0x4B8`-byte function. Declaring `D_80138270`, `D_80138274`, and `D_8013826C` volatile preserves the observed stores and produces the exact target symbol size of `0x4E4` bytes without changing the 32-byte stack frame.

The fill value is RGB5551-like packing:

`((red << 8) & 0xF800) | ((green << 3) & 0x07C0) | ((blue >> 2) & 0x003E) | 1`

The 16-bit value is duplicated into both halves of `D_80138244`, then used by the fill-color command. The routine emits the fill rectangle, a pipe sync, and the following other-mode command before setting red, green, and blue to 255.

## Current matching status

The current `src/boot/frame_begin.c` candidate compiles with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32` to a `0x4E4`-byte `func_80048510`. It matches every target word through `0x8004883C`. There are 52 differing words after that point, grouped at:

| Differing address range | Words |
| --- | ---: |
| `0x80048840..0x80048854` | 6 |
| `0x80048884..0x800488A4` | 9 |
| `0x800488AC..0x800488D8` | 12 |
| `0x800488E0..0x80048908` | 11 |
| `0x80048910..0x8004892C` | 8 |
| `0x80048940` | 1 |
| `0x800489D8..0x800489E8` | 5 |

The main difference is register coloring. The target keeps the red, green, and blue addresses in `t2`, `t3`, and `t4`; the current IDO candidate uses `t1`, `t2`, and `t3`. The target therefore loads the final constant 255 into `t1`, after restoring `ra`, while the candidate uses `t4` and schedules that load before the `ra` restore. The target also schedules several per-case address constructions before their stores, while the candidate interleaves those address calculations with stores. The arithmetic and memory effects after applying the register mapping are otherwise consistent; notably the RGB packing instructions from `0x80048930..0x8004893C` and the later display-list command sequence match.

`.local/frame-begin-probes/current/report.json` records every remaining word with its expected and candidate encoding. `.local/frame-begin-probes/variants.py` records the source-shape experiments. Pointer locals, volatile pointer/cast forms, chained assignments, phase locals, block-scoped intensity/reset locals, and equivalent RGB expression forms did not improve on the 52-word volatile-global candidate. A local permuter found lower synthetic scores only by inserting constant-control-flow constructs such as `if (1)` or `if (0)`; those forms were rejected as code-generation artifacts rather than evidence of the original source.

The follow-up recovery in `.local/recovery7-frame` also tested the compiler profile and original SDK macro shapes. IDO 5.3 at `-O2` or `-O3`, `-G0 -non_shared -mips1 -32`, preserves the exact 816-byte prefix and the same 52-word tail. IDO 7.1 at `-O2`/`-O3` increases the tail mismatch to 93 words, `-mips2` diverges near the start of the function, and `-O1` changes the whole allocation strategy. Adding `-Wab,-r4300_mul` to the 5.3 `-O2` profile is byte-identical to the normal build, so the newly established multiply workaround is not relevant to this routine.

The three color declarations were tested in all six declaration orders; all produce the same 52-word result. Changing red or green to unsigned changes code generation substantially and worsens the comparison, while blue must remain signed to preserve the target's arithmetic right shift. Duplicating the old SDK `GPACK_RGBA5551` expression with volatile channels also worsens the result because it repeats the volatile reads; the current single packed-color temporary is therefore supported by the target.

The final four display-list operations were separately rebuilt with old-SDK-shaped `gDPSetFillColor`, `gDPFillRectangle`, pipe-sync, and cycle-type macros. Each macro uses its own block-local `_g` packet pointer and receives `D_80138254++` as the packet argument, matching the SDK evaluation model. That candidate still has the exact `0x4E4` function size, exact prefix through `0x8004883C`, and the same 52 differing words. The tail mismatch is therefore not explained by those GBI macro scopes or by the RGB packing expression.

The candidate should remain excluded from matching progress until the remaining register-allocation/source-shape difference is recovered. No padding, inline assembly, unreachable code, or instruction patching is used.
