# History prisms and ground discs

The complete history prism is byte-matching C included in the ROM build and
source ownership count. The ground disc remains an excluded C candidate.

| Helper | Retail range | Natural IDO bytes | Differing words |
| --- | --- | ---: | ---: |
| `func_8000A910` | `8000A910..8000AC6C` | 860 / 860 | 0 |
| `func_8000AC6C` | `8000AC6C..8000B06C` | 1,024 / 1,024 | 194 |

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
halfword truncation, and color byte truncation. Replacing the alpha expression
with `size * 4` changes intermediate values at large signed inputs and changes
the instruction stream. The final stored alpha byte is equal: the wrapped
product is divisible by sixteen, and overflow changes its quotient by a
multiple of `2^28`, which disappears when narrowed to eight bits.

The natural 860-byte prism body and 24-byte stack frame match every retail
instruction. Independent splat and spimdisasm reassemblies cover the same complete
range; all external references resolve to the verified globals and renderer
helpers. The object has no initialized data or switch table to recover. IDO's
four trailing alignment bytes are zero and are checked before trimming.

## Alpha storage and IDO scheduling

The first four vertices share one chained alpha assignment. The remaining four
copy the first vertex's alpha byte. This keeps signed multiplication and division
before byte truncation, with the same color for both faces. It also reproduces
the retail temporary allocation without a word alpha local. The full signed
`size` remains available for the height calculation. No unused local, extra
formal parameter, enlarged record, or instruction patch is needed.

The XYZ position macro preserves one source line per vertex after preprocessing
and reproduces retail coordinate-store scheduling with conventional X, Y, Z
assignment order. All sixteen initializations use the same macro. This readable
representation matches the observed scheduling; it does not prove the spelling
of the original source or its macro definitions.

The ownership manifest declares exactly `8000A910..8000AC6C`. The linker replaces
only those 860 bytes with `history_prism.o` and leaves the neighboring fallback
ranges intact. Fresh runtime comparison and the early-effect guard require the
complete prism match. The guard continues to execute both functions with real
matched support and rejects all twelve mutation controls.

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

The original frame is 248 bytes; the candidate frame is 208 bytes. The complete
natural body is 1,024 bytes and differs in 194 words. The retail projected-vector
and temporary slots are verified, but the original C storage declarations and
unused frame areas remain unknown. The candidate uses a real three-word position array and the existing
draw prefix. It does not enlarge structures or add unused locals to reproduce
the retail frame.

Palette RGB values are loaded into word locals before the black override and
remain live across the trigonometric calls. Retail scales and shifts the cosine
result before calling sine. The candidate follows those lifetimes and uses
`index + currentVertex` for the perimeter address. These source changes reproduce
more of the retail instructions while keeping the same vertex and packet effects.
The radius mutation changes the factor at the cosine call and must still fail
the independent geometry oracle.

The local investigation compared 148 complete forms covering color lifetimes,
trig scheduling, old-index loop termination, vertex cursors, triangle macros,
aggregate declarations, allocation/load counts, palette storage, and index
promotion. Reordering aggregate declarations did not affect code generation.
Using the existing full object record increased the frame to 272 bytes without
improving instruction matching, so that form was rejected. Three-byte and
four-byte palette buffers also gave no instruction improvement. The published
candidate retains the established draw prefix, a real three-word position array,
and one palette entry. It does not add unused storage to force the retail frame.

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
full gameplay or original local storage. Prism ownership additionally requires
the independent complete instruction and section comparisons; the disc remains
nonmatching.
The void routines have no asserted incidental `V0` or `V1` return contract.

Analysis used the existing Robotron Ghidra MCP project, [splat](https://github.com/ethteck/splat),
[spimdisasm](https://github.com/Decompollaborate/spimdisasm),
[m2c](https://github.com/matt-kempster/m2c), and the installed matching tools.
Packet conventions were checked against the local [libreultra](https://github.com/n64decomp/libreultra)
GBI header; the retail commands remain authoritative.
