# Renderer polygons and hardware vertices

The renderer family at `0x80043930..0x800464F4` supplies vertex attributes,
material selection, texture loading, and polygon submission. Recovery uses
the original instructions, the mesh callers, and the retail diagnostics.
Every candidate is compared as a complete function with IDO 5.3,
`-O2 -G 0 -non_shared -mips1 -32`. Source-owned strings are compared with the
code that references them.

The accepted batch contains 20 complete functions totaling 4,720 code bytes
and 360 bytes of diagnostic strings. Its source units are:

| Source unit | Functions | Code bytes |
| --- | ---: | ---: |
| `renderer_vertex_attributes.c` | 6 | 1,080 |
| `renderer_material_texture.c` | 1 | 280 |
| `renderer_material_light.c` | 2 | 108 |
| `renderer_material_combined.c` | 1 | 656 |
| `renderer_light_select.c` | 1 | 84 |
| `renderer_material_untextured.c` | 1 | 160 |
| `renderer_material_reset.c` | 1 | 32 |
| `renderer_vertex_copy.c` | 2 | 924 |
| `renderer_texture_load.c` | 2 | 536 |
| `renderer_vertex_positions.c` | 2 | 648 |
| `renderer_mesh_positions.c` | 1 | 212 |

The polygon-submission, mesh-draw, and command-stream candidates are still
being compared. They are not included in these source-progress totals.

## Observed data formats

`RendererVertex` is the 16-byte vertex layout used by the display-list
commands: three signed position halfwords, a flag halfword, two texture
coordinate halfwords, and four color bytes. Its alternate normal view uses
three signed normal bytes and an alpha byte. The union retains doubleword
alignment. The vertex arena begins at `D_800CDBD0`; 22,000 entries reach
`0x80123AD0`, immediately before the renderer's state words.

The mesh callers advance polygons by `0x24` bytes. `RendererPolygon` records
the observed color index, vertex count, texture index, packed texture-corner
selectors, four signed vertex indices, four packed color words, and four
signed normal indices. The normal table has an eight-byte stride; only its
first three signed halfwords are used as normal components. Transformed
positions have three signed 32-bit components and a twelve-byte stride.

## Attribute and material helpers

The attribute helpers index from `D_80123AE4`, compare current-frame usage
against 10,000, and preserve the target's diagnostic behavior. Normal
components are arithmetic-shifted right by eight before being stored as
bytes. Two packed-color forms use different byte orders; neither interprets
the input's alpha byte. Texture coordinates use either a fixed six-bit
shift or the shift supplied by the caller.

`func_80043D68` selects texture state, tracks the cached texture, and changes
the combiner when entering or leaving textured polygons. `func_80043E80`
selects a directional light from the high byte of the polygon's first color
word. `func_80043EEC` combines texture and lighting transitions, including
the special color index 254 and its translucent render mode.

`func_800441D0` retains the original untextured-material path. Assigning 255
to the texture-state global before testing that global is present in the
retail instructions: IDO retains a self-comparison branch and its unreachable
body. This behavior is reproduced from ordinary source and verified as part
of the complete procedure.

`func_80045514` invalidates the cached light and texture indices with `-1`
and clears the textured-combiner flag. The eight-byte `func_80043EE4` is an
empty callback whose generated code retains the ABI argument spill.

## Texture loads and vertex copies

`func_80044270` and `func_800443A0` copy three or four input positions into
consecutive hardware vertices. Each signed word becomes a signed halfword,
and the functions update the primitive counts and advance the vertex cursor.
The triangle updates its counts after the bounds diagnostic; the quad does
so before it. Their checks retain the target's last-index calculations,
`base - frameBase + 2` and `base - frameBase + 3`.

`func_80045934` copies the transformed position array for a mesh without
advancing the global vertex cursor. It checks `mesh->vertexCount + base -
frameBase` against 10,000, then copies each twelve-byte input position into
the corresponding sixteen-byte hardware vertex. The mesh prefix has a
24-byte size assertion.

These three procedures retain unused scalar local slots needed to reproduce
the target stack layout. The unused locals have no inferred gameplay meaning.
Their complete generated procedures and all 120 additional diagnostic-string
bytes match; the evidence includes the instruction order, argument homes,
stack spills, and function boundaries.

`func_800462DC` and `func_800463E8` round the supplied texture address down
to an eight-byte boundary. A cached-address match emits no commands. A new
address emits a complete sync, image, tile, block-load, and tile-size
sequence. The two routines differ in image format and load dimensions.

The copy routines convert transformed signed word positions to hardware
halfwords. One applies the current RGB values and alpha 64; the other uses
per-vertex normal data with alpha 64. Their four-way loop unrolling is
generated by IDO from ordinary counted loops.

## References and evidence

The vertex layout was checked against `Vtx_t`, `Vtx_tn`, and `Vtx` in the
[`sm64` GBI header](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h).
The original game determines the polygon format and all packing, caching,
bounds, and submission behavior. The independently defined renderer types
reuse the project's existing display-list command abstraction. Reference
credits and pinned revisions are recorded in [CREDITS.md](../CREDITS.md).

Private target disassembly, actual callers, source/header snapshots,
compiler identity, symbol-layout snapshots, and complete comparison reports
are retained under `.local/recovery56-renderer`, with the accepted snapshot
in `.local/recovery57-integration`. Position-copy recovery and independent
integration proofs are under `.local/recovery61-renderer` and
`.local/recovery61-integration`. The matching manifest includes only
candidates whose entire code and declared data pass.

## Model-side geometry

The separate model-side walkers and transforms at `0x8003D2C0..0x80040968`
now include 11 complete C functions and 3,024 bytes. They reuse the existing
polygon, position, normal, and matrix layouts. Their exact ranges, hierarchy
record, fixed-point operations, and framebuffer behavior are documented in
[Model geometry and framebuffer services](model-geometry.md).
