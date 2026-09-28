# SDK audio effects

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

The effect records share the checked layouts in `sdk_audio_filters.h`.
`AudioEffect` owns the circular delay line and an array of 40-byte `AudioDelay`
records. Each delay can reference a 48-byte low-pass filter and a resampler.
The target instructions and their call sites identify these fields; the
reference SDK `audio/reverb.c` provides the corresponding algorithm names.

## Verified buffer and resampling helpers

`src/libultra/audio_effect_buffers.c` matches four complete functions with IDO
5.3, `-O3 -G 0 -non_shared -mips2 -32`. The combined range
`0x8006E818..0x8006EE08` is 1,520 bytes with no differing instruction words.

| Entry | Bytes | Operation |
| --- | ---: | --- |
| `func_8006E818` | 184 | Emit the buffer, coefficient-load and pole-filter commands, then clear the first-use flag |
| `func_8006E8D0` | 392 | Save samples into the circular delay line, splitting a write at its end |
| `func_8006EA58` | 396 | Load samples from the circular delay line, splitting a read at its end |
| `func_8006EBE4` | 548 | Load delay output with optional chorus resampling, preserving fractional samples and alignment |

The circular helpers advance a pointer below the base by one buffer length.
They split only when the requested end is strictly greater than the delay-line
end. The load helper always emits its final zero-address buffer command; the
save helper emits that command only after a wrapped write. Their RSP command
fields retain the original 16-bit masks and physical-address conversion calls.

The output helper quantizes its modulation ratio to the resampler's 15-bit
fraction, carries the fractional sample count between calls, and aligns the
load address down to eight bytes. It updates the accumulated delay difference
after emitting the resample command. A delay without a resampler takes the
direct buffer-load path.

## Verified parameter handler

`src/libultra/audio_effect_parameters.c` matches `0x8006EE08..0x8006F064`,
604 bytes, with IDO 5.3 at `-O3 -G 0 -non_shared -mips2 -32`. The compiler
emits an eight-entry jump table followed by the chorus-depth double constant.
The target owns the first 40 bytes of that generated `.rodata` at `0x80095FA0`;
the raw object has another eight bytes of alignment padding that are not part of
the target data range. Linking the 40-byte section at its target address gives
zero differing instruction words and matching read-only data bytes.

The handler maps parameter IDs to one delay section, aligns input and output
offsets down to eight bytes, writes the feed-forward, feedback and gain values,
computes chorus rate and depth, and reinitializes an existing low-pass filter
after changing its cutoff. IDO 5.3 `-O2` also produces an exact match for this
unit. IDO 7.1 `-O3` produces 608 bytes with 27 differing words, while the 5.3
`-O1` build does not reproduce the target-owned constant bytes.

## Verified effect pull

`src/libultra/audio_effect_pull.c` matches the complete
`0x8006F07C..0x8006F3BC` function, 832 bytes, with IDO 5.3 at
`-O3 -G 0 -non_shared -mips2 -32`. The same source also matches at 5.3 `-O2`.
IDO 5.3 `-O1` grows the function to 1,248 bytes and differs in 311 instruction
words; IDO 7.1 `-O3` keeps the 832-byte size but differs in 179 words.

The source keeps the SDK declaration layout and `SWAP` macro used by the
reference reverb implementation. Its unused `gain` local and second delay
pointer are retained because the reference source contains both and removing
them changes IDO 5.3's target stack layout. With both removed, the frame shrinks
from `0xA8` to `0xA0`; retaining only either declaration leaves additional
stack-slot differences. This is source-backed compiler behavior rather than an
inserted padding construct.

The specific declaration and swap evidence is
[libreultra `src/audio/reverb.c`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/audio/reverb.c#L40-L126).
The local comparison retains the exact source and each rejected declaration
variant, including the resulting frame and stack-slot differences.

The pull first mixes the two auxiliary channels into the delay-line input,
processes each delay section with optional feed-forward, feedback, resampling
and low-pass filtering, accumulates the section gains, advances the circular
input pointer, then moves the result back to the left auxiliary output. The
buffer-reuse check deliberately records `&effect->input[delay->output]` after a
section even though the corresponding output load uses the negative offset;
the target instructions and the reference SDK source both use that positive
update.

## Verified modulation leaf

`audio_effect_modulation.c` now matches all 168 bytes at
`0x8006E770..0x8006E818`. It advances the modulation phase, wraps above two by
subtracting four, forms the triangle wave from its absolute value, and applies
the resampler gain.

The required profile is IDO 5.3 with
`-O3 -G 0 -non_shared -mips2 -32 -Wab,-r4300_mul`. Without the assembler's
R4300 multiply workaround, the final multiply moves into the return delay
slot. Enabling the flag used by the inspected reference SDK builds places the
multiply before the return and preserves the target's no-op delay slot. The
same unchanged C expression then has zero differing words. Rejected profiles
and their exact inputs remain in the local evidence archive.
