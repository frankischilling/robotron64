# Actor and renderer services

Nine complete game procedures match all 1,804 instruction bytes with the
pinned IDO 5.3 game profile. The actor counter dispatcher also owns its
complete 48-byte relocated switch table. The
[provenance ledger](actor-and-renderer-services-provenance.json) records
procedure extents, source inputs, section placements and complete byte proofs.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_80005814` | `0x80005814` | 220 | Draw an indexed texture after configuring the renderer |
| `func_8000A2E0` | `0x8000A2E0` | 168 | Compute relative angle and distance from two actor positions |
| `func_8000CEC0` | `0x8000CEC0` | 176 | Allocate and initialize a dynamic actor-group pool |
| `func_8000D1FC` | `0x8000D1FC` | 184 | Append an indexed value to the current pair group |
| `func_8000D2D4` | `0x8000D2D4` | 184 | Append a nine-word parameter record |
| `func_8001B324` | `0x8001B324` | 184 | Mark an actor expired and decrement its counters |
| `func_80045124` | `0x80045124` | 240 | Load four individual vertices and submit two triangles |
| `func_8004ABC8` | `0x8004ABC8` | 220 | Configure texture and RDP state |
| `func_8004CCD0` | `0x8004CCD0` | 228 | Update five peak rendering metrics |

## Dynamic actor-group pool

The allocator reserves and clears exactly `0x2388` (9,096) bytes. It captures
command word `0x04` before diagnostics and allocation, stores the previous
global pool count as the current index, increments the count and reports
counts of eleven or more. After clearing, it explicitly resets words `0x04`,
`0x0C` and `0x08`, then stores the captured value at `0x00`. The source retains
all stores and the original absence of allocation-failure handling.

The shared heap view records these boundaries:

| Offset | Extent | Confirmed content |
| --- | ---: | --- |
| `0x000` | 16 | Value and three count/index words |
| `0x010` | 1,240 | First region, still represented by padding |
| `0x4E8` | 6,040 | Ten pair groups with a 604-byte stride |
| `0x1C80` | 1,800 | Fifty parameter records with a 36-byte stride |

Each pair group has a count followed by fifty eight-byte pairs. Its last
200 bytes remain padding. Pair append checks count 50 before writing but
continues after reporting it. It writes index `-1`, multiplies the supplied
value by ten, and increments the count. The original reset/index helpers
independently use offset `0x4E8` and stride 604.

Parameter append captures nine command words before storing them in the
order `00`, `04`, `14`, `18`, `0C`, `08`, `10`, `1C`, `20`. It increments the
global parameter count and reports exactly 50 after the write. The unchecked
continuation and equality test are preserved. Parameter meanings are not
assigned beyond their observed word offsets. These are heap views, so they
add no source-owned BSS bytes.

## Actor geometry and expiration

Relative geometry subtracts the first two position components, calculates
the wrapped angle relative to the second actor's heading, and calculates
integer distance from the sum of squared components. It writes the angle
before the distance and retains signed 32-bit arithmetic. The third position
component does not enter this calculation.

Expiration saves the old state byte, sets state to two, and only adjusts
counters for actors of kind zero. Old state zero decrements the session's
behavior counter indexed by the resource's kind. Resource kinds 17 through
20 decrement scene word `0x0C`; kinds 9 through 12 decrement word `0x08`.
Other kinds make no scene-counter change. The complete twelve-entry switch
table at `0x800902A4` contains four entries for each decrement and four
default entries. Its relocated bytes are compared independently with code.

## Rendering commands and metrics

The quad routine increments both primitive counters, loads one sixteen-byte
vertex into each of slots zero through three, then submits triangles
`(0, 1, 2)` and `(3, 0, 2)`. Its four input words remain 32-bit addresses.
The target's `0x04` vertex commands and doubled vertex indices match the
F3DEX/F3DLP command encoding described in the reference GBI header.

Texture setup emits a pipe sync, disables color keying and alpha comparison,
selects bilinear filtering and tile LOD, enables texture perspective and
enables texture mapping with scale `0x8000` in both directions. Indexed
texture draw uses an eight-byte table stride, advances its data pointer by
`texture << 10`, and passes the final value to the existing draw body. The
table's total extent and its second word remain unresolved.

The metric record is five signed words with stride 20. The updater clamps
the selected index to 0 through 201, then keeps the maximum render-buffer
byte usage, frame rate, primitive count, matrix count and vertex count in
their original field order. The existing reset clears `0xFB4` bytes, or
201 records, while this updater permits index 201. The source preserves
both bounds. The table's complete allocation is unresolved and remains
address-bound; no new storage ownership is claimed for it.

## References and validation

The pinned local [Super Mario 64 GBI header](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h)
and an online inspection of the same header corroborate command fields,
vertex slots and triangle encodings. The local
[IDO materials](https://github.com/n64decomp/ido) retain the compiler reference
basis. Robotron's complete instructions, allocation size, field accesses
and relocated table determine the accepted game source. No reference header
implementation is copied into these units. All thirteen requested projects
and their recorded revisions are credited in [CREDITS.md](../CREDITS.md).

Validation checks every complete procedure, the owned switch table, all
current independent comparison families and the whole 8,388,608-byte ROM.
Other executable regions still use fallback and remain excluded from these
recovered-source claims.
