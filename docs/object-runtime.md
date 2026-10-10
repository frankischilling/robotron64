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

Both selected surface routines now have complete excluded C candidates,
together with their shared camera-relative quad helper. Their annular and
tiled geometry, 128/100-vertex accounting, allocation-failure paths, and
remaining instruction differences are recorded in
[the surface notes](renderer-surfaces.md). The current CPU checker executes
this matching dispatcher and both candidate paths, including both selectors
and the zero-gate return, with no callee stubs.

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

## Excluded animation projection

`src/game/object_runtime_projection.c` reconstructs the full
`0x8003B2B0..0x8003B428` range. Its natural function size is 376 bytes,
with a 64-byte frame and eight separate zero alignment bytes. The current
IDO output still differs in 39 of the 94 instruction words, including
division scheduling and register use. It remains excluded from the build's
matching function list and adds no source-owned instructions or data.

The helper reads the signed reference index at context offset `0x0A`, calls
the resource loader, and blends two animation frames into `D_800C8C10`.
The clock difference is masked to twelve bits, divided by 512, then multiplied
by ten before selecting the reference frame. After the blend, it reloads the
selected animation count, appends complete eight-byte records, and publishes
animation cache entry 254. The copy loop retains the retail count reload on
each iteration. The cache data remains owned by the separate resource storage
translation units.

`make audit-object-projection` runs 524 guarded retail/source pairs against
an independent memory oracle. Cases include negative and zero counts, clock
wraparound, equal animation indices, overlapping and unaligned buffers, the
twelve-point blend boundary, and counts through 511. Equal-index fixtures
reserve enough source space for the later reference phases. Both executions
use the independently matching blend source and the complete 904-byte retail
loader, without callee stubs. Only preloaded or skipped-index loader paths
are covered; cache misses, file loading, and visual gameplay remain unproved.

The audit checks call arguments, complete fixture memory, read/write/code
bounds, stack canaries, saved registers, SP, and GP. It also compiles thirteen
source faults with IDO and runs an unchanged positive pair for each one. The
faults alter phase arithmetic, frame selection, footer addresses and strides,
cache fields, or an output guard byte. Three retail instruction mutations
remain separate checks. Execution agreement does not override the instruction
mismatch. Hashes and comparison limits are recorded in
[the projection audit](object-projection-execution-audit.json).

The private research used Ghidra MCP, splat and spimdisasm references verified
against all 376 retail bytes, m2c with the pinned IDO context, asm-differ,
objdiff, the fresh matching runner, and bounded decomp-permuter searches with
stack differences enabled. Retail bytes and generated assembly remain local.

Independent comparison output is kept under the ignored
`build/object-runtime-worker2-20260927/` family during recovery.
