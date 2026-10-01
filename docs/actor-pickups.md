# Actor pickups

`src/game/actor_pickup.c` reconstructs the complete 620-byte procedure
`func_800152E8` at `[0x800152E8, 0x80015554)` and its 64-byte, sixteen-entry
dispatch table at `0x8008FE04`. IDO 5.3 uses the established game profile.
Complete instruction and table comparisons are required for acceptance.

An actor's owner word supplies the player state. A pickup already in
animation 3 exits with zero. Otherwise, its resource's actor-kind byte
selects the behavior:

| Kind | Observed effect |
| --- | --- |
| 0–4 | Select sound 108. |
| 5 | Award one unit through the matching bonus helper; return flag 32 and select sound 98. |
| 6 | Create the kind-6 shield actor if absent. On success, set its player backpointer, add `D_8009D118 << 8` to the player's actor halfword at `0x10`, return flag 32, and select sound 106. |
| 7 | Increment player field `0x7C` and select sound 108. |
| 8–10 | Fill the first zero slot at player `0x70` or `0x74`. |
| 11–15 | OR the shifted kind bit into player byte `0x01` and select sound 98. |
| Other | Print the unknown-pickup diagnostic. |

For kinds below eleven, except 5–10, the routine records the kind at player
`0x6C` and clears `0x78`. A result other than 32 starts pickup animation 3
and records the scene timestamp. The sound call receives `(sound, 0, 1, 0)`;
the low byte of the result is returned.

The source preserves two unusual retail behaviors. Kind 6 after failed
allocation, kinds 8–10, and the default case reach the sound call without
writing its local sound word. Also, kinds 11–15 shift by values 32–36;
the target MIPS variable shift uses the low five bits of the shift count.
These paths remain as observed rather than receiving new initializers or
arithmetic fixes. All four incoming arguments are homed in the retail
prologue. The final two are unused, as in other recovered collision
callbacks; their meaning is unresolved.

`include/scene_player_runtime_internal.h` shares the existing 3,508-byte
player view with `scene_player_setup.c`. The pickup instructions confirm
that field `0x0C` is an actor pointer and that `0x78` is a word. The existing
setup routine's instructions and size remain unchanged. This view retains
the established actor pointer at `0x08`, pickup slots, and other setup
fields. The save image and score-counter prefix keep their existing views
of the same storage.

The target table selects distinct sound blocks for kinds 0–4 and shared
blocks for 8–10 and 11–15. Those destinations and all sixteen bounds are
compared as source-owned initialized data. No BSS ownership is added.
The [provenance ledger](actor-pickups-provenance.json) records both complete
procedures and the new table, with the already matching setup procedure
excluded from the new-function count.

Robotron's instructions, table, setup source, and bonus helper establish
the behavior. The thirteen requested local and online N64 references,
their pinned revisions, and licenses remain in [CREDITS.md](../CREDITS.md).
Further actor and contact work remains tracked by
[issue #43](https://github.com/frankischilling/robotron64/issues/43) and
[issue #40](https://github.com/frankischilling/robotron64/issues/40).
