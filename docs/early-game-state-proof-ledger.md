# Early game state proof ledger

The accepted sources compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`. Linked comparison reports use the current
symbol layout and validated US ROM. Each accepted report must record
`matches: true`, zero differing instruction words, and no owned-data errors.

| Source | Source SHA-256 | Procedures | Bytes |
| --- | --- | --- | ---: |
| `src/game/early_float_step.c` | `eb3ec4cc3deeac401b482d5498af64468dea6edefa3a3473ed3cd02b95e037ca` | `func_80012690` 0x50 | 80 |
| `src/game/early_selection_state.c` | `540ec304548c9e88da13efd36e3836039edf3318e5c85193d0c8996b6feda90d` | `func_8001276C` 0x120; `func_8001288C` 0xC4 | 484 |
| `src/game/early_actor_pair_balance.c` | `767adca8fa4b4c85e63da16b2cef0f3591de738e0478eee437c5ee3fad2f5271` | `func_80015130` 0x54 | 84 |
| `src/game/early_actor_create.c` | `609d0019e4cad9100c24a57fe39ad4dd4394cb1de5b97cafd73ba25771c53abc` | `func_80015184` 0x94; `func_80015218` 0x94; `func_800152AC` 0x3C | 356 |
| `src/game/early_actor_state.c` | `85df2bcafe131ce240243ea549cafe23831bf9171e42a8bc6edb98347eed5902` | `func_80015554` 0xC0; `func_80015614` 0x68 | 296 |

The current focused canonical comparison is
`build/worker1-early-game-state-next/report.json`, SHA-256
`07c0f34ce495bb04462906d5a5e67f57c4171d8dd7d59a85d7e425f42de9a7a0`.
It records five matching blocks, zero differing instruction words, and
1,300/1,300 target bytes. `mips-linux-gnu-nm -S` reports the procedure extents
listed above. `tools/owned_sections.py` reports no owned sections for any of
the five source files, and the IDO objects contain no private allocated data.

The manifest records all nine function boundaries separately while the linker
keeps `0x800126E0..0x8001276C` and `0x800152E8..0x80015554` as fallback gaps.
The extraction ranges cover those
gaps explicitly, so no unverified bytes are attributed to these sources.

The integrated `make -j2 verify` rebuild matched all 8,388,608 bytes of the US
target and reported SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
