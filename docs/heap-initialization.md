# Heap initialization boundary

`src/game/heap_empty.c` recovers the empty function at
`0x8004DED8..0x8004DEE0`. Its eight bytes are the return instruction and its
delay slot. IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces both
instructions from an empty C function. These bytes are a separate function,
not alignment belonging to the preceding initializer.

The initializer at `0x8004DE8C..0x8004DED8` and history-update routine starting
at `0x8004DEE0` remain excluded research candidates. Their current source and
comparison evidence do not establish matching C. The empty function does not
contribute any of their bytes to matching progress.
