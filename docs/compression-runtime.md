# Compression runtime

Nine complete functions recover 1,252 code bytes. The workspace source also
defines 368 initialized bytes and 3,928 bytes of BSS at their original addresses.
The Huffman table builder and the stored, fixed, dynamic, and literal/distance
decoding loops remain extracted fallback code.

| Source | Complete target range | Code bytes |
| --- | --- | ---: |
| `compression_table_release.c` | `0x8005E1E4..0x8005E1EC` | 8 |
| `compression_fixed_release.c` | `0x8005EE98..0x8005EEE0` | 72 |
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

These recovered declarations allow the remaining fallback decoder instructions
to use the same storage. They do not count the unrecovered decoding functions
as source. This organization is a reconstructed source unit, not a claim that
the original compiler used this exact file boundary.

## Verification and references

Each complete support routine passes its retained code comparison, and the
combined workspace routine passes with its initialized data and all BSS
definitions checked. The Makefile, linker, extraction spans, function manifest,
owned-section manifest, and `tools/compare_runtime.py` all register these units.
`make progress` additionally requires the complete ROM and linked source
provenance to pass before reporting source counts.

At this checkpoint all nine independent comparisons and all 106 tooling tests
pass. `make progress` verifies all 8,388,608 ROM bytes and counts 913 matching C
functions covering 118,676 bytes, with 1,352 initialized bytes and 4,090 BSS
bytes defined by source. The ROM SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

The [proof ledger](compression-runtime-provenance.json) records input identities,
complete code ranges, and owned sections. Current proof must be reproduced from
the current source and headers; historical reports alone are insufficient.

The DEFLATE representation, Huffman entry layout, and standard tables were
checked against [Perfect Dark's inflate implementation](https://github.com/n64decomp/perfect_dark/blob/169ed48bdcbfb3b568b028bd5bebb27680073514/src/inflate/inflate.c).
Its [MIT notice](licenses/perfect-dark.txt) is retained. Robotron's own ROM
establishes the refill size, output-limit behavior, error values, instructions,
and storage addresses described here. The broader N64 source collection is
credited in [CREDITS.md](../CREDITS.md).

The complete 8,592-byte compression unit is retained as local research. Its
remaining five procedures still differ after compilation and are excluded from
matching progress. No partly matching procedure or shifted instruction range
is included in this batch.
