# Expanded textured triangle submission

`src/game/renderer_expanded_triangle.c` reconstructs the complete 728-byte
procedure at `0x800444F8..0x800447D0` and its 40-byte diagnostic string span.

The function captures the vertex cursor, checks the last frame-relative
vertex index against 10,000, and retains the `prims.c` diagnostic at line
`0x252`. It then increments the triangle and total polygon counters and
consumes three packed two-bit texture corner selectors. Each corner uses
the existing signed-halfword coordinate table at `D_8007CDB0`.

The X and Z centroid components add the second position, third position,
and first position in that order, then divide by three using signed
truncation toward zero. If `D_800BF90C` is zero, each offset is computed as
`((centroid * 4) * D_8007CDC0) / 256`, again with signed truncation. Otherwise
both offsets remain zero. All three X and Z positions receive the same
offset; the Y positions remain unchanged. This translates the triangle in
the XZ plane rather than scaling its individual edges.

The source expresses the centroid and offset as three-component word
structures. Only their X and Z fields are used by this procedure. This
representation, declared before the cursor and loop locals, reproduces the
target's 88-byte stack frame. The original source type name is unknown.
The recovered structure is a compiler-supported reconstruction, and no
unused padding local is added to force the frame size.

The resulting positions become signed halfwords, each vertex receives the
current alpha, and the function emits a three-vertex load and triangle
command before advancing the global vertex cursor by three. Direct arena
indexing retains the target's position and alpha register choices.

## Verification and references

The source owns the complete diagnostic format and `prims.c` filename at
`0x80095060..0x80095088`. The verified compiler profile is IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. Acceptance checks all 728 instruction
bytes and all 40 initialized bytes, linked function metadata and placement,
current build inputs, and whole ROM equality. Instruction patches, inline
assembly, and unused local padding are absent. Complete hashes appear in
[the provenance ledger](renderer-expanded-triangle-provenance.json).

The clean archive `0c0b02e` also passed extraction, the full build, all 137
tooling tests, whole ROM equality, 783 independent runtime units, both startup
units, 18 assembly units, and eight data-only units. Its linked checkpoint
contains 1,298 matching C functions and 216,544 instruction bytes. The
1,255-file publication inventory passes the public audit. Broader checkpoint
results are recorded with [the image quad recovery](renderer-image-quads.md).

The local and online Super Mario 64 and libreultra GBI definitions support
the hardware vertex and command layouts:
[Super Mario 64 GBI definitions](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h)
and [libreultra GBI definitions](https://github.com/n64decomp/libreultra/blob/master/include/2.0I/PR/gbi.h).
Robotron's complete comparisons establish the centroid order, signed
division, translation, corner consumption, and diagnostic behavior.
Reference revisions and notices are in [CREDITS.md](../CREDITS.md). Further
polygon recovery remains tracked in issue #41.
