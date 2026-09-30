# Early game helper recovery

The early-game recovery replaces 820 bytes of fallback code with twenty-two
complete IDO 5.3 functions. The helpers cover renderer color state, render
presets, forwarding entry points, pool bookkeeping, callback constants, a
byte clear, actor state updates, and 12-bit signed-angle normalization.

| Source | Functions | Bytes |
| --- | --- | ---: |
| `early_actor_tick.c` | `func_80009F58` | 56 |
| `early_render_color.c` | `func_8000A200` | 28 |
| `early_render_presets.c` | `func_8000B964`, `func_8000B99C` | 112 |
| `early_render_dispatch.c` | `func_8000BE80`, `func_8000BEA0` | 64 |
| `early_pool_entry_clear.c` | `func_8000CF70` | 44 |
| `early_pool_count.c` | `func_8000D034`, `func_8000D054` | 92 |
| `early_pool_index.c` | `func_8000D2B4` | 32 |
| `early_byte_clear.c` | `func_8000D614` | 12 |
| `early_angle_normalize.c` | `func_8000DF14` | 28 |
| `early_actor_vector_clear.c` | `func_8000EAE4` | 20 |
| `early_global_reset.c` | `func_8000ECD0` | 20 |
| `early_callbacks_true.c` | `func_80015100`, `func_80015118` | 48 |
| `early_actor_mode3.c` | `func_80015BD4` | 36 |
| `early_actor_guarded_service.c` | `func_800162AC` | 76 |
| `early_actor_mode0.c` | `func_800162F8` | 36 |
| `early_six_arg_forward.c` | `func_80016914` | 60 |
| `early_callback_false.c` | `func_80017364` | 24 |
| `early_simple_forward.c` | `func_8001B448` | 32 |

`EarlyGamePoolState` names only the three leading words established by the
access patterns at `0x8000CF70`, `0x8000D034`, `0x8000D054`, and
`0x8000D2B4`. The entry-clear helpers retain byte-offset arithmetic for the
larger records whose full layouts are not yet recovered.

The renderer preset routines set the shared RGB state before forwarding to
the existing mode helper. The pair at `0x8000BE80` and `0x8000BEA0` are
separate retail entry points even though both forward their argument to the
same target routine.

The later wrapper group retains the original callback-shaped entry points.
Two return one, one returns zero, two select fixed actor modes, one forwards
its third and fourth inputs as stack arguments to a six-argument service, and
one preserves both incoming arguments while forwarding to `func_80009F90`.

The new actor-state leaves preserve the retail field operations directly.
`func_80009F58` advances one counter, applies the frame delta to another, and
sets state two after that value crosses below zero. `func_8000EAE4` clears the
three actor words at `0x6C`, `0x70`, and `0x74`. `func_8000ECD0` resets the
shared value at `D_8009EE04` to `-1`. `func_800162AC` conditionally forwards to
`func_80035244` unless animation one is active or either `0x4400` flag is set,
then returns `0x20`.

Canonical current-source verification is registered in
`tools/compare_runtime.py`. Source and comparison-result hashes are retained
in `early-game-provenance.json`. All functions compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`.
