# Toolchain investigation

The original compiler and SDK release remain unknown. C is the working source language; current evidence does not justify C++.

The bootstrap uses the Linux x86-64 [IDO static recompilation](https://github.com/decompals/ido-static-recomp) release v1.2. `tools/toolchain.py` pins archive SHA-256 values also recorded by Ocarina of Time's compiler archive signatures. Downloads go under ignored `.local/toolchain/`. No compiler executable is redistributed by this repository.

Install candidate versions with:

```sh
python3 tools/toolchain.py 5.3 7.1
```

For `src/game/math.c`, both candidates were tested with `-O2 -G 0 -non_shared -mips2 -32`. Both produced exactly the target's 16 text bytes. This tiny function cannot distinguish those versions, optimization choices, or the toolchain used for other translation units. IDO 5.3 is a provisional build choice, not an identification claim.

GNU MIPS binutils 2.42 supplies assembler, linker, object inspection, and binary conversion. Python 3.12.3 and GNU Make are used under Ubuntu WSL2. Python 3.12 or later is required for the installer archive filter. Further candidate testing must include branch scheduling, loads, stack frames, floating point, and relocations in larger routines.

## Tools considered

- Splat and spimdisasm: appropriate for the next executable split and symbol discovery. The current four extracted ranges do not yet require a segment inference dependency.
- asm-differ: useful when functions become too large for direct objdump comparison. Whole-ROM and selected-range comparison already run locally.
- decomp-permuter and decomp.me: useful after types and behavior are understood; not required for the first function.
- Ghidra and the supplied ares installation: available for later cross-reference and runtime work. Neither has been used as evidence yet.
- Asset extraction libraries: selection is pending identification of actual asset formats.
