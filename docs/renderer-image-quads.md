# Image quad submission

Four complete renderer procedures load a texture and submit a square from
the dynamic vertex arena.

| Function | Range | Instruction bytes | Position plane |
| --- | --- | ---: | --- |
| `func_8004A6B4` | `0x8004A6B4..0x8004A938` | 644 | XY |
| `func_8004A938` | `0x8004A938..0x8004ABBC` | 644 | XZ |
| `func_8004AD64` | `0x8004AD64..0x8004AFA4` | 576 | XY |
| `func_8004B098` | `0x8004B098..0x8004B2D8` | 576 | XY |

The first pair sets the shared signed extent `D_8008CB20` to 500. Its
complete four-byte initial value is 25 at `0x8008CB20..0x8008CB24`; the
existing renderer platform initializer also restores 25. The source owns
this mutable scalar. The other two procedures take the signed extent as a
parameter and do not change that global.

## Texture and vertex behavior

The first three procedures align the input image address down to eight
bytes and cache it in `D_80123B00`. They emit the eight commands for a
32-by-32 color-indexed, eight-bit texture block. The load uses the SDK's
16-bit load-block representation, followed by an eight-bit render tile.
The fixed pair uses texture coordinates 0 and 1984. The parameterized
indexed quad retains coordinates 0 and 4096 with the same texture load.

The RGBA procedure preserves the supplied address, writes both
`D_80123B00` and `D_80123B04`, and uses the 16-bit RGBA load and render
tile words. Its texture coordinates are also 0 and 4096. Its XY positions
reverse the Y signs used by the indexed square.

Texture setup occurs before vertex allocation in all four functions. An
allocation result of -1 skips vertex writes, vertex-load and quad commands,
and the four-vertex cursor advance. The texture commands and address cache
writes remain observable on that path.

On success, the functions write four positions, white RGB components, and
the current alpha byte. Direct global arena indexing for positions and a
local pointer for colors and texture coordinates reproduce the target's
register allocation. Each vertex's alpha write follows its RGB writes.
The first vertex writes RGB in ascending component order; the remaining
vertices write the components in descending order. The source also retains
the individual texture and position store orders present in the target.

Both fixed squares emit the forward and reverse quad windings. The
parameterized indexed quad emits the reverse winding, and the RGBA quad
emits the forward winding. Each successful path calls the existing dynamic
vertex cursor helper with four.

## Complete comparison

The fixed squares form one contiguous 1,288-byte C translation unit.
The parameterized indexed and RGBA functions each form a complete 576-byte
unit. The intervening function at `0x8004AFA4` remains extracted fallback
code and is excluded from these totals.

All units use the verified IDO 5.3 game profile:
`-O2 -G 0 -non_shared -mips1 -32`. Acceptance requires all 2,440 instruction
bytes, the four initialized extent bytes, linked function types, sizes and
placement, current source and header input identities, and full ROM equality.
Only unused zero alignment at the ends of compiler sections is trimmed.
No instruction patches, inline assembly, or unused local padding appear in
these procedures. Complete hashes and source ownership are recorded in
[the provenance ledger](renderer-image-quads-provenance.json).

A clean Git archive of `0c0b02e` passed fresh extraction, the complete build,
all 137 tooling tests, and byte-for-byte ROM verification. Independent
comparisons passed for all 783 runtime units, both startup units, 18 assembly
units, and eight data-only units. Linked progress confirms 1,298 matching C
functions with 216,544 instruction bytes, 9,531 initialized bytes, and
30,341 BSS bytes. The explicit 1,255-file inventory passes the publication
audit. Executable fallback remains outside these matching source totals.

## References

Local Super Mario 64 `include/PR/gbi.h` and libreultra
`include/2.0I/PR/gbi.h` supply the image format, size, tile and load-block
field definitions. Their online sources were consulted as well:
[Super Mario 64 GBI definitions](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h)
and [libreultra GBI definitions](https://github.com/n64decomp/libreultra/blob/master/include/2.0I/PR/gbi.h).
Robotron's complete comparisons establish its addresses, store order,
texture coordinates, failure paths, and winding choices. Pinned reference
revisions and notices appear in [CREDITS.md](../CREDITS.md). Further renderer
recovery is tracked in issue #41.
