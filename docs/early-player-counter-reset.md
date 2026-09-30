# Early player counter reset

`src/game/early_player_counter_reset.c` recovers `func_8001BF48` at
`0x8001BF48..0x8001BFB0`, replacing 104 bytes of fallback code.

The routine clears a 14-entry pair of signed-short state arrays. Each value is
set to `-1`, each parallel timer is set to zero, and `state[6]` is set to `-1`.
The two arrays are contiguous in RAM, so the source models them as one structure
with two `short[14]` members. IDO 5.3 then emits the same peeled and four-way
unrolled loop as the retail code.

The accepted source uses the game compiler profile: IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. The independent comparison at
`.local/early-final-proofs/early_player_counter_reset-report.json` matches all
104 target bytes with zero differing words. Its SHA-256 is
`3bdc3457429e58f8a148f5149b71b7ec6cb7cf854590edbc0557cb72730f874e`.
The source SHA-256 is
`2f8c5daab0ed27c63b0d39b6aebb9928b3f87a2dde7ea45be25f92e575a27807`.

The source owns only `.text`. `source_sections()` returns an empty owned-section
set, and the raw IDO object contains no allocated `.data`, `.rodata`, or `.bss`
section. The state overlay references existing RAM beginning at `0x8009E9E0`;
it does not create or claim that storage.
