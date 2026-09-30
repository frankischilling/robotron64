# Actor behavior continuation recovery

This recovery extends the accepted actor behavior family with the complete
420-byte resource-mode dispatcher at `0x8002A244..0x8002A3E8`. Its code and
52-byte generated switch table match the US target with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`.

## `func_8002A244`

`src/game/actor_behavior_next_a244.c` recovers the resource-mode behavior dispatch at
`0x8002A244..0x8002A3E8`.  Initialization clears the movement countdown for resource
kinds 8 and 9.  Runtime behavior handles the position refresh mode, the timed callback
transition for kind 9, the continuous heading mode shared with kind 8, and the timed
0..255 progress value for kind 13.

The kind-9 callback transition preserves the order of clearing flag `0x40`,
calling the old callback, and installing the new flag, callback, and timer 999.
The three installation assignments form a comma expression, as in the other
matched actor transitions. Kind 9 then falls through to kind 8's heading
update. Elapsed-clock subtraction and the progress division remain unsigned.

The compiler-generated jump table occupies VRAM `0x800939C4..0x800939F8`
(ROM `0x945C4..0x945F8`). The linker places this source-owned section explicitly,
and the comparison checks every table entry together with the full procedure.

The first exact proof is under `.local/recovery61-actors/`. Independent
canonical-source comparison, current transitive-header snapshots, compiler
identity, symbol-layout evidence, and integration records are under
`.local/recovery61-integration/`. Remaining behavior candidates are listed in
`actor-behaviors.md` and tracked in issue #40.
