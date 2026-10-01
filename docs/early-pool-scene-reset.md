# Early pool and camera reset

`func_8000D4F8` resets the camera, early pool records, actor object flags, and
debug context. Its complete range is `0x8000D4F8..0x8000D614`, with 284
instruction bytes.

The function clears the two camera state values and passes three zero
arguments to the camera angle and position services. The normal angle
service retains its half-turn Y offset in the fixed-angle representation.
`func_8003A1E4` sets the camera value at `0x1C` to `500.0f` and its mirrored
frame word to 500. The purpose of this value keeps its generic name.
The function resets ten index words to minus one. A second loop clears nine groups
of four index/value pairs, storing zero to each value and minus one to each
index. The outer loop uses `index != 9`; the inner loop uses `pair < 4`.
IDO unrolls the four pairs and preserves the target's store order.

The function sets the state word at `0x1EC` to one, writes the sentinel
`0xBEEF` at `0x1F0`, and copies the current frame value to `0xA0`. It clears
the menu/runtime flag through `func_80022050`, walks the actor list at
`D_800AA708`, and calls the object visibility service with zero for every
actor, clearing that object's enable byte. It finishes by selecting debug
context zero.

## State layout and complete comparison

The shared `EarlyPoolTickState` prefix now records the fields through
offset `0x1F0`, or 500 bytes. Its existing fields through `0x9C` retain their
offsets. Nine 32-byte groups begin at `0xA4`; ten index words begin at
`0x1C4`. The two final words begin at `0x1EC` and `0x1F0`. Compile-time checks
verify the eight-byte pair and 500-byte prefix. The names describe the
observed resets; the full allocation and the purpose of each record remain
unresolved. This recovery adds no initialized data or BSS ownership.

IDO 5.3 with the verified game profile `-O2 -G 0 -non_shared -mips1 -32`
reproduces every instruction word, including all camera calls, floating
argument transfers, unrolled reset stores, linked-list loads, and final
context call. Acceptance checks the complete linked function type, size,
placement, current source/header/compiler inputs, and full ROM equality.
The two existing users of the shared prefix also remain complete matching
source units. No padding locals, instruction patches, or inline assembly
are needed.

A clean archive of `adc496c` passes fresh extraction and build, all 137
tooling tests, 785 independent runtime units, both startup units, eighteen
assembly units, and eight data-only units. Linked progress records 1,301
matching C procedures and 217,456 instruction bytes, with 9,531 initialized
bytes and 30,353 BSS bytes owned by source. The complete 8,388,608-byte ROM
matches the supplied USA target, SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The publication audit checks all 1,263 public files.

Complete procedure hashes and build inputs are recorded in
[the provenance ledger](early-pool-scene-reset-provenance.json). Robotron's
instructions and the already recovered camera, object, menu, and debug
services establish the behavior. The IDO compiler materials and established
N64 matching workflows remain the compiler references, credited with local
and online use in [CREDITS.md](../CREDITS.md). Further early actor recovery
is tracked in issue #43.
