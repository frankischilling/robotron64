# Projectile spawn

`func_80038D8C` owns all 1,040 instruction bytes at `80038D8C..8003919C`
(ROM `3998C..39D9C`). Pinned IDO 5.3 with the existing game profile emits the
complete natural 260-instruction function, including its 104-byte frame.
Independent SPIM and splat reassemblies cover the same full extent. There is
no instruction padding, inline assembly, replacement opcode or new data/BSS
ownership. Three linker aliases view elements 1, 2 and 3 of the already owned
92-byte child-resource array; assertions keep them inside that source section.
The preceding function at `80038830..80038D8C` remains fallback.

The function copies a three-word position, adjusts Z, creates one actor for
resource kinds 1, 2 and 3 and three for other valid kinds. Each successful
actor receives flags, resource-specific speed and callbacks, trig-derived
velocity, two random position offsets and owner movement. Failed allocations
do not terminate the loop. The return value is the last allocation result,
including NULL after an earlier success. Negative products preserve signed
32-bit wrapping followed by division toward zero. The spawned flag update
is consumed in the first resource-selection condition; this ordering produces
the retail branch and register allocation without identity expressions.

Run `make audit-actor-projectile-spawn`. The audit compiles the full accepted
body and six real matching support units, then checks 606 paired fixtures
against separate call, result and complete guarded-memory oracles. It runs
actual trig, RNG and object-angle implementations, preserves twelve distinct
saved FPU words, and checks instruction/read/write bounds and integer ABI
state. Eight semantic source mutations, twelve saved-FPU corruptions and
three actual guest input faults must fail, with positive executions before
and after each fault.

Allocation alone is an argument-checked boundary that clobbers caller-saved
integer and FPU registers and supplies synthetic actors. Changing the local
position at allocation is an adversarial fixture, not a claim about allocator
behavior. Tests cover eleven valid resource kinds, failure masks, signed
angles, wrapping speeds/deltas, and mapped object indices 0, 1 and 17.
Unsafe kinds, arbitrary aliasing and full gameplay remain unverified.
Whole-ROM equality still includes extracted fallback elsewhere.

The reproducible split is [actor_projectile_spawn.yaml](../config/analysis/actor_projectile_spawn.yaml).
Tools and reference projects are credited in [CREDITS.md](../CREDITS.md).

The [acceptance ledger](actor-projectile-spawn-provenance.json) records all
34 fresh acceptance stages and the bounded audit. All 1,994 frozen public
inputs remained unchanged throughout execution.
