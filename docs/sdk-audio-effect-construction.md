# Effect construction and low-pass coefficients

Three complete procedures reconstruct low-pass initialization, effect creation
and attachment to the synthesizer's output graph. Together they account for
1,396 live code bytes and 432 initialized data bytes.

| Source | Procedure range | Live bytes | Initialized bytes |
| --- | --- | ---: | ---: |
| `src/sdk/audio_low_pass.c` | `0x8006B8A0..0x8006B940` | 160 | 0 |
| `src/sdk/audio_effect_create.c` | `0x8006B940..0x8006BD7C` | 1,084 | 432 |
| `src/sdk/audio_effect_allocate.c` | `0x8006BD80..0x8006BE18` | 152 | 0 |

## Delay sections and effect allocation

The constructor installs the effect's rendering, source-selection and
parameter callbacks. It chooses one of five presets, a caller-supplied custom
record, or the empty record for an unsupported effect identifier. The source
preserves the target's case order: small room, big room, echo, chorus, flange,
then custom. The corresponding numeric identifiers are 1, 2, 5, 3, 4 and 6.

Each parameter record starts with the number of delay sections and the delay
line length. Eight values follow for each section: input offset, output
offset, feedback, feed-forward, gain, modulation rate, modulation depth and
low-pass coefficient. The constructor allocates the section records and delay
line from the existing audio heap, clears the samples, and initializes each
section. Its sample, section and parameter indices retain the target's
16-bit unsigned behavior.

A nonzero modulation rate allocates the resampler and its state and computes
its increment and gain. A nonzero low-pass coefficient allocates the filter
and eight-byte pole state and generates the coefficient vector. Absent stages
have null pointers, while their parameter slots are still consumed. The
`AudioDelay`, `AudioLowPass` and pole-state layouts have compile-time size
checks of 40, 48 and 8 bytes respectively.

`func_8006BD80` selects the requested auxiliary bus, creates its embedded
effect, sets that bus as the effect's source, and adds the effect to the main
bus. It returns the same embedded effect pointer. The recovered caller in
`audio_synthesizer.c` uses this path when effects are enabled.

## Low-pass initialization

`func_8006B8A0` scales the signed frequency coefficient, derives the complementary
gain, and marks the RSP filter state for initialization. It clears the first
eight entries of the 16-short coefficient vector, stores the scaled frequency
in entry eight, and fills the remaining entries with successive powers of
that coefficient. The double-precision calculation and signed-short stores
match the target, including the narrowing after the initial scaling.

## Complete preset ownership

The constructor's `.data` is 400 bytes at `0x8008F260`, ROM `0x8FE60`.
All six arrays remain source-static and are checked against IDO's private
data records before linking.

| Array | Section offset | Bytes |
| --- | ---: | ---: |
| `smallRoomParameters` | `0x000` | 104 |
| `bigRoomParameters` | `0x068` | 136 |
| `echoParameters` | `0x0F0` | 40 |
| `chorusParameters` | `0x118` | 40 |
| `flangeParameters` | `0x140` | 40 |
| `nullParameters` | `0x168` | 40 |

Preset delays use the target's unit of 40 samples: 44.1 is first converted to
an integer and then rounded down to a multiple of eight. The source expresses
the delays through that conversion instead of embedding an opaque byte array.
Every resulting integer is checked against the normalized ROM.

The complete 32-byte `.rodata` section is at `0x80095EE0`, ROM `0x96AE0`.
It contains the relocated effect-selection table and the double-precision
modulation-depth conversion constant. None of these three units emits BSS.

## Source and comparison evidence

The verified Robotron instructions establish the full procedure extents,
field offsets, callback order, argument types and mixed-precision arithmetic.
The local historical filter study and pinned online libreultra
`src/audio/drvrNew.c` corroborate the SDK parameter meanings, preset units and
coefficient construction. Their use and revision are credited in
[CREDITS.md](../CREDITS.md); the reference-adapted study remains separate in
[sdk-audio-filters.md](sdk-audio-filters.md).

IDO 5.3 with `sdk-o3-mips2-r4300-mul` reproduces all three complete procedures
with zero differing words. The retained `effect-target-v1` and
`low-pass-target-v2` reports include source/header/compiler hashes and full
allocated-section checks. Each source is also registered for an independent
production comparison. The four-byte constructor alignment tail and
eight-byte allocator alignment tail are verified separately and excluded
from live C byte counts.
The [provenance record](sdk-audio-effect-construction-provenance.json) retains
the accepted source, header and toolchain hashes, complete procedure extents,
owned section placements and canonical comparison identities.
