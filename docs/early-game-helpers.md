# Early game helper recovery

The first early-game recovery tranche replaces 412 bytes of fallback code with
eleven complete IDO 5.3 functions. The helpers cover renderer color state,
two render presets, two forwarding entry points, pool bookkeeping, a byte
clear, and 12-bit signed-angle normalization.

| Source | Functions | Bytes |
| --- | --- | ---: |
| `early_render_color.c` | `func_8000A200` | 28 |
| `early_render_presets.c` | `func_8000B964`, `func_8000B99C` | 112 |
| `early_render_dispatch.c` | `func_8000BE80`, `func_8000BEA0` | 64 |
| `early_pool_entry_clear.c` | `func_8000CF70` | 44 |
| `early_pool_count.c` | `func_8000D034`, `func_8000D054` | 92 |
| `early_pool_index.c` | `func_8000D2B4` | 32 |
| `early_byte_clear.c` | `func_8000D614` | 12 |
| `early_angle_normalize.c` | `func_8000DF14` | 28 |

`EarlyGamePoolState` names only the three leading words established by the
access patterns at `0x8000CF70`, `0x8000D034`, `0x8000D054`, and
`0x8000D2B4`. The entry-clear helpers retain byte-offset arithmetic for the
larger records whose full layouts are not yet recovered.

The renderer preset routines set the shared RGB state before forwarding to
the existing mode helper. The pair at `0x8000BE80` and `0x8000BEA0` are
separate retail entry points even though both forward their argument to the
same target routine.

Canonical current-source verification is registered in
`tools/compare_runtime.py`. Source and comparison-result hashes are retained
in `early-game-provenance.json`. All functions compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`.
