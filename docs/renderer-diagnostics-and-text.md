# Renderer diagnostics and font drawing

This recovery owns twelve data units used by the renderer's diagnostic report
and adds five complete C candidates. The candidates are excluded from the
matching ROM build. Their presence does not increase the matching-function or
matching-code totals.

## Report behavior

`func_8004C6E0` at `0x8004C6E0..0x8004CCA4` prints the report once the startup
frame counter reaches ten. It prints the surviving version string
`Robotron64 V22.0 20/8/97 MHG` and the separate date `Oct 23 1997`. These are
internal diagnostic strings, not names for additional supported ROM revisions.

The report covers executable, initialized-data and BSS boundaries; the three
153,600-byte image buffers; asset lengths; seven resource-pool prefixes; heap
and display-list usage; and eight current and peak frame counters. The printed
`MyBss` range actually covers initialized data, while `MyData` covers BSS.
Those labels and the original spelling of the messages are preserved.

The heap report calls `func_8004DCE0` twice. That routine coalesces free heap
blocks while finding the largest block. Both calls remain in the candidate.
The last polygon line in the peak section reads the current counters for
polygons, triangles and quads, just as the retail function does.

Only the two-word count/element-size prefix of each pool is represented by
`DiagnosticResourcePrefix`. This does not establish a complete layout for the
records that follow those prefixes. The word at offset `0x34` of the dynamic
display-list record is likewise represented by a partial prefix.

## Source-owned storage

| Source | RAM range | Kind | Bytes |
| --- | --- | --- | ---: |
| Diagnostic messages | `80095640..80095B30` | Read-only data | 1,264 |
| Version string | `8007D6B0..8007D6D0` | Read-only data | 32 |
| Startup frame counter | `8007D8F0..8007D8F4` | Initialized data | 4 |
| Model, bitmap and animation lengths | `8008D360..8008D36C` | Initialized data | 12 |
| Instance pool prefix | `800781E4..800781EC` | Initialized data | 8 |
| Object pool prefix | `80077AA0..80077AA8` | Initialized data | 8 |
| Movie pool prefix | `80072BE8..80072BF0` | Initialized data | 8 |
| Path pool prefix | `80072BE0..80072BE8` | Initialized data | 8 |
| Vertex pool prefix | `8007CDA0..8007CDA8` | Initialized data | 8 |
| Matrix pool prefix | `8007D6A0..8007D6A8` | Initialized data | 8 |
| Hierarchy pool prefix | `8007C548..8007C550` | Initialized data | 8 |
| Current and peak frame counters | `80126B30..80126B70` | BSS | 64 |

The initialized contribution is 1,368 bytes. BSS contributes 64 bytes.
The vertex prefix records 22,000 elements of 16 bytes. The matrix prefix records
500 elements of 64 bytes, consistent with the already recovered two banks of
250 SDK matrices. These values do not establish a larger local `FixedMatrix`
or draw-state structure.

## Excluded C candidates

The full function ranges are registered in `CANDIDATE_BLOCKS`, and their entire
compiled text is compared with the retail bytes. None is registered in the
matching function manifest or selected by a ROM-build rule.

| Function | Purpose | Retail bytes | Compiled bytes | Differing words |
| --- | --- | ---: | ---: | ---: |
| `func_800496E0` | Fatal formatter, report call and infinite wait | 512 | 496 | 31 |
| `func_80049E3C` | Font glyph at the current text position | 1,144 | 1,184 | 137 |
| `func_8004A2B4` | Font glyph attached to an object draw state | 1,024 | 1,024 | 16 |
| `func_8004B590` | One- or two-player HUD | 1,588 | 1,584 | 323 |
| `func_8004C6E0` | Resource and renderer diagnostic report | 1,476 | 1,476 | 18 |

The sixteen object-glyph differences are stack and local offsets. Its current
frame is 160 bytes; the retail frame is 176. The report's remaining differences
are concentrated in caching the BSS-end address and scheduling its heap queries.
These unresolved candidates are tracked in [issue #61](https://github.com/frankischilling/robotron64/issues/61).

The glyph functions select 1,024-byte images from the font buffer, align the
image address down to eight bytes, and submit four vertices. No font image or
HUD texture data is published. Characters 14, 15 and `[` use blue, green and
red glyphs respectively; other glyphs use a white-to-configured-color gradient.
The screen glyph advances the text position only when vertex allocation succeeds.

The object glyph temporarily replaces the camera matrix in its alternate mode.
It restores the saved matrix only inside the successful-allocation branch.
The failure path therefore retains the replacement matrix. The retail function
does not explicitly set its return register, while its recovered object caller
propagates an integer result. The candidate preserves that unresolved return
behavior instead of supplying an invented success value.
Its candidate definition uses `void`; the caller's integer declaration remains
an unresolved mismatch between translation units.

The HUD retains both players' score, level and life displays, the five power
icons, the optional frame-rate digits, and the temporary level message. Arguments
whose meaning is not established retain neutral names. The three numeric glyph
helpers it calls already have matching sources.

Useful local-value, declaration-order, color-store, pointer and argument-type
probes were compiled against complete function ranges. A bounded diagnostic
permuter run did not produce a verified match. No dummy local, enlarged type,
inline assembly, instruction patch or partial-function substitution was added.
The exact current differences are recorded in
[`renderer-diagnostics-and-text-provenance.json`](renderer-diagnostics-and-text-provenance.json).

## Verification

The data-only comparisons check the full initialized ranges, symbol offsets,
section placement and BSS lengths using the pinned IDO 5.3 compiler. Full ROM
verification remains dependent on extracted fallback bytes for the five
candidates and the other unrecovered code. A matching ROM build with those
fallbacks is not completion of the source decompilation.

The provenance ledger records the twelve data comparisons, five candidate
comparisons and existing renderer/heap regressions. Existing renderer-effect and
matrix ledgers are refreshed when shared headers or ownership metadata change.
