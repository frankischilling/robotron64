# Random spawn position

`func_80027ED4` occupies all 696 bytes at `80027ED4..8002818C`
(ROM `28AD4..28D8C`). Its source is `src/game/actor_spawn_position.c`.
The complete IDO 5.3 output matches the independently reassembled retail
instructions, including the 104-byte frame, delay slots and division guards.
The source uses the existing 12-byte position and 124-byte actor views.
It adds no initialized data or BSS.

The function generates X and Y with signed RNG arithmetic:
`((random >> 3) % 3000) * 18 - 27000`, and sets Z to zero.
A nonzero axis constraint consumes two more random values. Their signed
remainders modulo 256 choose one axis and replace its coordinate with zero
or 60000. Negative random values retain signed shifts and remainders.

Zero spacing accepts the generated position without reading the actor list.
Otherwise the function walks `D_800AA708`, rejecting a candidate when both
absolute coordinate differences are strictly below their respective limits.
Each limit starts at 3000. An actor of kind two multiplies both limits by
`spacing * 30 / 10`, with the retail word multiplication and signed division,
then resets the limits after its test.

Each rejecting actor decrements the shared budget of 100. Several actors can
consume budget in one attempt. The scan continues after rejection unless the
budget reaches zero; failure returns zero without writing the output.
After a successful scan, the function copies all three position words and
returns one. Required pointers and linked-list termination remain unchecked.

The matching form uses a natural `continue` when spacing is zero, followed
by the actor scan. The local declaration order reproduces the retail register
choices and candidate position at frame offset `0x4C`.

`tools/check_actor_spawn_position.py` freshly compiles both this function and
the complete absolute-value support unit. It checks 5,768 guarded cases:
3,846 successes and 1,922 failures, including eight failures with a null
output pointer. The cases cover negative RNG values, signed overflow and
`INT_MIN` absolute value, both axis constraints, strict spacing boundaries,
kind-two scaling, several rejections in one scan, retries and output aliases
to an actor position or the head storage. It checks every RNG boundary,
guarded memory images, failure output, stack write ranges and saved integer
registers against the retail function and an arithmetic oracle.

The random generator uses a deterministic stub that clobbers caller-saved
integer registers. The absolute-value helper executes matching source.
This proof does not cover actual RNG state, complete gameplay, invalid
successful output pointers, cyclic lists, concurrent mutation or floating
register preservation. Signed overflow describes pinned IDO/MIPS behavior,
including the retail negative result for absolute value of `INT_MIN`.

Ghidra uses the verified position and actor layouts, the three-argument
integer prototype and the existing `GameActor *` list head. The call at
`800209E0` passes a zero axis constraint and tests the integer return value.
The external head is a four-byte uninitialized analysis view; it adds no
source-owned storage.

The [provenance ledger](actor-spawn-position-provenance.json) records the
current comparison, execution checks, clean ROM build and measurement limits.

The workflow follows the pinned compiler and independent comparison practices
in the [N64 reference study](reference-study.md). [Credits](../CREDITS.md)
lists the tools and local reference projects. No reference implementation was
copied; Robotron's retail instructions establish the behavior.
