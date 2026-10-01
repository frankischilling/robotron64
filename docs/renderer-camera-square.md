# Camera-relative square rendering

`func_80043070` constructs and submits a textured square in the horizontal
XZ plane. Its complete range is `0x80043070..0x800431C0`, with 336 instruction
bytes. The caller supplies its center's X and Z coordinates.

Each corner offsets X and Z by plus or minus 1,660, subtracts the camera's
corresponding position, and applies a signed arithmetic shift right by one.
The Y component is the negated camera Y position shifted right by one.
These shifts preserve the target's rounding for negative values. Corner
order is positive X/positive Z, positive X/negative Z, negative X/negative Z,
and negative X/positive Z.

The function transforms each corner independently through `D_800CD250`
using `func_8004D4B4`. It then writes four pairs of signed texture coordinates
at the current vertex-arena cursor: `(0, 0)`, `(3968, 0)`, `(3968, 3968)`,
and `(0, 3968)`. The last corner stores its second texture component first.
Finally it passes the four transformed positions to `func_80045214`, the
alpha-160 quad submission routine. That callee remains executable fallback
and contributes no new matching source to this recovery.

## Complete comparison

The source uses eight three-word position arrays and the existing vertex
union. Keeping the coordinate expressions directly in the corner assignments
reproduces the target's common-expression reuse and 144-byte frame. Separate
scalar coordinate temporaries produce a different frame and instruction
schedule. The source needs no padding fields, dummy expressions, instruction
patches, or inline assembly.

IDO 5.3 with the verified game profile `-O2 -G 0 -non_shared -mips1 -32`
reproduces every instruction word. Acceptance also checks linked function
type, complete size and placement, current source/header/compiler inputs,
and full ROM equality. This source unit owns no additional initialized data
or BSS. Complete procedure hashes and build inputs are recorded in
[the provenance ledger](renderer-camera-square-provenance.json).

A clean archive of `7411aaa` passes all 137 tooling tests, fresh extraction
and build, 784 complete runtime units, both startup units, eighteen assembly
units, and eight data-only units. Linked verification reports 1,300 complete
matching C functions and 217,172 instruction bytes. The rebuilt USA ROM
matches byte for byte, and the publication audit checks all 1,260 public files.

Robotron's instructions establish the geometry, signed shifts, transform
order, texture-coordinate stores, and final call. The local and online
[Super Mario 64 GBI definitions](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h)
and [libreultra GBI definitions](https://github.com/n64decomp/libreultra/blob/master/include/2.0I/PR/gbi.h)
support the existing sixteen-byte vertex layout. The references, inspected
revisions, and licensing notices are credited in [CREDITS.md](../CREDITS.md).
Further renderer recovery is tracked in issue #41.
