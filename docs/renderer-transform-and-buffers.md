# Renderer transforms and graphics buffers

`func_80047570` covers `0x80047570..0x80047A08`. The complete 1,176-byte
Euler rotation and scale submission routine matches the USA target with
the pinned IDO 5.3 game profile. Its two diagnostic strings own 64 bytes
at `0x80095360..0x800953A0`.

The routine clamps all three projected coordinates to -32000..32000,
checking the upper bounds first. It calls the cosine and sine helpers
for X, Y and Z, then constructs the same three-by-three rotation used
by `func_8003D2C0`. Each row is multiplied by its corresponding draw
scale and shifted right by four. Products retain their original
32-bit arithmetic and fifteen-bit intermediate shifts.

The source keeps that fifteen-bit precision in `fractionBits` and uses
it consistently for rotation products and matrix packing. IDO folds
the value into immediate shifts. Its declaration and use affect the
optimizer's register choices; replacing it with literals changes the
generated instructions. This is a complete byte comparison, not proof
of unique original names or source spelling. There are no unused
padding locals, larger fabricated matrix types, or instruction patches.

The generated matrix is packed into transposed integer and fractional
planes of a 64-byte `SdkMatrix`. Translation occupies the final integer
row, followed by one; the fractional translation row is zero. Submission
emits command `0x01020040`, increments the matrix cursor, reports values
of 250 or greater, and returns the submitted index. The overflow report
occurs after the write. It preserves `EXCCEDED`, `matrix.c`, and line 160.

## Source-owned storage

| Source | Target interval | Bytes | Evidence |
| --- | --- | ---: | --- |
| `renderer_matrix_arena_data.c` | `0x80126B90..0x8012E890` | 32,000 BSS | 250 indices, two buffer choices, 128-byte index and 64-byte buffer strides |
| `graphics_rsp_stack_data.c` | `0x8012E890..0x8012EC90` | 1,024 BSS | Graphics task stack pointer and explicit `0x400` byte size |
| `graphics_rsp_yield_data.c` | `0x80136CD0..0x801378D0` | 3,072 BSS | Graphics task yield pointer and explicit `0xC00` byte size |
| `renderer_matrix_cursor_data.c` | `0x8007D6A8..0x8007D6AC` | 4 initialized | Zero initial cursor; reset, submission and metrics references |
| `graphics_buffer_select_data.c` | `0x8007D910..0x8007D918` | 8 initialized | Zero initial matrix and framebuffer selectors; frame/task toggles |

The arena ends exactly at the RSP stack. The stack ends at the graphics
output buffer. The yield buffer ends at the audio thread's scheduler
object. The recovered arena and task buffers are aligned to eight bytes.
Independent comparisons check complete section sizes, symbol offsets,
alignment and target addresses; the linked build checks their placement
alongside every existing owned section.

`func_80048510` toggles the matrix buffer selector with XOR one and
`func_8005018C` toggles the framebuffer selector the same way. The
selectors' zero initial values establish the two buffer choices.
All three matrix submitters use the same arena strides and capacity.
The output buffer and its size pointer remain separately unresolved;
their surrounding address gap is not claimed here.

## Earlier supplied-matrix candidate

`src/game/renderer_matrix_scale.c` represents the complete adjacent
routine at `0x80047A08..0x80047D88`, 896 retail instruction bytes.
It applies each draw scale to one row of the supplied `FixedMatrix`,
shifts by four, and performs the same clamping, packing, command and
cursor update. Its diagnostic uses line 247 and the target's separate
string addresses.

At this earlier checkpoint, the candidate remained outside the function
manifest and build. The retail frame was 104 bytes and the candidate's frame
was 80; register allocation and scheduling also differed. That comparison is
recorded in the [provenance ledger](renderer-transform-and-buffers-provenance.json).
The later [supplied-matrix checkpoint](renderer-supplied-matrix.md) recovers
all 896 instruction bytes, the 104-byte frame and both diagnostic strings.

The ledger also records the matching transform, five complete data-only
units, and regressions for the existing matrix submitter, graphics task
builder, frame reset, and frame setup candidate. Full runtime, startup,
assembly and data comparisons, tooling tests, and a clean publication
build are required before integration.

Local libreultra `include/2.0I/PR/ucode.h` and `sptask.h` confirm the
standard 1,024-byte RSP stack and the 3,072-byte yield buffer with
64-bit alignment. The declarations and routines were reconstructed
from Robotron's target; no reference implementation was copied. All
thirteen requested projects remain credited in [CREDITS.md](../CREDITS.md).
Further renderer recovery is tracked by
[issue #41](https://github.com/frankischilling/robotron64/issues/41), and the
supplied-matrix instruction recovery by
[issue #59](https://github.com/frankischilling/robotron64/issues/59).

The checkpoint contains 1,341 matching C procedures and 235,436 matching
instruction bytes, with 10,335 source-owned initialized bytes and 449,799
BSS bytes. Independent comparison covers 824 runtime units, two startup
units, eighteen assembly units and twenty-eight data-only units. All 151
tooling tests pass. The rebuilt 8 MiB ROM equals the supplied target,
SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
Executable fallback remains unfinished and is excluded from those counts.
