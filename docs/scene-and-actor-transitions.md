# Scene and actor transitions

Seven complete procedures match all 1,720 instruction bytes with the pinned
IDO 5.3 game profile. Two complete relocated switch tables add 68 initialized
bytes. The [provenance ledger](scene-and-actor-transitions-provenance.json)
records every procedure extent, source input and table comparison.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_80009F90` | 228 | Create an effect actor and select one of six callbacks |
| `func_8000D3E8` | 272 | Advance the early pool initialization and timer states |
| `func_80015020` | 224 | Calculate scaled distance and the resource speed quotient |
| `func_8001A410` | 280 | Turn a collided actor and replace its expiration callback |
| `func_80021B38` | 220 | Convert scene arrival and tweak byte order |
| `func_80022BFC` | 252 | Select background kind, texture and both color triples |
| `func_80037050` | 244 | Update bonus counters and create spaced actors |

## Scene conversion and background selection

Scene conversion processes all 256 arrival records, then all 25 tweak
records. Each arrival first receives two 32-bit swaps, followed by four
16-bit swaps at delay, count, x and y. Each tweak receives a word swap,
then separate halfword swaps. The source retains this exact operation order
and the existing 3,348-byte scene layout. The ROM file loader now uses the
same scene conversion prototype.

Background selection masks the kind byte to seven bits. Kinds 1, 2, 3, 6,
7 and 8 become zero; kinds 0, 4, 5, 9 and 10 retain their values. Values
outside the eleven-entry switch also retain their masked value. The
complete 44-byte table is placed at `0x80092A98` and reconstructed by the
compiler from this control flow.

After updating palette tint values, the routine rereads the selected
background record, copies its texture index to the existing runtime cache
selection, then copies six color bytes to their original signed word
destinations. Background and color records have confirmed strides of 16
and 6 bytes. Their full table allocations and unused record bytes remain
unresolved; this batch claims no storage for those tables.

## Actor creation and collision

Effect creation requests kind nine with the original resource and source
position. On success it zeroes the third position component, stores the
tick handler address at word `0x5C`, and sets word `0x50` to 240. Selection
values zero through five choose the six original render callbacks, with
callback zero also serving as the default. The complete 24-byte switch
table is owned at `0x8008F958`.

Bonus creation copies the attached actor's twelve-byte position before
checking the mode flag. In the enabled mode it adds the amount to the
unsigned byte counter and attempts that many kind-nine creations. Successful
actors invoke their resource callback with value one. The first two position
components advance by 1,000 after every attempt, including failed creation.
In the other mode the amount is added to signed word `0x1C`. The existing
score-bucket helper shares the recovered 32-byte counter prefix; the full
player allocation is not inferred from that prefix.

The distance helper uses only the first two position components. It stores
integer square-root distance multiplied by 100, divides that value by the
sum of two signed resource halfwords at `0x50`, reports the result together
with signed resource values at `0x16`, and returns the quotient. The original
signed division traps and unchecked sum are preserved.

Collision turning creates effect three before examining resource kind.
Kinds 11 and 12 directly enter state two. Other kinds select animation one,
reverse the heading relative to the second actor, clear the original motion
fields and apply the heading to the object. Both original trigonometric
calls remain even though their return values are discarded. A pending
callback is cleared and invoked before installing the counter-expiration
callback with timer 999. Finally, the indexed session spawn counter is
decremented. The comma expression used for callback installation preserves
the target compiler's store scheduling and matches the existing restart
handler's source form.

## Early pool states and validation

State one reads the dynamic pool's value, scales it by 1,000, changes to
state two, records the current time, clears transition arrays, and sets a
3,000-unit delay. State two subtracts elapsed time and changes to state zero
only when the delay becomes negative. Other states subtract from the pool
timer and call the parameter scheduler. Timer expiration preserves the
original session command, timer reset and menu state assignments.

The state view exposes the confirmed prefix through `0x9C`, including the
two initialized leading words and timer fields. Its complete allocation is
unresolved and remains address-bound. The existing initializer retains its
complete instruction bytes after using this shared view.

The recorded local [IDO materials](https://github.com/n64decomp/ido) and
[Super Mario 64 matching build](https://github.com/n64decomp/sm64) supply
compiler and build references. Robotron's instructions, field offsets and
complete relocated tables establish the accepted game source. All thirteen
requested local and online references remain credited in
[CREDITS.md](../CREDITS.md). No reference implementation is copied into these
seven game units.

Validation covers all complete procedures, both owned tables, existing
callers and header users, every independent comparison family, and the
complete 8,388,608-byte ROM. The remaining executable fallback is excluded
from the recovered-source count.
