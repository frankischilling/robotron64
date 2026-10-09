# Bonus-child creation

`func_8000F030` owns the complete 744 instruction bytes at
`8000F030..8000F318`, ROM `FC30..FF18`. Pinned IDO 5.3 with the unchanged game
profile produces a natural 744-byte function. The object has eight trailing
alignment bytes; they are excluded from instruction ownership. No initialized
data, BSS or generated table is added by this function.

The routine selects an unchecked resource index, allocates a child and returns
null if allocation fails. Kind 4 installs the selected draw callback; kind 9
installs the fixed effect callback. Other resources submit a signed shifted
scale as a float and run the child service. The routine then derives the
child's movement toward the selected actor, or takes the parent angle and a
quarter of resource speed for kind 9. It submits the object angle, stores the
parent link and selects object mode 3. Both writes of Z = -1000 are preserved.

The selected resource pointer is dead after callback selection. The source
reuses that local for the selected actor and declares the child pointer before
it. Those consumed lifetimes and declaration order reproduce IDO's 56-byte
frame, every stack home and all floating registers. The source uses no unused
locals, frame padding, compiler flag changes or binary patches. Original
variable names and source spelling are unproved.

Splat and spimdisasm independently reassemble the entire retail function.
Fresh IDO, workbench, asm-differ and objdiff comparisons cover the natural
extent, instructions and relocations. The matching linker replaces the exact
fallback range and has size, VRAM, ROM and function-placement assertions. The
slot-9 resource alias is bound symbolically to the already source-owned array
at `D_800AC998 + 9 * 92`; it adds no data ownership.

The guarded Unicorn checker runs 1,668 cases / 3,336 paired executions. Eight
complete matching support units and two initialized tables execute compiled
code. Allocation, draw selection, RNG and object submissions use recorded ABI
stubs, which clobber caller-saved integer and floating registers. The checker
compares all child bytes, call snapshots, the returned pointer, input buffers,
surrounding canaries, stack and saved registers. Allocation returns a prepared
child or null. Invalid kinds, allocation aliasing, hardware drawing and complete
gameplay remain outside this proof.

The [current provenance ledger](actor-bonus-child-current-provenance.json)
records complete comparisons, guarded cases, isolated mutation controls,
clean full-ROM acceptance and tests. Other functions remain fallback; ROM
equality alone does not establish full source recovery.

Tools and local N64 references are credited in [CREDITS](../CREDITS.md),
[the reference study](reference-study.md) and [toolchain evidence](toolchain.md).
Local IDO optimizer sources helped inspect diagnostic intermediate files;
no compiler or reference-game implementation was copied into this source.
