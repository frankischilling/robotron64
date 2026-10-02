# Heap initialization boundary

`src/game/heap_empty.c` recovers the empty function at
`0x8004DED8..0x8004DEE0`. Its eight bytes are the return instruction and its
delay slot. IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces both
instructions from an empty C function. These bytes are a separate function,
not alignment belonging to the preceding initializer.

The initializer at `0x8004DE8C..0x8004DED8` remains an excluded research
candidate in `src/game/heap/initialize.c`. Its current evidence is recorded
in the [projectile trail and arena notes](projectile-trail-and-arena.md).
The history-update routine starting at `0x8004DEE0` is now matching C in
`src/game/actor_history_tick.c`. The empty function contributes only its own
eight instruction bytes to progress.
