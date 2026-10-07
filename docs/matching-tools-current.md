# Matching-tool evidence

The 2026-10-06 audit uses the current recovery sources in an isolated native
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

Fresh acceptance checks cover all 904 runtime comparison units, two startup
units, eighteen assembly units and 161 data-only units. The clean build matches
all 8,388,608 retail bytes. The checkpoint has 1,422 matching C functions /
306,456 bytes, twenty-nine assembly functions / 4,372 bytes, 36,351 initialized
data bytes and 557,447 BSS bytes. The text pool contributes 8,040 BSS bytes and
no new instructions. Both character-width tables add 144 initialized bytes.
The [guarded audit](text-record-storage.md) covers all thirty slots, exhaustion,
reset and every byte-valued character, with five rejected mutations.

The [resource storage audit](actor-resource-storage.md) adds 28,312 BSS bytes
in seven complete pools. The original reset bounds and accepted consumers
establish their counts and strides. All 52 ordinary fields across five resource
views agree between a pinned IDO layout probe and Ghidra. Twelve whole-pool reset
patterns and 960 already-loaded cases per image pass the independent byte,
access-count and stack models, with six rejected mutations. The projection
candidate remains excluded after 114 additional variants; its two stack-spill
differences remain unresolved.

Full source recovery remains incomplete: 143,728 declared fallback CPU bytes
in 188 spans and 164 unclassified bytes remain. The executable/function
denominator is unknown, and these checks do not establish complete gameplay.
