# Reverb rendering and delay-line transfers

Eight complete procedures reconstruct the effect's modulation, circular
buffer transfers, resampling, parameter updates and output mixing. They
occupy `0x8006E770..0x8006F3BC`, ROM `0x6F370..0x6FFBC`, and account for
3,148 live C bytes plus 40 initialized bytes.

| Procedure | Target range | Live bytes |
| --- | --- | ---: |
| `func_8006E770` | `0x8006E770..0x8006E818` | 168 |
| `func_8006E818` | `0x8006E818..0x8006E8D0` | 184 |
| `func_8006E8D0` | `0x8006E8D0..0x8006EA58` | 392 |
| `func_8006EA58` | `0x8006EA58..0x8006EBE4` | 396 |
| `func_8006EBE4` | `0x8006EBE4..0x8006EE08` | 548 |
| `func_8006EE08` | `0x8006EE08..0x8006F064` | 604 |
| `func_8006F064` | `0x8006F064..0x8006F07C` | 24 |
| `func_8006F07C` | `0x8006F07C..0x8006F3BC` | 832 |

The four transfer helpers are compiled together in `audio_effect_buffers.c`.
Their complete object procedure offsets are 0, `0xB8`, `0x240` and `0x3CC`
for `func_8006E818`, `func_8006E8D0`, `func_8006EA58` and `func_8006EBE4`.
IDO emits them in that order from their reverse source definition order.
The other four procedures each occupy a complete translation unit. All use
the existing checked audio filter, delay, low-pass and resampler layouts.

## Circular transfers and resampling

The load and save helpers move a pointer below the delay-line base forward by
one line length. They split a transfer only when its requested end is strictly
greater than the line end. Each portion emits a buffer command and a load or
save command using the existing physical-address conversion function. The
load helper always restores the sample-count buffer command; the save helper
does so only after a wrapped transfer. These differences follow the target's
control flow and command order.

The output helper takes the direct load path when a delay has no resampler.
Otherwise it computes the modulation ratio, quantizes it through a signed
integer with 15 fractional bits, and carries fractional sample consumption
in the resampler state. It rounds the input pointer down to eight-byte
alignment, loads the additional leading samples, then emits the resample
command with the corresponding DMEM offset. Afterward it clears the first-use
flag and updates the accumulated difference between consumed and requested
samples.

`func_8006E770` advances the modulation phase, wraps a value above two by
subtracting four, and forms a triangle from its absolute value minus one.
The multiply workaround in the registered compiler profile is required for
the final gain multiply to appear before the return instruction. The source
retains the target's mix of float storage and double constants.

The low-pass helper emits a buffer command, loads all sixteen coefficient
shorts and emits the pole-filter command with the existing gain and first-use
flag. It clears that flag only after generating the command.

## Parameters and effect output

The parameter handler maps each identifier after the first two fields to one
delay section and one of eight section parameters. Input and output offsets
are aligned down to multiples of eight; feedback, feed-forward and gain narrow
to signed shorts. Modulation rate uses the synthesizer's output frequency,
while depth scales the unsigned difference between output and input offsets.
A cutoff change regenerates the coefficients only when a low-pass record
already exists. The separate source callback handles the existing
`SDK_AUDIO_SET_SOURCE` parameter and returns zero.

The effect pull first requests upstream audio, mixes the auxiliary channels
into the delay-line input, and clears the accumulator. It visits each delay
section in order, reuses temporary buffers when the prior output pointer
matches, and applies feed-forward, feedback, optional resampling, low-pass
filtering and section gain. It advances the input pointer and moves the
accumulated output back to the left auxiliary buffer.

Two historical details remain in the source. The reuse pointer is assigned
with the positive output offset even though the corresponding read uses the
negative offset. The input wrap test is strictly greater than the end pointer.
Both are present in Robotron's instructions and the reference SDK; changing
either would alter the matching target.

## Source declarations and owned constants

The pull's unused `gain` and `previousDelay` declarations are retained because
the inspected libreultra `src/audio/reverb.c` contains the corresponding
locals. They accompany the original short temporary-buffer swap. Earlier
retained declaration probes demonstrate that removing these locals changes
the `0xA8` stack frame or individual stack slots. Their source provenance
explains the declarations; no synthetic prefix, padding array or forced
register assignment is used.

The parameter handler owns 40 `.rodata` bytes at `0x80095FA0`, ROM `0x96BA0`:
the eight-entry relocated dispatch table and the double depth-conversion
constant. The emitted object's eight trailing alignment bytes are checked
before trimming to that complete logical extent. No other reconstructed
reverb unit emits initialized storage or BSS.

## Validation and references

The complete Robotron instruction stream was inspected for all eight
procedures, including both branches of each circular transfer and the
resampling and mixing call sites. The historical filter study and pinned
online libreultra `src/audio/reverb.c` corroborate the command meanings,
declarations and SDK behavior; their use is recorded in
[CREDITS.md](../CREDITS.md).

The retained `reverb-target-v1` reports reproduce all 3,148 code bytes with
zero differing words using IDO 5.3 and `sdk-o3-mips2-r4300-mul`. They verify
every complete procedure extent and allocated section, and retain exact
source, header and compiler hashes. The five production source units are
registered for independent recompilation with the same ownership checks.
Natural trailing text alignment is excluded from the live C totals.
The [provenance record](sdk-audio-reverb-provenance.json) retains source and
header hashes, compiler identity, complete procedure and section ownership,
and candidate and canonical report identities.
