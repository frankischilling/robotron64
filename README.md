# Robotron 64

A matching decompilation of Robotron 64 for Nintendo 64. This source checkpoint contains 1,036 matching C functions covering 135,936 bytes, eight assembly functions covering 388 bytes, 1,361 bytes of source-owned initialized data, and 4,195 bytes of source-owned BSS. The build combines that source with extracted fallback regions to reproduce the target ROM byte for byte. The game is not fully decompiled.

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
make -j2
make verify
make progress
```

Setup downloads a checksum-pinned IDO 5.3 static recompiler and extracts fallback regions locally. The recovered game sources use verified O2/MIPS I profiles, including the documented R4300 multiply option for pitch scaling. The recovered SDK routines use their verified O1/O2/O3 MIPS II profiles, with MIPS III for the integer helpers and the R4300 multiply option for matrix utilities; a project-wide original compiler identification remains under investigation. The build links compiled source with those fallbacks into `build/us/robotron64.z64`. Verification compares every byte with the target. `make clean` removes generated build files; `make test` runs tooling tests without a ROM.

Progress is generated in `build/us/progress.json` from linked-byte comparisons, actual ELF section addresses, input-object symbols, and recorded source/header/object hashes. Every counted function belongs to a source file present in this checkout. The total executable size and function count are not established, so a whole-game percentage is not reported. See [matching evidence](docs/matching.md) and [toolchain investigation](docs/toolchain.md).

`make test` also checks every function's source and evidence paths, range, source language, consistent object ownership, and declared section placement without requiring a ROM. These metadata checks run in public CI; local build-input checks, linked-byte comparisons, and full-ROM comparison establish matching.

## Source and references

The reconstructed game source covers text and object helpers, movie commands and track files, actor lifecycle and resource loading, object-definition and scene commands, shell and save menus, background scrolling, palette controls, startup and scheduler dispatch, graphics tasks, frame helpers, fixed-point math, memory and ROM-file services, controller input, save files, and substantial game-side audio management. [Movie recovery](docs/movie-commands.md), [actor resources](docs/actor-resources.md), [object definitions and shell menus](docs/session-setup.md), [scene commands and backgrounds](docs/scene-commands.md), [save menus](docs/save-menus.md), [palette effects](docs/palette-effects.md), [controller services](docs/controller-services.md), [save format](docs/save-game.md), and [Pak files](docs/pak-files.md) record the recovered ranges and layouts.

The [tweak and string services](docs/tweaks-and-strings.md) recover the 100 named gameplay bindings, difficulty application, string lookup, and companion-file loading. [Script services](docs/script-services.md) cover file registration, cache lifecycle, and script-setup commands. [Actor motion](docs/actor-motion.md) and [actor behaviors](docs/actor-behaviors.md) describe the recovered motion blends, heading selection, and animation callback transitions.

The [renderer-state recovery](docs/graphics-state.md) covers display-list termination and calls, render-mode switching, directional lights, vertex-pool accounting, and environment colors. [Renderer geometry](docs/renderer-geometry.md) records hardware vertex attributes, material selection, texture uploads, and vertex-copy loops. [Sound bridges](docs/sound-bridge.md) and [geometry bridges](docs/geometry-bridges.md) document the game-side sound queue and transform wrappers. All counted functions and their generated tables or strings pass complete comparisons.

[Menu navigation](docs/save-menu-navigation.md) covers active-node changes,
forward and back callbacks, preview creation and release, and cleanup.
[Continue-code encoding](docs/continue-code.md) records the packed fields,
checksum, and character order. [Actor resource-mode dispatch](docs/actor-behavior-next.md)
preserves timed callbacks, animation transitions, and heading updates.

The recent recovery extends the game-side audio pipeline. [Audio properties](docs/audio-properties.md),
[host and stream services](docs/audio-host-stream.md), [command controls and voice capture](docs/audio-command-engine.md),
[hardware voice management](docs/audio-hardware-driver.md), and [sequence loading](docs/audio-sequence-loading.md)
record the recovered audio pipeline. [Compression runtime](docs/compression-runtime.md)
covers input handling, workspace allocation, block dispatch, fixed-block decoding,
and the source-owned Huffman tables and buffers. The table builder and stored,
dynamic, and literal/distance decoding loops still use fallback code.

[Bank initialization](docs/audio-bank-layout.md) and the
[volume, pan, and pedal commands](docs/audio-driver-commands.md) preserve the
packed bank records, sample relocation, private byte fields, and hardware updates.

[Early game state](docs/early-game-state.md) and [transition and lookup routines](docs/early-game-medium.md)
cover selection state, actor creation, callbacks, pointer initialization, and
one-hot value lookup. [Actor motion](docs/actor-motion.md),
[menu navigation](docs/save-menu-navigation.md), [model geometry](docs/model-geometry.md),
and [graphics runtime state](docs/graphics-runtime-state.md) record the additional
motion, Controller Pak menus, framebuffer drawing, and graphics helpers.
The [checkpoint evidence](docs/recovery-checkpoint.md) records the combined scope
and its reproduction commands.

The [SDK runtime recovery](docs/sdk-runtime.md) adds complete target-derived thread and message services, direct transfers, task yielding, video contexts, heap allocation, integer arithmetic, and the random-number generator. Its 50 functions and initialized seed are included in the source counts. Reference-adapted SDK experiments remain separate local research; remaining SDK fallback code is excluded from source progress. The [credits](CREDITS.md) record all thirteen requested reference projects, their inspected revisions, and the tools used for recovery.

[Time and priority services](docs/sdk-time-and-priority.md),
[scheduling and audio services](docs/sdk-scheduling-and-audio-services.md), and
[matrix conversion](docs/sdk-matrix-conversion.md) add 25 further SDK functions.
They recover the timer queue, thread-priority changes, message prepending,
synthesizer lifecycle, DMA submission, and fixed/float matrix conversion, with
all emitted state included in the complete comparisons.

## Development

Track work through GitHub Issues and submit coherent branches through pull requests. Matching claims require compiled-byte comparisons. Local ROM verification is authoritative; commercial ROM data must never enter Git or public CI artifacts.

`config/` records the target and symbols; `src/` contains reconstructed C; `linker_scripts/` places compiled and extracted regions; `tools/` contains project tooling; and `docs/` records binary evidence and uncertainties. See [the ROM map](docs/rom-map.md) and [bootstrap status](docs/bootstrap-status.md).

The [startup evidence](docs/startup.md) records the reconstructed assembly entry, initial PI reads, thread handoff, thread 3 initialization, and entry into the game loop. [Scheduler creation](docs/scheduler.md) and [scheduler runtime](docs/scheduler-runtime.md) cover all three dispatcher threads, client notifications, audio/graphics handoffs, SP yielding, DP completion, and framebuffer swaps. The Makefile explicitly selects integrated source files.
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

[Graphics task production](docs/graphics-tasks.md) covers the shared task record, both microcode choices, completion waits, and RDP setup commands. [Frame helpers](docs/frame-runtime.md) cover palette state, elapsed-time sampling, and fixed-point transforms.

Run `python3 tools/compare_runtime.py` to compile the recovered runtime blocks independently and compare them with the local target. `python3 tools/compare_runtime.py --candidates` checks the excluded frame and pacing sources and exits nonzero while they differ. [Frame-begin evidence](docs/frame-begin.md) records the remaining color-store and register-allocation differences. These candidates do not contribute to matching progress.

`python3 tools/compare_runtime.py --jobs 4` runs four independent source
compilations concurrently. Each uses a separate output directory and the same
checked layout and input hashes. Reports retain registration order, and any
compiler, ownership, changed-input or byte-comparison failure still fails the
run. The default remains one compilation at a time.

`python3 tools/compare_startup.py` independently checks startup and scheduler
creation/dispatch. `python3 tools/compare_assembly.py` separately reassembles
the entry, audio interrupt services, and recovered SDK assembly routines,
verifies their live symbol extents, and compares their full linked text and
alignment bytes with the target.

`tools/audit_publication.py --files <file-inventory.json>` checks a proposed
public checkpoint after those comparisons. The input is a JSON array of
repository-relative file paths selected for publication. The audit derives
counts and byte totals from the current manifest, rejects missing or stale
source/header proof metadata, and reruns the linked build and provenance
checks. Its report is written to `build/publication-audit.json`.
