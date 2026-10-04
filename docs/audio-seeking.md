# Audio sequence seeking

`func_80056EF0` advances from the current command, delay, integer position and
high half of the fractional accumulator. `func_80057124` starts at the sequence
data and decodes its initial delay. Each complete procedure covers 564 bytes.

Both paths dispatch backend commands 7 through 18 and sequence commands 19
through 35. Commands 17 and 18 skip their handler while seeking. Command 34
ends the scan before dispatch. Other codes invoke the sequence-end handler.
The returned position, remaining delay and command cursor retain the retail
unsigned arithmetic and overflow behavior.

Forward seeking refreshes the returned cursor after redirects and invalid
commands. Restart seeking keeps its previous cursor on those paths. Both
clear the redirect flag. The source preserves this difference.

The sequence-command array at `D_8008D96C` aliases the existing command table
at `D_8008D920 + 0x4C`; it adds no initialized storage. The automatic unused
word preserves IDO's retail stack layout, including decoder scratch at
`sp + 0x54`. Neither procedure owns new initialized data or BSS.

Ghidra MCP supplied control flow and retained the canonical `AudioVoice`
interfaces. Independently assembled splat/spimdisasm references match both
complete retail ranges. m2c supplied typed initial candidates; asm-differ,
objdiff and targeted IDO experiments check the final instructions. The
permuter was used during register-allocation research. No external game
source was copied.

Ghidra's call references connect the forward procedure to the relative seek
service at `0x80057358` and the restart procedure to the absolute seek service
at `0x800574B8`. The sequence-array alias is retained in Ghidra and the public
symbol map. Ghidra's complete 1,128-byte memory range agrees with the target.

The [proof ledger](audio-seeking-provenance.json) records complete byte
comparisons, compiler and input identities, independently assembled reference
hashes, objdiff results and the execution report. `tools/check_audio_seeking.py`
runs 1,808 cases against retail and compiled instructions, using the complete
real variable-length decoder and independently compiled command lengths. An
array model checks all guarded voice fields, command streams, output pointers,
decoder globals and handler traces. The harness also checks callee-saved
registers, stack restoration and memory guards; handler stubs poison caller-saved
registers after each call.

The cases include each scanned command class, invalid opcodes, skipped handlers,
multi-command streams, zero and multibyte delays, five-byte unsigned maximum
delays, accumulator wrap, backend byte indices and command redirects. Backend
and sequence handlers are ABI stubs. SDK synthesis, audio hardware and arbitrary
malformed unterminated streams are outside this check.

A clean extraction and build matches every byte of the 8 MiB target. Fresh
comparisons pass for 884 source blocks, 18 assembly units and 114 data units.
The checkpoint contains 1,402 matching C functions and 287,316 C instruction
bytes. Source-owned initialized data and BSS are unchanged. The candidate CPU
inventory still contains 162,880 fallback bytes in 200 ranges, plus 152
unclassified bytes; those ranges can include data or padding. This recovery
does not establish complete gameplay or full source completion.
