# Textured triangle and quad submission

`src/game/renderer_textured_submit.c` reconstructs two complete procedures
and their diagnostic strings from Robotron's renderer.

| Function | Range | Instruction bytes |
| --- | --- | ---: |
| `func_80044B18` | `0x80044B18..0x80044D84` | 620 |
| `func_80044D84` | `0x80044D84..0x80044F60` | 476 |

Both take pointers to three-component signed word positions. They capture
the current vertex cursor, compare the last vertex's frame-relative index
against 10,000, and retain the diagnostic call with its `prims.c` line
number. The quad uses `base - frameBase + 3` and line `0x2EA`; the triangle
uses `base - frameBase + 2` and line `0x31E`. A diagnostic does not abort
submission. Primitive and total-polygon counts increase after the check.

The packed byte `D_80123AE0` supplies one two-bit corner selector per
vertex. Each selector indexes the four pairs of signed texture coordinates
at `D_8007CDB0`, and the byte shifts right by two after each vertex. The
triangle's counted loop remains a loop in the output. IDO unrolls the quad
loop into four texture-coordinate pairs and retains each global byte write.

Each input component becomes a signed position halfword in the existing
16-byte hardware vertex layout. The routines set each vertex's alpha from
`D_80123AE8`, load three or four vertices, and emit a triangle or quad
command. The quad command contains triangles `(1, 2, 3)` and `(1, 3, 0)`.
The global vertex cursor then advances by three or four.

The source uses direct arena indexing for position and alpha writes and a
local vertex pointer for the load command. This source form reproduces the
target's register choices. The signed temporary used for each packed corner
also preserves the arithmetic shift emitted by IDO. No instruction patches,
inline assembly, or unused local padding are used in these procedures.

## Texture corners, strings, and verification

The complete mutable `short[4][2]` array at `0x8007CDB0..0x8007CDC0`
starts with pairs `(0, 0)`, `(0, 1984)`, `(1984, 1984)`, and `(1984, 0)`.
The two-bit mask and pair loads establish all four entries and their signed
halfword layout. The source owns and verifies all 16 initialized bytes.

The source owns 80 initialized bytes at `0x800950B0..0x80095100`: two
diagnostic formats and two `prims.c` strings. Their compiler-generated
alignment bytes are included in the complete data comparison. The ownership
record specifies all four static symbols and their offsets.

The compiler profile is IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.
Acceptance requires the entire 1,096-byte code span, 16-byte corner table,
and 80-byte string span to
match, exact linked function types, sizes and placement, current build
inputs, and full ROM equality. The final unused text alignment is trimmed
only when it contains zero bytes; it is not counted as recovered code.
The input identities and complete byte hashes are recorded in
[the provenance ledger](renderer-textured-submission-provenance.json).

The nearby opaque and alpha-160 quad routines remain outside this matching
unit. Their remaining compiler-layout differences are not included in its
function or instruction totals. Broader polygon and mesh recovery remains
tracked in issue #41.

## References

The local Super Mario 64 `include/PR/gbi.h` and libreultra
`include/2.0I/PR/gbi.h` check the hardware vertex layout and vertex, triangle,
and quad command packing. Their online sources were also consulted:
[Super Mario 64 GBI definitions](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h)
and [libreultra GBI definitions](https://github.com/n64decomp/libreultra/blob/master/include/2.0I/PR/gbi.h).
Robotron's complete instructions establish the specific command words,
corner consumption, diagnostics, cursor updates, and compiler behavior.
The pinned reference revisions and notices are in [CREDITS.md](../CREDITS.md).
