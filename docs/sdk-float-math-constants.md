# Float trigonometric constants

The complete sine and cosine coefficient blocks are emitted by their C source
files. Each contains five double polynomial coefficients, a reciprocal of pi,
two parts of pi for range reduction, and a float zero. The two 68-byte blocks
occupy RAM `80095D30` and `80095D80`, at ROM offsets `96930` and `96980`.

`SdkDoubleValue` and `SdkFloatValue` initialize the values through their exact
IEEE-754 words. The code reads the floating point member. This preserves the
SDK representation and the original loads, without depending on a host's
decimal-to-binary conversion. The five polynomial coefficients include the
leading one even though these procedures use only the remaining four.

Each compiler section has twelve trailing zero alignment bytes. These bytes
are checked and remain outside the 136-byte initialized-data count. The
following RCP interrupt conversion table and shared quiet NaN remain fallback.

The pinned local [libreultra](https://github.com/n64decomp/libreultra) files
`src/gu/sinf.c` and `src/gu/cosf.c` corroborate the values and union convention.
Target bytes, linked symbols, and complete instruction comparisons establish
the accepted Robotron layout. Full local and online reference credits are in
[CREDITS.md](../CREDITS.md).

Both complete functions retain their previous matches: sine is 448 bytes and
cosine is 360 bytes. The `sdk-o2-mips2-r4300-mul` profile remains required.
The ownership records require the ten data definitions to have their exact
offsets and sizes, and reject absolute symbol bindings for recovered data.
The [provenance ledger](sdk-float-math-constants-provenance.json) records both
data blocks and complete function proofs. All 688 runtime units, both startup
units, nineteen assembly units, and 118 tooling tests pass. The rebuilt
8,388,608-byte ROM matches every normalized target byte.
