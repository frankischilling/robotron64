# Boundary actor creation

`func_8000A074` occupies `0x8000A074..0x8000A200`, or 396 instruction bytes.
Its complete C object matches the supplied USA ROM under the pinned IDO 5.3
game profile. No executable bytes inside this procedure come from fallback.

The function creates a kind-nine actor using resource `D_800B2480` and the
source actor's position. Allocation failure returns a null pointer. A successful
allocation clears the new actor's Z coordinate before testing the source's X
and Y coordinates against boundaries derived from the signed halfword at
offset `0x06` and 30,000. The halfword's original field name is unresolved.

X takes priority over Y. A boundary hit fixes the corresponding new coordinate
at `-30000` or `30000`, submits angle zero for an X hit or 1,024 for a Y hit,
and stores that angle in the actor. The remaining path uses the signed
32-bit product of Y and X. Its sign selects angle 512 for a positive product
and 1,536 otherwise, including a zero product. The source retains the sign
expression and the target's multiplication operand order.

Every successful path installs `func_800077F4` in callback slot `0x00`, stores
the address of `func_80009F58` at `0x5C`, writes 240 at `0x50`, and returns the
new actor. Callback names and timer units are kept conservative. The actor
layouts and creation helper come from other verified Robotron routines.

The target ROM determines these constants, offsets, arithmetic, and ordering.
The N64 and IDO reference projects used for compiler and matching work are
credited in [CREDITS.md](../CREDITS.md). Complete-source comparison, linked
procedure metadata, current input hashes, and full ROM verification are
required before this function contributes to progress.
