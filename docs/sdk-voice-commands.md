# SDK voice allocation and commands

Nine complete procedures replace 1,512 bytes of the audio driver's extracted
code. The source uses one shared set of voice, physical-voice, sample, and
parameter records across the driver and Robotron's audio backend.

| Source | Procedure range | Functions | Code bytes | IDO 5.3 profile |
| --- | --- | ---: | ---: | --- |
| `voice_allocate.c` | `0x80066360..0x80066588` | 2 | 552 | O3, MIPS II, R4300 multiply option |
| `voice_start.c` | `0x80066590..0x80066674` | 1 | 228 | O2, MIPS II |
| `voice_pitch.c` | `0x80066680..0x80066704` | 1 | 132 | O2, MIPS II |
| `voice_volume.c` | `0x80066710..0x800667AC` | 1 | 156 | O2, MIPS II |
| `voice_pan.c` | `0x800667B0..0x80066834` | 1 | 132 | O2, MIPS II |
| `voice_stop.c` | `0x80066840..0x800668B8` | 1 | 120 | O2, MIPS II |
| `voice_release.c` | `0x800668C0..0x80066970` | 1 | 176 | O3, MIPS II, R4300 multiply option |
| `voice_priority.c` | `0x80066970..0x80066980` | 1 | 16 | O2, MIPS II |

## Allocation and release

Allocation first takes a pending-free physical voice, then a free voice. Both
paths unlink the selected node and put it on the allocated list. When those
lists are empty, the helper scans allocated voices and retains a candidate
whose priority is no greater than the requested priority and whose steal
offset is zero. Updating the comparison priority as the scan proceeds
preserves the target's ordering and tie behavior.

The public allocator initializes the virtual voice's configuration and then
attaches the selected physical voice. Stealing detaches the old client,
sets a 512-sample offset, requests a volume ramp to zero over 448 samples,
and schedules a stop at the end of the offset. The first parameter allocation
on that path is dereferenced without a null check in the target. The second
allocation is checked. The reconstruction preserves both behaviors.

Release moves an immediately reusable voice onto the pending-free list. A
voice with a nonzero offset instead receives a deferred-free parameter. A
failed deferred-free allocation returns before clearing the client's physical
voice pointer. The successful paths clear that pointer after scheduling or
queueing release.

## Parameter commands

Start, pitch, volume, pan, and stop require an attached physical voice. Each
allocates an update and returns without changing the voice when allocation
fails. The timestamp is the synthesizer's current parameter sample plus the
physical voice's offset. The channel receives the parameter through its
existing update-list callback.

Start carries the wavetable, unity-pitch flag, pitch, volume, pan, effect mix,
and attack time. Attack and volume durations use the driver's existing
microsecond-to-sample conversion. The effect-mix argument is an unsigned
byte, but the target retains a redundant signed-negative test and negation;
the source keeps that conditional in its original argument-width context.
The priority setter accepts a signed 16-bit priority and stores the same
field directly. These details distinguish the complete procedure matches
from superficially equivalent declarations or expressions.

## Shared records and callers

`AudioSynthVoice` and `AudioSynthVoiceConfiguration` now alias the canonical
SDK voice and configuration records. The game-side sample record embeds the
20-byte `AudioWaveTable` followed by its four-byte tuning value. Loop and
ADPCM-book definitions are shared with bank relocation. Robotron's bank
stores 128 coefficients per ADPCM book, giving a 264-byte record; its aligned
bank stride is checked separately by the existing layout header.

Bank initialization still reads serialized offsets before replacing them with
loop and book pointers. The shared union names describe those same words and
retain all original offsets. Compile-time checks cover the 28-byte voice,
six-byte configuration, 20-byte SDK sample, 24-byte game sample, 12-byte raw
loop, 44-byte ADPCM loop, and 264-byte book. Makefile dependencies include the
transitive headers so a shared declaration change rebuilds its users.

All 15 existing source units affected by these declaration changes were
independently rebuilt and compared over their complete code and owned data.
They retain zero differences, including the full 708-byte bank initializer.

## Verification and references

Each new unit has a full compiled-byte proof with exact ELF procedure offsets
and sizes. None emits initialized data, constants, or BSS. The allocator's
232-byte helper precedes its 320-byte public function in the object, even
though the public function appears first in the C file. Only verified trailing
alignment outside the live procedure extents is removed. All eight units are
registered for independent comparison, and their original ROM ranges are
provided by the production linker.

The target instructions and existing callers establish these implementations.
The pinned libreultra `synallocvoice.c` declaration and list-layout study at
`1aca5c13ca041cef86f8dc194b727361dad9c09b` corroborates the natural local-variable
order and the Boolean result of allocation. The corresponding online source
was checked during reconstruction. See [CREDITS.md](../CREDITS.md) and the
earlier [voice and resampler study](sdk-audio-voices.md); that study's adapted
implementation remains local research, while the target-derived units above
are part of the published source.
