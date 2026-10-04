# Audio hardware driver

This batch reconstructs 18 complete functions, 2,304 code bytes, 50 bytes of
private BSS, and eight compiler-generated constant bytes.

| Source | Complete range | Functions | Code bytes |
| --- | --- | ---: | ---: |
| `audio_pitch_scale.c` | `0x8005B000..0x8005B064` | 1 | 100 |
| `audio_backend_update.c` | `0x8005B66C..0x8005B7BC` | 4 | 336 |
| `audio_backend_voice_stop.c` | `0x8005B7BC..0x8005B854` | 1 | 152 |
| `audio_backend_patch.c` | `0x8005B9F8..0x8005BA24` | 2 | 44 |
| `audio_backend_release.c` | `0x8005C4F8..0x8005C684` | 2 | 396 |
| `audio_backend_decay.c` | `0x8005C684..0x8005C7F8` | 1 | 372 |
| `audio_backend_allocate.c` | `0x8005C7F8..0x8005CA34` | 1 | 572 |
| `audio_file_services.c` | `0x8005CCC0..0x8005CE0C` | 6 | 332 |

## Voice lifetime and file services

The allocator at `0x8005C7F8` scans the hardware voice records, selects an unused
record immediately, and otherwise retains a candidate whose priority permits
replacement. Equal-priority candidates use release state and start time to
choose the record to replace. The selected record is stopped before its new
patch, wave, key, and velocity are installed.

The frame update checks active hardware voices for release expiration and
attack completion. The release helpers set the zero-volume ramp, clear the
attack flag, and store an absolute release deadline. The decay helper combines
voice velocity, patch volume, track volume, and the selected master volume,
then applies the patch decay level and time. The voice-stop entry updates the
instance's running-voice count or delegates final removal to the sequencer.

The file-service procedures install and invoke an error callback, validate an
index, and retain a reference count around a shared stream. A failed initial
open reports the observed error and leaves the reference count unchanged.

## Shared layouts and calling conventions

The 20-byte hardware voice record now has explicit ownership, priority, key,
velocity, pedal, patch, wave, and timing fields. The sequencer voice's byte at
`0x11` counts its hardware voices, and bit zero tracks the observed pedal-release
state. The context's byte at `0x06` counts active hardware records. These names
replace unused opaque storage without changing the record sizes.

Capture and replay use the same typed patch and wave pointers as the allocator.
Key and velocity are unsigned byte arguments throughout the capture, replay,
and allocation calls. The previously recovered capture append and replay
procedures were independently rebuilt after these declarations changed and
still match their complete target ranges.

`audio_backend_internal.h` checks the 20-byte patch region, 24-byte wave record,
28-byte SDK voice, and six-byte SDK voice configuration. The SDK layout and
call signatures were checked against libreultra's `include/2.0I/PR/libaudio.h`.
WESS terminology and related record organization were compared with the
DOOM64-RE revision recorded in [CREDITS.md](../CREDITS.md). The implementation
and placement checks use Robotron's own instructions and data.

## Pitch code and constants

The pitch helper uses exponentiation by squaring with the target's positive
and negative cent factors, then applies the output-rate ratio. Its C literals
generate the eight bytes at `0x80095CC4..0x80095CCC`; that interval is removed
from the extracted-data fallback and is verified as source-owned `.rodata`.

The complete 100-byte function matches IDO 5.3 with the usual game options and
`-Wab,-r4300_mul`. Without that assembler option, the tested helper is four
bytes shorter and lacks the target multiply-hazard NOP. A compound assignment
to the final ratio also preserves the target floating-point return sequence.
The option is assigned only to this verified source file; the default game
profile and the previously established SDK profiles are retained. No emitted
instruction is patched after compilation.

## Proof and remaining work

The [provenance ledger](audio-hardware-driver-provenance.json) records each
accepted candidate's source, report, and linked-code hashes, together with the
source that was integrated. The private BSS ranges are derived from IDO's local
symbol metadata and the declared field sizes. Only unused final alignment is
trimmed from the object; each private variable retains its observed address.

The eight units are registered in `tools/compare_runtime.py`, which recompiles
them against the current headers, compiler profile, and symbol layout and
checks every code byte and owned constant. `make progress` checks the entire
ROM and linked source provenance before reporting recovered code. `make test`
checks the compiler-profile selection, manifest, and verification tools.

The [bank initializer](audio-bank-layout.md) has since been recovered as a
complete 708-byte function with four bytes of private BSS. Several command
handlers and portions of the sequencer are still candidates.
Same-size or low-difference
results do not qualify as matches and have not replaced their fallback spans.
This batch does not claim that the entire audio system is source-recovered.

The subsequent [volume, pan, and pedal batch](audio-driver-commands.md) adds
five complete procedures and preserves their adjacent private byte fields.

## Hardware voice initialization

`audio_backend_voice_start.c` recovers the 176-byte procedure at
`0x8005C334..0x8005C3E4`. It marks the hardware record active, clears the
observed `flag40`, sets `flag20`, and copies the owner, patch priority, key,
velocity, region, and wave. It clears the pedal-pending byte, samples the
current audio time, increments both active-voice counts, and invokes the
existing playback routine. The key and velocity parameters retain their
unsigned-byte ABI declarations used by the recovered allocation caller.

The source initializes the key and velocity before the pedal and resource
pointers. This assignment order reproduces the target's load scheduling and
all 176 bytes with the canonical audio header. The
[voice-initialization ledger](audio-voice-start-provenance.json) retains the
archived complete comparison and source identities. This procedure defines
no initialized data or private BSS. The subsequent [playback and dispatch
recovery](audio-playback-and-dispatch.md) owns the complete playback procedure
at `0x8005B064` and both backend tables.
