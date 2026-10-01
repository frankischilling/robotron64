# Scene actor reset and fade setup

`func_80032F70` covers `0x80032F70..0x800330F8`, or 392 instruction bytes.
It writes runtime state 4, conditionally requests sound 35, updates eligible
actors to animation 9, begins a palette fade with duration argument 6, and changes camera
state. The broader transition that calls it remains under investigation.

The sound condition adds the selected player's word at `0x1C` to the
nonnegative clamp of the byte at offset 6, then subtracts one. The byte is
loaded unsigned, but the shipped instructions still contain the signed
clamp branch. The source preserves that redundant test and the complete
expression. Its logical negation preserves the subtraction before the
zero test under IDO 5.3.

The actor loop follows the existing list at `D_800AA708`. It skips resources
whose byte at offset zero is nonzero and actors already using animations
1 or 4. For resource actor kinds 5 through 8, it also skips animation 3.
Every remaining actor receives `func_80027AB8(actor, 9, 1)`, the current
frame at offset `0x48`, and flag `0x8000`. The existing actor and resource
layouts establish all field offsets; no new structure or allocation is
claimed. The animation call may update the actor, so the subsequent loads
and stores retain their observed order.

The final calls use palette duration 6, camera values `(4, 1)` at offsets
`0x3C` and `0x40`, and zero at camera offset `0x44`. The function copies the
current frame to `D_800AD19C`. Those state words retain conservative names.

## Complete comparison

The verified game profile `-O2 -G 0 -non_shared -mips1 -32` reproduces all
392 bytes, including the 48-byte frame, selected-player stride, redundant
clamp, actor filters, animation call, frame and flag stores, palette call,
camera calls, and final state write. Acceptance checks the linked ELF
procedure type, size and placement, every instruction word, current source,
local headers and compiler inputs, and full ROM equality. This recovery
adds one complete C procedure and no initialized data or BSS ownership.

Complete procedure hashes and build inputs are recorded in
[the provenance ledger](scene-actor-reset-begin-provenance.json). Robotron's
target instructions and the recovered actor, palette and camera services
establish the behavior. The pinned IDO and established N64 matching
workflows are credited for local and online use in
[CREDITS.md](../CREDITS.md). Further scene and actor recovery remains tracked
by [issue #45](https://github.com/frankischilling/robotron64/issues/45).
