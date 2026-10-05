# Background dispatch

`func_800400D0` saves the 36-byte fixed view matrix, installs an identity
matrix and background projection, advances the color-wave clock, chooses
colors and a renderer, then restores the projection and saved matrix.

| Source-owned range | VRAM | ROM | Bytes |
| --- | --- | --- | --- |
| Complete dispatcher | `800400D0..800404F4` | `40CD0..410F4` | 1,060 C |
| Generated eleven-entry switch table | `80094C80..80094CAC` | `95880..958AC` | 44 initialized |
| Initial color mode | `8007CCB0..8007CCB4` | `7D8B0..7D8B4` | 4 initialized |

Color mode zero uses three sine phases derived from the clock multiplied
by eight, with divisors two, five and three. Each first-color channel has
amplitude 30 and bias 64; the second color is blue. Mode one uses divisors
two and three and a green phase offset of 512. Its red amplitude is 14
with bias 32, and its second color is black. Mode two loads the six scene
color words. The mode starts at two. Other mode values preserve retail's
uninitialized first-color behavior; the source does not add a default color.

The controller flag and save mode nine select height 11000. Other states
use height 14400. Both paths set width 19200. The absolute background kind
selects one of eleven renderer calls; out-of-range kinds skip rendering.
Projection restoration and matrix copying still occur.

Pinned IDO 5.3 produces every instruction, including the 144-byte stack
frame, and every switch-table entry. Named angle, sine, level and amplitude
locals represent the color calculation stages and retain the matching IDO
stack layout. They contain no unused padding variables. The raw text section
has twelve trailing alignment bytes, and the raw switch table has four;
neither tail is source ownership.

Independent spimdisasm output assembled with GNU MIPS binutils reproduces
the entire 1,060-byte procedure and all 44 table bytes. The mode word has a
separate four-byte assembly reference. The provenance ledger records full
comparisons, relocations and execution validation.

`robotron-tools splat split config/analysis/renderer_background.yaml` splits
these three verified ranges. Its generated instructions, switch table and
mode word also reassemble to the original bytes. All output, including the
surrounding binary spans, stays in ignored `.local/renderer-background-split`.

The [provenance ledger](renderer-background-dispatch-provenance.json) records
the fresh compiler comparisons, reference hashes, guarded execution and
clean-build checks. The existing source-owned tiled caller has a separate
140-case check in `tools/check_background_tiles.py`. It verifies all eighty
tile coordinates, the eight setup commands, allocation failure, signed depth
arithmetic and vertex-count accumulation. Its allocation and tile callees are
ABI stubs. These existing 452 bytes add no recovery progress in this change.

Ghidra MCP supplied caller, type and control-flow analysis. Its imported
fallback initialized-data block was marked read-only, which caused it to
fold the mode word to two and omit both sinusoidal branches. Retail MIPS
retains all three paths. The global's Ghidra comment records this discrepancy;
the MCP script route currently prevents changing that block's permissions.
The source and independent reference use the complete retail control flow.

`tools/check_background_dispatch.py` runs 15,000 cases with all eleven
renderer IDs, negative IDs, IDs outside the table, all three color modes,
invalid color modes, both height paths, and signed clock boundaries. The
copy, identity, absolute-value and sine callees execute freshly matched
instructions. Projection and renderer calls use ABI stubs that record every
argument, overwrite caller registers, and change the view matrix to check
restoration. Read and write guards protect the wave array, scene colors,
switch table and surrounding matrix bytes. Three instruction mutations
check clock storage, short-height selection and matrix restoration.

Whole-ROM equality still contains extracted fallback outside these ranges.
This recovery does not establish whole-game source completion or visual
gameplay correctness. Reference and tool attribution is in
[Credits](../CREDITS.md) and [Reference study](reference-study.md).
