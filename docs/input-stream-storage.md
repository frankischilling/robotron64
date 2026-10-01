# Audio stream sizing and input sequence storage

The complete procedure `func_80059644` at `0x80059644..0x800596C4` matches
all 128 instruction bytes with the pinned IDO 5.3 game profile. Six data-only
sources also own 80 initialized bytes and 1,252 BSS bytes. No partially
matched procedure contributes instruction bytes to this checkpoint.

## Variable-length size

The helper builds seven-bit groups in reverse order, retaining a clear high
bit on the last group and setting continuation bits on preceding groups.
It copies the groups forward until it reaches the clear high bit, then
returns the output length as an unsigned byte. A zero input returns one;
32-bit unsigned inputs require at most five bytes. The existing stream
reader and writer use the same continuation-bit convention.

The reconstructed reverse buffer has eight bytes and the forward buffer
sixteen. These accommodate all five groups. Declaring the input cursor before
the arrays reproduces their offsets in the target's 32-byte frame. The byte
store and right shift use one sequenced comma expression; separate statements
swap two instructions with this compiler. The source adds no operations to
shape the output. Matching establishes the generated procedure, not a unique
original spelling or buffer declaration.

The typed stream reader, writer, and size declarations now share
`audio_property_pipeline_internal.h`. Their complete comparisons must pass
with the changed header.

## Input storage

The matching input recognizer walks fourteen records with a 28-byte stride,
reads each signed button halfword, and uses paired progress and timer arrays.
The reset routine clears all fourteen progress/timer pairs. The file loader
copies `0x320` bytes into the button pool and clears its cursor. The sequence
definition procedure's target checks the pool against 400 halfwords and
selects three fixed sequences at record indexes 1, 13, and 12. That procedure
is published as `src/game/early_input_sequence_define.c` and registered in the
excluded candidate comparisons. It preserves the command fields, pool-limit
diagnostic, cursor advance, and fixed-sequence overrides. Its target supplies
the fixed lengths and addresses; compiler differences remain outside matching
progress. The current candidate compiles to 284 bytes with 69 differing
words, including a 56-byte frame where the target uses 64 bytes.

| Source definition | Address | Owned bytes | Storage |
| --- | --- | ---: | --- |
| `D_80073A48`, `D_80073A78`, `D_80073A80` | `0x80073A48` | 64 | Three initialized button sequences |
| `D_8009E588` | `0x8009E588` | 4 | BSS cursor word |
| `D_8009E590[400]` | `0x8009E590` | 800 | BSS signed button halfwords |
| `D_8009E9E0` | `0x8009E9E0` | 56 | BSS fourteen progress values and fourteen timers |
| `D_8009EE08[14]` | `0x8009EE08` | 392 | BSS sequence records |

The fixed sequences contain 24, three, and four button halfwords. Their
64-byte compiler section includes the verified two-byte alignment gap before
the third array. The source uses the observed game-button masks without
assigning speculative action names. The full records retain the existing
unknown fields; this work does not guess their meanings.

The loader uses the shared signed-halfword declaration instead of a separate
byte-array declaration. Its copy still consumes exactly 800 bytes. Independent
compilation checks every BSS symbol offset, trims only trailing compiler
padding, rejects executable code in data units, and checks all linked spans.
BSS consumes no ROM payload, and its size is not an initialized-byte match.

## Audio timing state

`audio_timing_data.c` defines the four initialized words at
`0x8008D868..0x8008D878`. The target initializes all four to zero. The timing
callback increments the first word, updates the millisecond word and
fractional accumulator, and tests the enable word before calling its two
services. The existing audio memory setup exposes the millisecond word to the
backend through a pointer. These accesses establish four separate word-sized
globals; the source preserves their shared unsigned/signed declarations.

The callback itself still differs in four register assignments and remains
fallback code. Its sixteen data bytes match independently without making a
claim about those instructions.

[The provenance ledger](input-stream-storage-provenance.json) records the
complete procedure, exact initialized sections, BSS extents, compiler
identity, and input hashes. The full ROM still uses extracted fallback code;
ROM equality does not establish a fully decompiled game.

The local libreultra `src/audio/seq.c` and `src/audio/cseq.c` provide context
for seven-bit continuation groups. The pinned IDO and SM64 references provide
compiler and matching-workflow context. Robotron's own instructions, callers,
and bytes establish this implementation and its storage; no reference code
was copied. All thirteen requested projects remain in [CREDITS.md](../CREDITS.md).
