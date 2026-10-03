# Indexed and RGBA image setup

The indexed wrapper at `8004ACA4..8004AD64` and the RGBA wrapper at
`8004AFA4..8004B098` now match all 436 instruction bytes, including their
120-byte and 128-byte stack frames. They live in `src/game/renderer_images/`
and replace both complete fallback spans.

Both wrappers set the local draw state's three scales from `D_8008CB34`,
clear all three angles, and copy the three projected-position words. The
indexed path selects renderer mode fifteen and restores texture defaults
before creating the draw state. The RGBA path submits the draw state first,
then selects the mode and restores the defaults. That ordering remains visible
when a called routine changes placement state.

Both disable texture perspective. The indexed path submits the existing
palette, sets alpha to 255, and draws an indexed square with extent twenty.
The RGBA path also clears the texture-filter field, emits the original
`0xB900031D / 0x00553078` render-mode packet, sets alpha to 128, and draws
an RGBA square with extent forty.

Six named locals hold the renderer mode, perspective command, perspective
setting, zero angle, alpha, and image extent. Every local participates in the
actual calls or stores. Their declarations reproduce the original frames
with the established 60-byte `RendererDrawState`. The earlier frame difference
did not establish a larger structure. No unused local, enlarged type,
instruction patch, or assembly replacement is introduced. The match does
not recover unique original variable names or translation-unit boundaries.

The fixed IDO 5.3 game profile remains `-O2 -G 0 -non_shared -mips1 -32`.
Fresh independent comparisons check complete procedure bytes and linked
placement. The optional checker is `python tools/check_renderer_image_setup.py`;
its execution coverage and limitations are recorded in the accompanying
[provenance ledger](renderer-image-setup-provenance.json).

All 1,536 execution cases pass: 768 indexed and 768 RGBA. Ten matching supporting
units execute their real compiled code, including matrix submission, short
trigonometry, texture defaults, palette submission, both image quads, vertex
allocation, and the warning no-op. The mode selector and fatal formatter use
recorded ABI stubs that clobber caller-saved integer registers. Mode mutation
checks whether placement is captured before or after the call.

Independent oracles check the full guarded matrix and vertex arenas, command
buffer, texture/palette inputs, cursors, and affected state. Cases include scale
product wrap, coordinate clamps, both matrix buffers, the final matrix slot,
the last four vertices, allocator rejection, and aligned/unaligned image
addresses. The checker reads only the initialized draw fields consumed by
the matching matrix routine. It does not infer values for unused local fields.
Invalid matrix selectors/storage, RSP/RDP rendering, and full-game behavior
remain outside this proof.

Robotron's retail instructions and existing matching callees establish the
behavior. The local SM64 compiler workflow and libreultra GBI packet definitions
remain credited in [CREDITS](../CREDITS.md). Whole-ROM equality includes fallback;
source recovery is still incomplete.
