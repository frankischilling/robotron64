# Early scene animation advance

`func_8000EE48` covers `0x8000EE48..0x8000F030`, or 488 instruction bytes.
It decrements the session animation index, marks the incoming actor's state
byte as two, creates the next actor, selects its animation path, and clears
the selected record's reset-slot bytes.

The resource choice clamps indices above four to four and preserves
negative indices. Each resource record has a verified 96-byte stride and
a resource payload at offset four. The source passes its known resource
prefix to the existing actor creator with kind eight and the incoming
actor's position. It stores the returned actor at session offset `0x80`.
The resource array extent and the final four payload bytes remain
unresolved; no resource storage is claimed.

On success, scale is `(float)(resourceScale * 2028) / 40960.0f`. The target
uses integer shift/subtract multiplication, conversion to float, and a
single-precision division. The child receives the parent's angle through
the existing object service and the first halfword at actor offset `0x10`.
Failure calls the existing diagnostic with `D_8008FB70`, then continues
through the same animation-selection code. The source preserves that
continuation, including its use of the returned pointer.

The selected 204-byte animation record supplies a word at offset zero.
When it differs from minus one, the routine passes that animation to
`func_8000ECE4`, with zero callback and timer, and the byte at offset `0x15`
in the indexed static record at `D_80073164`. It calls the camera flag
service with `(10, 5)` and clears session animation state `0xA8`. A minus
one word instead selects the existing `func_8000EDE0` service.

The routine reloads the session index and record after those calls. It
visits up to three 12-byte slots beginning at record offset `0xA8`, stopping
at the first minus one word and clearing each visited byte at slot offset
eight. The shared layout exposes these fields while retaining the verified
204-byte record, 328-byte session, 76-byte saved session, 444-byte save slot,
and 4,096-byte save image.

## Complete comparison

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces every instruction
word. The incoming actor parameter becomes the child pointer after
creation. A scoped parent local retains the original actor only through
child setup. The resource payload remains byte storage with an aligned
resource-prefix view. These declarations reproduce the target's 56-byte
frame and parent word at stack offset `0x2C`, without added workspace,
instruction patches, assembly, or unused arguments.

Acceptance checks the full linked procedure type, size and placement,
all instruction words, current source/header/compiler inputs, every
existing shared-header user, and whole-ROM equality. This recovery adds
one complete C procedure and no initialized data or BSS ownership.
Complete hashes and inputs are recorded in
[the provenance ledger](early-scene-animation-advance-provenance.json).

Robotron's target instructions establish the behavior. Pinned IDO and the
N64 matching-workflow references are credited for local and online use in
[CREDITS.md](../CREDITS.md). Further early actor and scene recovery remains
tracked by [issue #43](https://github.com/frankischilling/robotron64/issues/43)
and [issue #45](https://github.com/frankischilling/robotron64/issues/45).
