# Supplied-matrix scale submission

`func_80047A08` is complete matching C at `80047A08..80047D88`,
896 bytes and 224 instructions. The pinned IDO 5.3 game profile reproduces
its 104-byte frame and every instruction. The two retail diagnostic strings
at `800953A0..800953E0` now own 64 initialized bytes.

The routine clamps projected coordinates to -32000 through 32000, checking
all upper bounds before all lower bounds. It multiplies each row of the
supplied 36-byte `FixedMatrix` by the corresponding draw scale, then shifts
each signed 32-bit product right by four. It transposes these values into
the integer and fractional planes of one 64-byte `SdkMatrix`. Translation
occupies the last integer row; fractional translation is zero.

All seven semantic constants have consistently used local names: integer
precision, fractional shift, scale shift, projection limit, matrix capacity,
command word and physical address bias. Their declaration order preserves
the pinned compiler's frame and register scheduling. Each local contributes
to actual operations; the source retains the established matrix layout.

Submission writes `0x01020040` and the matrix's physical address, advances
the display-list cursor and increments the matrix index. The capacity check
occurs after the matrix write. The routine reports indices of 250 or greater
using the original `EXCCEDED` spelling, `matrix.c` and line 247, then returns
the current index minus one. The report can affect the reloaded index.

The original ROM and complete live Ghidra listing establish behavior and
boundaries. The local SM64 pinned-compiler workflow and libreultra SDK matrix
representation inform the existing comparison and layout conventions, as
credited in [CREDITS.md](../CREDITS.md). No reference implementation was copied.

`python3 tools/check_renderer_supplied_matrix.py`, with the optional analysis
dependencies installed, freshly compares the procedure and diagnostics. All
768 compiled-versus-retail cases pass an independent arithmetic and memory
oracle. They cover both buffers, mixed and extreme matrix/scale values,
clamp boundaries and the final valid matrix index. The checks verify the
entire guarded matrix arena, draw state, input matrix, command buffer,
cursor, buffer selector, return, stack and saved registers.

The overflow formatter uses a recorded integer ABI stub. Its 384 calls
verify the post-write sequence; 192 mutate the cursor to check the return's
reload. The formatter body, out-of-arena indices, invalid selectors, aliased
inputs, RSP rendering and full-game execution are outside this proof.

The complete 8,388,608-byte ROM remains identical to SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
All 851 runtime, two startup, 18 assembly and 92 data-only comparisons pass,
as do all 152 tooling tests without skips. This checkpoint owns 1,368 C
functions / 260,944 instruction bytes, 29,327 initialized bytes and 503,375
BSS bytes. Fallback remains 189,252 bytes in 216 ranges.

[The provenance ledger](renderer-supplied-matrix-provenance.json) records
current inputs, compiler identity, complete comparisons, ELF symbol-section
proof, Ghidra layouts and execution limits. Whole-ROM equality still includes
extracted fallback and does not establish complete decompilation.
