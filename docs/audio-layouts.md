# Shared audio layouts

The recovered audio procedures now use the same declarations for their context,
instances, voices, callback records, and backend operations. The previous control
header described some of those records separately, which made it possible for a
caller and its implementation to disagree about a field or function signature.

`include/audio_properties_internal.h` contains the shared declarations. The
record sizes and field accesses come from the Robotron 64 USA instructions and
the callers recovered in the audio control, property, and host batches. The
WESS work listed in [CREDITS.md](../CREDITS.md) provides supporting terminology;
the Robotron 64 binary determines the layout used here.

The backend operation table has a frame update entry at offset `0x08`, a stop
entry at `0x14`, a pause entry at `0x18`, and twelve command entries beginning at
`0x1C`. Commands 7 through 18 select those entries with `command - 7`. Existing
voice command wrappers and volume updates use this array directly.

The instance record is 24 bytes. It contains the voice-index list at `0x0C`,
gate bytes at `0x10`, and iteration bytes at `0x14`. The 80-byte voice record
contains the label count at `0x18`, data and command pointers at `0x30` and
`0x34`, label offsets at `0x38`, and a return-stack pointer at `0x40`. The shared
header also checks the 8-byte callback record, 16-byte record-table slot,
20-byte status record, and 76-byte backend table at compile time.

The declarations for `func_8005396C`, `func_80058A58`, and `func_80059438` now
agree with their observed return values and arguments. Makefile prerequisites
include the shared header for every affected translation unit, so editing a
layout recompiles its callers.

## Validation

A fresh build of this change matches all 8,388,608 bytes of the normalized USA
ROM. The SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
`make test` passes all 105 tooling tests and validates the 773 function records
and 12 source-owned data/BSS sections at this checkpoint. This change preserves
the existing 772 C functions and 103,200 recovered C bytes; it does not add
source coverage by changing declarations.
