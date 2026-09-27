# Matching workflow

Run `make setup`, `make -j4`, `make verify`, and `make progress` from Linux or WSL2. A clean rebuild starts with `make clean`. This removes generated build files, leaving the user-provided baserom and downloaded toolchain intact.

The linker places compiled text, object, and startup routines in their original ROM ranges. `config/functions.json` records every counted function; `linker_scripts/us.ld` also places compiler-generated text tables. Reconstructed entry assembly and alignment bytes supply `0x1000..0x1050`. Other ranges come from validated local extraction. `make verify` compares the complete output byte for byte and reports its SHA-256. Most bytes still depend on binary fallback.

`make progress` checks linked and input-object symbol addresses and sizes, actual ELF section VMA/LMA values, and each function's containment in its section. It extracts the linked section and compares each function's bytes to its target range. Using linked bytes resolves relocations before comparison. It fails on overlaps, incorrect placement, wrong symbol sizes, or byte differences. Unknown code totals and percentages are represented as JSON null.

Every successful source build writes a sibling `.o.provenance.json` record containing its source path and hashes of the source, declared include headers, and final object. Progress requires the manifest source to match this recorded input and rejects changed inputs or objects. Missing records require rebuilding the affected object. These generated records remain under `build/` and are never committed.

`make test` validates the manifest without a ROM and runs synthetic regressions for incorrect source attribution, stale inputs/objects, and wrong section load/runtime addresses. Public metadata validation checks paths and declared relationships; the local ROM build provides the compiled evidence.

Assembly has separate function and byte counters. The 56-byte entry routine contributes no matching-C bytes; its 24 alignment bytes are unmeasured. `unmeasured_rom_bytes` includes those bytes and all extracted fallback. The excluded `src/game/text_replacement.c` candidate does not contribute to matching progress.

For a selected ROM range:

```sh
python3 tools/verify.py baseroms/us/baserom.z64 build/us/robotron64.z64 --offset 0x1050 --size 0x10
```

Use `mips-linux-gnu-objdump -dr build/us/text.o` to inspect compiler output. `build/us/robotron64.map` records link placement. Unmapped data containers use synthetic VMAs of `0x90000000` and `0x91000000`; the game's runtime mapping for these regions remains unresolved.

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

The five initial helpers above contribute 400 C bytes. Validation uses IDO 5.3 static recompilation v1.2 and GNU MIPS binutils 2.42. The complete 8,388,608-byte output matches SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`. Current aggregate source totals are recorded in [bootstrap status](bootstrap-status.md).
