# Matching workflow

Run `make setup`, `make -j4`, `make verify`, and `make progress` from Linux or WSL2. A clean rebuild starts with `make clean`. This removes generated build files, leaving the user-provided baserom and downloaded toolchain intact.

The linker replaces ROM bytes `0x1050..0x1060` with compiled C. Other ranges come from validated local extraction. `make verify` compares the complete output byte for byte and reports its SHA-256. ROM equality at this stage proves reconstruction of the bootstrap layout; most bytes still depend on binary fallback.

`make progress` checks linked symbol addresses and sizes, extracts each configured object's text, and compares those bytes to the target range. It fails on overlaps, wrong symbol sizes, or byte differences. Functions in `config/functions.json` currently occupy their own complete text sections. Split that measurement when an object contains multiple functions. Unknown code totals and percentages are represented as JSON null, never guessed from ROM size.

For a selected ROM range:

```sh
python3 tools/verify.py baseroms/us/baserom.z64 build/us/robotron64.z64 --offset 0x1050 --size 0x10
```

Use `mips-linux-gnu-objdump -dr build/us/math.o` to inspect compiler output. `build/us/robotron64.map` records link placement. The unexplored remainder has a synthetic VMA of `0x90000000`; this is solely a linker container and does not represent the game's RAM mapping.

## First function

`func_80000450` returns the low 32 bits of its argument squared. Disassembly contains `multu a0,a0`, `mflo v0`, `jr ra`, and a zero delay-slot instruction. Both tested compiler versions produce the identical 16 bytes for the reconstructed unsigned C expression. The original parameter's signedness remains unknown.

Validation on the supplied target completed from clean extraction using IDO 5.3 static recompilation v1.2 and GNU MIPS binutils 2.42. All 8,388,608 output bytes matched, with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`. One C function (16 bytes) was measured. No whole-game source completion percentage is available yet.
