# Input-sequence definition

`func_8001BE2C` defines a record in the existing 14-element input-sequence
array. Its complete instruction range is `0x8001BE2C..0x8001BF48`, ROM
`0x1CA2C..0x1CB48`: 284 bytes. The next function starts immediately afterward.
The source is `src/game/input_sequences/define.c` and uses the pinned game
IDO 5.3 profile. Fresh spimdisasm and splat reassemblies reproduce every
instruction byte. Fresh IDO compilation, whole-function/section objdiff and
asm-differ agree. The raw compiler object has 288 text bytes; only its four
zero alignment bytes are trimmed, and the live function symbol is 284 bytes.

The command supplies its record index at offset `0x04`, four stored values
at offsets `0x08`, `0x10`, `0x14` and `0x18`, and the length at `0x1C`.
These accesses establish a minimum readable prefix of 32 bytes; they do not
establish the complete command-record extent. The routine reads those values
before writing the destination, so a command that overlaps the destination
record retains the original input values. The record's first word remains
unchanged.

The initial button pointer is `D_8009E590 + D_8009E588`. If the signed
32-bit sum of the cursor and requested length reaches 400, the routine calls
`func_8001C0D0` with the diagnostic format, cursor, stored record length and
400. The instructions reload the cursor and record length after the call.
The cursor advances by that length before any fixed-record replacement.

| Array index | Record address | Replacement length | Button table |
| --- | --- | --- | --- |
| 1 | `D_8009EE24` | 24 | `D_80073A48` |
| 12 | `D_8009EF58` | 4 | `D_80073A80` |
| 13 | `D_8009EF74` | 3 | `D_80073A78` |

The three record symbols are aliases into `D_8009EE08[14]`. Linker assertions
tie them to their 28-byte element offsets. The cursor, 400-short buffer,
14 records and fixed button tables were already source-owned; this change
adds no BSS ownership. The aliases add no storage. The routine emits no new
tables.

`src/game/input_sequences/limit_message.c` defines the diagnostic format at
`0x800903C8..0x800903E8`, ROM `0x90FC8..0x90FE8`. Its 31-byte array contains
30 text bytes and a terminator; the complete 32-byte compiler section retains
one verified alignment byte before the existing scene-action dispatch table.
This adds 32 initialized source bytes. IDO and separate spimdisasm/splat
references reproduce the entire section, and whole-section objdiff agrees.

Ghidra imports the canonical 28-byte C record with four-byte alignment. The
existing ELF analysis lacked these BSS mappings, so three uninitialized,
non-executable analysis blocks now describe the previously source-owned
4-byte cursor, 800-byte button array and 392-byte record array. Types and alias
labels preserve those boundaries; no live BSS contents are inferred.

Ghidra's inferred order around the cursor update is checked against the
retail instructions: the store in the branch delay slot precedes the fixed
length stores. No real incoming runtime caller has been established for this
entry. A Ghidra data reference is not evidence of a direct caller.

The diagnostic call and subsequent cursor reload share a source line to
preserve the pinned compiler's load scheduling. Its final cursor update uses
unsigned addition before conversion to `int`, matching the original `addu`.
The threshold expression retains the compiler's original signed arithmetic;
overflow executions characterize retail and pinned IDO behavior rather than
portable ISO C semantics. Negative or large cursors can form pointers outside
the button array; those cases characterize instruction-level word arithmetic
and do not assert portable C pointer arithmetic.

`tools/check_input_sequence_definition.py` executes the complete retail and
compiled instruction ranges with an independent whole-buffer and diagnostic
trace oracle. It covers every valid index, threshold and integer boundaries,
command/destination aliasing, and synthetic callback changes to the cursor
and length. Reads, writes and code are bounded; stack canaries, GP, SP and
saved integer registers are checked. All 1,176 retail/source cases pass, and
four deliberate mutations targeting the threshold, post-call cursor reload,
cursor store and fixed length are detected.

The formatter is an ABI-clobbering stub that returns synthetically. The
formatter and fatal reporter do not execute in this guard. Invalid indices,
inaccessible pointers and gameplay are outside its scope.

The bounded splat layout is `config/analysis/input_sequence_definition.yaml`.
Private reference assembly and binaries stay in ignored directories.
Ghidra MCP, spimdisasm, splat, m2c, asm-differ, objdiff, MIPS binutils and
Unicorn provide the analysis and independent comparison tools; the retail
ROM remains the behavior and byte-layout reference.

[Provenance](input-sequence-definition-provenance.json) records the complete
comparison, independent reference hashes, guarded executions, shared data
comparisons and final checkpoint validation. Whole-ROM equality includes
extracted fallback code and assets and does not establish full decompilation.
