# SDK memory helpers

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

`src/libultra/audio_copy.c` reconstructs the byte-copy function at
`0x8006F3C0..0x8006F434`. It reads from the first argument and writes to the
second, advancing both pointers once per byte. A nonpositive signed length
performs no copies. The loop proceeds forward and does not provide the
backward-copy behavior needed for overlapping ranges in the other direction.

IDO 5.3 with `-O3 -G 0 -non_shared -mips2 -32` produces all 116 target bytes.
The compiler unrolls the ordinary byte loop; no copied instruction words or
source padding are needed. The final 12 alignment bytes before the RSP boot
program are outside the function and remain fallback.

The independent comparison records the compiler identity and current source
and header hashes. Linked symbol checks and the full-ROM comparison establish
the function's placement at its original address.
