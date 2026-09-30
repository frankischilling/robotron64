# Runtime wrappers

`func_8004CDE8` at `0x8004CDE8..0x8004CE08` is the 32-byte game wrapper
around `func_800631F0`. Recovered actor, scene, movie, and menu callers use its
return value as their random source.

`func_8004CE70` at `0x8004CE70..0x8004CEB0` truncates its floating-point
argument to an integer, converts that result back to float, and passes it to
`func_80063220`. The IDO-generated FCSR save, temporary rounding-mode change,
conversion, and restore are part of the matched routine.

Both routines compile with IDO 5.3 using the project
`-O2 -G 0 -non_shared -mips1 -32` profile. Their accepted proofs compare each
complete procedure against the validated US target ROM.
