# Early game medium-state recovery

This recovery set contains five complete routines in the early game region:
an actor transition callback, a pointer/state initializer, two resource-state
routines, and a bitmask-driven value lookup. All five compile with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`.

| Source | Range | Function | Bytes |
| --- | --- | --- | ---: |
| `early_actor_transition.c` | `0x80017C10..0x80017CDC` | `func_80017C10` | 204 |
| `early_pointer_state.c` | `0x8001A170..0x8001A1F0` | `func_8001A170` | 128 |
| `early_resource_state.c` | `0x8001ADA0..0x8001AF44` | `func_8001ADA0`, `func_8001AEEC` | 420 |
| `early_value_lookup.c` | `0x8001BC38..0x8001BD24` | `func_8001BC38` | 236 |

`func_80017C10` checks the resource-kind bytes of two actors. When the second
resource kind is eight and the first is below four, it retires an active
callback under flag `0x40`, installs the callback at `0x80029E5C` with timer
999, selects animation three, and clears the actor fields at `0x6C` and
`0x70`. No direct `jal` caller appears in the current CPU catalog.

`func_8001A170` stores one entry from the 0x70-byte-stride table at
`D_800739D0`, probes its third argument through `func_8004C1C8` fourteen times,
and stores either the surviving value or zero. The cataloged direct caller is
`func_8001A2C4` at `0x8001A2C4`.

`func_8001ADA0` updates one 0x68-byte resource-state entry. Mode one and the
default path reset its timestamp, current value, and rate; mode zero clamps the
current value to the base plus two steps; mode two advances on the configured
interval, raises the current value toward the base plus fifteen steps, and
decays the rate by one quarter. `func_8001AEEC` applies the requested mode to
entries zero through four. The two procedures form one contiguous 420-byte
source block. The source uses the shared `ActorResource68Internal` layout and
its compile-time `0x68` size check. The speed-up interval at `D_800B0090` is an
`int`, consistent with the adjacent tuning globals and the `int *` target passed
to the tweak binding routine.

`func_8001BC38` maps one-hot bit masks into the fourteen-entry name-pointer
table at `D_80075994`. The target data contains thirteen pointers into the
`0x80091Axx` name strings followed by a null entry. Masks one and two use the
first two entries directly; later bits are checked in groups of four until
shift fourteen. `early_value_lookup.c` and `early_name_mask_lookup.c` share the
same pointer-table declaration. No direct `jal` caller appears in the current
catalog.

The surrounding fallback ranges remain explicit. `func_8001BF48` remains
excluded because its target loop spans a backing short-array layout that is not
yet represented by a valid C object model; treating the individual symbols as
scalar objects leads to invalid pointer arithmetic and nonmatching code.

Canonical byte comparisons are registered in `tools/compare_runtime.py`.
The detailed hashes, caller evidence, procedure sizes, owned-data result, and
full ROM verification are retained in `early-game-medium-proof-ledger.md` and
`early-game-medium-provenance.json`.
