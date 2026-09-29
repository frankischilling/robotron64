# PCM and ADPCM wavetable decoding

`src/sdk/audio_decoder.c` reconstructs the complete load-filter translation
unit: three public procedures and the private `decodeChunk` helper. Its
2,892 live code bytes cover `0x8006BF70..0x8006CABC`, ROM
`0x6CB70..0x6D6BC`. The object generates no initialized data or BSS.

| Procedure | Target range | Object offset | Live bytes |
| --- | --- | ---: | ---: |
| `func_8006BF70` | `0x8006BF70..0x8006C144` | `0x000` | 468 |
| `func_8006C144` | `0x8006C144..0x8006C4F0` | `0x1D4` | 940 |
| `decodeChunk` | `0x8006C4F0..0x8006C61C` | `0x580` | 300 |
| `func_8006C61C` | `0x8006C61C..0x8006CABC` | `0x6AC` | 1,184 |

## Wavetable configuration and reset

The parameter handler installs a wavetable, resets its sample position, and
selects the ADPCM or raw 16-bit processing callback. An ADPCM table's byte
length is truncated to a multiple of nine. The predictor book size comes
from its order and predictor count. When a loop exists, the handler copies
its start, end and count; ADPCM additionally copies the 32-byte initial
decoder state through the separately recovered `func_8006F3C0`.

Reset clears the partial-frame sample index and sample position, marks the
next block as the first, and restores the table's base address and loop count
when those records are present. Unsupported parameter identifiers do nothing.
As in the target, the parameter callback does not supply a defined integer
return value; its callers use the state updates rather than its result.

## Raw sample transfers

Raw decoding requests two bytes per sample through the configured DMA
callback. It adjusts the returned DRAM address down to an eight-byte boundary
and requests the corresponding extra bytes in RSP DMEM. Looped output handles
both DRAM and DMEM alignment, joining each new segment with a DMEM move when
either alignment requires it. The sample and source-address fields advance
using the target's original loop accounting.

For a non-looped request, bytes beyond the wavetable length are clamped to the
requested byte count. Available samples are transferred first; the remaining
output is cleared to zero. A zero-sample request returns the original command
cursor without producing packets.

## ADPCM frames and private chunk helper

Each ADPCM frame consumes nine source bytes and represents sixteen samples.
The public handler loads the predictor book, accounts for samples left from
the preceding frame, and calculates the additional frames needed. It handles
loop boundaries by decoding into aligned temporary output and joining the
segments in DMEM. The value `-1` retains the target's infinite-loop sentinel;
finite nonzero loop counts are decremented as segments are processed.

`decodeChunk` performs the aligned DMA load, optionally installs the loop
state, emits the buffer and ADPCM commands, and clears the first-block flag.
The predictor book and ADPCM state addresses use the target's inline
`0x1FFFFFFF` mask. This differs from the virtual-to-physical function call
required by the resampler and envelope stages.

The non-looped ADPCM path bounds the decoded sample count at the end of the
compressed data and clears the remaining output. It preserves the target's
separate paths for a partially decoded request and a request entirely beyond
the available frames.

## Source and matching evidence

The Robotron instruction records establish the procedure boundaries, register
operations, callback arguments and data updates. The pinned
`decompals/ultralib` `src/audio/load.c` was consulted for the SDK frame and
command definitions, wavetable interfaces and loop behavior. Its project
revision and credit are recorded in [CREDITS.md](../CREDITS.md). The earlier
reference-adapted experiment remains documented separately in the historical
[filter study](sdk-audio-filters.md).

The target's private helper uses IDO's internal register calling convention.
Keeping the actual helper and its callers in one C translation unit lets
IDO 5.3 reproduce that convention with `sdk-o3-mips2-r4300-mul`. The source
does not prescribe machine registers or inject assembly. Paired ECOFF static
procedure records verify the helper's full 300-byte extent and its position
between the two public processing procedures.

The retained candidate comparison matches all 2,892 live bytes with zero
differing words and verifies all four procedure offsets and sizes. The
canonical registry compiles the complete source unit again using the
production profile, symbols and ownership declarations. The four natural
trailing alignment bytes are checked before trimming and excluded from the
function byte total.
