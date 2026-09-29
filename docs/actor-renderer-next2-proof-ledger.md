# Actor and renderer continuation proof ledger

This checkpoint adds four complete procedures covering 284 target bytes. Each
source was compiled with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32`,
linked at its target VRAM address against the current symbol layout, and
compared across the complete procedure extent.

| Source | Procedure | Extent | Bytes | Result |
| --- | --- | --- | ---: | --- |
| `src/game/game_string_case_compare_n.c` | `func_8003B838` | `0x8003B838..0x8003B8E0` | 168 | 0 differing words |
| `src/game/runtime_random.c` | `func_8004CDE8` | `0x8004CDE8..0x8004CE08` | 32 | 0 differing words |
| `src/game/runtime_float_truncate.c` | `func_8004CE70` | `0x8004CE70..0x8004CEB0` | 64 | 0 differing words |
| `src/game/actor_history_byte_clear.c` | `func_8004EB60` | `0x8004EB60..0x8004EB74` | 20 | 0 differing words |

`mips-linux-gnu-nm -S` reports exact text sizes `0xA8`, `0x20`, `0x40`, and
`0x14` for these procedures. Their built objects contain only the matched
`.text` section and introduce no private allocated data. The typed call from
`func_80029D6C` was independently recompiled and remains an exact 44/44-byte
match after passing its actor argument to `func_8004EB60`.

The focused aggregate comparison is
`build/worker3-actor-renderer/report.json`, SHA-256
`e88be4f9ea9d0ee34baad1befc94949e9efc03060d54eb4f1335c56813949343`.
The accepted target ROM has SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

`make test` passes all 108 tests. The manifest validates 939 function records
and 29 source-owned data/BSS sections. A clean `make -j2 verify` rebuild
matches all 8,388,608 bytes of the target ROM with the same SHA-256 above.

Fallback ranges remain in place before and after every recovered extent. The
near-match candidates at `0x80030FEC`, `0x8003264C`, and `0x8003B734` remain
fallback until their complete procedures compile byte-identically.
