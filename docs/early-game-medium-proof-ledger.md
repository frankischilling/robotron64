# Early game medium-state proof ledger

The three accepted source units compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`. The focused linked comparison uses the
current symbol layout and the validated US ROM. It records three matches, zero
differing instruction words, and 568/568 target bytes.

| Source | Source SHA-256 | Procedure | Bytes |
| --- | --- | --- | ---: |
| `src/game/early_actor_transition.c` | `4b89e962e1a8fdd27ea50245ab6a24c2acbea411c83f6623ae03263aba33a0de` | `func_80017C10` 0xCC | 204 |
| `src/game/early_pointer_state.c` | `5b4173ceadee330d135a9cdd4d787eab720d11f0d56c1e5619e58e71716ff85f` | `func_8001A170` 0x80 | 128 |
| `src/game/early_value_lookup.c` | `6298283acb341a980eea281192dd55ea799ec470141321eb11ece4e5d1bf85d4` | `func_8001BC38` 0xEC | 236 |

The shared header `include/early_game_medium.h` has SHA-256
`9488cfae751b8d72756c7a0be2d0db00c88e6e2f8410231c07b585d6c2241ad8`.
The focused report is `build/worker4-early-game-medium/report.json`, SHA-256
`afb9e7b925b83c763aff997e1a7374c11fcc500335eecc1a3024f0074030682b`.
`mips-linux-gnu-nm -S` reports the complete procedure extents listed above.
`tools/owned_sections.py` reports no source-owned sections for these units, and
their IDO objects contain no private allocated data.

The manifest preserves fallback before, between, and after each recovered
range. `func_8001ADA0` remains fallback with an exact 332-byte candidate and
eight differing words, all in its default/mode-one path. `func_8001BF48`
remains fallback because its loop requires a valid reconstruction of the
backing short-array object; the scalar-label probe is explicitly rejected as a
C object model even though it helped identify the access pattern.

The integrated `make -j2 verify` rebuild matched all 8,388,608 bytes of the US
target and reported SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
