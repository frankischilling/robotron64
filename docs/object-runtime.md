# Object runtime

`src/game/object_runtime_service.c` reconstructs `func_8003B254`, the small
service dispatcher immediately after the main object update loop.

## Matching service group

`func_8003B254` covers VRAM `0x8003B254..0x8003B2B0`, ROM
`0x3BE54..0x3BEB0`, for 92 bytes. IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32` reproduces all 92 bytes with zero differing
words.

The function first checks `D_80075950`. A zero value returns zero without
calling either service routine. When the gate is nonzero, `D_800BA784` selects
between `func_800428C0` and `func_80042E2C`; either path then returns one. The
retail code does not pass arguments to those two calls in this routine.

Both callees save an incoming word to an argument slot but never consume
that saved value. `func_800428C0` stores it at `sp + 0xD0` at `0x800428FC`;
`func_80042E2C` stores it at `sp + 0x40` at `0x80042E48`. Their declarations
therefore retain the period C form without a parameter prototype. This
does not assert that the callee definitions take `void`, and it preserves
the original caller's lack of argument setup. No synthetic argument is
introduced to make these calls appear more strongly typed.

## Active-index rebuild

`src/game/object_runtime_active.c` reconstructs `func_8003B428` at VRAM
`0x8003B428..0x8003B4C0`, ROM `0x3C028..0x3C0C0`. The same IDO 5.3 flags
reproduce all 152 bytes with zero differing words.

The routine clears the 256-byte map beginning at `D_800C85C0`, then consumes a
zero-terminated list of integer indices. Each nonzero index is marked active
and passed to `func_80048DC0` with `D_80094C10`. Call-site evidence elsewhere
shows that `func_80048DC0` accepts a variable argument list; the object-runtime
source keeps that calling convention.

The main update loop and the projection helper remain recovery candidates.
`func_8003A8B0` has the supported signature `void func_8003A8B0(void)`; the
retail entry reads no incoming argument registers. `func_8003B2B0` has a
verified 376-byte boundary and recovered record-copy behavior, but its current
C still differs in register allocation.

Independent comparison output is kept under the ignored
`build/object-runtime-worker2-20260927/` family during recovery.
