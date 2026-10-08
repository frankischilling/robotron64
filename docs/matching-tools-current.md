# Matching-tool evidence

The 2026-10-07 audit uses the current recovery sources in an isolated native
WSL checkout and the pinned IDO 5.3 compiler. Tool installation, cached research,
viewer scores and ROM equality each answer different questions. Source acceptance
requires the complete independent code and data comparisons below.

| Tool | Verified version or revision | Work performed |
| --- | --- | --- |
| Ghidra MCP | Existing `robotron64.elf` project | Inspected complete functions, callers, types, memory blocks and retail instructions; synchronized the text pool and bonus-child evidence. |
| m2c | `708d2d2cb2698f091a92492b328f73b24209f72d` | Generated IDO-context pseudocode for complete heap, bonus-child, path, loader and rotation references. |
| asm-differ | `0dd09af8f8008f1f880327cf0aca3b26d2562ea2` | Compared complete rotation, path and bonus-child ranges, including stack offsets. |
| decomp-permuter | `059609d4aec73eb0650726772954e1ad575825f8` | Ran a bounded 600-second, two-worker path/bonus-child search with stack differences enabled and artificial no-op forms disabled. No match was accepted. |
| splat | 0.50.0 | Split complete verified retail ranges and produced independent assembly references. |
| spimdisasm | 1.42.4 | Independently disassembled those same ranges for reassembly and symbol-size checks. |
| objdiff | 3.8.2 | Inspected verified reference objects and independently linked images against current IDO output. |
| Unicorn | 2.1.1 | Executed retail and compiled instructions with independent models, memory/ABI guards and isolated source mutations. |

MIPS binutils reassembled both splat and spimdisasm output. Each reference
reproduces every byte in its verified range, including both rotation procedures:

| Range | Complete retail bytes | Current source result |
| --- | ---: | --- |
| `8000E720..8000E894` | 372 | Both rotation helpers match. |
| `8000E894..8000EAE4` | 592 | Path candidate differs in five words. |
| `8000F030..8000F318` | 744 | Bonus-child candidate differs in four words. |
| `8004BD00..8004C088` | 904 | Loader candidate differs in eleven words. |
| `8004DE8C..8004DED8` | 76 | Published heap candidate differs in eighteen words; private source variants reached sixteen. |

The tested ranges own no generated tables. Original alignment outside each
range remains outside its instruction count. m2c output is a research aid;
none of these mismatching candidates enters the matching link or progress.
The [bonus-child ledger](actor-bonus-child-current-provenance.json) records the
four remaining stack-related words and 1,668 guarded execution cases.

The existing `robotron-tools match` runner compiled rotation, path and bonus
child, reused their unchanged verified cache entries, then freshly compiled all
three again. Every run reported complete sizes and the same 0/5/4 differences.
Each candidate mismatch returned nonzero. Cache reuse therefore saves repeated
research work without changing acceptance. `robotron-tools diff` showed the
same full ranges through asm-differ. objdiff inspected both independently
assembled objects and linked images for the matching rotation control and
mismatching bonus-child candidate. Its percentages do not replace exact bytes.

Private context, splits, disassembly, objects, viewer reports and experiments
stay under ignored `.local`/`build` directories. The public ledgers contain
sizes, hashes and measured conclusions. Tool sources and N64 reference projects
are credited in [CREDITS](../CREDITS.md) and [the reference study](reference-study.md).
No third-party game implementation or generated retail code is added here.

Fresh acceptance checks cover all 906 runtime comparison units, two startup
units, eighteen assembly units and 191 data-only units. The clean build matches
all 8,388,608 retail bytes. The checkpoint has 1,424 matching C functions /
308,796 bytes, twenty-nine assembly functions / 4,372 bytes, 36,871 initialized
data bytes and 879,125 BSS bytes. The text pool contributes 8,040 BSS bytes and
no new instructions. Both character-width tables add 144 initialized bytes.
The [guarded audit](text-record-storage.md) covers all thirty slots, exhaustion,
reset and every byte-valued character, with five rejected mutations.

The [resource storage audit](actor-resource-storage.md) owns 28,840 BSS bytes
in seven translation units, including the [complete early group](early-resource-group.md). The original reset bounds and accepted consumers
establish their counts and strides. All 52 ordinary fields across five resource
views agree between a pinned IDO layout probe and Ghidra. Twelve whole-pool reset
patterns and 975 already-loaded cases per image pass the independent byte,
access-count and stack models, with six rejected mutations. The projection
candidate remains excluded after 114 additional variants; its two stack-spill
differences remain unresolved.

The [save storage audit](save-state-storage.md) adds 11,144 BSS bytes across
the complete two-player array, configuration/audio settings and save image.
Eight layouts and 52 fields agree with pinned IDO. Fresh and cached workbench
comparisons, asm-differ and objdiff use four independently reassembled retail
consumers. All 1,356 paired execution cases pass and six source mutations fail
after their controls pass. File services, settings application and menu refresh
are recorded ABI boundaries; byte copying executes real matching instructions.

The [script storage audit](script-resource-storage.md) adds 15,446 BSS bytes
across the complete file registry, signed string offsets and scene boundaries.
Twenty IDO/Ghidra layout checks agree across three types. Seven retail ranges
retain eleven distinct procedure extents and reproduce all 1,372 bytes through
both independent disassemblers. Six complete source units pass fresh and cached
workbench comparisons. Asm-differ and objdiff inspect the independent references;
symbol and relocation scores do not replace the linked-byte comparisons.
All 630 paired execution cases pass and seven isolated mutations fail after
positive controls. String helpers
execute matching code; diagnostics, file services and scene submission use
recorded integer ABI boundaries.

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

The [movie storage audit](movie-storage.md) adds 6,936 BSS bytes across the
complete 25-track pool and movie configuration. Nine types and 73 ordinary
fields agree with pinned IDO through 164 size, alignment and offset checks.
The guarded audit runs reset, lookup, load, release and callback registration:
687 paired cases pass and five isolated mutations fail after positive controls.
Byte-copy, clear and string routines execute matching instructions. Resource
load/free and diagnostics use recorded ABI boundaries.

The [movie update](movie-playback.md) owns all 1,816 bytes of its procedure.
Splat and spimdisasm reproduce every instruction and the genuine symbol extent.
Fresh and cached workbench comparisons pass; asm-differ and objdiff retain
their full reference views. All 2,241 guarded pairs and six isolated mutations
pass, including exact writes and saved O32 state. Changed-size controls are
linked separately from the adjacent status routine.

The object projection candidate at `8003B2B0` remains excluded. A separate
600-second, two-worker permuter search retained stack differences and produced
400 suggestions. Independent compilation of the twenty lowest-scoring forms
still found complete-function mismatches. Those scores add no matching credit.

Full source recovery remains incomplete: 141,388 declared fallback CPU bytes
in 186 spans and 164 unclassified bytes remain. The executable/function
denominator is unknown, and these checks do not establish complete gameplay.
