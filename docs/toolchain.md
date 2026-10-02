# Toolchain investigation

IDO 5.3 reproduces the recovered game code and several SDK compiler profiles. A project-wide original compiler identification and the SDK release remain unresolved. C is the working source language; current evidence does not justify C++.

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

## Verified source profiles

`tools/compiler.py` selects a profile by source path. The game defaults to
`-O2 -G 0 -non_shared -mips1 -32`. The retained SDK profile entries below record
local research experiments; this public checkpoint does not distribute or
compile their reference-derived SDK implementations. Its SDK ranges remain
extracted fallback. In the research build, SDK files receive an explicit override only
after their complete function ranges match. The recovered hardware services
use `-O1 -mips2`; audio sources also require `-O2 -mips2` or `-O3 -mips2`.
Those SDK profiles retain `-G 0 -non_shared -32`. O3 can emit functions in a
different order from their definitions in C; source order alone does not
establish linker placement.

Floating sine/cosine and the audio modulation leaf additionally use
`-Wab,-r4300_mul`, the assembler workaround also selected by the inspected
OOT and SM64 Makefiles. It changes multiply scheduling and instruction spacing.
The exact same sine, cosine and modulation C sources match 448, 360 and 168
target bytes with this flag, where their otherwise equivalent profiles differ.
It is recorded in explicit source profiles and object provenance; the build
does not patch those instructions after compilation. See [SDK math](sdk-math.md)
and [audio effects](sdk-audio-effects.md).

The ten 64-bit arithmetic helpers at `0x800614E0..0x800617A0` use
`-O1 -G 0 -non_shared -mips3 -32`. Both IDO 5.3 and 7.1 reproduce their 704
instruction bytes. This unit establishes its ISA and optimization profile,
but does not distinguish the compiler versions. See [SDK arithmetic](sdk-arithmetic.md).

The installer verifies every pinned compiler component against
`config/toolchain_files.json`. Object provenance records the selected profile,
compiler identity, input hashes and final object hash. Independent comparisons
use the same compilation entry point as the ROM build.

## MIPS III o32 object metadata

IDO's arithmetic object is ELF32 big-endian with MIPS III ISA flags, but the
compiler leaves the ABI field unset. GNU ld 2.42 then rejects combining it with
the o32 game objects as a mixture of 32-bit and 64-bit code. The existing
`-32` calling convention and pointer layout are unchanged by the use of native
64-bit arithmetic instructions.

For the verified MIPS III profile, `tools/compiler.py` checks the ELF class,
byte order, version, relocatable type, MIPS machine and ISA. It rejects a
conflicting ABI or floating-point register-width declaration, then adds only
`EF_MIPS_ABI_O32` (`0x1000`). All section bytes and the MIPS III ISA flag stay
unchanged. The original compiler output is retained beside the normalized
object with an additional `.ido` suffix. Tests cover unchanged payload bytes,
idempotence and incompatible inputs; the linked ROM comparison checks the
actual arithmetic instructions together with the rest of the game.

The same IDO metadata issue is handled by OOT's `tools/set_o32abi_bit.py` and
SM64's `tools/patch_elf_32bit.c` in the local reference checkouts. This is an
object-header compatibility step, not a code-generation or instruction fix.

## Tools considered

- Splat and spimdisasm: references for executable splitting and symbol discovery. The local spimdisasm inventory remains provisional and separate from matching counts.
- asm-differ: useful when functions become too large for direct objdump comparison. Whole-ROM and selected-range comparison already run locally.
- decomp-permuter and decomp.me: useful after types and behavior are understood; not required for the first function.
- Ghidra and Ghidra MCP now support the [tweak and actor investigation](tweak-storage-and-ghidra.md), with the loaded CPU range checked against the retail ROM. The supplied ares installation remains available for runtime work.
- Asset extraction libraries: selection is pending identification of actual asset formats.
