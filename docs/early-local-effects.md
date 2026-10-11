# History prisms and ground discs

Two previously unpublished helpers now have complete C candidates. They remain
excluded from the ROM build and the source ownership count.

| Helper | Retail range | Natural IDO bytes | Differing words |
| --- | --- | ---: | ---: |
| `func_8000A910` | `8000A910..8000AC6C` | 860 / 860 | 4 |
| `func_8000AC6C` | `8000AC6C..8000B06C` | 1,000 / 1,024 | 252 |

The profiles use pinned IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.
Complete splat and spimdisasm references independently reassemble to every
retail instruction byte. Typed m2c output and the live Ghidra analysis supplied
initial control-flow and field evidence; the original MIPS instructions decide
ambiguous details. Reference assembly and extracted bytes stay private.

## History prism

The object history renderer calls `func_8000A910(angle, size)` after setting up
the transform. The helper masks the angle to twelve bits, then divides by 1024.
It allocates eight vertices, uses the current renderer RGB globals, computes
alpha as `(size * 64) / 16`, and computes height as `(size * 370) / 16`.
Quadrants zero and two use the same orientation; one and three use the other.

Its six packets load eight vertices and emit five quads. The prism has an open
bottom. It advances the current vertex index by eight and commits the difference
from the allocation base. Allocation failure writes the failure index and emits
no vertices or packets.

Signed division and multiplication behavior matters. The checker independently
models 32-bit multiplication wrap, signed truncation toward zero, coordinate
halfword truncation, and color byte truncation. Algebraically reducing the alpha
expression to `size * 4` loses the retail behavior at large signed inputs.

The complete candidate has the retail length and stack frame. Four words still
use a different temporary register for alpha scaling. The XYZ position macro
preserves one source line per vertex after preprocessing and reproduces retail
coordinate-store scheduling. No padding, extra formal parameters, unused storage, or
instruction patches are added to conceal those differences.

## IDO statement grouping

IDO scheduling depends on source line boundaries as well as expression order.
Putting each XYZ initialization in a macro produces the retail store order with
the conventional X, Y, Z assignment order. All sixteen vertex initializations
use the same macro. This does not establish that the original source used that
macro; it gives a readable representation that matches the observed scheduling.

The complete 860-byte candidate retains the retail 24-byte frame. Its remaining
differences are at `8000A98C`, `8000A9CC`, `8000A9D0`, and `8000A9D4`: alpha
scaling uses `T0` where retail uses `V1`. Both expressions retain signed
32-bit multiplication and division before the color-byte store.

The local decomp-permuter run preserved each expanded packet macro on one
physical source line. Reformatting those macros into separate statements changes
IDO output and gives a misleading starting score. The corrected baseline has
four register differences with stack checking enabled. The two-worker search
performed 9,171 trials, including 463 compiler errors, without an improvement.
Twenty-one coordinate-macro and scalar-reuse forms, sixteen height-scope forms,
and forty-eight first-color ordering forms also produced no exact match.
Narrowing alpha storage or converting before division worsened instruction
matching; converting the product can also change signed-boundary behavior.

Diagnostic builds of the pinned optimizer reproduced every allocated output
section of the corresponding ordinary builds. They distinguished a globally
allocated alpha expression from a chained-store form that fixes the alpha
temporary but changes the size register. Those findings constrain further
research; they do not identify the original declarations. The candidate remains
excluded, and no source ownership is added.

## Ground disc

`func_8000AC6C(x, y, z, black)` keeps the four-word call interface used by the
object updater. Retail homes the incoming `y` word but ignores its value. The
relative position is `((x-cameraX)>>1, (-cameraY)>>1, (z-cameraZ)>>1)`.
It requests graphics modes two and one, transforms that position, and submits
the matrix before allocating vertices. Those mode and matrix effects also occur
when allocation fails.

On success it reads palette entry one. The center is at the origin. A nonzero
`black` flag selects black RGB and center alpha 160; otherwise it uses palette
RGB and center alpha zero. Ten perimeter vertices use cosine and sine at
`(index-1)*4096/10`, radius 200, and alpha 160. A vertex load and ten triangle
packets follow. It commits eleven vertices while leaving the current index at
the allocation base. Vertex flags and texture coordinates are untouched.

The original frame is 248 bytes. Its projected-vector and temporary slots are
verified, but the original C storage declarations and unused frame areas remain
unknown. The candidate uses a real three-word position array and the existing
draw prefix. It does not enlarge structures or add unused locals to reproduce
the retail frame.

The perimeter loop has ten iterations: its branch compares the old index before
the delay slot increments it. The initial typed m2c output misleadingly showed
an increment before the comparison. Ghidra also reports an overlapping delay
slot at `8000AF1C`: retail has an unreachable constant-zero branch targeting
that instruction, which is the delay slot of the next branch. The candidate
preserves reachable control flow without rewriting retail instructions.

## Reproduce the execution guard

Provide the documented USA baserom and the installed Unicorn, Capstone and
pyelftools dependencies, then run:

```sh
make check-early-local-effects
```

The receipt is `build/early-local-effect-execution/report.json`. It records
complete target comparisons and fresh byte matches for ten support units:
graphics mode dispatch, graphics modes, the vertex pool, the warning no-op,
palette access, integer sine/cosine wrappers, SDK sine/cosine, frame transform,
and matrix submission. Owned initialized helper sections are also matched;
the sine table is independently regenerated. No ABI stubs replace callees.

The guard executes 720 prism fixtures and 540 disc fixtures against both retail
and compiled candidates. It checks allocation boundary success and failure,
both prism orientations, signed-size limits, color byte truncation, camera
translation, three matrices, both color paths, and three incoming graphics
modes. Independent oracles check all vertex fields that retail writes,
untouched vertex storage, geometry packets, matrix packing, and pool counters.
Paired runs compare complete command output, call traces, and SDK matrix
storage. Read/write/code bounds, command tails, stack canaries, saved integer
and floating-point registers, SP, GP, and readonly fixtures are checked too.

Eight source mutations and four guest instruction mutations must be rejected.
They exercise prism height, quadrant selection, quad winding, commit count,
ground-camera height, disc radius, perimeter count, center alpha, and packet
encoding. These finite CPU fixtures do not execute the RSP/RDP or establish
full gameplay, original local storage, instruction matching, or new ownership.
The void routines have no asserted incidental `V0` or `V1` return contract.

Analysis used the existing Robotron Ghidra MCP project, [splat](https://github.com/ethteck/splat),
[spimdisasm](https://github.com/Decompollaborate/spimdisasm),
[m2c](https://github.com/matt-kempster/m2c), and the installed matching tools.
Packet conventions were checked against the local [libreultra](https://github.com/n64decomp/libreultra)
GBI header; the retail commands remain authoritative.
