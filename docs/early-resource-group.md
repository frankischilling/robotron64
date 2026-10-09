# Early resource group storage

The complete first group at `8009EA18..8009EE04` has a four-byte count,
ten 96-byte resource slots and ten integer parameters. The adjacent
`D_8009EE04` selector ends at `8009EE08`, where the independently owned
input-sequence storage begins. This replaces the five-record prefix with
a complete 1,004-byte group and its four-byte selector, adding 528 BSS bytes.
Fresh full acceptance verifies the expanded storage and every retained matching unit.

| Field | Offset | Extent | Evidence |
| --- | ---: | ---: | --- |
| `count` | `0` | 4 | Script command `8000EC30` stores five; setup loads the count |
| `resources` | `4` | 960 | Setup increments resource addresses by 96 within a 1,004-byte group |
| `parameters` | `3C4` | 40 | Script command writes ten four-byte values at this offset |
| `D_8009EE04` | `3EC` | 4 | Reset and script command write the adjacent selector |

Each slot retains the loader's established 88-byte resource view followed
by eight bytes whose interpretation is not established here. The matching
reset `8001D260..8001D3F0` clears the loaded flag in the first five slots.
Its addresses are `8009EA18 + 10 + i * 96`, which are the loaded flag bytes
in the resource view beginning four bytes into the group. The initializer's
halfword at `8009EA6C` is the first slot's `playbackSpeed`.

The matching boss constructor uses the same 1,004-byte selector stride
and interprets the first five resource views. Only the first group's
complete storage extent is owned here. Indexed references do not establish
a larger source-owned array; later addresses include the selector and
input-stream objects.

The full scene resource setup procedure is `8001D3F0..8001DE54`, 2,660 bytes,
with a 32-byte diagnostic and a ten-entry, 40-byte dispatch table. Fresh
Splat and standalone SPIM references reassemble every byte of these ranges.
Its complete C research candidate remains excluded: its code and generated
dispatch table differ. The zero argument to the resource loader disables
geometry loading; the call still loads resources and can return two for an
already loaded entry.

Private guarded execution checks cover 319 pairs, 638 executions and
28,894 observed calls per image. Copying and animation resolution execute
freshly matching C. Resource loading, the scene service and diagnostics
use recorded O32 boundaries. Mutation fixtures change indices, counts and
the dynamic-pool pointer after calls. These checks establish bounded
caller behavior and do not give the setup candidate instruction ownership.

Twelve pinned IDO layout probes agree with Ghidra on the group and slot
sizes, four-byte alignments and field offsets. The natural BSS section is
1,008 bytes: a 1,004-byte array object and a four-byte selector at offset
`3EC`. It emits no executable or initialized contents. The matching command
and selector reset pass 48 guarded pairs and two rejected binary mutations.
The complete resource audit passes 1,974 executions and all six source
mutation controls, including the five early resources on the already-loaded
path.

Run the reproducible checks with `make audit-early-resource-group` and
`make audit-actor-resource-storage`. The [ledger](early-resource-group-provenance.json)
records the complete section, procedure comparisons, layouts and execution
checks.

Analysis used the running Ghidra program, pinned IDO 5.3, Splat, SPIM, m2c,
asm-differ, objdiff and the local permuter. Tools and reference projects are credited
in [CREDITS](../CREDITS.md). A fresh clean build matches all 8,388,608 retail ROM bytes. Independent
comparisons pass 906 runtime, two startup, eighteen assembly and 191 data
units. All 29 excluded candidates remain nonmatching. The tooling suite
passes its 163 tests on Linux and Windows, with four Linux-only checks
skipped on Windows. Eight support units pass fresh workbench checks.
Whole-ROM equality retains fallback and does not establish source completion.
