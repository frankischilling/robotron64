# Audio volume, pan, and pedal commands

This batch recovers five complete functions, 1,296 code bytes, and 41 bytes of
private BSS. It continues the [hardware driver](audio-hardware-driver.md).

| Source | Complete range | Functions | Code bytes | Private BSS bytes |
| --- | --- | ---: | ---: | ---: |
| `audio_backend_volume.c` | `0x8005BCC8..0x8005BEFC` | 3 | 564 | 17 |
| `audio_backend_pan_pedal.c` | `0x8005BEFC..0x8005C1D8` | 2 | 732 | 24 |

The first two volume-unit procedures are the target's empty eight-byte command
handlers. They retain the voice argument used by the command dispatch table.
The third procedure implements the volume change.

## Volume and pan updates

Both change handlers read the next command byte and retain it in private
storage. An unchanged value returns without scanning the hardware voices. A
changed value updates the sequencer voice before visiting the active hardware
records owned by that voice. The scan stops after processing the voice's
recorded hardware-voice count or exhausting the hardware record table.

Volume combines the hardware velocity, patch-region volume, sequencer volume,
and the master volume selected by the voice category. The unsigned product is
shifted right by thirteen before conversion to the signed volume argument.
The SDK volume call retains the target's 1,000-unit ramp argument.

Pan changes reach the hardware only while the global pan setting is enabled.
The sequencer value and signed patch-region pan are added, offset by 64, then
clamped to `0..127`. Disabling that global setting still permits the sequencer
voice's stored pan to change.

## Pedal release

A zero command byte sets the voice's pedal-release bit. The handler scans its
active hardware records, skips the observed `flag40` state, and releases only
records marked as waiting for the pedal. It clears that waiting bit before
calling the existing release helper. A nonzero command clears the sequencer
pedal-release bit without visiting hardware records.

Pan and pedal share one source unit because their private bytes are adjacent:
the pan command's saved byte is at `0x80192B1E`, and the pedal counter follows
at `0x80192B1F`. The final hardware-record pointer is at `0x80192B24`. The
24-byte source-owned range preserves this packing and the internal alignment
before that pointer.

## Matching evidence

The [provenance ledger](audio-driver-commands-provenance.json) preserves the
retained candidate hashes, whole-code comparison results, current source and
header identities, and private-symbol layouts. All five procedures match
IDO 5.3's established game profile. Reversing the operands of the source-level
unchanged-value comparisons resolved the last branch-word differences in the
volume and pan routines. No generated instruction is patched.

The volume unit owns `0x80192AFC..0x80192B0D`; the combined pan/pedal unit owns
`0x80192B10..0x80192B28`. Only unused final compiler alignment is removed. The
intervening bytes are outside the claimed source-owned ranges. Every procedure
and private variable is checked through the canonical manifest, linker,
independent runtime comparison, and full build.

The target ROM supplies the command behavior, bitfields, integer arithmetic,
and storage layout. The SDK voice-call conventions and compiler workflow use
the references recorded in [CREDITS.md](../CREDITS.md). These functions do not
complete the remaining sequencer, playback, or note-setup routines.
