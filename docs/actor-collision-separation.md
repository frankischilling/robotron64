# Weighted actor separation

`func_80018E1C` comes from C at `src/game/collisions/separation.c`. Its complete
732-byte range is VRAM `80018E1C..800190F8`, ROM `19A1C..19CF8`, including the
return delay slot. The extracted fallback span and absolute function binding
were removed. The procedure adds no initialized data or BSS.

The six inputs are two actor pointers, two signed weights and two position
pointers. The shared declaration is in
`include/actor_collision_separation_internal.h`. Five existing callers use it;
older callers retain their 32-bit forwarding interfaces and cast the addresses
to the verified pointer types.

The procedure sums the actors' signed margins at offset `06` and computes the
integer distance between the input positions. When the distance is less than
the margin sum, it sets flag `10000` on each actor and computes a direction
from the input positions. It adds 400 to the overlap, divides each actor's
weighted trigonometric displacement by the total weight shifted left by 12,
and stores the first actor's X and Y before the second actor's X and Y. It
submits the two resulting positions in that order. Z remains unchanged.

A zero weight sum becomes two, and both weights are incremented. The shifted
denominator can still become zero for other signed weight sums. The four
guarded retail divisions remain in the compiled code. Arithmetic wrapping and
signed shifts preserve pinned IDO/MIPS behavior rather than portable ISO C
semantics. Position pointers can alias actor position fields, so ordered
reads and writes matter.

The independent retail reference uses installed splat/spimdisasm and GNU MIPS
assembly. The function symbol is 732 bytes; GNU assembly and IDO raw text each
have four trailing zero alignment bytes, which the linked source section
trims. Full instruction comparison includes the return and its delay slot.
Tool attribution remains in [CREDITS.md](../CREDITS.md).

`tools/check_actor_separation.py` executes ten complete matched code ranges,
including the separation procedure, real square-root and direction helpers,
integer sine/cosine, and the real position conversion procedure. Three
initialized data units are independently matched; tangent thresholds and all
short-sine samples also agree with their mathematical generators. Object
transform submission uses a recorded integer/FPU ABI stub.

The harness checks 563 retail/source comparisons against arithmetic, ordered
memory and float-byte oracles: 448 arithmetic cases, 96 actor/position alias
cases, 16 denominator-guard cases and three coordinate-wrap cases. Each call
checks actor state before a recorded service mutation. The first object
submission can mutate the second actor, checking its reloaded object index
and position. Memory and instruction bounds, guarded stack bytes, caller home
slots, saved integer registers, stack restoration, and F20 through F31 are
checked on normal returns. The object stub poisons caller-saved integer
registers and F0 through F19.

The 39 selected shifted-zero denominators stop immediately before the first retail
`break 7`. The harness verifies that instruction and the state at the trap;
it does not simulate the game's exception handler. Later division breaks,
invalid pointers, complete object submission and full gameplay remain outside
this matrix. Signed overflow describes pinned target behavior. These fixtures
do not establish portable C semantics or complete gameplay behavior.

Full-ROM equality still includes extracted fallback elsewhere. Only complete,
independently matched source ranges count toward decompilation progress.

The [verification ledger](actor-collision-separation-provenance.json) records
complete comparison, compiler/input hashes, execution and clean-build checks.
