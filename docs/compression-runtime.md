# Compression runtime

Fourteen complete functions recover all 8,592 code bytes in
`0x8005DA20..0x8005FBB0`. The workspace source also
defines 368 initialized bytes and 3,928 bytes of BSS at their original addresses.
The Huffman builder, literal/distance decoder, and dynamic decoder replace
the final three fallback spans in this unit: 6,116 additional C bytes.

| Source | Complete target range | Code bytes |
| --- | --- | ---: |
| `compression/huffman.c` | `0x8005DA20..0x8005E1E4` | 1,988 |
| `compression_table_release.c` | `0x8005E1E4..0x8005E1EC` | 8 |
| `compression/codes.c` | `0x8005E1EC..0x8005E9D0` | 2,020 |
| `compression_stored.c` | `0x8005E9D0..0x8005ECA8` | 728 |
| `compression_fixed.c` | `0x8005ECA8..0x8005EE98` | 496 |
| `compression_fixed_release.c` | `0x8005EE98..0x8005EEE0` | 72 |
| `compression/dynamic.c` | `0x8005EEE0..0x8005F71C` | 2,108 |
| `compression_workspace.c` | `0x8005F71C..0x8005F7E0` | 196 |
| `compression_allocate.c` | `0x8005F7E0..0x8005F804` | 36 |
| `compression_refill.c` | `0x8005F804..0x8005F878` | 116 |
| `compression_decode.c` | `0x8005F878..0x8005FAB0` | 568 |
| `compression_memory.c` | `0x8005FAB0..0x8005FB08` | 88 |
| `compression_cartridge.c` | `0x8005FB08..0x8005FB58` | 80 |
| `compression_cartridge_bounded.c` | `0x8005FB58..0x8005FBB0` | 88 |

## Input, workspace, and dispatch

The memory entry skips a four-byte prefix and selects direct byte input. The
cartridge entry selects a refill buffer. Its bounded companion stores an output
limit and returns immediately for a zero limit. The refill routine requests
65,536 bytes through the existing audio-transfer service, advances the cartridge
address, returns the first byte, and records the remaining 65,535 bytes.

Workspace initialization checks for a nonnull allocation and requires 24,000
bytes for the decoder, plus 65,536 bytes for cartridge input. It aligns the
buffer and table-allocation cursor to eight bytes. The allocator returns the
saved cursor before advancing and aligning it. This saved value is also used
in the cursor update, reproducing the target's complete instruction sequence.

The dispatcher consumes the final-block bit and two-bit block kind. It selects
stored, fixed, or dynamic decoding, returns error five for the reserved kind,
and stops on either the final block or an error. Decoder result nine denotes
the output-limit path and becomes success at the entry boundary. The fixed
table cleanup calls the target's empty release hook and clears both references.

The stored-block decoder discards the partial byte, reads the sixteen-bit
length and its complement, and returns error three when they disagree. It
clamps the copy to the remaining output limit, updates that limit, and copies
input bytes while advancing the 32,768-byte window. It saves the window and
bit-buffer state before returning zero or the output-limit result nine. Its
complete 728-byte comparison includes both direct and refill input paths. The
window-advance macro groups the pointer update and counter reset in one
statement; that grouping reproduces the target's IDO register allocation.

## Source-owned tables and storage

The initialized span is `0x8008DA40..0x8008DBB0`. It contains two null table
pointers, the 19-entry code-length order, the length and distance base/extra-bit
tables, and 17 bit masks. These are typed arrays and pointers with ordinary
initializers. Every emitted byte, including the compiler's final alignment,
matches the target.

The BSS span is `0x80192BD0..0x80193B28`. Its 23 definitions cover input/output
pointers, refill and window state, the table allocator, bit-buffer state, code
counts, level widths, table pointers, sorted symbols, offsets, and the fixed
and dynamic code-length workspaces. Their sizes and offsets are checked against
the actual compiler object. Eight bytes of unused final section alignment are
removed; none of the source definitions are shortened or displaced. Startup's
existing BSS clear covers this entire span.

The three recovered decoding procedures use this same storage; they introduce
no additional initialized data or BSS. The reconstructed file organization
does not establish the original translation-unit boundaries.

## Huffman tables and compressed blocks

The builder counts code lengths, checks for oversubscribed trees, sorts symbols
by length, and allocates linked lookup tables from the shared cursor. Each
eight-byte entry contains an operation byte, a bit count, two padding bytes,
and either a sixteen-bit value or a table pointer at offset four. The complete
function preserves its empty-tree, allocation-failure, incomplete-tree, and
oversubscribed-tree return paths. Its counts, level widths, table stack, sorted
symbols, and offsets are typed declarations in the shared header.

The code decoder follows literal and distance subtables, emits literals, and
copies match runs through the 32,768-byte window. The wrapped and nonwrapped
copy loops remain separate. The latter reloads the window base while writing
bytes; combining the two loops changes the instructions and alias behavior.
Both paths advance the window by its completed size. Retail checks the output
limit immediately after a literal and clamps copied runs separately. It does
not perform an additional limit check after each match. This behavior is
preserved rather than repaired.

The dynamic decoder reads the literal, distance, and code-length counts,
builds the code-length tree, expands literal lengths and repeat symbols, and
builds the final trees before invoking the code decoder. Repeat overruns return
eight. Tree errors retain their observed release calls and return values; the
distance-builder result is deliberately ignored. Successful completion releases
both tables and resets the allocation cursor.

Declaration order, assignment order, and bit-reader loop grouping reproduce
IDO's register allocation and scheduling. The dynamic decoder retains one
initialized empty index test in its first fill loop for this reason. It emits
no branch or additional instruction. The function has no uninitialized index
read. Original translation-unit boundaries remain unknown.

## Verification and references

Each complete routine passes its retained code comparison. The fixed
block decoder independently matches all 496 bytes of `0x8005ECA8..0x8005EE98`
and emits no initialized data or BSS. The
combined workspace routine passes with its initialized data and all BSS
definitions checked. The Makefile, linker, extraction spans, function manifest,
owned-section manifest, and `tools/compare_runtime.py` all register these units.
`make progress` additionally requires the complete ROM and linked source
provenance to pass before reporting source counts.

The final decoder checkpoint passed clean extraction, compilation and comparison
of all 8,388,608 ROM bytes. Independent comparisons passed for two startup,
891 runtime, eighteen assembly and 115 data units, alongside 163 tooling tests
and the existing audio seeking, tick, playback and voice-command execution
checks. `make progress` counted 1,409 matching C functions covering 295,580
bytes, with 31,239 initialized bytes and 505,187 BSS bytes defined by source.
The ROM SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

The [decoder proof ledger](compression-decoder-provenance.json) records current
input identities, complete code ranges, owned sections, tool comparisons and
execution results. The earlier [support proof](compression-runtime-provenance.json)
retains its historical checkpoint. Current proof must be reproduced from the
current source and headers; historical reports alone are insufficient.

The DEFLATE representation, Huffman entry layout, and standard tables were
checked against [Perfect Dark's inflate implementation](https://github.com/n64decomp/perfect_dark/blob/169ed48bdcbfb3b568b028bd5bebb27680073514/src/inflate/inflate.c).
Its [MIT notice](licenses/perfect-dark.txt) is retained. Robotron's own ROM
establishes the refill size, output-limit behavior, error values, instructions,
and storage addresses described here. The broader N64 source collection is
credited in [CREDITS.md](../CREDITS.md).

`tools/check_compression_runtime.py` independently recompiles all fourteen
procedures and the workspace tables before executing them against retail MIPS.
Its 262 generated fixtures cover direct and cartridge input, fixed and dynamic
trees, long overlapping copies, multiple refills, window boundaries, bounded
literal output, malformed trees, allocation failure and invalid lookup entries.
Canonical-code traversal independently checks the builder's produced table
entries. Seventy-six fixtures enter the dynamic decoder. The execution trace
SHA-256 is `0f21e269f5514982d5f3d9aa21257e384ca2a133fc131c7013760ac1f21c801f`.
Cartridge transfer is a recorded stub
that poisons caller-saved registers. Memory bounds, allocation contents, shared
state, buffer guards, saved registers, and the stack are checked. Hardware DMA
timing and arbitrary malformed pointers are outside this execution proof.

Independent splat and spimdisasm references are reassembled and checked against
each complete retail range. Typed m2c contexts, asm-differ views, raw and linked
objdiff comparisons, and stack-aware permuter results are retained in ignored
local directories. No reference instruction bytes or compressed game assets
are distributed in this repository.
