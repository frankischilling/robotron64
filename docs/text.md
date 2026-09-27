# Text initialization and character normalization

`func_800005E0` (ROM `0x11E0`, 44 bytes) clears 8,040 bytes at `0x800B6FF8` by calling `func_8003B694` with a zero fill value. Inspection of the callee shows byte stores advancing through the requested signed count. The cleared buffer is now identified as the 30-record text pool; see [record layout](text-records.md). Its original symbol name is unknown.

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

These values come from branch targets and immediate loads, including the 42-entry jump table at ROM `0x90278` / RAM `0x8008F678`. They establish numeric behavior; glyph appearance still needs investigation. The first caller's treatment of negative results is documented below.

## Matching evidence

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces both functions and the 168-byte jump table. The linker places the compiled table at its original address. The fallback extraction excludes both new function ranges and the table, so their matching bytes come from compiled C.

The source file represents only part of the original compilation unit. With only this table reconstructed, IDO rounded its `.rodata` to 176 bytes, while the next original table immediately followed the 168 bytes. Both tables are now reconstructed: see [text options](text-options.md). `tools/trim_padding.py` reduces the section's declared size by eight zero padding bytes before linking. It checks that the tail is zero and smaller than 16 bytes, and refuses to remove bytes touched by symbols or relocations. It updates the section symbol's size along with the section header. Instructions, table entries, and relocations are unchanged. The raw compiler object remains at `build/us/text.raw.o` for inspection. This temporary layout step can disappear when the source unit's remaining read-only data is reconstructed.

`make progress` checks each function's linked address, size, compiled-object symbol, and bytes. The full ROM comparison also verifies the generated table. The normalization work raised C progress from five functions and 400 bytes to seven functions and 768 bytes; the subsequent object-creation match is documented below. The table is not counted as code. Total code and data percentages remain unknown.

A clean extraction and build matches all 8,388,608 target bytes with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`. Padding-tool tests use synthetic ELF input and run without a commercial ROM.

## 3D text object creation

`func_80000750` (ROM `0x1350`, 456 bytes) normalizes a character and creates an object using a character-indexed resource record. The diagnostic at ROM `0x90220` explicitly describes an invalid character for a 3D string, supporting the subsystem interpretation. Function names remain address-based until more callers and interfaces are understood.

The record stride is 88 bytes. This function accesses an unsigned byte at offset `0x01`, a signed integer at `0x0C`, and a pointer at `0x28` whose first signed halfword becomes an object index parameter. `TextGlyphResource` represents those fields and keeps the unexamined portions as padding. The type does not claim the full original resource layout.

The fourth argument becomes a boolean before object allocation. The compiled source reuses that argument for the returned object index. With separate flag and object variables, IDO emitted the same instruction count but a different stack frame. Reusing the argument and declaring the resource pointer before the normalized-character local reproduces the original 48-byte frame and spill offsets.

The caller distinguishes the normalizer's negative results: `-2` returns `-1` immediately, while `-1` invokes the diagnostic and then continues to index the resource table at `-1`. The reconstruction preserves this latter behavior. Whether the diagnostic returns at runtime still requires tracing its implementation.

For successful allocation, the function changes object codes for `&`, `;`, and character 149 to 13, 11, and 12 respectively. It reads the first signed resource index, computes `(resource->scale * 4 * scale) / 40960.0f`, and calls the object's configuration helpers. Mode 11 invokes `func_80039E0C` with the object and mode. The callee stores both incoming arguments to their stack slots and returns zero; this establishes the otherwise unobvious second argument. The visible effect of the other property setters remains to be traced.

The new function matches all 456 bytes with the existing IDO flags. The partial object's text section ends eight bytes before its compiler-aligned size, so the existing checked padding tool also reduces `.text` to `0x4C8`. The function's instructions and relocations remain unchanged. Full ROM verification and per-function symbol/byte checks pass. The object-creation match raised C progress to eight functions and 1,224 bytes. Subsequent allocation and release matches are documented in [text records](text-records.md). Assembly progress remains 56 bytes.
