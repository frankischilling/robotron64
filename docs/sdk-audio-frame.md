# SDK audio frame and synthesizer

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. The separate target-derived reconstruction
> of this unit is now documented in [synthesizer runtime](sdk-synthesizer-runtime.md).
> Historical comparison artifacts below describe the earlier reference study.
> References to integration in this report describe the local research build.

The audio frame and synthesizer initialization code belong to one original
Nintendo audio-library translation unit. Recompiling the recovered routines as
one source file accounts for every target text byte from `0x80065C30` through
`0x80066310` and the two adjacent double constants at `0x80095E50`.

The local 2.0I libreultra reference identifies the routines and their source
relationships. Its `src/audio/synthesizer.c` at commit
`1aca5c13ca041cef86f8dc194b727361dad9c09b` declares the two static timing
helpers at lines 34-35, keeps the otherwise unused `ALVoice *vv` and
`ALVoice *vvoices` declarations at lines 43 and 45, and declares
`alAudioFrame` with an `Acmd *` return and `s16 *outBuf` at line 143.

## Recovered object layout

IDO 5.3 `-O3 -G 0 -non_shared -mips2 -32 -Wab,-r4300_mul` emits the recovered
source in the following target layout.

| Range | Bytes | Recovered role |
| --- | ---: | --- |
| `0x80065C30..0x80065C38` | 8 | Optimized out-of-line remnant of a meaningful static timing helper |
| `0x80065C38..0x80065C90` | 88 | Convert microseconds to an aligned sample count |
| `0x80065C90..0x80065CC8` | 56 | Move a physical voice to the pending-free list |
| `0x80065CC8..0x80065D28` | 96 | Collect pending physical voices back into the free list |
| `0x80065D28..0x80065D40` | 24 | Return an audio parameter record to the free list |
| `0x80065D40..0x80065D70` | 48 | Allocate an audio parameter record from the free list |
| `0x80065D70..0x80065D78` | 8 | Second optimized out-of-line remnant of the static timing helpers |
| `0x80065D78..0x80066010` | 664 | Build one audio command frame |
| `0x80066010..0x80066310` | 768 | Initialize the synthesizer, filters, voices, buses, and update pool |

The two eight-byte entries are emitted by the compiler from the real static
helper definitions. The source keeps both helpers with their complete behavior:
one scans the registered clients for the next sample deadline, while the other
converts callback microseconds to samples without the 16-sample alignment used
by the public conversion routine. Optimized normal symbols do not distinguish
the two dead remnants, so the source does not assign a speculative helper name
to either address.

The source order follows the SDK `synthesizer.c`: synthesizer initialization,
audio-frame generation, parameter allocation and release, physical-voice
collection helpers, the unrounded time conversion, the public aligned time
conversion, and the next-client scan. IDO O3 emits the functions in the target
order above. Compiling the frame alone leaves both static remnants beside the
frame and therefore gives the wrong object boundary; compiling the complete
source unit places them at the two target gaps and reproduces the surrounding
helper functions at their existing addresses.

## Audio frame

`func_80065D78` takes the command-list pointer, command-count output, a signed
16-bit output-buffer pointer, and a sample count. It returns the next audio
command pointer. It first processes client callbacks whose scheduled sample is
inside the requested frame, rounding each parameter deadline down to a
16-sample boundary. It then renders blocks no larger than the synthesizer's
maximum output size, emits the segment command, points the output filter at the
current DRAM output position, pulls the filter graph, advances the sample
counter, writes the generated command count, and collects pending voices.

The conversion used after a client callback is the SDK expression
`((float)microseconds * outputRate / 1000000.0) + 0.5`. Keeping this as the
static helper lets IDO inline it with the exact target register allocation.

## Synthesizer initialization

`func_80066010` initializes the synthesizer and allocates the save filter,
auxiliary and main buses, physical voices, per-voice decoder/resampler/envelope
filters, and the parameter-update pool from the configured heap. Its target
stack frame is `0x78` bytes.

The two unused virtual-voice pointer declarations are retained because they are
present in the original SDK source and affect IDO's frame allocation. Removing
them shrinks the independently compiled candidate frame to `0x70` bytes while
leaving the rest of the instructions unchanged. With the SDK declarations in
place, the 768-byte function matches exactly at both IDO 5.3 O2 and O3 when it
is compiled alone. The complete original synthesizer unit distinguishes the
actual profile as O3.

## Generated read-only data

The combined source emits exactly 16 bytes of `.rodata` at `0x80095E50`, ROM
offset `0x96A50`. They are two copies of the double-precision value
`1000000.0` (`41 2e 84 80 00 00 00 00`). The first is referenced by
`func_80065C38`; the second is referenced by the inlined conversion in
`func_80065D78`. The target contains the same 16 bytes at the same addresses.

## Compiler evidence

The complete `0x80065C30..0x80066310` object and its 16-byte `.rodata` match
only with the tested IDO 5.3 O3 profile. IDO 5.3 O1 emits 2,080 text bytes and
IDO 5.3 O2 emits 1,664. IDO 7.1 produces the same nonmatching O1/O2 sizes;
7.1 O3 restores the 1,760-byte size but differs in 419 instruction words.
IDO 5.3 O3 emits 1,760/1,760 target text bytes and 16/16 target read-only-data
bytes with zero differences.

## Integrated ownership

The build uses one `audio_synthesizer.c` object for all nine procedures and
the 16-byte generated `.rodata`. The manifest verifies the two private timing
procedures through IDO's paired procedure/end records and verifies every live
byte. Earlier split-source experiments remain private recovery evidence.

The game-side caller in `src/game/audio_task_build.c` includes the shared
declaration from `sdk_audio.h`. Its physical output address is explicitly
converted to the signed 16-bit buffer pointer accepted by `func_80065D78`.
The corrected caller, complete synthesizer object, generated constants, and
integrated ROM all match their targets.
