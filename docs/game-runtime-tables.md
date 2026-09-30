# Runtime tables and game services

Eight complete game procedures match all 1,372 instruction bytes with the
pinned IDO 5.3 game profile. Two complete BSS definitions own 488 bytes.
The [provenance ledger](game-runtime-tables-provenance.json) records the
source inputs, linked procedure extents, storage symbols and ROM hashes.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_8000A21C` | `0x8000A21C` | 196 | Select a random value between either ordering of two endpoints |
| `func_8001A2C4` | `0x8001A2C4` | 128 | Initialize both player input views and the session input view |
| `func_8001A350` | `0x8001A350` | 192 | Create a kind-1 actor, randomize its frame and increment its counter |
| `func_80027940` | `0x80027940` | 200 | Assign both label pointers in each menu record |
| `func_80027A10` | `0x80027A10` | 168 | Insert an actor pair into the first free table entry |
| `func_80035190` | `0x80035190` | 180 | Apply the actor value threshold and install animation 6 |
| `func_8004B45C` | `0x8004B45C` | 156 | Draw extracted digits with increasing horizontal coordinates |
| `func_8004B4F8` | `0x8004B4F8` | 152 | Draw extracted digits in reverse order with decreasing coordinates |

## Number drawing and menu labels

Both number routines use the recovered decimal digit extractor. The local
24-byte array and local drawing coordinates reproduce the complete 96-byte
and 88-byte stack frames. Counts below 21 enter the loops. Each digit sets
the drawing coordinates with depth 200 and submits its unsigned-byte value
plus `'0'`. Horizontal coordinates change by eight after each submission.
The forward loop visits the extractor's first digit first; the reverse loop
visits its last digit first. The extractor clamps negative inputs to zero.
The character-submission body remains in fallback.

Menu records have stride `0x28`. Each supplied label is loaded once and
stored at record offsets `0x08` and `0x0C`. Counts at or below zero skip all
stores. IDO supplies the four-iteration loop unrolling. The record's other
fields retain padding, and the external table's total length is unresolved.
No table storage or commercial label text is counted as reconstructed data.

## Actor pair table

The table at `0x800A4580` has twenty eight-byte entries, each holding a
follower and source actor pointer. The insertion routine returns one after
writing the first entry with a null follower, or zero when every entry is
occupied. It preserves the original behavior for null arguments. The fixed
twenty-entry scan establishes the complete 160-byte BSS extent, ending at
`0x800A4620`. Source owns that whole table with a checked record size.

The separate position-follow routine still uses fallback. Its close private
comparison does not count toward the source totals.

## Session counters and actor creation

The shared session view has four contiguous short-counter arrays:

| Offset | Entries | Initialization bytes | Role |
| --- | ---: | ---: | --- |
| `0xB8` | 36 | `0x48` | Behavior actors |
| `0x100` | 8 | `0x10` | Scene actors |
| `0x110` | 11 | `0x16` | Unresolved intermediate counters |
| `0x126` | 16 | `0x20` | Random-spawn actors |

The initializer at `0x80021874` through `0x800218C0` clears exactly these
four spans. This evidence corrects the scene array's earlier sixteen-entry
view and extends the shared view through `0x146`, with two bytes of trailing
alignment. Its checked size is `0x148` (328 bytes), ending at the separately
bound state word `0x800AD280`. The saved prefix remains `0x4C` bytes. The
whole session now has one BSS definition; interior aliases retain their
original addresses and add no storage to the count.

Actor creation calls `func_800283D4(1, resource, position)`. A null result
returns immediately. A successful result reads the random value before
querying the object frame limit, computes `(random >> 3) % limit`, scales
that frame index by 256 and increments the resource-kind spawn counter.
No zero-limit guard or counter bound is added.

## Input initialization and value transition

Input initialization calls the existing pointer-state initializer for both
player views and the session view with values 0, 2 and 0. It then resets
each input counter view and calls the platform input service. Player views
remain address-bound aliases; their complete storage is not newly claimed.

A null actor makes the value transition return zero. Values below 257 set
actor state 2, clear owner word `0x0C` and return one. Other values apply
animation 6, invoke a previous callback after clearing flag `0x40`, then
install `func_80029210`, set that flag and timer 999. The owner is a partial
16-byte view of the pointer carried in actor field `0x3C`; its broader role
is unresolved. The unused third argument retains its original stack spill.

The random endpoint routine uses the smaller endpoint as its base and the
endpoint difference as the signed remainder divisor. Equal endpoints retain
the shipped division-by-zero trap; no special case is inserted.

## References and validation

The local [IDO materials](https://github.com/n64decomp/ido) and
[Super Mario 64 matching build](https://github.com/n64decomp/sm64) provide
compiler and build references. Robotron's complete instructions, record
strides and initialization calls establish these game layouts. All thirteen
requested projects and their recorded revisions are credited in
[CREDITS.md](../CREDITS.md).

Validation recompiles every user of the session header and checks complete
independent procedures, both owned BSS sections and all 8,388,608 ROM bytes.
Executable fallback remains, so this batch does not establish full recovery.
