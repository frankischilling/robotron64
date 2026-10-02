# Human movement and animation behavior

Two complete C procedures replace 3,824 fallback instruction bytes. The
compiler-generated movement switch table owns 36 bytes, and the human
diagnostic owns 28 bytes including its terminator and alignment. Both sources
use pinned IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.

| Function | Complete VRAM range | Instruction bytes | Source |
| --- | --- | ---: | --- |
| `func_8002A808` | `8002A808..8002AF2C` | 1,828 | `src/game/actor_behaviors/human.c` |
| `func_8002B7BC` | `8002B7BC..8002BF88` | 1,996 | `src/game/actor_behaviors/stride.c` |

## Human movement

Initialization computes X and Y velocity from separate random headings, then
sets an independently randomized object heading. All three random calls remain
separate. Resource kinds zero through three pulse the object color with the
elapsed clock and select different channel ratios. The existing color setter
accepts four arguments: an object and three channel values.

Animation zero finishes an existing movement blend or begins a new blend after
the flag, initialization, and random-period gates. Animation one shrinks the
special model, follows its animation frame in Z, and expires on its frame or
clock limit. Animations three and nine return directly; other states use the
reconstructed diagnostic at `8009396C..80093988`.

Higher resource kinds stop movement in animation one. Otherwise they record
object history and periodically choose a cardinal direction toward the current
player. Each position is divided by two before subtraction, retaining signed
division toward zero. The handler then refreshes movement speed, velocity,
and heading.

## Movement, height, and callbacks

The second handler increments the active counter, caches the current player,
and sets flag `2000`. Resource distance at offset `18`, speed, and the scene
parameter determine the movement-blend duration. This identifies a signed
16-bit distance field in the existing resource prefix without changing its
layout.

Initialization quantizes a heading toward the origin. Resource kind one enters
animation eight, chooses an initial height, updates the object position, and
installs its callback. Other kinds add a random delay to the clock reference.
Animation four returns to animation zero after 3,000 ticks. Animations one,
six, and eight update vertical movement or scale. Animation seven either
transitions back to eight or blends movement toward the player with half the
computed duration. Animation zero finishes an active blend or begins a new one,
quantizes the player heading, and applies the per-kind heading offset. Its
random gate can transition kind one to animation six and replace the callback.
The final property call records whether Z is nonzero. The 9-entry generated
switch table spans `800939F8..80093A1C`.

Both handlers retain signed random remainders followed by unsigned division
for the tick-rate gate. The compiler's original division traps remain present.
Callback replacement invokes the old flagged callback before installing the
new callback and timer.

## Setter interfaces

The integer rotation setters, `func_800396F4` and `func_80039740`, now use void
interfaces. Retaining a transform pointer and accessing the object array
directly for the integer-angle store preserves each complete 76-byte body and
the surrounding 1,976-byte unit. The movie actor, scene motion reset, and
menu-preview creator also remain exact at 436, 264, and 356 bytes respectively.
No recovered caller consumes either return value.

The property setter requires separate provisional module views. Its complete
32-byte body spills a byte formal and stores its low byte. Player setup passes
one; the movement handler passes an integer Boolean through a direct call.
Declaring the caller argument as a byte introduces an extra mask instruction.
Widening the callee removes its required argument-home store. The implementation
guard in `object.h` preserves the byte formal in `object_transforms.c` while
callers use the promoted scalar interface. All observed calls discard the
undefined return value.

These declarations reproduce the verified N64 calling convention for the
observed values zero and one, but their function types are incompatible in
ISO C. The project prompt permits preserving historical undefined behavior
where matching requires it. This is a provisional reconstruction of the
module interfaces; exact instructions do not prove that the original source
used mismatched declarations. Strict ISO C portability and link-time type
optimization are not established. No indirect function-pointer cast, invented
return expression, padding statement, or fixed-register variable is used.

## Validation and remaining work

Ghidra confirms the complete 457- and 499-instruction ranges, the switch
references, and the original direct property call. Clean publication validation
and exact input hashes are recorded in `actor-family-provenance.json`.

The family `8002A244..8002E65C` now contains 23 complete matching C procedures
covering 15,224 instruction bytes. Its remaining complete procedure,
`8002DDBC..8002E65C`, covers 2,208 bytes. A private complete candidate has 27
differing instruction words; all 536 generated table bytes match. That candidate
remains outside matching counts and source ownership, and issue 40 remains open.

The checkpoint contains 1,359 matching C functions and 253,232 instruction
bytes, plus 27,675 source-owned initialized bytes. Assembly and BSS totals
remain 29 procedures / 4,372 bytes and 458,883 bytes. The provisional CPU
interval contains 196,964 fallback bytes in 224 ranges and 152 unclassified
bytes. Whole-ROM equality still includes extracted fallback ranges; the game
is not fully decompiled, and no complete function or executable-byte denominator
has been established.
