# Text initialization and character normalization

`func_800005E0` (ROM `0x11E0`, 44 bytes) clears 8,040 bytes at `0x800B6FF8` by calling `func_8003B694` with a zero fill value. Inspection of the callee shows byte stores advancing through the requested signed count. The cleared buffer's fields and purpose remain unknown, so its name remains address-based.

`func_8000060C` (ROM `0x120C`, 324 bytes) maps input character codes into the game's text encoding. Uppercase ASCII letters become lowercase. Lowercase letters, ASCII digits, and codes 170 through 179 pass through. The switch implements these additional mappings:

| Input | Output |
| --- | --- |
| `/` | `:` |
| `=` | `[` |
| `%` | `]` |
| `-` | 220 |
| `?` | `_` |
| `!` | 92 (backslash) |
| `.` | `^` |
| `,` | `Z` |
| `*` | backtick |
| double quote, `#`, apostrophe, `+`, `:`, `@` | `:` |
| space or backslash | -2 |
| 23, `&`, `;`, `[`, `^`, `_`, 149 | unchanged |
| other codes | -1 |

These values come from branch targets and immediate loads, including the 42-entry jump table at ROM `0x90278` / RAM `0x8008F678`. They establish numeric behavior; glyph appearance and caller interpretation of negative results still need investigation.

## Matching evidence

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces both functions and the 168-byte jump table. The linker places the compiled table at its original address. The fallback extraction excludes both new function ranges and the table, so their matching bytes come from compiled C.

The current source file represents only part of the original compilation unit. IDO rounds its `.rodata` to 176 bytes, while the next original table immediately follows these 168 bytes. `tools/trim_padding.py` reduces the section's declared size by eight zero padding bytes before linking. It checks that the tail is zero and smaller than 16 bytes, and refuses to remove bytes touched by symbols or relocations. It updates the section symbol's size along with the section header. Instructions, table entries, and relocations are unchanged. The raw compiler object remains at `build/us/text.raw.o` for inspection. This temporary layout step can disappear when the source unit's remaining read-only data is reconstructed.

`make progress` checks each function's linked address, size, compiled-object symbol, and bytes. The full ROM comparison also verifies the generated table. Current C progress is seven functions and 768 bytes, up from five functions and 400 bytes. The table is not counted as code. Total code and data percentages remain unknown.

A clean extraction and build matches all 8,388,608 target bytes with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`. Padding-tool tests use synthetic ELF input and run without a commercial ROM.
