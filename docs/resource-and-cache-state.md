# Resource and cache state

Three complete procedures match all 564 instruction bytes with the pinned
IDO 5.3 game profile. The [provenance ledger](resource-and-cache-state-provenance.json)
records their complete extents, source inputs and linked comparisons.
This batch claims no new initialized or BSS storage.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_8000CF9C` | 152 | Append a resource and position to the current dynamic group |
| `func_8000E5C8` | 296 | Initialize or advance an actor's shrinking scale and heading |
| `func_8004BC8C` | 116 | Clear both cache flag families and restore the renderer pointer |

## Dynamic resource groups

The appender captures all three incoming values before writing the heap.
It stores the resource index unchanged and multiplies both position values
by 200. It then rereads the heap pointer and current group to increment the
record count. The original unchecked append remains; no bounds check is added.

The 124-byte group stride consists of a count word and ten twelve-byte
entries, each holding resource index, x and y. Combined with the complete
allocator, this establishes all ten groups in the heap's previously opaque
1,240-byte first region. The full pool still occupies 9,096 bytes. The shared
definition now exposes these entries and replaces the unused older prefix
view. Pair-group tails remain unresolved.

## Scale and heading state

Initialization stores the handler's own address, clears the accumulated
heading value, sets scale word `0x50` to 4,096, and clears three motion words.
Updates multiply the scale word by the resource's signed scale at `0x0C`
before converting to floating point and dividing by 40,960. The existing
object scale function receives that result.

The scale word decreases by fifteen times elapsed time and clamps at zero.
The accumulated heading value increases by elapsed time, and its signed
quotient by four is added to the actor's heading. The source retains the
original division behavior for negative values and masks the stored heading
to twelve bits. Once scale falls below 700, the existing counter-decrement
helper changes the actor's state. The early resource view now shares the
confirmed scale word with the established glyph/actor resource layout.

## Cache flags

Cache reset first invokes the existing resource flag reset. It clears the
loaded byte in all 400 model cache entries at stride twenty, then clears
all 400 animation cache entries at stride sixteen. Both tables remain
address-bound views of the runtime arena. Their identifier halfword at
offset two is already established by the cache bridge. The model cache
bridge now shares its twenty-byte definition with this reset routine.

Finally, the routine restores the renderer's current pointer from its saved
pointer. Complete instruction comparison also checks the compiler's four-way
unrolling of the animation loop.

## Evidence and validation

The reconstruction uses Robotron's complete instructions and the existing
matching callers. The pinned local [IDO materials](https://github.com/n64decomp/ido)
and [Super Mario 64 build](https://github.com/n64decomp/sm64) remain the compiler
and matching-workflow references, as recorded in [the credits](../CREDITS.md).
No implementation from another game is copied into these procedures.

Validation covers tooling tests, extraction, the complete rebuilt USA ROM,
all runtime, startup, native assembly and data comparison units, linked
function extents and source provenance. A fresh archive build and publication
audit check the committed tree independently of private probes and generated
working files. Existing users of the changed shared headers retain their
complete target instructions.
