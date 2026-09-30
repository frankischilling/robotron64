# Parameter and rendering state

Six complete procedures match all 1,728 instruction bytes with the pinned
IDO 5.3 game profile. The history writer also owns its complete four-byte
floating-point constant at `0x80095B34`. The
[provenance ledger](parameter-and-rendering-state-provenance.json) records
the complete procedure, input and storage comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_8000E3B4` | 316 | Schedule dynamic parameters into eight active slots |
| `func_8000EAF8` | 304 | Count parameter completions and create the completion actor |
| `func_80026A10` | 252 | Select Controller Pak result pages |
| `func_80046C2C` | 204 | Set the tile origin and rendering mode |
| `func_80048020` | 324 | Convert the fixed rotation matrix to RSP matrix storage |
| `func_8004E820` | 328 | Write the next position and heading history record |

## Dynamic parameter scheduling

The session's word at `0x54` selects the next 36-byte parameter record.
Word `0x6C` supplies its start time. A parameter becomes eligible only when
its unsigned time value is strictly less than the unsigned elapsed time.
Equality does not schedule it. Scheduling records the parameter pointer and
both signed halfword counts, clears the completion count and timer, advances
the session index, then advances the slot cursor modulo eight. Every slot is
ticked afterward. Once the parameter list is exhausted, the routine combines
all eight slot results and sets the completion flag when none remain active.

The completion callback changes its stored handler only when it still holds
the expected parameter handler. It increments the selected signed halfword
and compares it with that slot's original count. Reaching the count attempts
one kind-nine actor creation with the parent's third position component
temporarily zero. The resource index advances and clamps at five even if
creation fails. The parent position is restored before the score bucket
update, which reads session word `0x4C`. A successful child then invokes its
resource callback with value one.

The shared session definition exposes these three confirmed words while
retaining its established 328-byte allocation. The array reset helper now
uses the same parameter pointer type as the scheduler. No new slot-array
storage is claimed in this batch.

## Controller Pak result pages

Result one resets the alternating page index. Result minus one alternates
between two pages and increments the index after either choice, resetting
values at least two before selecting a page. Other results choose between
the two remaining pages using the existing flag and reset the index. The
unused incoming argument and all original calls are retained.

## Matrix and rendering commands

The matrix converter transposes the nine entries of the game's 3 by 3 fixed
matrix into the upper-left part of an aligned 64-byte RSP matrix. Arithmetic
right shifts by fifteen write the integer halfwords; left shifts by one
write the fraction halfwords. It explicitly fills both planes, including
the final integer diagonal value one and the zero fraction plane entries.

The rendering routine emits four complete commands. It calls the existing
display list, writes a tile rectangle from the renderer state's two origin
words with an endpoint offset of `0x7C`, enables geometry bits `0x20204`, then
writes the original texture lookup-table mode. Each coordinate is masked
before field packing. The state pointer is reread for the second command
word, as in the target instructions.

Pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/gu/mtxutil.c` corroborates the matrix's integer and fraction planes.
Pinned local [Super Mario 64](https://github.com/n64decomp/sm64)
`include/PR/gbi.h` corroborates tile-size packing and the geometry commands.
Robotron's complete instructions establish the accepted transpose, fixed
scale, masks, command order and constants. These routines were reconstructed
from Robotron evidence; the reference implementations were not copied.

## History records and verification

History slots contain sixteen records of sixteen bytes. The writer derives
the slot from actor word `0x50`, retains the original null-address check,
and masks word `0x4C` to select a record. It converts position components
in order zero, two, one, multiplying each floating-point value by 1,400 and
dividing by 60,000 before integer conversion. It then multiplies the stored
integers by twelve, stores the signed heading, and increments the full
unmasked actor index. The table's total allocation remains unresolved.

Validation covers complete standalone routine comparisons, all current
runtime, startup, native assembly and data comparisons, linked procedure
extents, owned constant bytes, tooling tests and the entire rebuilt USA ROM.
A clean archive build and publication audit check the committed source and
exclude private probes, compiler binaries, the baserom and extracted assets.
