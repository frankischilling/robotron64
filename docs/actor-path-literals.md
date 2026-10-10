# Actor path and name literals

Six terminated byte arrays replace 204 initialized fallback bytes. The mutable
actor-name alphabets occupy 75 bytes at `80074AA4..80074AEF`. Path diagnostics
occupy 76 bytes at `8008F9A8..8008F9F4`, 24 at `8008F9F4..8008FA0C`, and 29 at
`8008FA0C..8008FA29`. Only characters and their first NUL terminators receive
ownership. The following zero bytes remain extracted fallback.

Definitions live beside their existing consumers. Both name arrays remain
writable: actor setup converts decimal digits to character values 170..179
and replaces the final three characters with `3B 26 95`.
The diagnostics retain the original spelling, tabs, and newlines. All four
consumer functions must still match their complete retail ranges.

Run `make audit-actor-path-literals` for fresh code/data comparisons and bounded
execution. Fatal capacity paths stop at the actual diagnostic boundary; unsafe
continuations and full gameplay are outside that audit. The warning path's
unusual address comparison is preserved, with no claim that ordinary fixtures
can reach it.

The audit checks 102 paired cases, independent whole-pool and alphabet oracles,
bounded memory access, integer O32 preservation on returning paths, and twelve
character/terminator mutations. Actual character conversion, string length,
coordinate scaling, integer square root and warning formatting run as matching
MIPS code. Warning output uses an argument-checked returning service boundary.
The private compiler `sizeof` probe verifies all six declared array extents;
IDO's zero-sized ELF data symbols are not used as extent evidence.

Independent Splat and spimdisasm references reproduce complete aligned banks.
Their four following zero bytes are checked against retail, but receive no
source ownership. Compiler `.data` tails are likewise excluded. Code ownership
and BSS totals do not change.

The supplied USA ROM provides the bytes and caller references. Ghidra,
Splat, spimdisasm, pinned IDO, MIPS binutils and Unicorn are credited in
[CREDITS.md](../CREDITS.md).
