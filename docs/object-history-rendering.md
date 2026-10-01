# Object history rendering

`func_8004E968` covers `0x8004E968..0x8004EB60`. Its complete 504-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. It emits no initialized data or BSS.
The source is `src/game/object_history_render.c`.

The matching object update calls this routine with its `ObjectDrawResource`
pointer, current frame, and frame limit. The resource supplies a history
count at `0x4C` and slot at `0x50`. Those fields extend the existing partial
resource view without moving any previously recovered field. Each slot in
`D_8013FE00` contains sixteen 16-byte records. The matching history writer
records three coordinates and an angle in that ring.

The renderer selects mode one and sets an RGB color from
`D_8008D4C0[resource->type->variant - 4]`. For resource mode one, the first
draw size is `(duration - frame) * 16 / duration`; other modes use sixteen.
Starting at the newest history entry, it samples every second record,
stopping after the sixteen-entry window or at a negative history index.
Each coordinate is made relative to the camera and halved with a signed
shift. The view matrix transforms that position before the matrix packet
and angled trail geometry are emitted. Draw size decreases after each
sample and clamps to zero.

`RendererDrawState` is a sixty-byte view of the confirmed fields in
`ObjectRecord` at `0x38..0x74`: flags, three scales, three angles, world
position, projected position, draw resource, and draw value. The model
pointer at `0x74` remains in the enclosing object. These are recovered
field relationships, not surviving original type names. The matrix packet
routine reads the projected coordinates at relative offsets
`0x28..0x30`; this caller assigns those coordinates and leaves the other
local draw fields unwritten. Their original behavior is preserved.

The source retains signed division and shifts, the history-pointer check,
the exact loop limit, and the original call order. The full instruction
comparison covers the 160-byte stack frame, all local addresses, register
selection, and branch delay slots. The
[provenance ledger](object-history-rendering-provenance.json) records the
source, compiler, transitive inputs, complete bounds, and linked bytes.

Robotron's instructions and matching callers establish the behavior.
All thirteen requested local and online N64 references, their pinned
revisions, and licenses remain in [CREDITS.md](../CREDITS.md). Further
renderer and actor work remains tracked by
[issue #41](https://github.com/frankischilling/robotron64/issues/41),
[issue #43](https://github.com/frankischilling/robotron64/issues/43), and
[draft PR #46](https://github.com/frankischilling/robotron64/pull/46).

A clean Git archive of `a9f9ca0ea12005f58b5cd9f1389376846e5b15dd`
passes fresh extraction and build, all 137 tooling tests, 798 runtime
comparison units, both startup units, eighteen assembly units, eight
data-only units, and linked progress verification. The complete rebuilt
8 MiB ROM equals the supplied target, SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The publication audit checks all 1,303 tracked files. That checkpoint has
1,315 matching C procedures and 223,740 matching instruction bytes; its
unrecovered executable fallback remains excluded from those counts.
