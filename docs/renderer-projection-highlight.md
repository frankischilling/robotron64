# Renderer projection and highlights

`func_8004913C` covers `0x8004913C..0x800493F4`. Its complete 696-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32 -Wab,-r4300_mul`. The source is
`src/game/renderer_projection_highlight.c`. The complete 48-byte constant
span at `0x80095468..0x80095498` also matches, including alignment.
The recovery adds no BSS.

The routine passes 480 and the existing view prefix's first word to the
matching angle wrapper. That wrapper converts both inputs to integers and
calls the recovered integer angle service. The returned float is multiplied
by the double constants 360 and `0.000244140625`, preserving both double
operations before conversion to the local float field of view. The precise
meaning of the view prefix's first word remains unassigned here.

It clears `D_FLT_8007D904`, then computes the two light components using
the matching cosine and sine wrappers, the signed counter at
`D_80138268`, float `0.0061359182`, and double 75. It reads the counter
again for the second component and advances it by eight afterward. The
source preserves the stores and the separate float and double operations.

The matching perspective builder writes the matrix at the active graphics
state's base. Its inputs are the calculated field of view, float aspect
`1.3333333730697632`, near plane 100, far plane 50000, and scale one. It
also writes the local unsigned halfword normalization value.

The matching look-at and highlight builder writes a second matrix at
state offset `0x80`, the 32-byte look-at object at `0x1C0`, and the
16-byte highlight object at `0x200`. Its eye is `(0, 0, 0)`, target is
`(0, 0, 400)`, and up vector is `(0, 1, 0)`. The first light uses the
two animated components and Z value -70; the second uses `(100, 0, 0)`.
The highlight dimensions are 32 by 32. Byte-address views describe these
observed offsets without claiming the intervening state layout or storage.

The routine converts the existing 36-byte fixed matrix at `D_800CD250`
into the SDK matrix at `D_8013D958`. It then emits five commands: two
look-at entries, perspective normalization, the perspective matrix, and
the converted fixed matrix. Their words are `0x03840010`, `0x03820010`,
`0xBC00000E`, `0x01030040`, and `0x01010040`. The matrix operands retain
the observed conversion from byte addresses in KSEG0 to physical addresses.
Each command advances the existing display-list cursor by eight bytes.

The twelve float locals all supply observed matrix or light arguments.
Their scalar declarations, the field-of-view slot at stack offset `0x70`,
and the normalization halfword at `0x9E` reproduce the full 160-byte frame.
No unused local or extra formal argument supplies its size. The R4300
multiply workaround reproduces the floating-point scheduling and delay
slots; the ordinary game profile does not match this procedure.

The [provenance ledger](renderer-projection-highlight-provenance.json)
records complete instruction and constant bounds, compiler inputs, and
linked bytes. The SDK interface and layouts are checked against the credited
local libreultra source and matching SDK callees. All thirteen requested
N64 references, pinned revisions, and licenses remain credited for local
and online use in [CREDITS.md](../CREDITS.md). Further renderer recovery is
tracked by [issue #41](https://github.com/frankischilling/robotron64/issues/41)
and [draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
