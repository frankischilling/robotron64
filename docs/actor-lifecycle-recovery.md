# Actor creation, enforcer behavior, and pursuit

Three complete C procedures replace 3,884 fallback instruction bytes. Their
three compiler-generated switch tables own another 208 bytes. The brain
diagnostic owns 24 initialized bytes, including its terminator and alignment.
The sources use pinned IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.

| Function | Complete VRAM range | Instruction bytes | Source |
| --- | --- | ---: | --- |
| `func_8001AF44` | `8001AF44..8001B324` | 992 | `src/game/actor_lifecycle/create.c` |
| `func_8002C4AC` | `8002C4AC..8002CB48` | 1,692 | `src/game/actor_behaviors/enforcer.c` |
| `func_8002CF24` | `8002CF24..8002D3D4` | 1,200 | `src/game/actor_behaviors/pursuit.c` |

## Creation and parent lookup

The creator accepts a kind, position, and optional parent. Pointer value
`BEE0` suppresses parent lookup. Otherwise kinds 13 through 16 and 21 through
24 search the active actor list for kind zero and resource kind four below
the requested kind. Kinds 13 through 16 require that parent; kinds 21 through
24 can proceed without one. An available parent supplies the spawn position.

The allocator receives kind zero and the requested 104-byte resource record.
Successful allocation selects animation nine and mode one. Resource kinds
9 through 12 and 17 through 20 consume entries from the two scene limit
arrays, advancing their separate cursors. Parent-linked kinds clear movement,
hide the child through zero scale, select animation five, and replace the
parent callback after invoking an existing flagged callback. Kinds 33 and 34
clear Z, set flag two, and record the current clock.

Every successful creation increments the session's per-kind actor counter.
It also increments the early pool counter when `D_800BA74C` is not minus one.
The latter accesses identify the counter array beginning at offset `08` of
`EarlyPoolTickState`; its existing 500-byte prefix retains the same size.
The already recovered `func_8001B324` remains in
`src/game/actor_behavior_counter_expire.c` and is not counted as new work.

The signed 16-bit scale temporary preserves the integer-to-float conversion
before division by 40,960. Multiplications by zero still evaluate the original
trigonometric calls. The creator's 34-entry switch table spans
`8009021C..800902A4`.

## Enforcer behavior

The enforcer routine rotates the object with the clock and dispatches on the
animation byte. Animation four returns to animation zero after 3,000 ticks.
Animation five grows scale over 1,000 ticks, retaining unsigned elapsed-time
arithmetic. Animations one, six, and seven skip the movement and firing work.

The normal path finishes a movement blend or periodically aims toward the
current player. Its speed derives from Manhattan distance, the signed resource
range, and resource speed, with a zero lower bound. Resource kind fourteen
can instead enter animation six and install its special callback. After the
session's 4,000-tick gate, a separate random test can allocate a projectile,
choose its drawing callback, aim with a random angular offset, and scale speed
by distance and difficulty. The routine writes Z as minus 1,000 during this
path and finally overwrites it with 2,000; both original stores are retained.

The routine has one observed argument. Its 9-entry generated switch table
spans `80093A44..80093A68`. The drawing callback uses the existing typed
four-byte prefix and `EarlyRenderHandler` return type.

## Pursuit and attack transition

The pursuit routine handles animation-specific diagnostics, scale oscillation,
and timeout transitions. Its normal path periodically creates a visual actor
for resource kind twenty-eight, refreshes a target from the nearest-actor
search or current player, and blends movement toward that target.

After the session time gate, it checks the combined counters for child kinds
seven and eight and a signed resource period. A successful random test enters
animation two, clears movement, and installs `func_800295CC` with timer twenty.
Its 9-entry generated switch table spans `80093A68..80093A8C`; the diagnostic
at `800939A4` is independently owned by `brain_diagnostic.c`.

## Heading setter and validation

The provisional pointer return of `func_80039514` reserved register `v0`
across calls in the pursuit routine. The setter stores the heading and has no
observed return-value consumers. A void signature with a local transform
pointer and direct object-array field access reproduces its complete 88-byte
body and the surrounding 1,976-byte transform unit. This follows the same
evidence used to correct the scale setter in the preceding recovery.

Player setup also constrains `func_80039BFC`, the property-byte setter.
With the heading setter declared void, an integer declaration for this
earlier call reproduces the target's actor-pointer registers. Its complete
32-byte body does not define a return value, and its sole observed caller
discards the result. The reconstructed C retains that fall-through behavior
instead of inventing a return expression. This declaration is supported by
the combined callee/caller match; it does not establish an original source
spelling or a meaningful result. Player setup itself remains unchanged.

Clean extraction and compilation reproduce all 8,388,608 retail ROM bytes,
with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
All 151 tooling tests pass. Independent comparisons pass for 840 runtime
units, two startup units, 18 assembly units, and 77 data-only units.
`actor-lifecycle-provenance.json` records the three new units, 36 interface
regression units, generated tables, diagnostic, exact input hashes, and
Ghidra evidence for seven complete procedure ranges.

The checkpoint contains 1,357 matching C functions and 249,408 instruction
bytes, plus 27,611 source-owned initialized bytes. Assembly and BSS totals
remain 29 procedures / 4,372 bytes and 458,883 bytes. The provisional CPU
interval still contains 200,788 fallback bytes in 226 ranges and 152
unclassified bytes. Neither the complete function denominator nor the total
executable size is established; whole-ROM equality includes extracted
fallback ranges and does not establish source completion.
