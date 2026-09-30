# Actor search and projectile fan

Two newly recovered procedures match all 732 instruction bytes with the
pinned IDO 5.3 game profile. The existing projectile service wrapper retains
its complete 32 bytes after its argument and return interface is corrected.
[The provenance ledger](actor-search-and-projectile-fan-provenance.json)
covers these three complete procedures, 764 bytes in total. The wrapper was
already counted; this batch adds two C functions and 732 live C bytes.
No new initialized data or BSS is claimed.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_80027D8C` | `0x80027D8C` | 328 | Return the first or nearest actor that passes kind and animation filters |
| `func_800295CC` | `0x800295CC` | 404 | Choose a projectile fan count, check capacity and replace the actor callback |
| `func_8003919C` | `0x8003919C` | 32 | Forward the parent, angle offset and third word to the projectile creator |

## Actor search

The search follows the existing actor list from `D_800AA708`. Actor kind must
equal the supplied kind. A zero resource-kind limit disables that filter;
otherwise the resource kind must be strictly smaller than the signed limit.
Animation `0xDEAD` disables the animation filter. Other values must equal
the actor's animation byte.

An immediate search returns the first actor that passes all filters. A
nearest search uses `abs(actor.x - position.x) + abs(actor.y - position.y)`.
It captures both coordinate differences before either absolute-value call.
Z is ignored. The best distance starts at signed `0x7FFFFFFF` and replacement
requires a strictly smaller distance, so ties retain the earlier actor.
The returned pointer starts at zero and remains zero if no candidate wins.

The original signed arithmetic, absolute-value calls and low-word distance
sum are retained. No new overflow or empty-list checks alter the comparison.
The shared interface already describes all five arguments and the returned
actor pointer; this recovery uses that definition directly.

## Fan count and callback

Resource kinds 26 and 27 select counts two and four. Kind 28 first evaluates
`((random >> 3) % 255) & 0xC0`. A nonzero result selects zero. Otherwise a
second random call selects `(random >> 3) % 4 + 4`. Other kinds select one.
Both random shifts and remainders remain signed, including behavior for
negative random words.

The actor's object scale is set to 80 on all three axes before the loop.
Each iteration checks the sum of the existing counters at `D_800ACD90[7]`
and `[8]` against `D_800AC97C`. The limit has the surviving tweak label
`MAX_BRAIN_MISSILES`. Passing the check forwards the actor, angle offset
`(index << 9) - ((count << 9) / 2)`, and resource kind minus 25. The complete
signed division is retained. Capacity is checked again for every iteration.

After the loop, flag `0x40` invokes the old callback after clearing that bit.
The flags are reloaded after that call, then `func_80029210` and timer 999 are
installed with `0x40` set. This happens even when the count is zero or every
capacity check fails. The timer, flag and callback stores retain their
original instruction order.

## Forwarding interface

The wrapper forwards the three incoming argument registers unchanged to
`func_8004E1C0` and returns its actor pointer. The downstream procedure uses
the parent and angle offset, homes the third word, and returns an allocated
actor or zero. Its complete disassembly provides the argument and return
evidence. The shared header now describes both interfaces, and the wrapper
passes the arguments explicitly. This produces the same complete 32 bytes.

The third word is unused in the downstream procedure; its conservative name
records the caller's supplied kind without assigning it an effect. The
downstream creator still has stack-layout differences and remains fallback.
It contributes no matching functions, code bytes or storage to this batch.

## References and validation

The pinned local [IDO](https://github.com/n64decomp/ido) and
[Super Mario 64](https://github.com/n64decomp/sm64) compiler and matching-build
references provide the existing workflow basis. Complete Robotron
instructions establish the filters, distance, random selection, capacity
checks, callback stores and forwarding interface. All thirteen requested
projects remain recorded in [CREDITS.md](../CREDITS.md). No reference
implementation is copied into these procedures.

Validation covers all tooling tests, fresh extraction and build, every
runtime, startup, native assembly and data comparison, complete linked
procedure extents and the exact USA ROM. Publication also checks a fresh
committed archive and its public source inventory.
