# Bootstrap status

The target is the supplied USA ROM with header revision zero. `config/target.json` records measured hashes of its normalized bytes. The recovered game source matches with IDO 5.3 and O2/MIPS I. Project-wide compiler identification, the SDK release, CIC, and complete segment layout remain under investigation.

Completed locally:

- Created the public repository and bootstrap branch.
- Installed Git identity and commit-message guards.
- Added byte-order normalization and strict target validation.
- Built a deterministic extraction, assembler, linker, and binary comparison pipeline.
- Matched five functions at `0x80000450..0x800005E0` with IDO 5.3 and MIPS I; documented differences against IDO 7.1 and MIPS II candidates.
- Verified full ROM equality after clean extraction and build.
- Added automated object-byte progress checks and public tooling tests.
- Identified three SDK assembly sequences and two embedded graphics microcode version strings.

The [README](../README.md) records the current public function and byte totals, measured from the build's `progress.json`. Recent recovery covers actor-resource loading and setup helpers, object definitions, scene commands, background images, save-menu status dispatch, palette controls, controller services, and save/Pak file handling. See [movie track files](movie-files.md), [actor resources](actor-resources.md), [scene commands](scene-commands.md), [save menus](save-menus.md), [palette effects](palette-effects.md), [controller services](controller-services.md), [save format](save-game.md), and [Pak files](pak-files.md) for the behavior and compiled ranges.

The [random spawn-position chooser](actor-spawn-position.md) has a complete
696-byte C comparison. Its signed arithmetic, axis constraints, per-actor
rejection budget and failure output are checked with matching absolute-value
code and a deterministic RNG boundary.

The [boss update](boss-update.md) has a complete 668-byte C comparison,
24 retained initializer bytes and 6,936 guarded execution cases. Lighting
executes matching source. Effect, trigger and spawn calls use recorded ABI
boundaries; complete gameplay and original unused-local declarations remain
outside that proof.

The [Controller Pak directory menu](controller-pak-menu.md) has a complete
596-byte C comparison, 148 initialized bytes and 648 measured BSS bytes.
Its title storage's original declaration remains unknown. A guarded execution
check preserves the formatter and label-overlap behavior.

The current checkpoint extends game audio through
handle/property controls, voice capture and allocation, sequence-table loading,
and compression input, workspace, and dispatch. Actor callbacks, menu and
Controller Pak flows, early-game state, graphics helpers, and framebuffer drawing
also have complete source comparisons. [Checkpoint evidence](recovery-checkpoint.md),
[audio command controls](audio-command-engine.md), [hardware voices](audio-hardware-driver.md),
[sequence loading](audio-sequence-loading.md), and [compression runtime](compression-runtime.md)
record the functions and source-owned storage. The README contains the measured
combined totals; individual recovery notes retain their historical batch counts.

An earlier seven-function recovery added 2,228 C bytes and 45 private BSS bytes for bank
initialization, volume, pan, pedal release, and the extra kinemation command.
All four new source units have complete independent comparisons; the full
build and linked progress at that checkpoint verified 934 C functions and the entire target ROM.

The [input-sequence recovery](early-input-sequences.md) adds the complete
280-byte recognizer and shares its counter layout with the matching reset
helper. The [string append helper](game-memory.md#string-append) adds another
52 exact instruction bytes. Its 212-byte sampling caller now also matches.
The [contact and sound recovery](input-contact-sound.md) adds the complete
632-byte actor contact gate, 228-byte relative-field helper, and 176-byte
immediate sound dispatcher plus its 32-byte warning.
The [remaining-range inventory](remaining-ranges.md) records unresolved CPU
fallback spans without treating every span as code or claiming a completion
percentage.

Most remaining ROM content uses extracted fallback. Total executable bytes and function count are unknown, and no whole-game percentage is claimed. SDK implementations adapted from reference checkouts remain outside this public source checkpoint pending a verified redistribution basis; their private comparison results do not contribute to these totals.

The 56-byte boot entry is reconstructed as symbolic assembly, followed by 24 alignment bytes. Its measured assembly bytes are separate from C progress. The initial PI-read loop and thread handoff reproduce all 304 original bytes from C. Thread 3 and its adjacent frame helper add 624 bytes; scheduler creation and its two queue accessors add 496 bytes. These blocks preserve the original stack layout, unsigned scale arithmetic, VI configuration, and thread arguments.

The scheduler creation and dispatcher functions compile together into a `0xB70`-byte range. Six following helpers compile separately into `0xEC` bytes. The split preserves IDO's original loop-epilogue alignment. The task producer and scheduler share one checked `0x58`-byte record.

Public tooling tests check normalization, comparison, padding handling, function metadata, build-input records, and section-address validation without a ROM. The manifest check rejects missing source or evidence files, overlapping ranges, conflicting sources for an object, inconsistent declared placement, and malformed records. Matching progress additionally checks the complete ROM, each linked function, input-object symbols, actual ELF load/runtime addresses, and source/header/object hashes recorded by the build recipes.

The publication audit derives expected counts from the current manifest and
checks the individual function inventory as well as its totals. Independent
comparison reports must contain the current source units and source/header
hashes. The audit rejects stale evidence even when its old byte count happens
to equal the current count.

See [reference study](reference-study.md) and [credits](../CREDITS.md) for the inspected source trees and recorded revisions. The public game implementation is reconstructed from Robotron's instructions and callers. Separately scoped SDK notes preserve the results of local source/profile comparisons without distributing those reference-derived implementations.

[Text record evidence](text-records.md) recovers the 30-record pool and matching allocation/release routines.

[Text option evidence](text-options.md) covers four additional functions and the second compiled switch table.
