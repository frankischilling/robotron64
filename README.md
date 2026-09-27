# Robotron 64

A matching decompilation of Robotron 64 for Nintendo 64. The bootstrap build reproduces the target ROM byte for byte with ten matching C functions and extracted binary fallbacks. Most code and data remain unexplored.

This repository does not contain the original game ROM and will not provide one. Supply your own legally obtained copy. Extracted commercial assets and generated binary files remain outside Git.

## Target

USA, game ID `NRXE`, header revision 0, 8 MiB. Hashes refer to big-endian byte order:

```text
SHA-1   44d158bc2aeefb111a620b61e043b2703e6c5808
SHA-256 91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd
```

## Prepare the baserom

Use x86-64 Linux or WSL2 with Python 3.12 or later, GNU Make, and MIPS binutils. The normalization tool also works on Windows.

On Ubuntu 24.04:

```sh
sudo apt install python3 make binutils-mips-linux-gnu
```

```sh
python3 tools/rom.py '/path/to/Robotron 64 (USA).n64' --output baseroms/us/baserom.z64
```

The tool accepts big-endian, byte-swapped, and word-swapped input, verifies the normalized target, and preserves the original file.

## Build and verify

```sh
make setup
make -j4
make verify
make progress
```

Setup downloads a checksum-pinned IDO 5.3 static recompiler and extracts fallback regions locally. The original compiler version remains under investigation. The build links compiled source with those fallbacks into `build/us/robotron64.z64`. Verification compares every byte with the target. `make clean` removes generated build files; `make test` runs tooling tests without a ROM.

Progress is generated in `build/us/progress.json` from linked-byte comparisons and input-object symbols. The current result is ten matching C functions, 1,836 bytes. The total code size and function count are unknown, so a whole-game percentage is not reported. See [matching evidence](docs/matching.md) and [toolchain investigation](docs/toolchain.md).

## Development

Track work through GitHub Issues and submit coherent branches through pull requests. Matching claims require compiled-byte comparisons. Local ROM verification is authoritative; commercial ROM data must never enter Git or public CI artifacts.

`config/` records the target and symbols; `src/` contains reconstructed C; `linker_scripts/` places compiled and extracted regions; `tools/` contains project tooling; and `docs/` records binary evidence and uncertainties. See [the ROM map](docs/rom-map.md) and [bootstrap status](docs/bootstrap-status.md).

The [startup investigation](docs/startup.md) records the reconstructed assembly entry and thread handoff. The Makefile explicitly selects integrated source files. `src/boot/startup.c` remains an excluded, nonmatching research candidate.
`make analysis-setup` and `make analyze` generate an optional local disassembly and provisional function inventory. See [executable inventory](docs/executable-inventory.md); these estimates do not contribute to matching percentages.

[Text matching evidence](docs/text.md) covers the buffer-clear wrapper, character mappings, generated jump table, and 3D text object creation.

[String allocation and release](docs/text-records.md) document the recovered text-record pool and packed fields.
