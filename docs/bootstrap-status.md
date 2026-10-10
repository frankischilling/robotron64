# Bootstrap status

The target is the supplied USA ROM with header revision zero. `config/target.json` records measured hashes of its normalized bytes. The recovered game source matches with IDO 5.3 and O2/MIPS I. Project-wide compiler identification, the SDK release, CIC, and complete segment layout remain under investigation.

Current verified totals are 1,433 matching C functions / 316,808 instruction
bytes, twenty-nine assembly functions / 4,372 bytes, 37,867 initialized bytes
and 879,161 BSS bytes. The clean pinned-IDO build matches the entire retail ROM.
The mesh command interpreter adds 1,336 complete instruction bytes and a 68-byte
generated switch table; [its evidence](renderer-mesh-commands.md) covers both
independent reassemblies and 1,080 guarded command streams with seven mutations.
There remain 133,376 declared fallback CPU bytes in 180 spans and 164 unclassified
bytes. A complete function/executable denominator is unknown; full source recovery
remains incomplete. Earlier checkpoints below retain their historical counts.

The complete [inverse camera writer](renderer-inverse-camera.md) adds 428 C
instruction bytes. Its 104-byte frame, consumed scalar allocation and existing
36-byte matrix definition reproduce the full retail body with unchanged IDO
flags. Both independent reassemblies agree, and the guarded audit covers
16,640 pairs with eight controlled source faults. The matrix move adds no BSS.

The complete [renderer fatal formatter](renderer-fatal-formatter.md) adds 512
instruction bytes. Its verified contiguous C context reproduces IDO's epilogue
alignment; 806 guarded pairs and five instruction faults cover the formatter's
CPU behavior and infinite wait.

The [screen glyph clock and execution audit](renderer-screen-glyph-audit.md)
adds four BSS bytes and a guarded checker with 816 paired cases, eight real
support units, and eight controls. It adds no matching CPU instructions; the
full glyph and HUD candidates still differ.

The [heap initializer audit](heap-initializer-audit.md) refines the excluded
void candidate to 76 natural bytes and thirteen differing words. All 449
retail/C pairs and ten controls pass; this adds no source ownership. The
original return declaration and instruction match remain unresolved.

The [diagnostic line audit](renderer-diagnostic-line-audit.md) distinguishes
308 natural C bytes from its aligned comparison window. All 528 retail/C pairs
and twelve controls pass; 57 differing words still prevent source ownership.

The [actor boundary reflection](actor-boundary-reflection.md) contributes one
complete 1,520-byte function with an 88-byte frame. Independent reassemblies,
1,818 guarded pairs and semantic, saved-FPU and guest-access controls pass.
The consumed upper-X object index and direct Y magnitude calculation resolve
the remaining allocation differences. It adds no initialized data or BSS.

The [actor ring callback](actor-ring.md) has an excluded C candidate and a
reproducible guard. Its 1,800 execution pairs pass with ten real matching
support units, and 32 deliberate guest/source faults are rejected. The complete
1,024-byte compiled output differs from retail's 1,044 bytes in 204 words;
this research adds no instruction, initialized-data or BSS ownership.

The [missile update callback](actor-missile-update.md) has an excluded
1,372-byte C candidate, exact 28-byte dispatch table and reproducible guard.
All 1,592 pairs pass with thirteen real matching support units; 36 faults
are rejected and four actual zero-duration traps agree. The callback retains
190 differing instruction words and a 72-byte frame instead of retail's 448.
It adds no source ownership, and child allocation remains outside the guard.

The [startup projection](startup-projection-and-diagnostics.md) contributes one
complete 864-byte function with a 184-byte frame. Independent retail reassemblies
and 396 guarded execution pairs agree. Seven source faults and three actual
guest invalid-access probes are rejected after positive controls. The final
two packet writes share one consumed pointer local; no data or BSS is added.

The [actor boundary clamp](actor-boundary-clamp.md) contributes one complete
600-byte function with a verified 72-byte frame. Both independent reassemblies,
972 guarded boundary pairs and five source mutation controls pass. It adds no
initialized data or BSS.

The [actor-group path callback](actor-group-path.md) now contributes one complete
matching C function / 592 instruction bytes. Both independent retail references
and the natural IDO function extent agree. Its interpolation block preserves
the endpoint temporary register; source-owned data and BSS totals are unchanged.

The [scene resource setup candidate](scene-resource-setup.md) now has public C
and a reproducible checker: 319 pairs, 42 compiled layout checks and five
rejected mutations. Its 2,688-byte code and ten-entry table still differ from
retail; the candidate owns no new code or storage.

The [complete early resource group](early-resource-group.md) adds 528 BSS
bytes, expanding the verified first group and adjacent selector to 1,008 bytes.
All retained instructions match; 48 guarded command/reset pairs and the full
1,974-execution resource audit pass. Its 2,660-byte scene setup research
candidate stays excluded because both its code and generated table differ.

[Game initialization](game-initialization.md) adds 96 initialized bytes and
880 BSS bytes. The complete candidate passes 919 paired executions and 4,112
level lookups but retains eleven stack offset differences and stays excluded.
The two startup-modified control labels have writable C storage; their retail
bytes and positions are unchanged.

[Scene resource selection](scene-resource-selection.md) passes 1,683 paired
cases and 17 mutation controls. Its complete 1,032-byte candidate has the exact
dispatch table but still differs in 40 instruction words and remains excluded.

[Scene storage and arrival insertion](scene-arrivals.md) adds 3,348 BSS bytes
and 60 initialized diagnostic bytes. All 3,713 paired cases and nine mutation
controls pass; pinned IDO and Ghidra agree on 99 layout values across three
types. The insertion candidate remains excluded with 55 differing words and
a 48-byte frame instead of the retail 56-byte frame. No code is credited.

The [text record pool](text-record-storage.md) adds 8,040 bytes of source-owned
BSS and both width tables add 144 initialized bytes. All thirty allocation slots,
exhaustion and the full reset pass 744 guarded cases per image; another 1,024
cases check every byte-valued character. Five isolated source mutations are rejected. The
[current matching-tool audit](matching-tools-current.md) independently compares
911 runtime units, two startup units, eighteen assembly units and 198 data-only
units. The [bonus-child creator](actor-bonus-child.md) contributes one complete
matching C function / 744 instruction bytes. Reusing the selected pointer and
preserving declaration order reproduces its 56-byte frame and all stack homes;
initialized data and BSS ownership do not change.

Seven [actor resource pools](actor-resource-storage.md) add 28,312 BSS bytes
without adding instructions or initialized bytes. The reset and already-loaded
loader path pass 1,944 guarded executions and six mutation controls. Pinned IDO
and Ghidra agree on all 52 ordinary fields in five resource views, including
their sizes and alignments. That checkpoint retained two startup-projection stack differences;
the current projection recovery above resolves them.

[Player and save storage](save-state-storage.md) adds 11,144 BSS bytes in
three complete sections. All 1,356 paired execution cases and six isolated
mutation controls pass. Ghidra and pinned IDO agree on eight types and 52
field layouts. The full player restore length, complete save buffer and
1,011-word checksum are preserved. No new instructions are credited.

[Script and resource storage](script-resource-storage.md) adds 15,446 BSS bytes
in three complete sections. All 630 paired cases and seven isolated mutation
controls pass. The registry and offset resets cover every element; lookups
preserve case folding, signed offsets and strict scene boundaries. Pinned IDO
and Ghidra agree on twenty size, alignment and field checks across three types.

[Renderer setup storage](renderer-setup-storage.md) adds both complete default and tile setup lists,
328 initialized bytes and 56 BSS bytes. Independent references, pointer
relocations, pinned IDO layout probes and 2,265 guarded pairs verify the
packet addresses, tile packing, mutable light directions and frame snapshots.
Texture bytes remain extracted assets.

[Object angle constants](object-angle-constants.md) add six complete scalars /
36 initialized bytes, preserving the retail setter/getter value asymmetry.
All 2,898 paired cases, six compiled-data mutations and ten address controls
pass. No new instructions or BSS are credited.

[Peak metrics storage](renderer-peak-metrics-storage.md) adds the complete 201-record array /
4,020 BSS bytes. Its already matching reset and writer pass 1,210 paired
cases, seven source mutations and 290 array-bound controls. The retail
index-201 heap alias is preserved and checked in separate boundary cases.
No new instructions or initialized bytes are credited.

[HUD state dispatch](game-hud-state.md) adds one complete matching C
function / 524 instruction bytes, with no new data or BSS. Splat and spimdisasm
independently reproduce the natural 131-instruction extent; fresh and cached
workbench checks, asm-differ and objdiff agree. A bounded four-worker permuter
search retained stack differences; the final readable source was independently
compiled and guarded. Ghidra and IDO agree on 260 size, alignment, offset and
width probes across six types and 124 ordinary fields. All 595 paired cases,
eleven isolated source mutations and four bounds controls pass. The evidence
preserves retail's uninitialized single-player secondary powers word and
limits execution claims to the caller's fifteen-word ABI boundary.

[Audio startup storage](audio-startup-storage.md) adds ten complete C-owned
sections totaling 279,320 BSS bytes. Its 786 paired execution cases and eight
rejected mutations cover startup, scheduler cycling, heap boundaries and
generation-mode storage within the documented service limits.

[Movie storage](movie-storage.md) adds 6,936 BSS bytes in two complete sections.
All 687 paired cases and five isolated mutation controls pass. IDO and Ghidra
agree on 164 size, alignment and ordinary-field checks across nine types.
The reset's full byte counts, all 25 track slots and three valid callback
slots are preserved. No new instructions are credited.

[Movie update](movie-playback.md) adds the complete 1,816-byte procedure.
All 2,241 retail/C execution pairs and six isolated mutations pass. The audit
checks full objects, exact writes, service traces, bounds and saved O32 state.
Both independent assembly references and fresh/cached workbench comparisons pass.

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

Both [controller polling procedures](controller-polling-and-storage.md) now
have complete comparisons covering 832 bytes. Their 6,316 guarded cases check
connection masks, signed sticks, button edges and SDK call boundaries. The
existing button halfwords retain their addresses as private static storage.

The [palette transition allocator and updater](palette-transitions.md) have
complete 232-byte and 1,200-byte C comparisons. Allocation, bitfield narrowing,
RGB inputs, and four-byte base-color snapshot preserve the existing pool layout.
The related command storage adds 15,648 bytes of checked BSS ownership for
source colors, configurations, ranges, and counters.
The seven-entry transition index table adds 28 initialized control-data bytes;
the adjacent palette resource remains extracted.
The updater preserves signed cycling/interpolation, position reflection and
wrapping, IDO argument evaluation order, lighting calls, and overlapping uploads.

The [renderer color wave state](renderer-color-wave.md) adds 260 bytes of
checked BSS ownership for its time accumulator and sixteen wave records.
An aggregate preserves the array's four-byte offset without IDO inserting
padding. The [material cache reset](renderer-material-reset.md) also matches
its complete 1,912-byte function. The related animated color grids still use
fallback; their close instruction comparisons do not add recovered function bytes.

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

The rotating-ring renderer now owns its complete 568-byte instruction range.
Its fresh spimdisasm/splat references, pinned IDO output, and 640 guarded CPU
cases agree; three deliberate mutations fail. The source preserves packets
pointing beyond each four-vertex group. This checkpoint verifies 1,419 C
functions / 303,668 bytes and the entire target ROM. There remain 146,516
fallback CPU bytes in 190 spans and 164 unclassified bytes. See
[Rotating ring renderer](renderer-rotating-rings.md) for the range and limits.

The renderer state checkpoint also owns two initialized depth-blend target
words and eight complete material display lists: 440 additional data bytes.
Pinned IDO output and independent spimdisasm/splat reassembly agree on each
range. That checkpoint brought initialized source data to 31,907 bytes. C instruction totals
remain 1,419 functions / 303,668 bytes; the inverse camera matrix, depth-blend
routine and animated RGB grid remain nonmatching candidates. See
[Renderer material presets](renderer-material-presets.md) for boundaries and
caller/RSP limits.

The two separate initialized 256-color tables, numeric conversion alphabet,
and fatal formatter output template add 2,076 data bytes. Initialized source
data now totals 33,983 bytes; instruction and BSS totals are unchanged. All
256 palette/light indices are covered in 1,071 guarded executions, and numeric
helpers read the freshly compiled alphabet in the diagnostic formatter checker.
The fatal formatter remains excluded. See
[Palette color tables and formatting constants](palette-color-tables.md).

The [input-sequence definition](input-sequence-definition.md) adds 284 complete
C instruction bytes with 1,176 guarded cases and four detected mutations. Its
three record aliases add no storage ownership. Its complete diagnostic format
section adds 32 initialized bytes. That input checkpoint reached 1,420 C functions /
303,952 bytes, 34,015 initialized bytes and 521,095 BSS bytes.
The candidate CPU range retains 146,232 fallback bytes in 189 spans, plus
164 unclassified bytes; some unresolved spans may be padding or data.

[Renderer primitive state](renderer-primitive-state.md) adds four initialized bytes and 32 BSS bytes.

The [session initializer diagnostics](session-initializer-diagnostics.md) add
104 initialized bytes in four complete C arrays. Initializer instructions and
its dispatch tables remain outside matching ownership.

Nine [scripted file diagnostics](scripted-file-diagnostics.md) add 480
initialized bytes in complete C arrays; their six callers already match.

Seventeen [script and resource literals](script-resource-literals.md) add
272 initialized bytes; the eight-byte unexplained gap remains fallback.

[Projectile spawn](actor-projectile-spawn.md) adds one complete function and
1,040 code bytes, with no new initialized data or BSS ownership.

[Actor collision capture](actor-collision-capture.md) adds one complete
function, 1,712 code bytes and a 96-byte generated dispatch table.
