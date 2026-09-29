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

The retained `func_8003B838` source has SHA-256
`42cd56d58e4540b43b5e051a44d0817a84939da0bb4cd2094cb302784a0265b9`;
its exact comparison report has SHA-256
`8acb447151a64410f2fcd256d05af7f6f423bb23bb5e6f200ad3044e593db9f3`.
Three ordinary simplifications were checked with the same compiler profile:
direct assignment to the byte local, assignment in the zero-test condition,
and direct assignment to an `int`. Their reports are retained as
`b838_uchar_direct`, `b838_uchar_condition`, and `b838_int_direct` under
`.local/recovery-worker3-next2/probes/`; each keeps the complete 168-byte size
but differs at `0x8003B8A0` and `0x8003B8A8` because IDO chooses `v0` instead
of the target's `t6`. Their report SHA-256 values are
`9dc833b26be20865a00d8edff340172dd91c3d126b6f80e8a2e3905ae3af9a86`,
`441f24c5c46e86992fc3e30201844d7532cd4c568530f028a07526f9fe2e9c26`, and
`09768efb3a315f0a485320c8c47196c085f876a80c01254971042c534e52b897`.
The explicit wide load followed by byte narrowing is retained because it is the
ordinary source form that reproduces the target register lifetime.

The focused aggregate comparison is
`build/worker3-actor-renderer/report.json`, SHA-256
`e88be4f9ea9d0ee34baad1befc94949e9efc03060d54eb4f1335c56813949343`.
The accepted target ROM has SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

The target procedure at `0x8004E7D4` clears the actor's `0x50` word, scans
`D_8008D4AC` with a hard limit of 20 bytes, and stores only indices `0..19`
back into that word. `func_8004EB60` loads the same 32-bit field with `lw` and
uses it as the byte index when clearing the table entry. The array declaration
therefore records the observed 20-byte backing extent. The instruction stream
does not distinguish signed from unsigned 32-bit indexing; the recovered actor
field remains `int`, matching the producer's ordinary loop-counter use.
The updated source SHA-256 is
`ee0e2b61bda9d1b3e08e426a9669079e780a619300d5689716343c003b1c47ea`;
`.local/recovery-worker3-next2/probes/eb60_extent20/report.json` still reports
20/20 bytes and zero differing words, with report SHA-256
`4b5f903b11571e280503573fad8b5f695ae5da5cf76cc19daf2466b3eb0b9ede`.

`make test` passes all 108 tests. The manifest validates 939 function records
and 29 source-owned data/BSS sections. A clean `make -j2 verify` rebuild
matches all 8,388,608 bytes of the target ROM with the same SHA-256 above.

Fallback ranges remain in place before and after every recovered extent. The
near-match candidates at `0x80030FEC`, `0x8003264C`, and `0x8003B734` remain
fallback until their complete procedures compile byte-identically.
