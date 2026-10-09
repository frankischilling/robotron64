# Actor collision capture

`func_8001737C` owns the complete 1,712 instruction bytes at
`8001737C..80017A2C` (ROM `17F7C..1862C`) and its compiler-generated
24-entry, 96-byte dispatch table at `80090038..80090098`.
Pinned IDO 5.3 with the game profile emits the natural 428-instruction
function and 56-byte frame. Full SPIM and splat reassemblies, Ghidra
extent review, and fresh linked comparisons check the entire code/table.
The switch owns its table directly; there are no inserted opcodes,
instruction padding, inline assembly or new BSS claims.
The child resource name views element 33 of the existing 88-byte primary
resource pool; linker assertions keep that alias within its owned section.

The collision matrix calls this handler for actor pair [0][3]. It checks
the second actor's kind and animation, then handles first-actor kinds
5, 6, 7, 8 and 25 through 28. Paths retire an existing callback before
installing its replacement, copy a three-word position, select animations,
clear velocity, update object attachment/index/properties, create fragments,
or allocate a child and call its initializer. The return value is always
zero. The final two formal position pointers are stored but not read.
Three masked angle thresholds use signed comparisons. Trig calls remain
observable even where speed has just been set to zero.

Run `make audit-actor-collision-capture`. The audit checks 838 paired retail
and compiled executions against separate state, call-order and arithmetic
oracles. It executes fourteen complete matching support units and two
matching data units, with instruction/read/write bounds, guarded memory,
integer ABI state and twelve distinct saved FPU words. Ten compiled source
mutations, twelve actual saved-FPU corruptions and three actual guest-input
faults must fail. Each mutant executes its own generated dispatch table.
The threshold fixtures include values immediately around all three edges.

Allocation, original callbacks, the child initializer, fragments and sound
playback are argument/state-checked synthetic ABI boundaries that clobber
caller-saved registers. Callback mutations are adversarial fixtures.
The audit also executes 904 unowned retail loader bytes on valid cache
hits; those bytes receive no source credit. Asset misses, unsafe indices,
audio hardware, fragment effects and full gameplay remain unverified.
Stack interiors are bounded and ABI checked, not claimed byte-identical.
Whole-ROM equality still includes extracted fallback elsewhere.

The split is [collision_capture.yaml](../config/analysis/collision_capture.yaml).
Tools and reference projects are credited in [CREDITS.md](../CREDITS.md).

The [collision acceptance ledger](actor-collision-capture-provenance.json) records
all 39 fresh stages, natural extents, relocations, guarded execution and limits.
