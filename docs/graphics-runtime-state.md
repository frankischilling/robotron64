# Graphics runtime state helpers

Six complete helpers provide 868 bytes of matching C in the graphics runtime
range beginning at `0x80049AD8`.

| Function | Code bytes | Behavior |
| --- | ---: | --- |
| `func_80049AD8` | 212 | Cache a palette pointer and emit the seven palette upload/load synchronization packets. |
| `func_80049BAC` | 516 | Initialize renderer state, upload the default palette, emit fixed combine/render/geometry state, and set `D_8008CB20` to 25. |
| `func_80049DB0` | 40 | Append render-mode packet `0xB9000002, 0`. |
| `func_80049DD8` | 28 | Store three caller-supplied words in the `0x8013D9A0` state triplet. |
| `func_80049DF4` | 28 | Store three caller-supplied words in the `0x8008CB24` state triplet. |
| `func_80049E10` | 44 | Store `value >> 4` and the floating-point scale `value / 256`. |

The routines use the existing `FrameCommand` packet abstraction and otherwise
touch only the target addresses visible in the retail instructions. The
palette helper stores its input in `D_80123B04` before issuing the same
`FD100000`, tile/load synchronization, and `BA000E02` sequence used by the
frame path. The initializer calls `func_800466E4`, uploads the palette at
`D_8007D920`, then reproduces the target command words before writing 25 to
`D_8008CB20`. The
integer divisor in `func_80049E10` is intentional: under IDO 5.3 it retains
the target `256.0f` conversion/division sequence instead of folding the
operation into a reciprocal multiply.

The complete linked USA ROM matches the reference byte-for-byte after these
helpers replace their fallback range. Compilation uses IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`.
The canonical comparison registration and current-source proof hashes are
recorded in [`objects-renderer-provenance.json`](objects-renderer-provenance.json).
