# Renderer color wave storage

Source defines the complete 260-byte BSS span at `0x800CD2B4..0x800CD3B8`:
the four-byte time accumulator followed by sixteen 16-byte color wave records.
The neighboring framebuffer depth word at `0x800CD3B8` is a separate symbol.
No initialized ROM bytes or runtime BSS contents are claimed for this storage.

`func_800400D0` adds the frame step to the accumulator before selecting a
background renderer. The grid renderers at `0x800414C4` and `0x80041B24`
read that accumulator, visit all sixteen records, and advance their record
pointers by sixteen bytes. The three-channel renderer accesses the color,
amplitude, frequency and phase bytes at offsets `0..2`, `4..6`, `8..10` and
`12..14`. The fourth byte of each group retains an unresolved field name.
Both renderers build a four-by-four vertex grid and commit sixteen vertices.

The independent NOBITS assembly reference declares one 260-byte state object,
with a four-byte counter and a 256-byte array beginning at offset four. C uses
that same aggregate: IDO aligns a separate array to eight bytes and would
insert unwanted padding after the counter. Compile-time checks verify the
record size, state size and array offset. The complete compiled and linked
section must have the recorded extent, with no code or initialized data.
Object comparison checks the whole BSS layout. These are
layout checks; they do not substitute for execution checks of recovered code.

The renderer procedures remain excluded from source ownership while their
complete instruction comparisons differ. Their independently reassembled
reference ranges are `0x800414C4..0x80041B24` (1,632 bytes) and
`0x80041B24..0x800420B0` (1,416 instruction bytes plus four alignment bytes).
The nearby material reset at `0x800420B0..0x80042830` also remains excluded
(1,912 instruction bytes plus eight alignment bytes). Partial matches and
permuter scores do not count toward the recovered function totals.

The [provenance ledger](renderer-color-wave-provenance.json) records the
compiler identity, current source and header hashes, independent object
comparison and complete field extents. No original ROM or extracted assets
are included in this change.
