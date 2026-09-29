# Early game medium-state proof ledger

The four accepted source units compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`. The focused linked comparison uses the
current symbol layout and the validated US ROM. The accepted procedures total
988 target bytes with zero differing instruction words.

| Source | Source SHA-256 | Procedure | Bytes |
| --- | --- | --- | ---: |
| `src/game/early_actor_transition.c` | `4b89e962e1a8fdd27ea50245ab6a24c2acbea411c83f6623ae03263aba33a0de` | `func_80017C10` 0xCC | 204 |
| `src/game/early_pointer_state.c` | `5b4173ceadee330d135a9cdd4d787eab720d11f0d56c1e5619e58e71716ff85f` | `func_8001A170` 0x80 | 128 |
| `src/game/early_resource_state.c` | `9ef65252ee629122b281d3594b77deb1c58fb67d9796d5a1fbe6048f918fc3f5` | `func_8001ADA0` 0x14C; `func_8001AEEC` 0x58 | 420 |
| `src/game/early_value_lookup.c` | `73ca4d36d769f175314aa783a0002ffc5c5f579123bf0cfe059aa979f3465527` | `func_8001BC38` 0xEC | 236 |

The shared header `include/early_game_medium.h` has SHA-256
`9207f823423f8ee1ef960eb15b0ac4d2680e7c7366e7d453b64948b9c5c2166f`.
The name-table header `include/early_name_table.h` has SHA-256
`eacafb64b03bc99d3146cb4b8fa1a4bffda91212da39381ec7411028541b0dd8`.
The resource-state header `include/early_resource_state.h` has SHA-256
`d5f560a8dba312fdd195194d3653b62c5e66d631dc669dc643017a0fb87b71f8`.
The shared resource layout header `include/actor_resource_internal.h` has
SHA-256 `cff60e1efe0fca370f8dbbda1b453163c6bcf9405c650a44581e861a913aa8fa`.
Its `ActorResource68InternalMustBe104Bytes` check fixes the layout at `0x68`
bytes while exposing the fields used by `func_8001ADA0`.
The original focused report is `build/worker4-early-game-medium/report.json`, SHA-256
`afb9e7b925b83c763aff997e1a7374c11fcc500335eecc1a3024f0074030682b`.
The current correction report is `build/worker1-early-interface-correction/report.json`,
SHA-256 `27edcdbb414a6fc50752877a127aded68c80c43df5b2dde843422b1866af5897`;
it recompiles every matching unit affected by the current early-game headers,
including the pointer-typed `func_8001BC38`.
The resource-state focused report is `build/worker1-early-game-next/report.json`,
SHA-256 `13c2876ff6c3c04a2468ca0b44626b8f2d1db26c9f1d0a34a304261d3bad844d`;
it records 420/420 bytes and zero differing words.
The backing-type correction for `D_800B0090` also leaves the complete
`src/game/tweak_bind_all.c` routine exact. Its source SHA-256 is
`180fbabcf1cdabf69e7ebda5de71ea020127ac748a6eb6a211a2fc3ca8e16f32`,
and `build/worker1-early-game-next/tweak-bind-report.json` has SHA-256
`9ee43725d532cac7281606dd636bb771c3e4ef01f302911707bf53e8cf0b4d3a`
with 2,056/2,056 bytes and zero differing words.
`mips-linux-gnu-nm -S` reports the complete procedure extents listed above.
`tools/owned_sections.py` reports no source-owned sections for these units, and
their IDO objects contain no private allocated data.

The manifest preserves fallback before, between, and after each recovered
range. `func_8001BF48` remains fallback because its loop requires a valid reconstruction of the
backing short-array object; the scalar-label probe is explicitly rejected as a
C object model even though it helped identify the access pattern.

The pre-review resource-state candidate is retained in this ledger by hash:
source `6e2e05e2c0bcf011410e75347fa56d550b4a9dad2fa110b77119569ba55e73e1`
and focused report
`1d4a6cb89196427f8a8f902630dcbc21fc58df47a8e4d0c3bba4352f5dabb1c5`.
It was superseded because the mode-zero source used a self-assignment and
viewed `D_800B0090` through an incompatible byte-array declaration.

The integrated `make -j2 verify` rebuild matched all 8,388,608 bytes of the US
target and reported SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
