# Early quad rendering and command-file execution

`func_8000B06C` is a complete 376-byte source match at
`0x8000B06C..0x8000B1E4`, ROM `0xBC6C..0xBDE4`. IDO 5.3 with the existing
game profile reproduces every instruction byte. Two data-only units also
own 352,016 BSS bytes. The separate command-file executor candidate is
excluded from the matching build and source totals.

## Quad submission

The function receives four pointers to three signed 32-bit position words.
It writes four consecutive 16-byte hardware vertices beginning at
`D_800CDBD0[D_80123AE4]`. Coordinates are stored as halfwords, so the target's
truncation is preserved. All four vertices receive alpha 128 and the current
color words: red from `D_80138270`, green from `D_80138274`, and blue from
`D_8013826C`.

Three eight-byte commands follow. The vertex-load word `0x0400103F` describes
four vertices starting at hardware vertex zero in the older F3DEX-compatible
packing. The two `0xB1` packets encode triangle pairs `(1, 2, 3)` / `(1, 3, 0)`
and `(2, 1, 0)` / `(2, 0, 3)`. Those pairs draw both orientations of the quad.
The arena cursor advances by four and the display-list cursor advances by
24 bytes.

The local libreultra `2.0I/PR/gbi.h` vertex and two-triangle macros establish
the packet interpretation. This does not settle which graphics microcode
the game selects; issue #6 continues that investigation. The source uses
the repository's existing `FRAME_COMMAND` helper and target-derived words.
No reference implementation was copied.

Direct arena indexing matters for IDO's alias analysis. A candidate that
wrote through a cached vertex pointer produced the same values but delayed
the first packet-pointer load, leaving three load-delay slots empty and
expanding the complete function to 400 bytes. Direct indexed writes resolve
that difference with ordinary C. No unused declarations, stack padding,
instruction patching, or inline assembly are required.

## Source-owned storage

| Source | Address | Bytes | Definition |
| --- | --- | ---: | --- |
| `renderer_vertex_arena_data.c` | `0x800CDBD0` | 352,000 | 22,000 doubleword-aligned `RendererVertex` records |
| `early_render_color_data.c` | `0x80138268` | 16 | Projection-angle word followed by blue, red, and green words |

The arena ends at `0x80123AD0`, before the renderer's state words. The
existing frame-reset routine selects starts 2,000 and 12,000; each frame's
vertex limit is 10,000. The shared vertex declaration and observed state
boundary give the 22,000-record extent. All compiled symbol offsets,
alignment, section sizes, linker placement, and overlap checks are verified.
These are BSS definitions, not initialized ROM data or extracted assets.

`func_8000A200` supplies the three color words. The existing projection
routine `func_8004913C` increments the preceding angle word by eight and
uses it for its highlight setup. Both callers now use the common declarations
in `early_render_internal.h`, and their complete matches are rechecked.

## Command-file executor

`src/game/command_scripts/execute.c` reconstructs `func_8003264C` at
`0x8003264C..0x800327AC`, ROM `0x3324C..0x333AC`. It changes the caller's
filename extension to `.TOK`, loads the file, and visits 32-bit command words.
The low fifteen opcode bits select an eight-byte `CommandScriptEntry`.
Each record contains a handler and argument count; advancing past a record's
command consumes `argumentCount + 1` words.

`-1` sets the stop flag. A handler runs when it is present and either the
machine-enable word is set or the opcode selects entry zero. A handler can
also set the stop flag. The allocation is released after the loop, the stop
flag is cleared, and normal completion returns one. A missing allocation
reports the existing diagnostic and returns zero. The unused mode argument
and the unused signed 16-bit loop counter remain in the reconstruction
because the target retains them.

The complete 352-byte procedure now matches and replaces its ROM fallback.
Reusing the named raw opcode for the masked index recovers the target's
temporary lifetimes. The two terminated strings also own 36 initialized
bytes. See [the current comparison and layout evidence](actor-effects-and-command-scripts.md)
and its provenance ledger. The earlier four-word comparison below records
the excluded candidate before this promotion.

## Verification

The accompanying [provenance record](early-render-command-streams-provenance.json)
records the complete quad extent, compiler/toolchain identities, current
source and header hashes, both BSS units, and the excluded executor result.
Acceptance also requires the full runtime, startup, assembly, and data
comparisons, tooling tests, fresh extraction/build, publication audit, and
both public CI runs. A ROM match with fallback bytes does not establish that
the remaining game source is recovered.
