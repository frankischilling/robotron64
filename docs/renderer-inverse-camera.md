# Inverse camera matrix

`func_8003F480`, `8003F480..8003F62C`, samples the three negated integer
camera angles and writes the nine signed words of `D_800CD250`. The complete
428-byte function matches pinned IDO 5.3 with the unchanged game profile.
Its caller is `func_8003A8B0`; the call occurs at `8003A90C`.

The six calls use the real fixed sine and cosine wrappers. Each product uses
its low 32 bits and an arithmetic shift by fifteen. The shared Y/Z products
are truncated before the subsequent X rotation. Combining those shifts into
one final shift would change rounding and overflow behavior.

The C source names both negative X terms and the consumed truncated products.
It retains a copy of the shift count for the rotated rows and the declaration
order that reproduces IDO's register and spill allocation. Both shift locals
have the same value, fifteen; they do not describe different fixed-point
formats. All seventeen scalar locals are consumed. There are no unused frame
locals, dummy arrays, instruction patches or compiler flag changes. Matching
the instructions establishes this reconstruction, not the original spelling
or order of the developers' declarations.

## Code and storage ownership

The raw object contains a 428-byte function, a 104-byte frame and four trailing
zero instruction-alignment bytes. The existing padding verifier removes only
those four bytes and rejects symbols or relocations touching the removed tail.
The build retains the raw object. Code ownership increases by one complete
function and 428 bytes.

`view_inverse_matrix.c` also defines the existing 36-byte `FixedMatrix` at
`800CD250`. This same-unit definition is needed for the matching address-load
allocation. It replaces the data-only matrix translation unit. The owned BSS
section, address, symbol and 36-byte extent are preserved; the raw BSS has
twelve trailing alignment bytes. This move adds no BSS ownership. The runtime
comparison checks the matrix object definition and linked placement together
with the complete function.

The canonical types remain in the existing headers: a 36-byte `FixedMatrix`
and a 40-byte `FrameView`, both aligned to four bytes. The three angle words
occupy offsets `10`, `14` and `18` in hexadecimal. Ghidra retains the void
signature, natural function bounds, canonical types and original memory.
Those BSS addresses are outside the analysis program's mapped memory; no
memory block or global data instance is invented.

## Independent comparisons

Fresh splat and spimdisasm references each reassemble to all 428 retail bytes.
Ghidra memory and the freshly linked source agree with that entire range.
`robotron-tools match --fresh`, asm-differ and objdiff use the current source
and independent references. The byte comparison also verifies natural symbol
bounds, relocations, matrix placement and absence of extra initialized data.
Private generated assembly, objects, ROM content and searches stay outside Git.
Tools and N64 reference projects are credited in [CREDITS.md](../CREDITS.md).

## Execution audit

Run `make audit-inverse-camera` after preparing the baserom and installing the
documented Linux/WSL tools. The checker requires the complete instruction
match and matrix definition before executing either body. Fresh fixed math,
SDK sine and SDK cosine source units execute with their validated sine table.
The table agrees with the mathematical generator and a separate mathematical
oracle. No callee stubs or patched instructions are used.

The checker exercises 16,640 retail/source pairs, or 33,280 executions. Every
masked phase is exercised separately on each axis with nonzero companion
angles. Cartesian boundary cases and deterministic full-width inputs cover
negative angles, period wrapping and signed negation boundaries. The independent
oracle constructs quantized Y/Z axes and rotates their rows around X, checking
all nine words rather than copying the candidate's scalar expressions.

Each run checks all six call arguments, instruction/read/write bounds,
unchanged complete FrameView, matrix and stack canaries, SP, GP and saved GPRs.
The stack extent includes the writer and two nested 24-byte cosine frames.
Eight separately compiled source faults cover the angle sign, initial shift,
both negative X terms, first-row sine, copied row shift, final store and a
matrix overrun. Each fault is rejected after an unmodified positive pair.

These are bounded CPU checks. They do not establish arbitrary aliases, full
gameplay, graphics microcode or hardware behavior. Current hashes, comparisons,
controls and clean-build results are recorded in
[the provenance ledger](renderer-inverse-camera-provenance.json). Issue #35
continues to track the remaining object-update and draw-dispatch work.
