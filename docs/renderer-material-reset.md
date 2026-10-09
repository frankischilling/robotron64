# Renderer material cache reset

`func_800420B0` resets the renderer arena cursor and two counters, calls the
existing resource/cache reset, and initializes the material word for all 400
model-cache entries. It then applies 68 ordered assignments and bitwise updates
using resource kind bytes. Repeated kinds retain the retail assignment order.
The existing actor cleanup and graphics pool initialization routines call it
with no arguments.

The complete function occupies `0x800420B0..0x80042828`, or ROM
`0x42CB0..0x43428`: 1,912 instruction bytes. The following eight zero alignment
bytes are separately checked and remain excluded from recovered code totals.
The module generates no initialized data, BSS, or switch tables.

The arena's model cache starts at offset 20 and uses a 20-byte stride. Its
material word is at offset four in each record. The source uses a prefix view
relative to the arena, consistent with the existing runtime views. Resource
kind accesses reuse the verified 88-, 92-, and 104-byte resource layouts.
`D_8009F560` remains an external resource array; its linker binding adds no
source-owned data bytes.

Keep the default-material loop's assignment on its own source line. Pinned IDO
5.3 changes the unrolled store order when the control and assignment share a
line. The ordinary multiline loop matches the retail instructions without a
different compiler profile or explicit assembly.

Independent reassembly, complete IDO comparison, guarded execution, and final
build evidence are recorded in `renderer-material-reset-provenance.json`.
The execution harness runs the actual matched resource and cache reset callees
and checks an independent state oracle, memory guards, return behavior, and
callee-saved registers. It covers colliding resource kinds and all byte indices.
These deterministic cases do not establish end-to-end gameplay behavior.

Analysis uses the existing Ghidra MCP program, spimdisasm, splat, m2c,
asm-differ, objdiff, pinned IDO, MIPS binutils, and Unicorn. No reference game
source or retail assets are included in this recovery.
