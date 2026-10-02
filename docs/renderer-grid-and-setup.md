# Procedural grid and renderer setup

The complete routine at `800431C0..80043930` now has a C candidate in
`src/game/renderer_setup/grid.c`. It remains excluded from the ROM link and
matching instruction totals. Three terminated setup display lists and their
viewport and lighting records have separate, verified source ownership.

## Grid behavior

The routine emits a pipe sync, selects mode one, configures its texture and
rendering state, and passes the existing bitmap identifier to the texture-cache
helper. It negates and halves each camera position component, transforms that
vector through the existing fixed matrix, and submits the translated matrix.
The matrix submission happens before the vertex allocation check.

A successful allocation produces seven rows of seven vertices. X and Z run
from -4149 to 4149 in steps of 1383, and Y is zero. Texture U runs from -96 to
96 in steps of 32, shifted left six bits; V is the row coordinate shifted left
eleven bits. The routine calls the absolute-value helper once per vertex and
discards its result. It writes an intermediate red/green ramp, then overwrites
those components with gray 64, blue 64, and alpha 255. The initial ramp writes
and all 49 calls remain in the candidate.

After committing 49 vertices, the routine emits seven strips of six cells.
Each cell loads two vertices from the first row and two from the indexed row,
then emits two quad packets with opposite winding. The first strip therefore
pairs the first row with itself. The final strip's second pair ends at vertex
48, within the generated vertices. The source preserves these addresses and
does not change the routine into a conventional neighboring-row grid.

The successful path emits its final sync, combine and perspective commands,
submits the setup list at `8007CA70`, and calls the existing final-state helper.
Allocation failure returns after the earlier mode, texture, and matrix work;
it skips vertex generation and the final state restoration. The incoming word
is stored but never read, so its original source type and this routine's callers
remain unresolved.

## Setup ownership

| Source | RAM interval | Initialized bytes |
| --- | --- | ---: |
| Grid setup commands | `8007CA70..8007CAC8` | 88 |
| Viewport | `8007CAC8..8007CAD8` | 16 |
| Ambient and directional light | `8007CB00..8007CB18` | 24 |
| Frame geometry setup commands | `8007CB18..8007CB58` | 64 |
| Frame RDP setup commands | `8007CB58..8007CBD8` | 128 |

The three command arrays contain eleven, eight, and sixteen eight-byte packets,
each ending in the observed display-list terminator. The frame-begin candidate
calls the RDP and geometry arrays. The grid candidate calls its own setup array.
Their complete boundaries and referenced addresses are checked independently.

The geometry array loads a 16-byte viewport, clears the observed geometry mask,
disables texturing, enables shading, selects one directional light, and loads
the directional and ambient records. The viewport's scale and translation both
contain `(640, 480, 511, 0)`. The ambient color and its SDK copy are `(5, 5, 5)`;
the directional color and copy are `(175, 175, 175)`, with direction
`(70, 50, -70)`. The SDK unions retain eight-byte alignment and their established
16-byte viewport, eight-byte ambient, and sixteen-byte light sizes.

IDO emits the pointer-bearing geometry array in `.data` and the other four
units in `.rodata`. The grid array and lighting unit have trailing compiler
alignment bytes outside their declared extents; those bytes remain outside
source ownership. The forty-byte gap at `8007CAD8..8007CB00` is also excluded.
The public source contains reconstructed command fields and typed SDK records.

## Evidence and limits

The candidate is compiled with the pinned IDO 5.3 game profile. Its complete
text is 1,872 bytes against the retail 1,904 bytes, with 409 differing words.
Its frame is 280 bytes against the retail 328. It receives no matching C credit.
Used local placement, coordinate-loop forms, pointer lifetimes, and the existing
object-record view were investigated privately. No unused storage, enlarged
record, instruction patch, inline assembly, or constant control-flow construct
was added to force a match.

`python3 tools/check_renderer_grid.py` independently compiles the candidate and
five matching support units. It executes the actual fixed transform, matrix
submission, absolute-value, vertex-pool, and diagnostic no-op instructions.
Mode, texture-cache, and final-state calls use deterministic stubs. The optional
Unicorn dependency is the same pinned analysis dependency used by the trail and
heap checker.

All 480 cases pass and cover allocation success, the 9800/9801 threshold, the final valid
49-vertex allocation, signed and clamped camera positions, three matrices,
both matrix buffers, two matrix indices, and a texture stub that changes the
view before its later reads. Comparisons include call order, vertex snapshots
at each absolute-value call, all affected vertex and matrix bytes, display-list
commands, pool/matrix counters, and allocation guards. Reference checks also
verify the 49 calls, 181 successful-path packets, and the final two-vertex load
ending at vertex 48. No RSP/RDP execution or GPU output is checked.

Robotron's instructions and matching callees establish the grid behavior.
The pinned local libreultra `2.0I/PR/gbi.h` establishes viewport, light, command,
and other-mode field layouts. SM64 and Zelda GBI headers provide supporting
SDK references. No reference game implementation was copied. The requested
reference projects and licenses remain recorded in [CREDITS](../CREDITS.md).
The grid's remaining instruction work is tracked in
[issue #73](https://github.com/frankischilling/robotron64/issues/73); frame setup
remains tracked in [issue #32](https://github.com/frankischilling/robotron64/issues/32).
Whole-ROM equality still includes extracted fallback and does not establish
complete source recovery.
