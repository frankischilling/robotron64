# Early game state proof ledger

The accepted sources compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`. Linked comparison reports use the current
symbol layout and validated US ROM. Each accepted report must record
`matches: true`, zero differing instruction words, and no owned-data errors.

| Source | Source SHA-256 | Procedures | Bytes |
| --- | --- | --- | ---: |
| `src/game/early_float_step.c` | `eb3ec4cc3deeac401b482d5498af64468dea6edefa3a3473ed3cd02b95e037ca` | `func_80012690` 0x50 | 80 |
| `src/game/early_selection_state.c` | `540ec304548c9e88da13efd36e3836039edf3318e5c85193d0c8996b6feda90d` | `func_8001276C` 0x120; `func_8001288C` 0xC4 | 484 |
| `src/game/early_actor_create.c` | `03e5630d39bd6b8101c308637886c3d890d05be9db3abd2f5b45c8effe007ed3` | `func_80015184` 0x94; `func_80015218` 0x94; `func_800152AC` 0x3C | 356 |
| `src/game/early_actor_state.c` | `afb1729d1c7c2b758159134ac2dbd6dc31fb632b90f5693fa1a4a1f242adb0f5` | `func_80015554` 0xC0; `func_80015614` 0x68 | 296 |

The focused canonical comparison is
`build/worker4-early-game-state/report.json`, SHA-256
`368d7fb14a3b86763b0b879b039f1a4277e079b659f7bb1fbeb5a8b7fbb8ac40`.
It records four matching blocks, zero differing instruction words, and
1,216/1,216 target bytes. `mips-linux-gnu-nm -S` reports the procedure extents
listed above. `tools/owned_sections.py` reports no owned sections for any of
the four source files, and the IDO objects contain no private allocated data.

The manifest records all eight function boundaries separately while the linker
keeps `0x800126E0..0x8001276C`, `0x80015130..0x80015184`, and
`0x800152E8..0x80015554` as fallback gaps. The extraction ranges cover those
gaps explicitly, so no unverified bytes are attributed to these sources.

The integrated `make -j2 verify` rebuild matched all 8,388,608 bytes of the US
target and reported SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
