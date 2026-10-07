# Actor resource storage

Seven complete resource definitions replace absolute linker bindings with
28,312 bytes of C-owned BSS. The matching 400-byte reset at
`8001D260..8001D3F0` establishes each count and stride from its original pointer
increments and end bounds. Gaps between these ranges remain unowned.

| Symbol | C type and count | Complete range | Bytes |
| --- | --- | --- | ---: |
| `D_800B1BE8` | `TextGlyphResource[244]` | `800B1BE8..800B6FC8` | 21,472 |
| `D_800AF1F0` | `ActorResource68Internal[36]` | `800AF1F0..800B0090` | 3,744 |
| `D_800ACE58` | `TextGlyphResource[8]` | `800ACE58..800AD118` | 704 |
| `D_8009AA00` | `ActorResource5CInternal[16]` | `8009AA00..8009AFC0` | 1,472 |
| `D_8009AFD8` | `TextGlyphResource[4]` | `8009AFD8..8009B138` | 352 |
| `D_8009B138` | `TextGlyphResource` | `8009B138..8009B190` | 88 |
| `D_8009EA18` | `ActorResource60Internal[5]` | `8009EA18..8009EBF8` | 480 |

The already owned eleven child records at `800AC998..800ACD8C` participate in
the same reset and are checked without adding their 1,012 bytes again. The
reset clears bit `0x80` of the byte at offset six in all other records, or
offset ten in the five 96-byte records. It repeats the first sixteen primary
records. This second pass is retained, giving 341 flag-byte reads and writes.
All other flag bits and record bytes are preserved.

The existing Ghidra analysis now has seven uninitialized, non-executable
blocks and complete array types with these exact bounds. Applying the types
leaves existing code units and labels intact. A pinned IDO probe agrees with
Ghidra on the sizes, alignments, offsets and widths of all 52 ordinary fields
in the five resource views, including the loader's overlapping 88-byte view.
The projection pointer `D_8009B168` lies at offset `0x30` in the singleton
`D_8009B138`, sharing the bytes of `animation.tracks[2]`. Its bounded context
view reads a signed halfword at offset `0x0A`, the same position as the
animation view's `loopIndex`. This does not add a separate storage object or
establish the meaning of the other context bytes.

The resource loader's matching range at `8001CF68..8001D260` establishes the
88-byte view, including model and texture handles, names, ten animation
pointers, and the loaded flag. Its already-loaded path returns two without
accessing those handles or calling another function. The enemy speed and
tweak consumers use the 104-byte stride; child and effect consumers use the
92-byte and 88-byte views. Early resource arguments use the 96-byte view.
Unknown fields keep their existing offsets and names.

Each data-only translation unit is independently compiled with pinned IDO.
The ownership checker verifies the complete NOBITS section, symbol offset,
linker address and size, and rejects executable or initialized content.
Compiler alignment beyond the declared object is checked before trimming.
The linker places each section as `NOLOAD` and asserts its address, extent and
base symbol. Primary-record aliases are expressions relative to the source
array and add no storage.

`tools/check_actor_resource_storage.py` executes the original and freshly
compiled reset against an independent model of all eight complete pools. It
checks the complete records, guarded gaps, the repeated flag writes, instruction
and memory bounds, and preserved O32 registers. The loader's already-loaded
path is checked at every record in the seven compatible pools; no loader
callee is stubbed or permitted to execute on that path. Reset behavior and
this bounded loader path do not establish model loading or complete gameplay.

Twelve reset cases per image combine three byte patterns with loaded flags
clear, set, alternating and inverse alternating. Another 960 cases per image
cover every one of the 320 records with a flag at offset six and geometry
arguments zero, one and minus seventeen. This gives 1,944 target-function
executions. The model checks all 29,324 pool bytes and the entire 116,200-byte
arena spanning their guarded gaps. The loader checks its seven saved-register
stores and restores against the complete stack model and returns two.

Six isolated source mutations fail after an unmodified positive control:
shortening or overrunning the primary pool, setting its loaded flag,
shortening the repeated pass, shortening the secondary pool and clearing
the complete early-resource flag halfword. Access counts detect the shortened
duplicate pass even though its final memory contents are unchanged.

Run the checks with the optional analysis environment:

```sh
.venv/bin/python tools/compare_data.py
.venv/bin/python tools/check_actor_resource_storage.py --mutations
```

The [verification ledger](actor-resource-storage-provenance.json) records the
complete data and code comparisons, layout evidence, guarded executions and
mutation controls. This storage recovery adds no functions or initialized ROM
bytes. Analysis tools and reference projects are credited in
[CREDITS](../CREDITS.md).
