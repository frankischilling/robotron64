# Object angle constants

The three existing object angle setters use separate floats initialized to
`3.141592f`. The three getters use separate doubles initialized to `3.13159`.
The getters therefore do not invert the setters exactly. These retail values,
the middle component's 1,024-unit offset, and the different setter/getter masks
are preserved.

| Source section | Runtime range | ROM range | Bytes |
| --- | --- | --- | ---: |
| Setter floats | `0x80094C20..0x80094C2C` | `0x95820..0x9582C` | 12 |
| Getter doubles | `0x80094C30..0x80094C48` | `0x95830..0x95848` | 24 |

Each scalar's width follows its complete consumer loads and the declarations
in `object.h`. Each of the six scalar objects has its own definition. The four retail bytes
at `0x80094C2C..0x80094C30` remain extracted. Pinned IDO emits four trailing
zero alignment bytes for the float unit and eight for the double unit. Those
compiler bytes are checked and trimmed; they add no ownership.

Both decimal C initializers and independently assembled `.float`/`.double`
initializers reproduce all 36 retail bytes. The float bits are `0x40490FD8`;
the double bits are `0x40090D7F0ED3D85A`. The data definitions remain mutable,
consistent with the existing extern declarations. The setters and getters
retain their separate values.

The complete 1,976-byte transform source unit remains matching. The guarded
execution check runs all three real setters and getters with compiled constant
sections, checks the complete object pool and transform storage, and exercises
each constant after changing its live value. Its independent oracle rounds the
setter arithmetic to float and the getter division to double, then preserves
retail truncation, offsets, and masks. Invalid object/transform addresses and
isolated compiled-data mutations are checked separately.

The [provenance ledger](object-angle-constants-provenance.json) records current
compiler inputs, complete section comparisons, execution evidence and clean
build validation. This adds 36 initialized bytes, with no new instructions or
BSS. The boundary-motion procedure at `0x80017F9C` remains a private nonmatching
candidate and is excluded from source progress. Full game recovery remains
unfinished; whole-ROM equality still includes extracted fallback ranges.
