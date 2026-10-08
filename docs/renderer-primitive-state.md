# Renderer primitive state

Two C translation units own the renderer's packet globals and expansion
controls. They add four initialized bytes and 32 BSS bytes. No instruction
bytes or additional matching functions are credited.

| Definition | Type and purpose | Runtime address | Bytes |
| --- | --- | --- | ---: |
| `D_80123AE0` | Byte containing four two-bit texture-corner selectors | `80123AE0` | 1 |
| `D_80123AE4` | Signed current vertex index | `80123AE4` | 4 |
| `D_80123AE8` | Integer alpha, truncated by vertex-byte stores | `80123AE8` | 4 |
| `D_80123AEC` | Graphics-resource pointer | `80123AEC` | 4 |
| `D_80123AF0`, `D_80123AF4`, `D_80123AF8` | Integer color components | `80123AF0..80123AFC` | 12 |
| `D_8007CDC0` | Mutable integer expansion parameter, initially `0x12` | `8007CDC0` | 4 |
| `D_800BF90C` | Integer expansion gate | `800BF90C` | 4 |

The packet state occupies `80123AE0..80123AFC`, including the compiler's
three bytes of alignment between the byte selector and first integer.
The following four-byte gap remains unowned. The expansion gate owns only
`800BF90C..800BF910`; neighboring object state is separate.

The existing headers supply these types. Matching polygon preparation uses
byte stores for the selector. Matching triangle and textured submission use
byte loads, consume two selector bits per corner, and update
the vertex index as a four-byte global. Polygon preparation stores the
four-byte alpha word, which vertex emission truncates to a byte. Graphics
resource setup allocates, loads and frees the cached pointer; framebuffer
copy reads it, and vertex color emission reads the three component words.
The object runtime candidate writes the expansion gate and parameter, while the
matching expanded triangle and geometry bridge read them. These accesses
establish storage widths without granting ownership to excluded consumers.
Ghidra decompilation was checked against the original MIPS instructions;
its overlapping global labels are not used to infer a larger structure.

Pinned IDO 5.3 emits the seven packet symbols at offsets `0, 4, 8, 12, 16,
20, 24`, with object sizes `1, 4, 4, 4, 4, 4, 4`. Its 32-byte raw BSS
section has four trailing alignment bytes; the owned extent is 28 bytes.
The expansion translation unit emits one four-byte data symbol and one
four-byte BSS symbol. Each raw section is aligned to sixteen bytes; only
its complete four-byte symbol extent is retained.

ROM `7D9C0..7D9C4` contains `00 00 00 12`. The linked data contribution
must reproduce those four bytes exactly. Linker assertions enforce the
section addresses, extents and every symbol offset. The absolute expansion-gate bindings in both symbol maps and the main
linker script, and all packet-state bindings, are removed so the
final ELF obtains these definitions from their C objects.

The reproducible data comparisons, matching consumers, clean ROM build,
progress measurement and tooling tests are recorded in
[the provenance ledger](renderer-primitive-state-provenance.json).
The target remains USA NRXE revision zero. Matching ROM equality still
uses fallback code and does not establish full source recovery. Tool and
reference credits are retained in [CREDITS](../CREDITS.md).
