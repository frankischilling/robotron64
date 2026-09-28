# Model geometry and framebuffer services

Eleven complete functions provide 3,024 bytes of matching C for model
rotation, polygon submission, hierarchy traversal, vertex operations, and
framebuffer services.

| Source | Function | Code bytes |
| --- | --- | ---: |
| `model_rotation.c` | `func_8003D2C0` | 380 |
| `model_polygons_plain.c` | `func_8003EB7C` | 284 |
| `model_polygons_color.c` | `func_8003EC98` | 392 |
| `model_hierarchy_vertices.c` | `func_8003F168` | 428 |
| `model_camera_identity.c` | `func_8003F62C` | 36 |
| `model_camera_rotation.c` | `func_8003F650` | 420 |
| `model_mesh_iteration.c` | `func_8003F7F4` | 36 |
| `model_normals_blend.c` | `func_8003F818` | 512 |
| `model_vertices_scatter.c` | `func_8004000C` | 184 |
| `model_framebuffer_copy.c` | `func_800404F4` | 108 |
| `model_framebuffer_texture.c` | `func_80040874` | 244 |

## Mesh and hierarchy data

The polygon walkers reuse the existing 36-byte `RendererPolygon`, 24-byte
mesh prefix, twelve-byte transformed position, and eight-byte normal
layouts. A vertex count of three chooses the triangle path; other values
choose the four-vertex path. The colored variant takes the high byte of
the first packed color word, loads its palette word, and assigns that color
to all four attribute slots before submission.

`ModelGeometryNode` is 100 bytes. It contains three position words at zero,
30 signed child indices at `0x1E`, a child count at `0x5A`, and a vertex
count and first vertex at `0x60` and `0x62`. Uninterpreted bytes retain their
observed offsets. A compile-time assertion checks the complete record size.

The recursive transform reads three angle halfwords from the node's
eight-byte angle entry. Zero angles use an identity matrix; other angles
use the recovered rotation builder. The node's position is transformed by
its parent matrix and added to the incoming translation. The combined
matrix transforms its contiguous vertex range, then becomes the parent for
each child. The implementation uses the established `ShortPosition` and
`FixedMatrix` declarations from `fixed_geometry.h`, including the existing
vertex-transform calling convention.

## Rotation and vertex operations

The rotation builder preserves the target's signed fixed-point products
and each right shift by 15. Reassociating these expressions can change both
the rounding and the compiler's instruction order. The camera variant uses
the negatives of the three stored camera angles; the identity helper resets
the separate camera matrix.

The normal-selection routine copies three halfwords from the second input
for entries zero through eleven and from the first input afterward. It
leaves the fourth halfword in each entry unchanged. The scatter routine
adds independent random values from the game's `[-100, 100]` call to X and
Y, and applies `inputZ / 2 + random - 500` to Z. The target's signed division
and input/output update order are preserved.

`func_8003F7F4` retains the target's empty loop over the mesh vertex count.
It contributes only its complete 36-byte procedure; no behavior is inferred
for that entry point beyond the observed loop.

## Framebuffer operations

The copy routine returns without copying when the source pointer is null.
Otherwise it copies exactly `320 * 480` halfwords into the selected
framebuffer. This count describes the target's transfer; it is not a claim
about the display mode or visible dimensions.

The texture routine rounds the supplied address down to an eight-byte
boundary and emits the target's eight synchronization, image, tile,
block-load, and tile-size packets through the existing display-list macro.

## Verification and references

Complete target ranges, caller excerpts, seeds, exploratory candidates,
compiler fingerprints, source/header snapshots, and comparisons are under
`.local/recovery66-geometry`. Independent canonical comparisons and actual
procedure-boundary checks are under `.local/recovery67-integration`.
These units define no initialized data or BSS and use IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`.

The existing renderer types were checked against the vertex and GBI layouts
in [Super Mario 64](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h).
Robotron's instructions and callers determine its own node format,
fixed-point order, iteration limits, and command values. The complete
reference collection and the local m2c/permuter workflow are credited in
[CREDITS.md](../CREDITS.md). Rejected candidates, including artificial
conditions or jumps from search output, remain outside matching progress.
