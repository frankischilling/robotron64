# Reconstructed short-sine lookup table

All 1,024 signed short entries are reconstructed as:

```text
table[index] = floor(32767 * sin(index * pi / 2046))
```

Indices zero and 1,023 include the exact mathematical endpoints, zero and
32,767. The complete 2,048-byte table is now emitted by `src/sdk/short_sine.c`
at RAM address `8008DBB0`, ROM offset `8E7B0`. Its end is `8008E3B0`; subsequent
SDK globals remain fallback. Function and BSS counts do not increase.

`tools/generate_short_sine_table.py` uses decimal arithmetic at precision eighty
and a sine series whose terms stop below `1e-70`. Explicit analytic endpoints
avoid rounding an approximation to one down by one unit. The build checks the
committed declaration against that deterministic generator before compiling.
The build consumes the committed values and verifies their generation with
decimal arithmetic.

The generator's 1,024 values match every target short. A separate compile/link
comparison checks the complete 112-byte sine procedure together with all
2,048 initialized bytes, including the symbol's exact address and size. Normal
ownership records require the table's emitted `.data`, input identities, and
linked placement. The whole-ROM comparison also covers these bytes.

The pinned local [libreultra](https://github.com/n64decomp/libreultra) file
`src/gu/sintable.h` corroborates the same quarter-wave entries. The target ROM
and independent mathematical reconstruction establish the accepted values.
The earlier short-math checkpoint counted only the sine/cosine code; this
recovery adds 2,048 source-owned initialized bytes. Full reference credits and
revisions are in [CREDITS.md](../CREDITS.md).

All 684 runtime units, both startup units, nineteen assembly units, and 116
tooling tests pass. The [provenance ledger](sdk-short-sine-table-provenance.json)
records full table hashes, emitted symbol extents, generator identity, and the
complete linked function comparison. Current progress requires fresh proofs
for the current checkout.
