# SDK audio voice allocation and resampling

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

Two previously excluded libaudio units now reproduce their retail objects with
ordinary C. The source shape follows the local 2.0I libreultra reference at
commit `1aca5c13ca041cef86f8dc194b727361dad9c09b`. The matching library profile
is IDO 5.3 with `-O3 -G 0 -non_shared -mips2 -32 -Wab,-r4300_mul`.

## Voice allocation

`src/libultra/audio_synth_allocate.c` is the SDK `synallocvoice.c` unit. Its
retail object occupies `0x80066360..0x80066590`, 560 bytes including eight
bytes of final text alignment.

| Range | Bytes | Operation |
| --- | ---: | --- |
| `0x80066360..0x80066448` | 232 | Select a pending-free/free physical voice, or choose an allocated voice eligible for stealing |
| `0x80066448..0x80066588` | 320 | Initialize a virtual voice, attach a physical voice, and schedule the ramp/stop updates when a voice is stolen |
| `0x80066588..0x80066590` | 8 | Natural object text alignment |

The allocation helper checks the pending-free list first, then the free list.
If neither has a voice, it scans allocated voices and keeps a candidate whose
priority is no greater than the requested priority and whose steal offset is
zero. A stolen voice receives a 512-sample offset. The old virtual voice is
detached, a volume update ramps it to zero over the first 448 samples, and a
stop update is scheduled for the end of the offset before the physical voice is
attached to the new virtual voice.

The exact O3 object is emitted in the same order as the target even though the
source places the public allocation routine before its helper. IDO 5.3 O3
matches all 560 object bytes with zero differing words. The live 552 code bytes
also compare with zero differences when the alignment tail is excluded.

The optimization/compiler checks distinguish the target profile:

- IDO 5.3 O1 emits 688 bytes for the 560-byte target and differs in 170 words.
- IDO 5.3 O2 emits 544 bytes and differs in 140 words.
- IDO 5.3 O3 emits 560/560 bytes with zero differences.
- IDO 7.1 O3 emits 560 bytes but differs in 17 words.

This unit owns no generated data.

## Resampler

`src/libultra/audio_resample.c` corresponds to the SDK `resample.c` filter.
Its retail object begins at `0x8006CAC0`. The two live functions end at
`0x8006CDB4`; twelve zero bytes align the next object to `0x8006CDC0`.

| Range | Bytes | Operation |
| --- | ---: | --- |
| `0x8006CAC0..0x8006CBAC` | 236 | Handle source, reset, start, pitch, unity-pitch, and forwarded filter parameters |
| `0x8006CBAC..0x8006CDB4` | 520 | Pull source samples directly at unity pitch or quantize/resample them at the configured ratio |
| `0x8006CDB4..0x8006CDC0` | 12 | Natural object text alignment |

The pull bypasses the resampler when unity-pitch mode is active and emits a
DMEM move after pulling the source. Otherwise it clips the ratio to the SDK
maximum, quantizes it to the RSP resampler's 15-bit pitch resolution, carries
the fractional input-sample count between calls, asks the upstream filter for
the required number of samples, then emits the buffer and resample commands.
The first-use flag is cleared after the first resample command.

IDO 5.3 O3 matches the complete `0x300`-byte text object, including the
12-byte alignment tail, with zero differing words. Comparing only the live
functions gives 756/756 bytes and zero differences. IDO 7.1 O3 also produces
the same resampler object exactly, so this unit by itself does not distinguish
the compiler version. O1 emits `0x3E0` bytes of text. O2 emits `0x2F0` bytes,
and both O1 and O2 emit only `0x30` bytes of `.rodata`, too little to reproduce
the target-owned constant section. The neighboring exact allocation unit is
the stronger IDO 5.3 discriminator.

### Generated constants

The O3 resampler object emits a 64-byte aligned `.rodata` section. The first
52 bytes belong to the target at `0x80095F00`, ROM offset `0x96B00`; the final
12 bytes are compiler alignment padding. The owned bytes contain the
nine-entry parameter jump table, four bytes of internal alignment, the
double-precision and single-precision forms of the maximum resampling ratio
used by the clipping path. The private owned-section proof trims only the
trailing alignment and verifies all 52 target bytes.

## Types and callers

The existing shared declarations already match the target and the SDK source.
`SdkAudioVoiceConfig` stores a signed 16-bit priority, signed 16-bit effect-bus
index, and an unsigned 8-bit unity-pitch flag. The target loads those fields at
offsets 0, 2, and 4. `AudioResampler` also matches the SDK layout: filter,
state, float ratio, integer unity-pitch flag, float fractional delta, integer
first-use flag, update-list pointers, and integer motion state.

The resampler constructor installs `func_8006CBAC` as the pull callback and
`func_8006CAC0` as the parameter callback. Synthesizer initialization connects
each resampler to its decoder through the parameter callback. The reconstructed
tree has no direct caller of `func_80066448` yet; the SDK sequence and sound
players call the corresponding `alSynAllocVoice` interface. No shared-header
correction is required for these recovered units.
