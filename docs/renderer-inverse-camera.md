# Inverse camera matrix investigation

`func_8003F480`, `8003F480..8003F62C`, samples the three negated integer
camera angles and writes the nine signed words of `D_800CD250`. Its 428-byte
retail body calls the real fixed sine and cosine wrappers six times. Each
product uses its low 32 bits and an arithmetic shift by fifteen. The shared
Y/Z products are truncated before the subsequent X rotation.

The revised ordinary C names those products and the other consumed truncated
terms. It emits the retail 104-byte frame, without unused locals or a padding
matrix. All sixteen scalar declarations are consumed. The complete IDO 5.3
comparison still differs in 68 words and emits 448 live bytes. The earlier
private candidate differed in 70 words with a 64-byte frame; the previous
public source differed in 78 words. This writer remains excluded from source
ownership and the ROM uses extracted fallback for it.

The search checked 4,096 consumed-product and declaration forms, plus 71
aggregate, array and baseline comparisons. A two-worker permuter ran for
120 seconds with stack differences enabled. Of 73 saved sources, 26 passed
the local-use and alias review; none improved the complete comparison.
The frame agreement is a useful source-layout clue;
it does not establish the original declarations or a matching procedure.

## Independent evidence

Fresh splat and spimdisasm references each reassemble to all 428 retail bytes.
The existing Ghidra program's bytes agree with the same range. The caller is
`func_8003A8B0` at `8003A90C`. A pinned IDO layout probe agrees with Ghidra on
the 36-byte `FixedMatrix`, the 40-byte `FrameView`, their four-byte alignment,
and all FrameView field offsets and widths. The angle words occupy offsets
`10`, `14`, and `18` in hexadecimal.

The canonical FrameView definition is imported into the existing Ghidra type
manager. Its BSS address is outside that analysis program's mapped memory,
so no memory block or global data instance was invented. The public source
uses the existing canonical headers and symbol maps.

The matching workbench, asm-differ and objdiff retain the full-range mismatch.
Private generated assembly, objects, ROM content and searches stay outside Git.
The tools and N64 reference projects remain credited in [CREDITS.md](../CREDITS.md).

## Execution audit

Run `make audit-inverse-camera` after preparing the baserom and installing the
documented Linux/WSL tools. This audit succeeds on behavioral agreement while
recording the independent instruction mismatch. It never adds matching bytes.

The audit executes three freshly compiled, completely matched support units:
fixed math, SDK sine and SDK cosine. The sine table agrees both with the
high-precision mathematical generator and the separate oracle's mathematical
values. There are no callee stubs or patched instructions.

Both retail and candidate pass 16,640 cases, or 33,280 executions. Every masked
phase is exercised separately on each axis with nonzero companion angles;
Cartesian boundary inputs and deterministic full-width inputs cover negative
angles, period wrapping and signed negation boundaries. The independent oracle
constructs quantized Y/Z axes and rotates their rows around X, checking all nine
output words rather than copying the candidate's scalar expressions.

Each run checks the six call arguments, instruction/read/write bounds,
unchanged complete FrameView, matrix and stack canaries, SP, GP and saved GPRs.
The stack extent includes the writer and two nested 24-byte cosine frames.
Five private source mutations change an angle sign, shift count, first-row
sine, row combination sign or final store. All five are rejected, with thirty
unmodified retail/candidate positive executions.

This is bounded CPU evidence. It does not verify a full game, graphics
microcode, hardware behavior or instruction matching. Current hashes, type
proofs and comparison addresses are recorded in
[the provenance ledger](renderer-inverse-camera-provenance.json).
