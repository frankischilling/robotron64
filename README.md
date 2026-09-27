# Robotron 64

A matching decompilation of Robotron 64 for Nintendo 64. The bootstrap build reproduces the target ROM byte for byte with sixty matching C functions and extracted binary fallbacks. Most code and data remain unexplored.

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

Progress is generated in `build/us/progress.json` from linked-byte comparisons, actual ELF section addresses, input-object symbols, and recorded source/header/object hashes. The current result is sixty matching C functions, 7,696 bytes, plus 56 bytes of reconstructed assembly. The total code size and function count are unknown, so a whole-game percentage is not reported. See [matching evidence](docs/matching.md) and [toolchain investigation](docs/toolchain.md).

`make test` also checks every function's source and evidence paths, range, source language, consistent object ownership, and declared section placement without requiring a ROM. These metadata checks run in public CI; local build-input checks, linked-byte comparisons, and full-ROM comparison establish matching.

## Development

Track work through GitHub Issues and submit coherent branches through pull requests. Matching claims require compiled-byte comparisons. Local ROM verification is authoritative; commercial ROM data must never enter Git or public CI artifacts.

`config/` records the target and symbols; `src/` contains reconstructed C; `linker_scripts/` places compiled and extracted regions; `tools/` contains project tooling; and `docs/` records binary evidence and uncertainties. See [the ROM map](docs/rom-map.md) and [bootstrap status](docs/bootstrap-status.md).

The [startup evidence](docs/startup.md) records the reconstructed assembly entry, initial PI reads, thread handoff, thread 3 initialization, and entry into the game loop. [Scheduler evidence](docs/scheduler.md) covers the matching creation routine, six queues, three threads, and queue accessors. The Makefile explicitly selects integrated source files.
`make analysis-setup` and `make analyze` generate an optional local disassembly and provisional function inventory. See [executable inventory](docs/executable-inventory.md); these estimates do not contribute to matching percentages.

[Text matching evidence](docs/text.md) covers the buffer-clear wrapper, character mappings, generated jump table, and 3D text object creation.

[String allocation and release](docs/text-records.md) document the recovered text-record pool and packed fields.

[Text options](docs/text-options.md) document the matched option setter, accessors, and second generated jump table.
`src/game/text_replacement.c` remains an excluded research candidate. Its behavior and reproducible nonmatching comparison are documented in [text replacement](docs/text-replacement.md).

[Text wrapper](docs/text-wrapper.md) records the matched create-or-replace helper and its return behavior.

[Text editing](docs/text-edit.md) covers matched suffix replacement and active-record cleanup.

[Text properties](docs/text-properties.md) covers numeric runs, selected non-space runs, and whole-record updates.

[Text conversion](docs/text-conversion.md) records the matched integer/float helper and an initial inventory of the next large routine.

[Object transform evidence](docs/object-transforms.md) covers 32 matched transform and property helpers, including the target's seven empty routines.
