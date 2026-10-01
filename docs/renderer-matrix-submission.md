# Renderer matrix submission

`func_80047D88` covers `0x80047D88..0x80048020`. Its complete 664-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. The source is
`src/game/renderer_matrix_submit.c`. Its two diagnostic strings own the
64 bytes at `0x800953E0..0x80095420`; it adds no BSS.

The routine takes the existing sixty-byte `RendererDrawState` view and a
36-byte `FixedMatrix`. It first clamps all three projected coordinates
to the signed interval from -32000 to 32000. Upper bounds are checked
for all three coordinates before their lower bounds are checked.

`D_80126B90[index][buffer]` addresses one 64-byte SDK matrix. The index
comes from `D_8007D6A8`; the buffer comes from `D_8007D910`. The address
calculation has a 128-byte index stride and a 64-byte buffer stride.
These declarations describe the observed addressing and claim no new
ownership of the matrix arena or counters.

The routine writes the matrix's integer half as sixteen signed shorts.
It transposes the input's three-by-three entries and shifts each right
by fifteen. The final row contains the three projected coordinates and
one. It advances the short pointer by sixteen before writing the
fractional half, where the same transposed entries are shifted left by
one. The remaining fractional entries are zero. The matching
`func_80048020` converter independently confirms this packing; that
converter supplies zero translation instead.

The display-list command is `0x01020040` with the matrix's physical
address. After submission, the routine increments `D_8007D6A8`, reports
values of 250 or greater through `func_800496E0`, and returns the counter
minus one. The capacity diagnostic occurs after the matrix write and
command. It does not prevent the write. The source preserves the
original spelling `EXCCEDED`, file string `matrix.c`, and line value
`0x13B`.

The [provenance ledger](renderer-matrix-submission-provenance.json)
records complete procedure bounds, linked instruction bytes, both
diagnostic strings, compiler inputs, and the matching ROM hash.
All thirteen requested N64 references, pinned revisions, and licenses
remain in [CREDITS.md](../CREDITS.md). Further renderer recovery is
tracked by [issue #41](https://github.com/frankischilling/robotron64/issues/41)
and [draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
