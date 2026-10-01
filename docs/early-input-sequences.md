# Player input sequences

`src/game/early_player_sequence.c` reconstructs the complete 280-byte procedure
at `0x8001BFB0..0x8001C0C8`, corresponding to ROM `0x1CBB0..0x1CCC8`.
It compiles to the original instructions with IDO 5.3 and the normal O2/MIPS I
profile. The following eight alignment bytes remain fallback and are not
included in its instruction count.

The input prefix uses held buttons at offset `0x1C` and writes the completed
sequence index at offset `0x18`. The matching reset helper already writes `-1`
to the same index and initializes fourteen signed-short positions and timers.
Both sources now share the 56-byte counter layout in
`include/early_input_internal.h`. The prefix describes the first 36 bytes used
by input sampling; it does not replace the complete session or save layout.

The recognizer records newly pressed bits as `(held ^ previous) & held` in
`D_8009764C`, then updates the previous mask in `D_80097648`. It walks fourteen
28-byte definition records at `D_8009EE08`. Each record supplies a sequence
length at offset `0x14` and a signed-short button-list pointer at `0x18`.
The other five words remain unnamed. [Input storage evidence](input-stream-storage.md)
records the source-owned sequence records, counters, button pool, cursor, and
three fixed arrays at their recovered placements.

For each sequence, a negative position becomes zero. The routine captures that
position before subtracting the frame delta from its signed-short timer. An
expired timer resets the stored position, but the current button comparison
still uses the captured position. A matching press increments the stored
position and resets the timer to 1,000; a different press clears the position
and also resets the timer. Completion is tested on a frame with no new press.
The first completed sequence clears its position and timer, stores its index,
and returns that index. Otherwise the function returns `-1` without rewriting
the session's sequence index. The narrowing timer arithmetic and unchecked
button-list access are retained.

## Input sampling

`src/game/early_player_input_sample.c` matches all 212 instruction bytes at
`0x8001A1F0..0x8001A2C4`. It samples the selected controller, conditionally merges
the controller two ports away, updates current and newly pressed masks, and
calls the matching recognizer. The two confirmed menu pointers suppress the
second-controller merge. Its `GameSessionState` argument follows the existing
save-menu callers; the input view covers only the observed prefix.

The routine retains a second input pointer for the pressed-mask copy. Both
pointers refer to the same confirmed session prefix. IDO eliminates the pointer
assignment while allocating the new-press result to the target's `t6` register.
The complete comparison checks every instruction, call, branch, stack offset,
and argument interface. The source contains no instruction patches or inline
assembly and now belongs to the matching runtime comparisons.

The matching recognizer and reset helper belong to the independent runtime
comparison and linked-progress checks. Full ROM verification remains required
before publishing a source checkpoint. [Provenance](early-input-sequences-provenance.json)
records the current instruction hashes and complete matching caller,
recognizer and reset comparisons.
Controller and early-game recovery are
tracked in GitHub issues [#39](https://github.com/frankischilling/robotron64/issues/39)
and [#43](https://github.com/frankischilling/robotron64/issues/43).

The complete sequence-definition candidate is in
`src/game/early_input_sequence_define.c`. It preserves the command-field stores,
400-halfword limit diagnostic, cursor update, and fixed-sequence overrides. Its
compiler differences remain excluded from matching progress.
