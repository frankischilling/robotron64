# Actor motion and callback state

Three complete procedures match all 1,092 instruction bytes with the pinned
IDO 5.3 game profile. No new initialized data or BSS allocation is claimed.
[The provenance ledger](actor-motion-callback-state-provenance.json) records
the complete linked functions, compiler inputs and exact USA ROM hashes.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_80035CC8` | `0x80035CC8` | 372 | Walk the actor list and change object state or reset motion and replace a callback |
| `func_80029E5C` | `0x80029E5C` | 380 | Create a child, assign random motion, allocate a history slot and advance the parent's callback |
| `func_80018CC8` | `0x80018CC8` | 340 | Separate the first actor from the second along X and Y |

## List traversal and callback replacement

The list helper follows `next78` from the existing head `D_800AA708`.
A nonzero mode applies object property value zero to actor kinds 2 and 6.
Mode zero applies value one to those kinds and also resets kind 2 actors:
animation 6 with reset, fields `0x2C`, `0x6C` and `0x70` cleared, both zero-angle
trigonometric calls retained, and the object angle set to zero.

For kind 2, flag `0x40` invokes the previous callback after clearing that bit.
The helper reloads the flags after the callback, sets `0x40`, installs
`func_80029194` and sets timer 999. The callback can change the actor's flags;
the reload is part of the original behavior. The helper reads the next link
after these calls and has no separate saved next pointer.

## Child motion and history slot

The child resource is entry `parent->resource24->actorKind + 4` in the existing
88-byte resource array `D_800ACE58`. The existing scene allocator creates
kind 3 and updates its scene count. Its canonical `GameActor *` return is
cast to the shared actor behavior view for the verified field accesses.

The callback sets field `0x2C` to the child's resource speed divided by ten.
Two independent random calls produce signed angles
`(random >> 3) % 4096`. Their cosine and sine values are multiplied by speed,
divided by ten and then divided by 4096 to set fields `0x6C` and `0x70`.
The products retain their low 32 bits, and both signed divisions truncate
toward zero. A third random call supplies the object's angle. A mask cannot
replace the signed remainder for negative inputs.

The original accesses the child before testing whether it is null. The late
test only controls history-slot allocation; it does not protect the earlier
resource and object accesses. The source preserves this ordering. The parent
then enters `func_80029D98` regardless of the late allocation condition.

The history-slot allocator's shared header describes its existing 84-byte
prefix, including words at `0x4C` and `0x50`, and its twenty-byte occupancy
array. This prefix is not a new allocation or a claim that actors are 84 bytes.
Moving the definition to the header leaves all 76 allocator instruction bytes
unchanged. Its call uses an explicit cast from the actor view.

## Axis separation

The separation distance is the sum of the actors' signed halfwords at offset
`0x06`, multiplied by six and divided by four. The intermediate arithmetic
and signed division are preserved. The helper captures both X and Y
differences before it moves either component.

For a positive difference smaller than the separation distance, the first
actor moves outward by `separation - difference`. For a negative difference
whose negation is smaller, it moves outward by `separation + difference`.
Each moved axis immediately updates the object's position through
`func_800290B0`. Zero differences and exact-distance cases do not move that
axis. The second actor and Z component receive no direct stores.

The Y decision uses the previously captured difference after the X update
call, while its store reads the first actor's current Y position. There are
no added distance clamps, overflow guards or null checks. Both unused incoming
words and the complete call and return sequence match.

## References and validation

The pinned local [IDO materials](https://github.com/n64decomp/ido) and
[Super Mario 64 build](https://github.com/n64decomp/sm64) provide the compiler
and matching workflow references. Robotron's instructions establish the
field offsets, callback reload, signed arithmetic and late null check.
All thirteen requested projects remain recorded in [CREDITS.md](../CREDITS.md).
No reference implementation is copied into these procedures.

Validation includes all tooling tests, extraction and build, every runtime,
startup, native assembly and data comparison, complete linked function
extents and the exact rebuilt ROM. Publication also verifies a fresh committed
archive and its public source inventory. The adjacent object interpolation
candidate remains unrecovered and contributes no matching bytes.
