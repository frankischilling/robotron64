# Toolchain investigation

IDO 5.3 is supported by a matching 400-byte source block. A project-wide original compiler identification and the SDK release remain unresolved. C is the working source language; current evidence does not justify C++.

The bootstrap uses the Linux x86-64 [IDO static recompilation](https://github.com/decompals/ido-static-recomp) release v1.2. `tools/toolchain.py` pins archive SHA-256 values also recorded by Ocarina of Time's compiler archive signatures. Downloads go under ignored `.local/toolchain/`. No compiler executable is redistributed by this repository.

Install candidate versions with:

```sh
python3 tools/toolchain.py 5.3 7.1
```

Run `python3 tools/compare_compilers.py` to repeat the comparison for `src/game/text.c`. It links candidate objects at the original address with the discovered table symbols, compares ROM range `0x1050..0x11E0`, and writes `build/compiler-comparison/report.json` with source and output hashes.

All candidates use `-O2 -G 0 -non_shared -32`. Results for the same C source:

| IDO | ISA flag | Output size | Different bytes |
| --- | --- | --- | --- |
| 5.3 | `-mips1` | 400 | 0 |
| 5.3 | `-mips2` | 400 | 143 |
| 7.1 | `-mips1` | 400 | 14 |
| 7.1 | `-mips2` | 400 | 157 |

The IDO 7.1 MIPS I candidate differs at ten instructions in `func_80000460`, starting at `0x80000464`: it masks the character into `a1`, whereas the target and IDO 5.3 use `t6`. Later temporary registers consequently differ. MIPS II changes load/branch scheduling in the string helpers. The square function alone matches all four candidates.

The build therefore uses IDO 5.3 with MIPS I for this source block. This experiment does not exclude another compiler/source combination or different flags in other translation units.

GNU MIPS binutils 2.42 supplies assembler, linker, object inspection, and binary conversion. Python 3.12.3 and GNU Make are used under Ubuntu WSL2. Python 3.12 or later is required for the installer archive filter. Further candidate testing must include branch scheduling, loads, stack frames, floating point, and relocations in larger routines.

## Tools considered

- Splat and spimdisasm: appropriate for the next executable split and symbol discovery. The current four extracted ranges do not yet require a segment inference dependency.
- asm-differ: useful when functions become too large for direct objdump comparison. Whole-ROM and selected-range comparison already run locally.
- decomp-permuter and decomp.me: useful after types and behavior are understood; not required for the first function.
- Ghidra and the supplied ares installation: available for later cross-reference and runtime work. Neither has been used as evidence yet.
- Asset extraction libraries: selection is pending identification of actual asset formats.
