# Collision dispatch initialization

`func_80019E40` covers `0x80019E40..0x8001A168`. Its complete 808-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. The source is
`src/game/collision_dispatch_initialize.c`.

The routine first clears every entry in the ten-by-ten callback matrix.
It then visits the upper triangle, including the diagonal, selects a
handler from two actor-kind indices, and writes that handler into both
`[first][second]` and `[second][first]`. All unlisted pairs remain null.
Kinds five through nine have no additional handlers in their upper rows.

| First kind | Second kind | Callback |
| ---: | ---: | --- |
| 0 | 0 | `func_8001669C` |
| 0 | 1 | `func_80016950` |
| 0 | 2 | `func_80015BF8` |
| 0 | 3 | `func_8001737C` |
| 0 | 4 | `func_80016C1C` |
| 0 | 5 | `func_80017364` |
| 0 | 8 | `func_80016914` |
| 1 | 2 | `func_8001567C` |
| 1 | 3 | `func_80017A2C` |
| 1 | 4 | `func_8001631C` |
| 1 | 5 | `func_80016618` |
| 2 | 2 | `func_800152AC` |
| 2 | 3 | `func_80015F00` |
| 2 | 5 | `func_800162AC` |
| 2 | 7 | `func_800152E8` |
| 2 | 8 | `func_80015B5C` |
| 3 | 4 | `func_80017ACC` |
| 3 | 5 | `func_80017C10` |
| 4 | 5 | `func_80017CDC` |
| 4 | 8 | `func_80017E50` |

The callback consumer at `0x800194DC` loads the matrix using the actors'
kind bytes at `0x1C`. It supplies two actor addresses and two three-word
position vectors, swaps their order according to the kind comparison,
and applies the returned low and high nibbles to the actors' state bytes.
The table's common interface reflects those four arguments and the signed
word result used by that caller. Existing callback declarations retain
their confirmed actor views, integer arguments, or byte results; explicit
function-pointer casts preserve that heterogeneous table interface.
The larger consumer and unrecovered handlers remain fallback.

The matrix is a reconstructed 400-byte BSS definition at
`0x800974A0..0x80097630`. Its row and entry strides are forty and four
bytes in both initializer and consumer. The next address is the existing
selection state, which is separate storage. The source claims no extent
for that neighboring object. Startup clears this matrix within the
confirmed BSS range.

Three compiler-generated jump tables begin at `0x8009013C`,
`0x80090154`, and `0x80090178`, with six, nine, and seven entries.
Together with eight alignment bytes, they occupy the complete 96-byte
span ending at `0x8009019C`. Every relocated entry and alignment byte
matches the ROM. These tables are generated from the C switches.

The comparison includes every instruction, the 56-byte stack frame,
register saves, both loops, symmetric stores, and all three tables.
The [provenance ledger](collision-dispatch-initialization-provenance.json)
records complete bounds, compiler inputs, linked bytes, and the BSS symbol.
All thirteen requested N64 references, pinned revisions, and licenses
remain credited for local and online use in [CREDITS.md](../CREDITS.md).
Further collision recovery is tracked by
[issue #40](https://github.com/frankischilling/robotron64/issues/40)
and [draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
