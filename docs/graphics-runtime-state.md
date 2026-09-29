# Graphics runtime state helpers

Four complete helpers provide 140 bytes of matching C in the graphics runtime
range beginning at `0x80049DB0`.

| Function | Code bytes | Behavior |
| --- | ---: | --- |
| `func_80049DB0` | 40 | Append render-mode packet `0xB9000002, 0`. |
| `func_80049DD8` | 28 | Store three caller-supplied words in the `0x8013D9A0` state triplet. |
| `func_80049DF4` | 28 | Store three caller-supplied words in the `0x8008CB24` state triplet. |
| `func_80049E10` | 44 | Store `value >> 4` and the floating-point scale `value / 256`. |

The routines use the existing `FrameCommand` packet abstraction and otherwise
touch only the target addresses visible in the retail instructions. The
integer divisor in `func_80049E10` is intentional: under IDO 5.3 it retains
the target `256.0f` conversion/division sequence instead of folding the
operation into a reciprocal multiply.

The complete linked USA ROM matches the reference byte-for-byte after these
helpers replace their fallback range. Compilation uses IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`.
