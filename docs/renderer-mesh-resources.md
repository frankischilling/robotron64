# Mesh submission and renderer resource loading

The provenance ledger and candidate table in this document record PR 66 at
`0f50d61`. The loader now has eleven differing words. Its first file
halfword is the point count and its second is the frame count; their names
were reversed in the original publication. See [cache and formatter recovery](resource-cache-and-formatting.md)
for the corrected layouts and current comparisons.

This recovery follows the fixed-alpha quad checkpoint in
[PR 64](https://github.com/frankischilling/robotron64/pull/64).
Robotron 64's retail instructions and data determine the behavior below.
The SDK graphics-field definitions provide the packet interpretation; the
reference projects used by this repository are credited in [CREDITS](../CREDITS.md).

## Complete mesh submission

`func_80045534` occupies `80045534..80045934`, with 1,024 instruction bytes.
Its C source is `src/game/renderer_primitives/mesh_submit.c`.
The procedure captures the vertex cursor, checks the mesh vertex count
against the 10,000-vertex frame limit, and copies all three position words
into signed halfword fields of the hardware vertex array. It then emits
the vertex-load packet using the captured cursor and mesh vertex count.

Each polygon supplies four vertex indices. The lighting flag selects
normal-based vertex color calculation or indexed palette colors. Normal
records have an eight-byte stride. Three-vertex polygons use the target's
rotated triangle index order; the other path emits a quad. The global
vertex cursor advances once, after all polygons have been submitted.

The two polygon pointers have distinct jobs: one reads the current record's
fields, and the other is passed to the material setup calls. Keeping the
field pointer local to the polygon loop reproduces the target's 104-byte
stack frame. Every local is used by the recovered behavior.

## Resource loader candidate

`func_8004BD00`, at `8004BD00..8004C088`, has a complete 904-byte C
candidate in `src/game/renderer_resources/load.c`. It remains excluded
from the matching manifest and ROM link. Its remaining instruction
differences are tracked in [issue 65](https://github.com/frankischilling/robotron64/issues/65).
The current pinned IDO 5.3 comparison produces exactly 904 live bytes with
eleven differing words, all pointer register choices. The raw object also
contains eight zero alignment bytes, checked separately against retail.
The complete function still needs a match; the original PR 66 ledger below
retains its historical sixteen-word comparison.

The three signed arguments select a model, animation, and bitmap. A model
of `-1` is skipped; animations are accepted from 0 through 254; negative
bitmaps are skipped. The model and bitmap branches do not add an upper
bound. Cache entries use the existing resource base at `D_80078274`, with
separate 20-, 16-, and 8-byte index strides.

The prefix views in `include/renderer_resource_loader.h` expose only the
fields accessed here. The offsets include the preceding cache regions;
their sizes are not array strides and do not define new global storage.

| Cache | Data offset | Loaded flag | Signed identifier |
| --- | --- | --- | --- |
| Model | `0x10` | `0x14` | `0x16` |
| Animation | `0x1F50` | `0x1F5C` | `0x1F5E` |
| Bitmap | `0x3850` | `0x3854` | `0x3856` |

A cache miss resolves the identifier to a name and replaces its first
period with a zero byte. This mutates the name returned by the resource
lookup. The loader formats a path, retains the `resource.c` error guards,
rounds the file length up to four bytes, and increments the corresponding
asset-length counter. These counters already have independent source
ownership.

Models use the model allocator, file loading, relocation, and mesh setup
calls before the cache is marked loaded. Animations use the same allocator.
Their first two signed halfwords give point and frame counts; point records
begin eight bytes into the file. The loader copies those counts into the
cache, then shifts each point's signed x, y, and z fields left by three.
The fourth halfword is retained. The loop re-reads the signed file counts
on every iteration, as the target does.

Bitmaps reserve eight extra bytes from the heap and round the returned
pointer up to an eight-byte boundary before loading the file. No allocator
failure handling is added.

## Filename and diagnostic ownership

`src/game/renderer_resources/messages.c` reconstructs nine constants at
`80095530..800955E4`, covering 180 initialized bytes and no BSS.

| Start | Constant | Aligned bytes |
| --- | --- | ---: |
| `80095530` | Model filename format | 16 |
| `80095540` | Model load diagnostic | 36 |
| `80095564` | `resource.c` | 12 |
| `80095570` | Animation filename format | 12 |
| `8009557C` | Animation load diagnostic | 32 |
| `8009559C` | `resource.c` | 12 |
| `800955A8` | Bitmap filename format | 16 |
| `800955B8` | Bitmap load diagnostic | 32 |
| `800955D8` | `resource.c` | 12 |

The compiler supplies the alignment bytes. Independent data comparison
checks every owned byte, section extent, symbol offset, and linked address.
Ownership of these strings does not give the excluded loader instruction
credit.

## Remaining polygon candidates

The expanded quad and diagnostic line remain excluded candidates. The
command-stream candidate preserves its switch dispatch, separate copy and
load cursors, lighting branch, palette updates, polygon calls, and returned
vertex count. Its generated switch table is still unowned. Private fixed
table placement was useful for instruction research, but the public
comparison uses the repository's actual linker inputs.

| Candidate | Retail bytes | Compiled bytes | Differing words |
| --- | ---: | ---: | ---: |
| Expanded quad `func_800447D0` | 840 | 840 | 167 |
| Diagnostic line `func_800453D8` | 316 | 316 | 57 |
| Mesh commands `func_80045A08` | 1,336 | 1,360 | 300 |
| Resource loader `func_8004BD00` | 904 | 904 | 16 |

The command candidate's raw table section occupies 80 bytes. Its first
seventeen entries cover the retail table's 68 bytes, with five differing
entries. Neither those entries nor the section padding receive data credit.

The adjacent functions and data are checked again after integrating the
mesh and diagnostic definitions. Full comparison results, hashes, and
progress counts are recorded in `renderer-mesh-resources-provenance.json`.
The rebuilt ROM continues to include binary fallback for unrecovered
regions; a matching whole-ROM hash does not imply full source recovery.
