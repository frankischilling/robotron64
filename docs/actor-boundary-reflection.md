# Actor boundary reflection

`func_800186D8` occupies the complete retail range `800186D8..80018CC8`
(ROM `192D8..198C8`): 1,520 bytes, 380 instruction words and an 88-byte frame.
Pinned IDO 5.3, O2, MIPS I reproduces every byte from
`src/game/actor_contacts/reflection.c`. Its natural function symbol and raw text
section are both 1,520 bytes. It generates no alignment tail, initialized game
data, jump table or BSS.

The linker and manifest own exactly this extent. The corresponding extraction
span and absolute function binding are removed; the adjacent clamp and collision
routines keep their existing placements. Size, runtime-address, ROM-address and
entry-symbol assertions protect the replacement. The full ROM comparison still
includes other extracted fallbacks and does not establish complete decompilation.

## Behavior and source structure

The routine clamps Y lower, Y upper, X lower and X upper in that order, using
inclusive comparisons and the signed halfword at actor offset `06`. It reflects
the corresponding velocity component, submits object headings when motion is
nonzero, submits positions and returns whether any boundary changed the actor.
The source retains the velocity self-assignments present in retail.

The scene-arrival field at `800BA784` enables a separate diagonal bound. This
word is already owned at `D_800B9A78 + 0xD0C`; the function adds no storage for
it. The diagonal branch subtracts the actor halfword twice, computes a fixed
point slope, preserves position signs and applies the original quadrant-specific
velocity changes. The third heading cutoff is 3,096. The final heading is
written to the actor's signed halfword at offset `08`.

Six consumed integer locals reproduce the original allocation. The `value`
local first supplies the object index to the upper-X position submission and
later holds the absolute slope ratio. Rectangular bounds are evaluated directly,
and the final diagonal Y expression consumes the X magnitude directly:

```c
value = actor->objectIndex;
func_800290B0(value, actor->position);

/* In the subsequent diagonal branch. */
actor->position[1] =
    (limit - func_8004CEF0(actor->position[0])) *
    BOUNCE_SIGN(actor->position[1]);
```

These actual value lifetimes reproduce the spill homes and the A3 slope
register. No unused local, padding, forced register, fabricated condition,
instruction patch or altered compiler flag is used. Original variable names
and source spelling remain unproved. Callback-sensitive position reads are
retained.

## Independent verification

Fresh splat and SPIM disassemblies independently reassemble all 1,520 original
bytes. Their natural symbols, relocations and complete linked extents agree
with the original ROM. Fresh pinned compilation, asm-differ and raw/linked
objdiff comparisons verify the complete source output. Viewer scores alone
are not acceptance evidence. Ghidra retains the original bytes and the
`ActorBehaviorActorInternal *` prototype used by the C headers and generated
m2c context.

The [current acceptance ledger](actor-boundary-reflection-current-provenance.json)
records source/compiler hashes, natural extents, relocations, owned sections,
independent references, clean build and ROM checks. The earlier
[research ledger](actor-boundary-reflection-provenance.json) describes the
excluded candidate before this recovery and retains its historical evidence.

The execution checker passes 1,818 retail/source pairs, or 3,636 principal
executions, including 36 injected position mutations at a submission boundary.
Six complete matching support units and their initialized data are freshly
compiled; reached angle, arithmetic, position and object-transform helpers
execute actual instructions. A separate integer and rounded-float model checks
actor records, object records, transforms, callback arguments and return values.

Every guest instruction and memory access is bounded. The checker verifies
canaries, GP, SP, saved integer registers and twelve distinct incoming F20..F31
words. Fresh controls reject five semantic source changes, twelve executed
saved-FPU corruptions and three guest instruction/read/write faults after
positive controls. These finite fixtures do not establish arbitrary inputs,
aliasing, division exception delivery or full gameplay. Negative object indices
use deliberately mapped synthetic records. The mutation fixtures do not assert
that the normal position helper changes the actor.

## Reproduce the checks

With the pinned toolchain and user-supplied target ROM:

```sh
make check-actor-boundary-reflection
python3 tools/check_actor_boundary_reflection_controls.py
python3 tools/compare_runtime.py --jobs 2
make setup
make -j2
make verify
make test
make progress
```

The default reflection checker requires complete instruction equality before
running execution fixtures. An optional alternate source path remains available
for research and reports its instruction and execution results separately.
Private disassembly, binaries, diagnostic compiler copies and extracted input
remain outside Git. The matching workflow and local SM64/IDO references are
credited in [CREDITS](../CREDITS.md), [the reference study](reference-study.md)
and [the toolchain notes](toolchain.md).
