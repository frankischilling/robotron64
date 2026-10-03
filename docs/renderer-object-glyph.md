# Object-attached font glyph

The complete routine at `8004A2B4..8004A6B4` matches 1,024 instruction bytes,
including its 176-byte stack frame. Four used scalar locals hold white, the
vertex count, and the two glyph sizes. Their declarations and the scope of
three used geometry locals reproduce the frame with the existing 36-byte
`FixedMatrix` and 60-byte `RendererDrawState`. No padding local or larger
structure is inferred from the match.

The character mapper selects a 1,024-byte font image. The glyph submits the
original eight texture packets, then four vertices if allocation succeeds.
The upper vertices are white; the lower vertices use the configured RGB
components. All four have alpha 255 and retain their original vertex flags.
The two draw counters and vertex cursor advance only on success.

Normal mode transforms camera-relative coordinates shifted right by one.
Alternate mode saves the camera matrix, replaces it with the fixed identity,
and uses `(-x >> 2, y >> 2, -z >> 2)`. Matrix submission runs before vertex
allocation on both paths. The camera matrix is restored only on success;
alternate-mode allocation failure leaves the identity matrix in place.

The C return contract remains unresolved. The retail epilogue leaves `v0`
from the last allocator call: `-1` after rejection, or the advanced vertex
cursor after success. The matching callback `func_8003A778` propagates that
register, and the excluded runtime dispatcher consumes its integer value.
These observations do not uniquely establish the original C return type.
Explicit, defined integer-return candidates add instructions and are not
accepted as matching source.

The shared internal header records the existing provisional views: a `void`
callee with a byte character formal and an integer callback declaration with
a promoted character argument. These are incompatible ISO C function types.
The pinned separate compilation and verified N64 instructions preserve the
retail behavior; the match does not resolve this source-interface limitation.
It remains tracked in [issue #61](https://github.com/frankischilling/robotron64/issues/61).

The optional checker is `python tools/check_renderer_object_glyph.py`.
It independently recompiles the complete glyph, the callback and nine matching
support units. Glyph mapping, matrix identity and transforms, short trigonometry,
vertex allocation, the warning no-op and RGB selection execute their real code.
Only the fatal formatter uses an integer ABI stub; continuing after that normally
nonreturning diagnostic is synthetic.

Independent oracles check glyph indices, fixed arithmetic, packed matrices,
vertices, command packets, counters, surviving `v0`, and guarded input/state
storage. Coverage includes all 256 input bytes, promoted-argument truncation,
both modes, fourteen special scene pointers, coordinate and product wrap,
matrix clamping, both matrix buffers, the final valid matrix slot, the last
four vertices, allocator rejection and matrix restoration on each path.
Full runtime-dispatch execution, invalid storage/selectors, RSP/RDP rendering
and full-game behavior are outside this proof.

All 2,688 cases pass: 2,112 direct glyph calls and 576 complete callback calls.
They include 1,680 alternate-mode cases, 1,248 synthetic continuations of the
matrix diagnostic and 992 vertex-allocation rejections. Current complete
comparisons, inputs, linked placement, Ghidra layouts/call sites and execution
evidence are recorded in the [provenance ledger](renderer-object-glyph-provenance.json).

Robotron's retail bytes and existing matching callees establish the behavior.
The local SM64 matching workflow and libreultra vertex/GBI definitions are
credited in [CREDITS](../CREDITS.md). No commercial font image is published.
Whole-ROM equality still includes fallback and does not establish a complete
source decompilation.
The existing font-image address is named in the runtime symbol bindings;
its storage remains target-derived fallback and adds no source-owned data.
