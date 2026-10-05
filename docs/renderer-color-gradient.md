# Color gradients

These two renderers write colored vertices at depth 32000 using signed
world-space extents. Their complete procedures and shared initialized data
have independent source ownership.

| Symbol | VRAM range | ROM range | Owned bytes |
| --- | --- | --- | --- |
| `func_80040F5C` | `80040F5C..80041180` | `41B5C..41D80` | 548 C |
| `func_80041180` | `80041180..800414C4` | `41D80..420C4` | 836 C |
| `D_8007CCA8`, `D_8007CCAC` | `8007CCA8..8007CCB0` | `7D8A8..7D8B0` | 8 initialized |

## Four-vertex gradient

`func_80040F5C` writes four vertices with one RGB color at the positive Y
extent and another at the negative Y extent. Its seven arguments are full
o32 integer words: six color channels followed by a mode selector.

The routine selects graphics mode two, emits three state commands, and queries
the dynamic vertex pool. A failed query leaves those commands in place and
writes `-1` to `D_80123AE4`. Otherwise it stores coordinates and RGBA values,
emits a vertex-load packet and two triangles, and commits four vertices.
Coordinates truncate to signed 16-bit storage; RGB values truncate to bytes.
Alpha is 255. Vertex flags and texture coordinates keep their prior contents.
Zero mode selects render-mode word `005049D8`; nonzero selects `0050007B`.

## Twelve-vertex gradient

`func_80041180` takes six integer color channels. It selects mode two and
emits `BA000602/00000000`, `B7000000/00000004`,
`FCFFFFFF/FFFE793C`, and `B900031D/00552078` before querying the pool.
Failure preserves these commands and records index `-1`. Success writes
twelve vertices, emits `040030BF` with their address, then emits three
two-triangle packets and commits twelve vertices.

The first rectangle spans Y `+height` to `+2000`; the second spans `-2000`
to `-height`; the third spans `-2000` to `+2000`. Each uses X `-width`
and `+width`. The four vertices at the outer height extents use the first
color, and the eight vertices at Y `+2000` or `-2000` use the second.
Coordinates and RGB values truncate to their storage widths. Alpha is 255;
flags and texture coordinates retain their contents. The source preserves
the retail coordinate-store order without volatile accesses or unused locals.

## Shared layout and comparisons

The two signed extent words at `8007CCA8..8007CCB0`, ROM `7D8A8..7D8B0`,
start at 16000 and 11000. Their eight initialized bytes have their own source
and ownership record. Both functions use the existing 16-byte vertex layout
and eight-byte display-list packet layout. No new BSS ownership is claimed.

The source uses pinned IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.
A macro groups each vertex's four color stores on one preprocessed line.
IDO schedules these stores differently when they occupy separate source
lines. Both complete functions match retail, including their return delay
slots. Each raw object has twelve zero alignment bytes after the procedure,
which the build removes. Neither function emits initialized data, BSS, or
a switch table. The extent object has eight zero alignment bytes after its
eight initialized bytes; these are also excluded from ownership.

An independent splat/spimdisasm listing, assembled and linked with GNU MIPS
binutils, matches all 1,384 retail code bytes. Raw and linked objdiff comparisons
report 100 percent for both functions and text sections. Fresh asm-differ and
workbench comparisons also cover four complete graphics support units.
Ghidra MCP supplied control flow, type, memory, and caller analysis. Tool and execution evidence
is recorded in [the provenance ledger](renderer-color-gradient-provenance.json).

## Guarded execution

`python3 tools/check_renderer_color_gradient.py` compares current IDO output
and retail instructions against a separate vertex and packet oracle. It runs
4,800 CPU cases: 1,200 cases with caller-register-clobbering ABI stubs and
3,600 with real graphics pool, mode, mode-dispatch, and debug-noop code plus
their initialized tables and strings. The four-vertex renderer contributes
3,840 cases, and the twelve-vertex renderer contributes 960.

Eight extent pairs include retail dimensions, zero, signed integer endpoints,
and 16-bit wrap boundaries. Five palettes include negative and out-of-byte
channels. Cases cover failed queries, several pool offsets, the exact final
valid commit ending at vertex 22000, and prior graphics modes 2, 1, and 18.
The four-vertex renderer also covers mode selectors 0, 1, -1, and 7.

Checks constrain every emulated store, guard the vertex, command, and stack
spans, and preserve untouched vertex fields and input extents. They verify
callback order, arguments, pool counts, mode globals, preserved integer
registers, SP, and F20 through F31. MIPS load/store wrappers initialize and
observe FPR bits because Unicorn's direct MIPS FPR register API rejects them.
Real support code and initialized data must remain byte-identical after each
execution.

The checks do not execute RSP/RDP rendering, test commits beyond vertex 22000, or establish
visual gameplay correctness. Whole-ROM equality still includes extracted
fallback outside the recovered ranges and does not establish whole-game
source completion. Tool and reference attribution is in
[Credits](../CREDITS.md) and [Reference study](reference-study.md).
