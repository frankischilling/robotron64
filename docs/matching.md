# Matching workflow

Run `make setup`, `make -j4`, `make verify`, and `make progress` from Linux or WSL2. A clean rebuild starts with `make clean`. This removes generated build files, leaving the user-provided baserom and downloaded toolchain intact.

The linker replaces ROM bytes `0x1050..0x11E0` with compiled C. Reconstructed entry assembly and alignment bytes supply `0x1000..0x1050`. Other ranges come from validated local extraction. `make verify` compares the complete output byte for byte and reports its SHA-256. ROM equality at this stage proves reconstruction of the bootstrap layout; most bytes still depend on binary fallback.

`make progress` checks linked and input-object symbol addresses and sizes, extracts the linked text section, and compares each function's bytes to its target range. Using linked bytes resolves the width-table relocations before comparison. It fails on overlaps, wrong symbol sizes, or byte differences. Unknown code totals and percentages are represented as JSON null, never guessed from ROM size.

Assembly has separate function and byte counters. The 56-byte entry routine contributes no matching-C bytes; its 24 alignment bytes are unmeasured. `unmeasured_rom_bytes` includes those bytes and all extracted fallback. Excluded candidates such as `src/boot/startup.c` do not contribute to matching progress, even when a local experiment matches part of a candidate.

For a selected ROM range:

```sh
python3 tools/verify.py baseroms/us/baserom.z64 build/us/robotron64.z64 --offset 0x1050 --size 0x10
```

Use `mips-linux-gnu-objdump -dr build/us/text.o` to inspect compiler output. `build/us/robotron64.map` records link placement. The unexplored remainder has a synthetic VMA of `0x90000000`; this is solely a linker container and does not represent the game's RAM mapping.

## First function

`func_80000450` returns the low 32 bits of its argument squared. Disassembly contains `multu a0,a0`, `mflo v0`, `jr ra`, and a zero delay-slot instruction. Both tested compiler versions produce the identical 16 bytes for the reconstructed unsigned C expression. The original parameter's signedness remains unknown.

## Initial text helpers

| Function | Bytes | Confirmed behavior |
| --- | --- | --- |
| `func_80000450` | 16 | Return low 32 bits of squared input |
| `func_80000460` | 184 | Select a character-dependent integer from two tables, or a default; return value plus one |
| `func_80000518` | 80 | In-place conversion of ASCII digits to byte values 170 through 179; accepts null and returns original pointer |
| `func_80000568` | 60 | Inverse conversion for bytes 170 through 179; returns original pointer and does not check null |
| `func_800005A4` | 60 | Uppercase ASCII lowercase letters in place; does not check null |

The table-lookup routine uses `D_80072B40` for 26 lowercase letters and `D_80072BA8` for ten digits in either encoding. Width is a provisional interpretation supported by those ranges and the extra unit added on return; caller analysis is pending. Unknown characters use five before the final increment, space uses two, and hyphen uses four when the first argument is nonzero. A zero first argument yields six for every character. The asymmetrical null handling in the string routines is preserved.

Validation on the supplied target completed using IDO 5.3 static recompilation v1.2 and GNU MIPS binutils 2.42. All 8,388,608 output bytes matched, with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`. Five C functions (400 bytes) were measured. No whole-game source completion percentage is available yet.
