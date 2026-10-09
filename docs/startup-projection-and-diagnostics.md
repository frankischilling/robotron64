# Startup projection and diagnostic report

The complete resource report at `8004C6E0..8004CCA4` matches the retail
instructions from `src/game/renderer_diagnostics/report.c`. Its 1,476 bytes
replace executable fallback. The startup projection routine at
`80048DDC..8004913C` now reproduces all 864 instruction bytes from
`src/game/renderer_projection/setup.c`. Its complete natural extent replaces
executable fallback. The [current projection ledger](startup-projection-current-provenance.json)
records the fresh source acceptance; the report and data retain their existing ownership.

## Diagnostic report

The report prints only when the startup frame counter is at least ten.
It preserves the original version, date, memory-region labels, pool sizes,
current counters, peak updates, and the final peak-polygon line's reads of
the current counters. Its messages and resource prefixes already have
verified source ownership.

The two calls to the largest-free-block helper occur before the report reads
the heap's first-block pointer. Both calls can coalesce free blocks and remain
in the source. The report uses the first result to calculate occupied space
and prints the second result as the available block size. It preserves the
original unsigned address arithmetic and the integer representation used for
the BSS-end address. The local BSS-end value is used again to calculate the
gap before the image buffers. No unused local or enlarged record is needed
for the match.

## Startup projection

The startup and frame-service callers pass their existing matrix-buffer
pointer. The routine writes a perspective matrix into the current buffer's
64-byte slot and a view matrix at that slot plus `0x80`. It computes the field
of view from the existing angle helper with inputs 480 and the view record's
first word, multiplies by 360 in double precision, and divides the result by
4096 through multiplication by `0.000244140625`.

The two light coordinates are sine and cosine of the frame angle multiplied
by `0.0061359182f`, then scaled by 75 in double precision. The routine increments
the angle by eight after reading it for both coordinates. It uses aspect
`1.3333333730697632f`, near plane 100, far plane 50000, and perspective scale
one. The existing SDK perspective routine writes the normalization halfword.

The SDK look-at/highlight call writes at offsets `0x1C0` and `0x200`. Its eye
is at the origin, its target is `(0, 0, 400)`, and its up direction is
`(0, 1, 0)`. The first light uses the animated coordinates and Z=-70; the
second uses `(100, 0, 0)`. Both texture dimensions are 32.

The display list receives two look-at commands, perspective normalization,
and the projection/view matrix pair. Separate SDK calls create zero translation
and rotation matrices at offsets `0x2A0` and `0x260`; the final commands submit
those matrices. The source preserves the target's differing address
conventions for look-at data and physical matrix addresses.

These offsets establish the accessed fields. They do not establish a complete
original matrix-buffer structure. The source keeps the existing byte-address
view rather than inventing fields in unobserved gaps.

## Constants and state

| Source | RAM range | Kind | Bytes |
| --- | --- | --- | ---: |
| Projection constants | `80095438..80095468` | Initialized constants | 48 |
| Animated light coordinates | `8007D904..8007D90C` | Initialized data | 8 |
| Perspective normalization | `8013D950..8013D952` | BSS | 2 |

The constants source defines the observed double 360, float angle multiplier,
double 75, second float angle multiplier, second double 75, and float far plane.
Compiler alignment supplies the intervening and final zero bytes. IDO emits
these external scalar constants in its `.data` input section; the linker places
that section at the observed constant addresses. These address-based names
are analysis names for the literal pool, not recovered original symbols. The two
light coordinates start at float zero and float one. Existing matching
projection/highlight and matrix-submission routines confirm their types.
The normalization word is written through the SDK's unsigned-short pointer
and consumed by the matching frame-matrix command helper. The six bytes after
that word are outside this ownership claim.

## Matching evidence

The report uses the pinned IDO 5.3 game profile. Projection uses the unchanged
verified R4300 multiply profile of the neighboring projection/highlight routine.
Its natural and complete raw text are both 864 bytes, with a 184-byte frame and
216 matching instructions. No alignment bytes are credited and no new data or
BSS is added. Splat and spimdisasm independently reassemble the full retail range.

The final two matrix packets reuse one consumed `FrameCommand *` local through
`FRAME_COMMAND_REUSE`. This gives IDO the retail look-at pointer home at stack
offset `0x6C`. The macro keeps each allocation and packet write in one expansion,
preserving the retail assembler schedule. Separate statement lines change eight
scheduling words despite preserving the pointer home. The ordinary packet scopes
and shared final pointer reproduce all bytes without changing compiler flags.
Original source spelling and local names remain unknown.

The public checker runs 396 pairs / 792 principal executions. Thirteen complete
matching C support units and the eight-byte SDK square-root routine execute real
instructions; no ABI stubs execute. Fresh support comparisons cover 6,944 code
bytes and 516 initialized bytes. A separate rounded arithmetic and fixed-matrix
model checks perspective, look-at, highlight, complete buffer gaps, all seven
packets, globals and O32 arguments. Every guest instruction, read and write is
bounded. State and stack canaries, GP/SP, saved integer registers and twelve
distinct F20..F31 values are checked. The SDK rotation initializer's four-byte
write stays within its already owned static BSS object.

Seven isolated source faults and three actual guest invalid-access probes fail
after positive controls. Reproduce the bounded checks with:

```sh
python3 tools/check_startup_projection.py
python3 tools/check_startup_projection.py --controls
```

Fixtures cover finite widths and angles, two separate buffers and matrix indices
zero and one. Nonfinite floating-point exceptions, arbitrary global aliasing,
RSP/RDP results and complete gameplay remain unverified. Whole-ROM equality still
includes other extracted fallback and does not establish full source recovery.

The [original report/data ledger](startup-projection-and-diagnostics-provenance.json)
preserves its earlier nonmatching projection checkpoint. Current projection
ownership and full validation appear in the separate current ledger. The local
SM64, SDK and IDO references and the analysis tools are credited in
[CREDITS](../CREDITS.md), [the reference study](reference-study.md) and
[the toolchain notes](toolchain.md). No reference game's implementation is copied.

The existing diagnostic and font issue remains open for its other candidates:
[issue #61](https://github.com/frankischilling/robotron64/issues/61).
The remaining startup projection stack slot is tracked by
[issue #71](https://github.com/frankischilling/robotron64/issues/71).
Renderer recovery remains tracked by
[issue #41](https://github.com/frankischilling/robotron64/issues/41).

Robotron's retail instructions and matching consumers establish these behaviors.
The pinned local libreultra, SM64, and Zelda GBI definitions were inspected for
look-at command scope and SDK layouts. All thirteen requested N64 reference
projects, revisions, and licenses remain credited in [CREDITS](../CREDITS.md).
Full ROM verification still uses fallback for unrecovered procedures and does
not mean that source recovery is complete.
