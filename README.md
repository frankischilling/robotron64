# Robotron 64

A matching decompilation of Robotron 64 for Nintendo 64. This source checkpoint contains 1,354 matching C functions covering 245,524 bytes, twenty-nine assembly functions covering 4,372 bytes, 27,379 bytes of source-owned initialized data, and 458,883 bytes of source-owned BSS. The build combines that source with extracted fallback regions to reproduce the target ROM byte for byte. The game is not fully decompiled.

This repository does not contain the original game ROM and will not provide one. Supply your own legally obtained copy. Extracted commercial assets and generated binary files remain outside Git.

## Target

The [PI manager](docs/sdk-pi-manager.md) recovers creation, DMA and disk
completion, disk interrupts, complete transfer records, switch table, handle pointers, and
private thread/queue storage.

[Initialization and exception context](docs/sdk-initialization-and-exceptions.md)
recover SDK startup, Pak ID repair, all four exception entries, and the complete
contiguous exception/thread assembly unit.

[Interrupt and kernel storage](docs/sdk-interrupt-storage.md) reconstructs
CPU priority and handler tables, RCP masks, thread queue state, exception
scratch context, and the disk callback stack in four data-only units.

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

`make remaining` inventories the unresolved fallback spans in the candidate CPU
range and writes `build/us/remaining.json`. It runs without a ROM, orders the
spans by size, reports ROM and runtime addresses, and rejects overlapping source
ownership. These declared layout bytes include possible data and padding;
[the remaining-range notes](docs/remaining-ranges.md) explain how to use them
alongside verified matching progress.

`make test` also checks every function's source and evidence paths, range, source language, consistent object ownership, and declared section placement without requiring a ROM. These metadata checks run in public CI; local build-input checks, linked-byte comparisons, and full-ROM comparison establish matching.

## Source and references

[Actor behaviors and spawn callback](docs/actor-behavior-recovery.md) replace
5,328 instruction bytes across five complete procedures and own 68 initialized
bytes in the hulk's generated switch table and diagnostic.
The object scale setter's refined `void` interface matches the brain caller,
the complete setter unit, and its other accepted callers. The spawn callback
also establishes the creator's actor-pointer return. Ghidra MCP retains typed
procedures, the recovered switch flow, and verified table.

[Tweak insertion and storage](docs/tweak-storage-and-ghidra.md) adds both
complete insertion routines, 420 instruction bytes, 232 initialized bytes,
and 1,694 BSS bytes. Ghidra MCP analysis uses the verified ELF symbols and
shared actor/tweak types, with every loaded CPU-range byte checked against
the retail ROM.

[Annular and tiled surface rendering](docs/renderer-surfaces.md) adds three
complete excluded C candidates covering 1,968 retail bytes. A new MIPS checker
passes 1,336 cases with thirteen matching support units and no callee stubs;
it checks CPU geometry, commands, counters, and service dispatch on documented
paths. Matching instruction totals remain unchanged.

[Procedural grid and renderer setup](docs/renderer-grid-and-setup.md) recovers
three terminated setup command arrays and their viewport/light records for
320 initialized bytes. The complete 1,904-byte grid renderer has an excluded
C candidate with 480 MIPS execution cases covering CPU commands, vertices,
matrices, counters, and call order.

[Startup projection and diagnostic report](docs/startup-projection-and-diagnostics.md)
adds the complete matching 1,476-byte report, 48 initialized constant bytes,
eight initialized light-coordinate bytes, and a two-byte normalization word.
The complete 864-byte startup projection candidate remains excluded with
two differing words in a saved pointer's stack slot.

[Projectile trail and resource arena](docs/projectile-trail-and-arena.md)
reconstructs the complete trail callback as an excluded C candidate and owns
68 initialized bytes and sixteen BSS bytes for arena/heap state and diagnostics.
An optional MIPS execution checker compares its returns, ribbon geometry,
colors, and vertex accounting with the target using deterministic callee stubs.
It also compares the heap initializer's complete memory-write sequence.
Instruction matching remains required before the callback receives credit.

[Resource cache storage and destination formatting](docs/resource-cache-and-formatting.md)
adds the complete 664-byte destination formatter, its 80-byte generated
table, 14,400 initialized cache-bank bytes, 24 initialized control bytes,
and 6,000 BSS bytes for identifier maps.
Animation point and frame counts now follow their verified consumers; the
resource loader remains excluded with eleven differing words.

[Mesh submission and renderer resource loading](docs/renderer-mesh-resources.md)
adds the complete 1,024-byte mesh submitter and 180 initialized bytes for
resource paths and diagnostics. The complete model, animation, and bitmap
loader remains an excluded candidate; its current evidence is in the cache
and formatting notes above.

[Fixed-alpha quad and polygon command recovery](docs/renderer-polygon-emission.md)
adds two complete quad procedures with 904 instruction bytes and 200
initialized diagnostic bytes. Three complete polygon and command-stream candidates
remain excluded from matching progress.

[Controller polling and storage](docs/controller-polling-and-storage.md)
recovers the complete 272-byte motor duty update, 48 initialized bytes,
and 1,308 BSS bytes for connection masks, Pak records, access state and
directory buffers. Both complete polling candidates remain excluded.

[Renderer diagnostics and font drawing](docs/renderer-diagnostics-and-text.md)
owns 1,368 initialized bytes and 64 BSS bytes for report messages, version text,
pool prefixes and frame counters. Four complete C candidates cover 4,268 retail
instruction bytes and remain excluded; the report now matches as described above.

[Renderer transforms and graphics buffers](docs/renderer-transform-and-buffers.md)
adds the complete matching 1,176-byte Euler matrix submitter, 76 initialized
bytes, and 36,096 BSS bytes for the matrix arena, RSP stack and yield buffer.
The adjacent supplied-matrix routine remains an excluded C candidate.

[Fan, prism, and image setup recovery](docs/render-submission-effects.md)
adds 24 initialized bytes and twelve BSS bytes. Five full C candidates cover
4,164 retail instruction bytes; all remain excluded from matching progress.
Both image wrappers differ only in four stack/argument instructions each.

[Early tube and star rendering](docs/early-render-effects.md) reconstructs three
nonmatching C candidates covering 3,116 retail instruction bytes and owns
104 initialized bytes for their shared angle, depth, and RGB palette. These
candidates remain excluded from the matching build and executable totals.

The reconstructed game source covers text and object helpers, movie commands and track files, actor lifecycle and resource loading, object-definition and scene commands, shell and save menus, background scrolling, palette controls, startup and scheduler dispatch, graphics tasks, frame helpers, fixed-point math, memory and ROM-file services, controller input, save files, and substantial game-side audio management. [Movie recovery](docs/movie-commands.md), [actor resources](docs/actor-resources.md), [object definitions and shell menus](docs/session-setup.md), [scene commands and backgrounds](docs/scene-commands.md), [save menus](docs/save-menus.md), [palette effects](docs/palette-effects.md), [controller services](docs/controller-services.md), [save format](docs/save-game.md), and [Pak files](docs/pak-files.md) record the recovered ranges and layouts.

The [tweak and string services](docs/tweaks-and-strings.md) recover the 100 named gameplay bindings, difficulty application, string lookup, and companion-file loading. [Script services](docs/script-services.md) cover file registration, cache lifecycle, and script-setup commands. [Actor motion](docs/actor-motion.md) and [actor behaviors](docs/actor-behaviors.md) describe the recovered motion blends, heading selection, and animation callback transitions.

[Input sequences](docs/early-input-sequences.md) recover the fourteen-sequence
recognizer and share the checked counter layout with its matching reset helper.
The controller-sampling caller also matches all 212 original instruction bytes. The [string append helper](docs/game-memory.md#string-append)
also has a complete matching source comparison.

The [renderer-state recovery](docs/graphics-state.md) covers display-list termination and calls, render-mode switching, directional lights, vertex-pool accounting, and environment colors. [Renderer geometry](docs/renderer-geometry.md) records hardware vertex attributes, material selection, texture uploads, and vertex-copy loops. [Sound bridges](docs/sound-bridge.md) and [geometry bridges](docs/geometry-bridges.md) document the game-side sound queue and transform wrappers. All counted functions and their generated tables or strings pass complete comparisons.

[Textured polygon submission](docs/renderer-textured-submission.md) recovers
complete triangle and quad submission, packed texture corner consumption,
alpha writes, primitive counts, the mutable corner table, and bounds diagnostics.

[Actor following and graphics pacing](docs/actor-follow-and-graphics-pacing.md) recover both position followers and the complete graphics message loop, including its compiler-generated 31-entry dispatch table. The [controller motor worker](docs/controller-motor-worker.md) preserves queue waiting, serialized controller access, and SDK start/stop results.

[Scheduled groups and attached actors](docs/early-parameter-slot-tick.md) recover
timed group emission and parent-relative actor following, including timer
overshoot, parent handler transitions, and movement field reset.

The [Controller Pak notice](docs/renderer-controller-pak-notice.md) preserves
the unsigned time window, character spacing, skipped spaces, and complete
compiler-emitted string block.

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
and the source-owned Huffman tables and buffers. The stored-block decoder is
recovered. The table builder, dynamic, and literal/distance decoding loops
still use fallback code.

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

The SDK audio graph now includes [voice allocation and commands](docs/sdk-voice-commands.md),
[synthesizer initialization](docs/sdk-synthesizer-runtime.md),
[filter construction](docs/sdk-audio-filter-construction.md),
[mixing and stereo output](docs/sdk-audio-output.md), and the
[PCM/ADPCM decoder](docs/sdk-audio-decoder.md). The
[envelope mixer](docs/sdk-audio-envelope.md),
[effect presets and construction](docs/sdk-audio-effect-construction.md), and
[complete reverb path](docs/sdk-audio-reverb.md) preserve their control queues,
sample arithmetic, circular transfers and RSP command order. All emitted
tables, constants and private procedure extents are included in their proofs.

[Game queries and glyph services](docs/game-query-and-glyph-services.md)
recover active-instance counts, unique sequence and owner enumeration,
renderer character mapping, and an actor callback handoff. The source uses
the existing checked records and lock interfaces.

[Controller and Pak storage](docs/sdk-controller-pak-reconstruction.md)
recovers 44 further SDK procedures for polling, identification, file allocation,
reads and writes, inode repair, motor commands, and CRC calculation. Their
19,744 code bytes and all persistent controller packet storage are checked
against the target, including the shipped error paths and stack behavior.

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

[Camera angles](docs/camera-angles.md) recover both complete angle setters,
their exact constants, and shared camera storage. [Controller input mapping](docs/controller-input-mapping.md)
recovers stick filtering, game-button bits, and the legacy polling call.

[Actor position conversion and score option adjustment](docs/actor-position-score-option.md)
recover two complete routines and the position scale literal.

[Audio stream sizing and input sequence storage](docs/input-stream-storage.md)
recover the complete size helper, fixed input sequences, timing words, and
typed input storage.

[Decimal parsing and input storage](docs/float-parser-controller-state.md)
recover the complete floating parser and 106 bytes of shared controller BSS.

[Actor history and model transforms](docs/actor-history-model.md) recover
projectile allocation, steering and position history, chain reset, and recursive
model transforms. The shared history pool owns 24 flags and 4,608 BSS bytes.

[Graphics task production](docs/graphics-tasks.md) covers the shared task record, both microcode choices, completion waits, and RDP setup commands. [Frame helpers](docs/frame-runtime.md) cover palette state, elapsed-time sampling, and fixed-point transforms.

Run `python3 tools/compare_runtime.py` to compile the recovered runtime blocks independently and compare them with the local target. `python3 tools/compare_runtime.py --candidates` checks the excluded frame, object-update, record-copy, inverse-camera, and input-sequence definition sources and exits nonzero while they differ. Candidate spans must not overlap recovered functions. [Frame-begin evidence](docs/frame-begin.md) records the remaining color-store and register-allocation differences. These candidates do not contribute to matching progress.

`python3 tools/compare_runtime.py --jobs 4` runs four independent source
compilations concurrently. Each uses a separate output directory and the same
checked layout and input hashes. Reports retain registration order, and any
compiler, ownership, changed-input or byte-comparison failure still fails the
run. The default remains one compilation at a time.

`make compare-data` independently compiles both video timing files, rejects
executable content, and checks their complete owned data and linked symbols.
The [video timing and swap notes](docs/sdk-video-modes-and-swap.md) describe the
parameter generator and separate data proofs.

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
