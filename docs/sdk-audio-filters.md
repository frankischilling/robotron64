# SDK audio filters and effect construction

> Local reference study: the reference-adapted SDK implementations described
> below remain in the private research worktree. Separate target-derived
> reconstructions are documented in [filter construction](sdk-audio-filter-construction.md)
> [audio output](sdk-audio-output.md), the [wavetable decoder](sdk-audio-decoder.md),
> the [envelope mixer](sdk-audio-envelope.md), and
> [effect construction](sdk-audio-effect-construction.md). The complete
> [reverb renderer](sdk-audio-reverb.md) now has its own source and section proof.
> References to integration and
> comparison artifacts in this historical report describe the research build.

The remaining decoder, envelope, and effect-construction regions are standard
Nintendo libaudio source. Recovery uses the local 2.0I libreultra reference at
commit `1aca5c13ca041cef86f8dc194b727361dad9c09b` and the neighboring proven
library profile: IDO 5.3 with
`-O3 -G 0 -non_shared -mips2 -32 -Wab,-r4300_mul`.

The new `include/sdk_audio_filter_internal.h` supplies source-private SDK field
names and type aliases while size-checking them against the project's existing
public audio structs. It does not introduce a second runtime layout. It also
preserves the SDK distinction between `K0_TO_PHYS`, which compiles to an inline
`& 0x1fffffff` mask, and `osVirtualToPhysical`, which calls `func_800606A0`.
That distinction is required by the retail decoder code.

## Decoder (`load.c`)

`src/libultra/audio_decoder.c` is a mechanical translation of the SDK
`src/audio/load.c` body onto the verified project names. The complete original
object occupies `0x8006BF70..0x8006CAC0`, 2,896 bytes.

| Range | Bytes | SDK role |
| --- | ---: | --- |
| `0x8006BF70..0x8006C144` | 468 | `alLoadParam`: configure/reset the wavetable decoder |
| `0x8006C144..0x8006C4F0` | 940 | `alRaw16Pull`: pull raw 16-bit samples and handle loops/alignment |
| `0x8006C4F0..0x8006C61C` | 300 | `_decodeChunk`: DMA one ADPCM chunk and emit decode commands |
| `0x8006C61C..0x8006CABC` | 1,184 | `alAdpcmPull`: decode ADPCM frames, loops and zero-fill overflow |
| `0x8006CABC..0x8006CAC0` | 4 | Natural object text alignment |

The canonical comparison is `2896/2896` with zero differing words. The object
has no source-owned data section.

When an ADPCM wavetable supplies a loop state, `alLoadParam` copies its 32-byte
state through `func_8006F3C0`. That function is the already recovered
`src/libultra/audio_copy.c`, corresponding to the SDK `alCopy`; it remains a
separate object at its existing target address. No decoder code overlaps it.

## Envelope mixer (`env.c`)

Target and compiler evidence extend the envelope object's start 276 bytes
earlier than the initially named public-handler region. The complete original
`env.c` object occupies `0x8006CDC0..0x8006DA20`, 3,168 bytes.

| Range | Bytes | SDK role |
| --- | ---: | --- |
| `0x8006CDC0..0x8006CDE8` | 40 | `_ldexpf` helper |
| `0x8006CDE8..0x8006CED4` | 236 | `_frexpf` helper |
| `0x8006CED4..0x8006CFB4` | 224 | `alEnvmixerParam` |
| `0x8006CFB4..0x8006D184` | 464 | `_getRate` envelope-rate calculation |
| `0x8006D184..0x8006D41C` | 664 | `_pullSubFrame` command generation |
| `0x8006D41C..0x8006D4CC` | 176 | `_getVol` current-volume estimate |
| `0x8006D4CC..0x8006DA14` | 1,352 | `alEnvmixerPull` update processing and subframe rendering |
| `0x8006DA14..0x8006DA20` | 12 | Natural object text alignment |

The normal project comparator, including strict source-private data ownership,
reports `3168/3168` and zero differing words.

### Envelope initialized data

The object owns `0x140` bytes of `.data` at `0x8008F3F0`, ROM `0x8FFF0`.
The first `0x100` bytes are the source-static `eqpower[128]` table. IDO's ECOFF
debug records name `eqpower` as a private `.data` definition at offset zero;
`tools/ido_symbols.py` verifies that record without globalizing the symbol.

The remaining `0x40` bytes are the eight-double `logtab[]` declared as an
automatic local inside `_getRate`. IDO promotes that initialized local array to
the same `.data` section, but does not emit it as an `stStatic` source-private
symbol: the ECOFF private-data reader reports only `eqpower`, while the raw
object records `.data` size `0x140`. The compiler bytes from offset `0x100`
through `0x13F` match the target exactly.

The envelope also owns `0x60` bytes of `.rodata` at `0x80095F40`, ROM
`0x96B40`. They contain the helper math constants and `alEnvmixerPull` switch
table. The section ends exactly at `0x80095FA0`, where the separately recovered
effect-parameter table begins. Both envelope data sections match byte-for-byte.

## Effect construction

`src/libultra/audio_effect_init.c` contains the effect constructor and six SDK
preset arrays. `audio_effect_allocate.c` contains the allocation wrapper from
the separate original SDK source. The build preserves their distinct retail
object boundaries.

### `alFxNew` / `func_8006B940`

`func_8006B940` is `0x8006B940..0x8006BD7C`, 1,084 live bytes. It is the final
O3-emitted function from the original `drvrNew.c` object whose earlier filter
constructors are already recovered in `audio_filter_constructors.c`. IDO adds
one natural zero word at `0x8006BD7C`, giving this object's tail
`0x8006B940..0x8006BD80` a verified 1,088-byte projection.

The function installs the effect callbacks, selects one of the default/custom
parameter sets, allocates and clears the delay line, initializes each delay
section, and allocates optional resampler and low-pass state. The recovered
source preserves Nintendo's non-numeric switch order:
`SMALLROOM`, `BIGROOM`, `ECHO`, `CHORUS`, `FLANGE`, `CUSTOM`, while the actual
IDs are 1, 2, 5, 3, 4 and 6 respectively.

The low-pass pole state is the SDK `POLEF_STATE`, four shorts or eight bytes.
The original `alHeapDBAlloc` declaration also uses signed `s32 num` and
`s32 size`. Those signed argument types are observable in this caller: an
unsigned declaration makes IDO reload literal `1` into `$a3`; the SDK signed
declaration reuses the target's live `$s8 = 1`. `audio_runtime.h` and the
allocator definition now share the SDK signature, including its file-pointer
and line-number debug arguments. The allocator itself remains an exact
84-byte match with its separately established O2/MIPS II profile.

### `alSynAllocFX` / `func_8006BD80`

`src/libultra/audio_effect_allocate.c` is the separate original `synallocfx.c`
object. Its live function is `0x8006BD80..0x8006BE18`, 152 bytes, followed by
eight bytes of natural text alignment through `0x8006BE20`. The canonical
project comparison compiles to 160/160 target bytes with zero differences.
The SDK body repeatedly forms `&synth->auxiliaryBus[bus].effects[0]`; retaining
those expressions rather than introducing a convenience local is required for
the target code shape.

The production recovery preserves the retail boundary directly:
`audio_effect_init.c` contains the `drvrNew.c` effect constructor and preset
data, while `audio_effect_allocate.c` contains `synallocfx.c`. IDO therefore
produces the four-byte and eight-byte end pads naturally. Earlier private
projections are retained only as recovery evidence; the canonical production
sources now prove both object layouts without any inserted gap instructions.

### Effect preset data

The `drvrNew.c` side owns `0x190` bytes of `.data` at `0x8008F260`, ROM
`0x8FE60`. IDO ECOFF private-data records give these exact source definitions:

| Static source array | Offset | Bytes |
| --- | ---: | ---: |
| `smallRoomParameters` | `0x000` | `0x68` |
| `bigRoomParameters` | `0x068` | `0x88` |
| `echoParameters` | `0x0F0` | `0x28` |
| `chorusParameters` | `0x118` | `0x28` |
| `flangeParameters` | `0x140` | `0x28` |
| `nullParameters` | `0x168` | `0x28` |

The same object owns `0x20` bytes of `.rodata` at `0x80095EE0`, ROM
`0x96AE0`: the six-entry effect-selection jump table followed by the
double-precision chorus-depth conversion constant. Both sections match the
retail bytes exactly. Strict private-symbol verification succeeds with all six
arrays still `static`.

## Verification and integration notes

Canonical exact results under IDO 5.3 O3/mips2 with `-Wab,-r4300_mul` are:

- decoder object: 2,896/2,896 text bytes, zero differences;
- envelope object: 3,168/3,168 text bytes, plus 320/320 `.data` and 96/96
  `.rodata`, all exact;
- `audio_effect_init.c`: 1,088/1,088 text bytes, plus 400/400
  `.data` and 32/32 `.rodata`, all exact;
- `audio_effect_allocate.c`: 160/160 text bytes, exact.

`AudioLoadFilter`, `AudioEnvelopeMixer`, `AudioDelay`, `AudioLowPass`, and the
callback signatures agree with the target accesses and SDK layouts. The
corrected shared allocator signature is used by all four integrated units.

The manifest counts thirteen live functions totaling 7,284 C bytes. The
four-, eight-, four-, and twelve-byte object alignment gaps remain outside
those counts. Independent comparisons also verify 848 initialized data bytes.
The integrated full-ROM build verifies these units together with every
previously recovered caller and the source/header/object provenance records.
