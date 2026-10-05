# Actor damage and value transition

`func_80035244` now comes from C at `src/game/collisions/damage.c`. Its complete
284-byte range is VRAM `80035244..80035360`, ROM `35E44..35F60`, including the
return delay slot. The extracted fallback span and absolute function binding
were removed. This procedure adds no initialized data or BSS.

The handler preserves the actor's prior health, checks the global damage guard,
and either subtracts the other actor's health directly or calls the existing
pair-balance procedure. It updates the owner's child through the existing value
transition procedure. After that call it reloads health and the countdown:
nonpositive health or an expired countdown submits a color change and retires
the actor; otherwise it sets the damage flag and records the current clock.

The health fields are signed shorts at offset `10`. Direct subtraction wraps
when stored back to the short. Pair balance clamps negative health before two
ordered stores, so aliased actor arguments have a different result from two
distinct actors. The owner is a partial 16-byte view with its child pointer at
offset `0C`; the allocation's complete layout remains unknown.

`include/actor_damage_internal.h` gives the damage handler, child value update,
and retirement procedure consistent signatures. Four existing callers now use
that declaration. The two older early-actor callers retain their existing
32-bit argument interfaces and cast the forwarded address to the verified actor
view. Their complete instruction ranges are independently recompiled to check
that the type correction preserves the existing calls.

An initialized empty test near the start of the damage handler preserves IDO
register allocation. Its value is explicitly zero before the test. A permuter
result that tested an uninitialized local was rejected; the initialized version
was freshly compiled and matched independently.

`tools/check_actor_damage.py` executes the damage handler together with the real,
matched `func_80015130` pair-balance and `func_80035190` child-value helpers. It
checks 656 retail/source comparisons against independent state and event
oracles: 480 arithmetic cases, 25 signed countdown cases, 64 alias cases,
64 service-mutation cases, 15 early-disable cases with null unused pointers,
and eight resource short-circuit cases. All guarded actor, owner, resource and
global bytes are checked before service calls and after return. The harness
also checks memory and instruction bounds, the return value, caller argument
home slots, guarded stack bytes, saved integer registers, stack restoration,
and F20 through F31 using MIPS instructions. Recorded service stubs poison
caller-saved integer registers and F0 through F19.

Animation, prior callbacks, object color and retirement remain recorded service
boundaries in this harness. Synthetic callback mutations check fresh reads and
event order; they do not prove those services' complete effects. Required actor
and owner pointers are valid synthetic allocations. Short wrapping and signed
overflow describe the pinned IDO/MIPS behavior, not portable ISO C. This is not
a gameplay, rendering or allocation-completeness claim.

Private research on `func_8002DDBC` remains excluded from source ownership. Its
current candidate still differs in 27 instruction words, despite matching all
536 generated switch-table bytes. Its three forwarding callee declarations
were reconciled with the already matched two-argument implementations and the
Ghidra analysis. No code or data from that candidate is counted here.

The independent retail reference uses the installed splat/spimdisasm tools and
GNU MIPS assembly. Typed m2c context, asm-differ views, raw and linked objdiff
comparisons, and fresh Workbench comparisons are retained privately. The public
verification ledger is [actor-damage-provenance.json](actor-damage-provenance.json).
Tool attribution remains in [CREDITS.md](../CREDITS.md).

Full-ROM equality still includes extracted fallback elsewhere in the game.
Only independently matched source ranges count toward decompilation progress.
