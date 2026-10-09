# Rotating ring renderer

`func_80040968` writes twelve groups of four vertices with rotating XY
positions, depth 32000, three random color channels in `[0, 128)`, and alpha
255. The angle advances by 1024 within each group. The shared wave clock and
an offset of 24000 down to 2000 determine the rotation. Radius falls from
19210 to 1610 in steps of 1600. The allocator cursor advances by 48 vertices.

The complete function occupies `0x80040968..0x80040BA0`, or ROM
`0x41568..0x417A0`: 568 instruction bytes. IDO emits eight additional zero
alignment bytes in the raw object; they are trimmed because the next retail
function starts immediately at `0x80040BA0`. The module owns no initialized
data, BSS, or generated tables. The following random grid stays in fallback.

Each vertex-load packet uses the pointer *after* the four vertices just
written. The last packet points beyond all 48 new vertices. The source keeps
this retail behavior. The packet/memory proof does not execute the RSP or
claim that the resulting display is correct.

The named coordinate, color, packet, and constant locals preserve the
128-byte retail frame. All locals are used. Keep the outer loop's paired
initializations and increments in its `for` header; moving them into a
`do` loop changes three setup instructions under pinned IDO 5.3.

`make check-renderer-rotating-rings` freshly compiles and compares the entire
function and nine support modules, including their owned data. The checker
uses actual graphics mode, allocator, sine/cosine, and random-number callees.
Its independent arithmetic, packet, state, and call oracle covers signed
clock extremes, four initial modes, four RNG seeds, valid allocator indices
up to 21952, and a direct `-1` return. Read/write and code guards, surrounding
canaries, saved registers, and return checks protect every case. Three
instruction mutations must fail. Formatter paths for allocator warnings
are outside these cases; an attempted unmatched callee fails the code guard.

Ghidra's existing `robotron64.elf` program contains the bounded function,
verified signature, and behavioral notes. Its reported data reference at
`0x00004F94` does not establish a runtime caller. The independent spimdisasm
and splat references are reassembled and compared against every retail byte.
Full compiler, reference, execution, and build evidence is recorded in
`renderer-rotating-rings-provenance.json`.

Tool and reference attribution is in [Credits](../CREDITS.md) and
[Reference study](reference-study.md). Whole-ROM equality still includes
fallback code and does not establish whole-game source completion.
