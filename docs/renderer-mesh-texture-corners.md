# Mesh texture corners

`D_800736D0` contains four pairs of signed 16-bit texture coordinates:
`(0, 0)`, `(0, 1984)`, `(1984, 1984)`, and `(1984, 0)`. The complete table
occupies sixteen bytes at VRAM `0x800736D0`, ROM `0x742D0..0x742E0`.

The mesh drawing procedures at `0x80011030` and `0x8001162C` select each pair
with two bits from a polygon's texture-corner byte. Their signed halfword
loads use a four-byte pair stride. The triangle loop consumes three pairs;
the quad path consumes four. These reads establish the table's element type
and complete four-pair extent.

The source declaration in
[`mesh_texture_corners.c`](../src/game/renderer_primitives/mesh_texture_corners.c)
owns only those sixteen initialized bytes. It emits no procedure, BSS,
relocation, or extra initialized section. The separate table `D_8007CDB0`
has similar values and remains a distinct object at its original address.

The two drawing procedures remain extracted fallback code. Private research
on `func_80011030` passed 836 guarded paired cases, but its complete compiled
body still differs from retail instructions. In particular, the first
untextured polygon's uninitialized corner lifetime remains unproved. None
of that procedure's code is credited by this data recovery.

The acceptance record is
[`renderer-mesh-texture-corners-provenance.json`](renderer-mesh-texture-corners-provenance.json).
The original user-supplied ROM, Ghidra analysis, independent SPIM and splat
assembly, and pinned IDO output supply the evidence. Tool credits are in
[`CREDITS.md`](../CREDITS.md).
