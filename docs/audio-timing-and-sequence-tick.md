# Audio timing and sequence tick

`func_80058A58` advances the tick counter and fractional clock. It adds
`0x85555` with 32-bit wrap, transfers the high half to shared time and keeps
the low half. A nonzero enable word calls the command service followed by
the sequence tick. Clearing that word in the first callback still allows the
second callback. The complete function covers 132 bytes.

`func_8005A9AC` visits active voices until its active-voice budget or pool scan
ends. Paused voices consume the active budget without advancing their clock.
Other active voices accumulate fractional time and pending command time. The
position-limit flag dispatches the backend stop callback after an unsigned
threshold comparison. The backend frame callback runs even when no voice is
active, using the first voice's current backend.

Due commands dispatch backend codes 7 through 18 or sequence codes 19 through
35. Other codes use sequence-table entry 10. Backend dispatch always advances
and decodes afterward. Sequence dispatch skips decoding when the callback
retires the voice or redirects its cursor, then clears the redirect flag.
Callback boundaries reload the static current-voice pointer and opcode; the
source preserves those retail reloads and uses the resulting state.

The sequence function has 920 instruction bytes followed by 12 zero alignment
bytes. The complete 932-byte linked range is compared, but the function manifest
counts only 920 C bytes. Together these functions add 1,052 matching C bytes
and replace 1,064 fallback bytes. Their private BSS covers all 16 bytes at
`0x80192800`: a voice pointer, active budget byte, three retained padding bytes,
scan counter and opcode. Existing clock data and command tables supply their
initialized state; this change adds no initialized data.

The timing source uses a local volatile view of the shared time word. This
reproduces IDO's retail access ordering while retaining the established clock
pointer interface. It does not establish the original declaration's qualifier.

IDO's call-effect analysis depends on the visible decoder definition. The
sequence source includes the already recovered decoder for compilation; its
separate object continues to own the body at `0x80059580`. The compiler retains
the untouched combined object beside the partitioned object as `.ido`.
`tools/partition_text.py` retains the complete sequence function, rebases its
symbol and relocation offsets, and turns the decoder definition into an
external reference. It copies every retained MIPS instruction unchanged and
supplies only the verified zero alignment padding. Unexpected functions,
live tails, overlapping symbols and unsupported references are rejected.
The original translation-unit boundaries remain unknown.

Ghidra MCP supplied control flow, prototypes and complete memory reads.
Independently reassembled splat/spimdisasm references verify both complete
ranges. Typed m2c candidates, asm-differ, objdiff, permuter experiments with
stack differences and direct IDO comparisons support the reconstruction.
Objdiff reports 100 percent for the linked text and function views. The raw
sequence objects use different BSS relocation symbols; the complete linked
bytes, BSS placement and execution checks resolve those differences.
No external game source was copied. The tools are credited in
[CREDITS.md](../CREDITS.md).

`tools/check_audio_ticks.py` checks 216 timing cases and 2,078 sequence cases
against retail instructions and independent byte models. Some cases execute
the timing and sequence routines together. Both images execute the complete
real decoder and use independently compiled command lengths. The untouched
combined object's complete 84-byte decoder is also linked and compared.

The oracle covers unsigned overflow, scan and active budgets, pause and stop
flags, command classes, cursor redirects, retirement, opcode and current-voice
changes, backend changes and callback order. It checks guarded clock, context,
voice, stream and dispatch memory; all private BSS bytes and decoder state;
callee-saved registers and stack restoration. Boundary callbacks poison
caller-saved registers. The command service, sequence handlers and backend
callbacks are recorded ABI stubs. Synthesis, hardware audio and arbitrary
malformed unterminated streams are outside this oracle.

The [proof ledger](audio-ticks-provenance.json) records compiler/input identities,
complete range comparisons, reference reassembly, objdiff and execution results.
Clean extraction and full-ROM verification, fresh startup/runtime/assembly/data
comparisons and tooling tests validate the integrated build. ROM equality still
includes substantial extracted fallback and is not decompilation completion.
