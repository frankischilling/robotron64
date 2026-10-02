# Annular and tiled surface rendering

Three complete C candidates cover `800428C0..80043070`, a contiguous
1,968-byte renderer span. All remain excluded from the ROM link and matching
instruction totals. The already matching object-service dispatcher selects
the annular renderer when its selector is nonzero and the tiled renderer
otherwise; a zero service gate calls neither routine and returns zero.

## Geometry and state

`func_800428C0` draws four annular bands with eight quads each. The inner
radii are 0, 2250, 4500, and 6750; each corresponding outer radius adds 2500.
Adjacent bands therefore overlap by 250 units. The first band starts at the
origin. Each sector spans 8192 units in the SDK's sixteen-bit angle space,
starting at 4096. The final angle wraps back to 4096 through the matching
short trigonometry helpers. Y is zero for all input corners.

The annular renderer passes four corners to `func_80042BDC`. That helper
copies all twelve input words, subtracts the camera position, applies signed
right shifts by one, and transforms each corner through `D_800CD250`.
Its texture corners are `(0,0)`, `(1984,0)`, `(1984,1984)`, and `(0,1984)`.
The final corner stores V before U. The existing alpha-160 quad routine
submits the transformed corners, emits a vertex-load packet and two
triangles, and advances the shared cursor by four.

`func_80042E2C` selects mode one and submits a 5-by-5 arrangement of squares.
X and Z centers run from -6640 through 6640 in steps of 3320. The matching
`func_80043070` constructs each square's plus/minus-1660 corners and uses
texture extent 3968. It calls the same alpha-160 submitter. The two surface
paths produce 128 and 100 vertices, with 32 and 25 quad-counter increments.
Neither path writes the existing RGB components or vertex flag halfwords.

Both renderers emit their initial state and call the texture-file cache before
requesting the dynamic vertex cursor. They preserve the allocator's 9800/9801
threshold relative to the frame start. On success they commit the cursor
difference, emit final synchronization/combine/perspective commands, submit
the setup list at `8007CA70`, and execute the matching final-state helper.
Allocation failure retains the earlier state and texture work but skips
generation, commit, and final restoration. The annular path does not select a
graphics mode itself.

Both entry points home an incoming word without reading it. Their legacy
caller prepares no argument. Their definitions retain an unused word
parameter, and the caller-facing declarations remain unspecified-argument C
declarations; no stronger original type is asserted.

## Complete comparisons

| Procedure | Retail bytes | Compiled bytes | Differing words |
| --- | ---: | ---: | ---: |
| Annular surface `func_800428C0` | 796 | 796 | 102 |
| Camera-relative quad `func_80042BDC` | 592 | 560 | 131 |
| Tiled surface `func_80042E2C` | 580 | 580 | 71 |

The annular candidate's frame is 192 bytes against retail 208; the quad
helper's is 144 bytes against retail 168. The tiled frames are both 64 bytes.
The tiled candidate has the exact stack frame, saved registers, and loop
instructions; its remaining differences concern temporary-register choices
in the command sequence. The other candidates still differ in local storage,
register allocation, and scheduling. Matching lengths do not establish a
match. Used loop/coordinate forms, local views, and SDK macro shapes were
tested privately. No dummy local, padding record, instruction patch, inline
assembly, or empty constant-control-flow construct was introduced.

The candidates use the pinned IDO 5.3 game profile. Current independent
checks pass for 830 runtime units, two startup units, eighteen assembly units,
and 69 data-only units. All 32 excluded candidates are compared separately.
Matching totals stay at 1,347 C functions / 239,776 bytes, twenty-nine assembly
functions / 4,372 bytes, 27,079 initialized bytes, and 457,189 BSS bytes.

## CPU execution evidence

`python3 tools/check_renderer_surfaces.py` compiles the three candidates and
thirteen complete matching support units. The actual scaled trigonometry,
short sine/cosine code and reconstructed 2,048-byte quarter-wave table,
fixed transform, quad and square submission, vertex-pool allocation/commit,
graphics mode/state, texture-cache hit path, texture-load commands,
diagnostic no-op, and object-service dispatcher execute compiled instructions.
Their source-owned initialized sections are loaded from the verified ELF
objects. No callee stubs are used. File-cache misses and fatal diagnostics are
rejected, rather than modeled as successful calls.

All 1,336 cases pass: 480 annular, 480 tiled, 216 standalone quad, and 160
service-dispatch cases. They cover successful allocation, its threshold and
failure, the final valid 128-vertex allocation, four camera positions, three
matrices, modes one and sixteen, cached/uncached texture-command state, the
controller bit that advances texture phase, both service selectors and gates,
and independent, repeated, and reversed input pointers for the quad helper.
The file cache itself is kept on its hit path in these cases.

Each comparison checks complete vertex buffers, CPU command bytes, call
order, per-quad vertex snapshots, input preservation, renderer/phase/pool
counters, and guards. Reference assertions check primitive and vertex totals,
command counts, texture corners, alpha 160, unchanged RGB/flags, unwritten
vertices, and the service's integer result. At vertex base zero, the leading
guard includes the existing texture identifier; its initialized value is
preserved. The checker does not execute RSP/RDP commands or prove GPU output,
instruction matching, file-cache misses, or every possible input.

The current checkpoint also reruns the existing 480 grid, 5,040 trail, and
256 heap-initializer cases, for 7,112 CPU cases across the three optional
checkers. All 151 public tooling tests pass, and a fresh build matches all
8 MiB of the selected retail ROM. The fresh publication review verifies all
1,495 public files and current source/header/compiler/layout evidence.

Robotron's complete instructions and matching callees establish the geometry
and access order. The pinned local libreultra `2.0I/PR/gbi.h` and SM64 GBI
definitions establish the packet/vertex formats and SDK macro behavior.
The existing reconstructed short-math source supplies the trigonometry;
the stale external-table comment in its shared header is corrected.
Reference projects and licenses remain recorded in [CREDITS](../CREDITS.md).
The [provenance ledger](renderer-surfaces-provenance.json) records all three
candidates, supporting comparisons, initialized support sections, and execution
hashes. Remaining matching work is tracked in
[issue #75](https://github.com/frankischilling/robotron64/issues/75), related
to #41 and #73. Whole-ROM equality still includes extracted fallback and
does not establish complete source recovery.
