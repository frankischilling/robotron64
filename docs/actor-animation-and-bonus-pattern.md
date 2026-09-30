# Actor animation traversal and bonus patterns

These two complete procedures are reconstructed from the USA target ROM.
Independent linked comparisons cover every instruction; the full build retains
the target ROM hash. The historical proof is recorded in
[actor-animation-and-bonus-pattern-provenance.json](actor-animation-and-bonus-pattern-provenance.json).

| Procedure | Address | Instruction bytes | Source |
| --- | --- | ---: | --- |
| Actor animation traversal | `0x80029FD8` | 620 | `src/game/actor_list_animation_tick.c` |
| Early bonus pattern | `0x8000F318` | 456 | `src/game/early_bonus_pattern.c` |

This batch adds 1,076 matching C bytes. It adds no initialized data or BSS.

## Animation traversal

The traversal clears the complete existing twenty-entry actor position-pair
table and resets `D_800BB130` before walking the live actor list. At completion
it copies that counter to `D_800BB134`. Both counter allocations remain
address-bound.

Animation 9 uses a 300-unit interval measured from the actor's word at offset
`0x48`. The subtraction retains the shipped low 32 bits before conversion to
the signed remaining interval. Flag `0x8000` selects the increasing angle
fraction; its expired path disables the object and stores frame `0x100`.
The other path uses the decreasing fraction. Future timestamps can produce
fractions outside the usual range; the source adds no clamp.

On expiration, mode 2 submits the zero fraction. A kind-0 actor whose resource
kind is 1 switches to animation 8. Other actors switch to animation 0, capture
the current time, and invoke the update word at offset `0x5C` with second
argument 1. The callback result is unused. Outside animation 9, kind-0 actors
wait until unsigned elapsed time from the session timestamp reaches 1,301;
other kinds invoke that update with second argument 0 immediately.

The shared 328-byte session layout now exposes the timestamp at offset `0x68`.
Its following parameter-start word remains at `0x6C`. The list's next pointer
is read after callbacks, preserving changes made during an update.

## Bonus pattern

The period is 3 when the signed level is at least 170 and the signed animation
index is below 4, and 2 otherwise. The old signed counter value is used for the
remainder before incrementing the counter. Remainder 0 selects kind 9,
remainder 1 selects kind 4, and every other value selects kind 6. The source
retains negative remainder behavior and the separate sound-13 calls.

Kind 9 starts a 30-unit counter and records its timestamp. Kind 4 records the
separate three-unit counter and timestamp, then submits child indices 0 through
9. Kind 6 increments the index by two inside the loop before submission, so
its four child calls receive indices 2, 5, 8 and 11. The final index 11 is part
of the shipped behavior.

Callback replacement clears flag `0x40` before invoking the prior callback,
then reloads the actor flags. It installs `func_8000FBC0`, sets the flag and
stores timer 999 in the verified instruction order. The child creator's three
arguments and created-actor return are confirmed by its complete disassembly;
its source candidate still has compiler differences and remains fallback.

## References

The compiler, ABI, linked comparison and source ownership workflow follows the
pinned [IDO](https://github.com/n64decomp/ido),
[Super Mario 64](https://github.com/n64decomp/sm64) and
[libreultra](https://github.com/n64decomp/libreultra) references recorded in
[CREDITS.md](../CREDITS.md). That file credits all thirteen requested local and
online N64 reference projects with their revisions and URLs. Robotron-specific
arithmetic, offsets and control flow above come from the target ROM and complete
compiler comparisons. No reference implementation is copied into these routines.

Validation covers all tooling tests, fresh extraction and build, every runtime,
startup, assembly and data comparison, complete procedure extents and the exact
USA ROM. Publication also checks a fresh committed archive and its public files.
