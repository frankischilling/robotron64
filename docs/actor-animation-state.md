# Actor animation state and expiration

Five complete procedures match all 852 instruction bytes with the pinned
IDO 5.3 game profile. Each has its original complete function extent and
an independent compiled comparison. No new data or BSS ownership is
claimed. [The provenance ledger](actor-animation-state-provenance.json)
records the linked procedures, compiler inputs and complete ROM hashes.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_80029194` | `0x80029194` | 124 | Copy eight auxiliary animation bytes, select animation 8 and apply its loop index |
| `func_800294A4` | `0x800294A4` | 160 | Select animation 8, create a child and install the animation callback |
| `func_80029B80` | `0x80029B80` | 200 | Decrement the repeat value or expire the actor with randomized timing |
| `func_80029C48` | `0x80029C48` | 172 | Decrement the repeat value or expire the actor with the stored timing interval |
| `func_80029D98` | `0x80029D98` | 196 | Decrement a scene counter or select animation 1 and replace the callback |

## Repeat and counter behavior

The byte at actor offset `0x22` is now exposed as `value22` in the three
shared actor views. These procedures treat it as a repeat count, but the
field keeps a conservative name because other behaviors can reuse it.
Actor size remains `0x7C`; no field offset changes.

Both repeat handlers first select animation 0 with reset enabled. For
values below 2, they set state 2 and decrement the resource-kind counter
only when the previous actor state is zero. Larger values are decremented
and the timestamp is adjusted. The randomized adjustment adds
`3000 - ((random >> 3) % 1500 + D_800B00A0)` to the timestamp, retaining
the signed shift and remainder. The other handler subtracts unsigned
`D_800B1BDC` and adds 1200. Its repeated timestamp assignment is preserved.
There are no new counter floor checks or range checks.

The scene handler uses resource kinds below 4 to decrement the existing
scene counter array and set actor state 2. Other kinds select animation 1
and install `func_80029D6C` with timer 999 after invoking any prior callback
whose flag `0x40` was set.

## Auxiliary animation and child setup

The resource pointer at `0x48` is animation track 8 in the existing
ten-track layout. The auxiliary routine copies eight bytes from
`D_8009AFC0` to that track's final eight bytes, selects animation 8 without
reset, and forwards its signed short loop index to `func_8003945C`.

The child routine selects animation 8 with reset and calls
`func_8001A350` using `D_8009F928` and the parent's position. A successful
child has position component 2 cleared and its field `0x3C` set to the
parent pointer. The existing partial actor view represents that field as
an integer, so the original 32-bit pointer conversion is retained. A
failed child allocation does not prevent callback installation. The
parent receives `func_80029210` and timer 999 through the original
previous-callback replacement path.

## References and current limits

The recorded [IDO source materials](https://github.com/n64decomp/ido) and
[Super Mario 64 build](https://github.com/n64decomp/sm64) provide compiler
and matching workflow references. Robotron's instructions establish the
actor offsets, counter updates and calling sequence. All requested N64
references are credited in [CREDITS.md](../CREDITS.md).

The full build, all independent comparisons and the publication audit are
rerun after the actor header change. Nonmatching position-follow and chain
reset probes remain private and do not contribute to these totals.
