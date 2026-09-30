# Scheduled groups and attached actors

`func_8000E4F0` occupies `0x8000E4F0..0x8000E5C8`, or 216 instruction bytes.
Its complete C object matches that target range with the pinned IDO 5.3 game
profile. The name remains address based; no original symbol survives.

The routine reads a slot's parameter pointer, subtracts `D_8009EF94` from its
timer, and returns zero when its signed remaining count is at most zero. The
timer subtraction also happens for an exhausted slot. A positive count returns
one, including frames on which the timer remains positive.

When the timer is due, the routine selects a 124-byte first group from the
dynamic pool using parameter field `04`. It passes that group and parameter
fields `10`, `14`, and `18` to `func_8000E108`, replaces the timer with field
`20`, and decrements the signed halfword count. It emits at most one group per
call and discards any timer overshoot. There is no index or pointer validation
in this routine.

The group, parameter, and slot layouts come from the matching dynamic pool
appenders and scheduler, with the supplied Robotron 64 USA ROM determining
the accesses and update order. Other games' behavior was not substituted.
The reference projects and compiler sources used by the project are credited
in [CREDITS.md](../CREDITS.md).

`func_8000DFEC` occupies `0x8000DFEC..0x8000E108`, or 284 instruction bytes.
Its complete C object also matches. In this handler, actor field `3C` points
directly to another actor. The shared actor view calls that field `owner3C`,
so this use needs an explicit cast to the established actor layout.

A missing parent leaves the child unchanged. Parent state `21 == 2`, or a
parent handler equal to `func_8000EAE4`, releases the child. A parent using
`func_8000E5C8` starts the child's scale decay. Otherwise, the child copies
the parent's angle, rotates its saved X/Y offsets in place through
`func_8000E720`, adds the parent's three position words, submits its object
position and angle, and clears fields `6C`, `70`, and `74`. This routine does
not advance the offset independently.

Together these routines recover two complete procedures and 500 instruction
bytes. They add no initialized data or BSS ownership.

The corresponding provenance ledger records the complete independent object
comparison and linked function metadata. ROM equality alone does not establish
whole-game source completion while executable fallback remains.
