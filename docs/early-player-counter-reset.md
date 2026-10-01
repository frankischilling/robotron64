# Early player counter reset

`src/game/early_player_counter_reset.c` recovers `func_8001BF48` at
`0x8001BF48..0x8001BFB0`, replacing 104 bytes of fallback code.

The routine clears a 14-entry pair of signed-short state arrays. Each value is
set to `-1`, each parallel timer is set to zero, and `state[6]` is set to `-1`.
The two arrays are contiguous in RAM, so the source models them as one structure
with two `short[14]` members. The layout is now shared with the matching
[input-sequence recognizer](early-input-sequences.md) through
`include/early_input_internal.h`. IDO 5.3 emits the same peeled and four-way
unrolled loop as the retail code.

The accepted source uses the game compiler profile: IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. The independent comparison in
`build/runtime-comparison/report.json` matches all 104 target bytes with zero
differing words. The current source, shared header, compiler, and instruction
hashes are recorded in [input-sequence provenance](early-input-sequences-provenance.json).

The source owns only `.text`. `source_sections()` returns an empty owned-section
set, and the raw IDO object contains no allocated `.data`, `.rodata`, or `.bss`
section. The state overlay references existing RAM beginning at `0x8009E9E0`;
it does not create or claim that storage.
