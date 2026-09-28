# Object creation and model state

Fifteen complete functions add 800 bytes of matching C around the start of
the object manager. Each unit stops at its actual procedure boundary; the
four-byte gap before `func_800391C0` remains outside source progress.

| Source | Functions | Code bytes |
| --- | ---: | ---: |
| `object_service.c` | 1 | 32 |
| `object_registration.c` | 4 | 92 |
| `object_creation.c` | 3 | 448 |
| `object_model_access.c` | 7 | 228 |

`func_800391C0` raises the recorded high-water index when necessary and
returns the supplied index. Its neighboring callbacks include an empty
entry point, a signed-halfword dereference, and an integer passthrough.
Their unused arguments and complete ABI argument stores are retained.

`func_8003921C` rejects creation when the object counter reaches 251. It
otherwise calls the existing slot allocator and installs the supplied draw
resource, model, type, and count in the 120-byte object record. The target
writes the record before checking the returned index for failure. The
reconstruction preserves that order, including the conditional count update
and unconditional increment of the object counter.

`func_800392F4` removes the object's count from the running total only for
the target status value, then calls the existing release helper.
`func_80039358` marks all 300 status entries free, decrements the live-slot
counter while it is positive, and clears the object counter. IDO generates
the target's four-entry unrolling from the counted loop.

The model-state helpers read and write the observed bytes at object offsets
`0x0E`, `0x14`, and `0x15`. The frame setter writes the requested frame,
fetches the frame byte through the existing model/frame pointer layout, and
then sets the object's halfword at offset two to one. The write order is
part of the complete comparison.

## Evidence

The target assembly, callers, and initial source sketches are retained under
`.local/recovery64-map/objects`. Recovery proofs are under
`.local/recovery65-objects`; canonical source/header snapshots and independent
procedure-boundary checks are under `.local/recovery67-integration`.
All units use IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` and define no
initialized data or BSS. They reuse the existing object, model, and draw
layouts rather than introducing alternate record sizes.

The original game determines this behavior. Compiler and N64 workflow
references, including the requested reference collection, are credited in
[CREDITS.md](../CREDITS.md).
