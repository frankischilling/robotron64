# Renderer material presets and depth-blend origin

Two initialized signed words at `0x8007C5B4..0x8007C5BC` hold 0 and -2000.
The bounded retail `func_8003FDC4` reads them as XY blend targets while retaining
the input Z coordinate. Its weight is `256 - (-z * value) / 300`, with signed
division and arithmetic shifts. These globals remain writable. Ghidra folded
their initial values into literals in its first decompilation; the disassembly
has three reads of each symbol in the odd-element prefix and two-element loop.
The 584-byte routine itself remains in fallback because its C candidate differs.

Eight adjacent display lists occupy `0x8007C5C0..0x8007C770`, or ROM
`0x7D1C0..0x7D370`: 54 eight-byte packets, 432 bytes. Their lengths are
6, 7, 7, 7, 7, 6, 7 and 7 packets. Each starts with pipe sync and ends with
the complete end-display-list packet. Their intermediate packets set cycle,
texture LOD, geometry, render and combine modes. Literal packet words retain
the retail settings without guessing a material name. The four intervening
bytes at `0x8007C5BC` remain extracted; they are outside both source ranges.

`compare_data.py` checks all symbol offsets, complete initialized sections,
alignment and absence of executable content. Independently assembled spimdisasm
and splat data references reproduce every owned ROM byte. The proof records
the pinned compiler, source hashes, raw and trimmed sizes and fresh clean-ROM
validation in `renderer-material-presets-provenance.json`.

Ghidra reports no incoming references to the eight list starts. This ownership
does not establish runtime callers or RSP execution behavior. It adds 440 bytes
of initialized source data and no recovered CPU instructions. Whole-ROM equality
still contains fallback and is not whole-game source completion.

Packet names and bit fields were checked against the local libreultra 2.0I
`PR/gbi.h`. Tool and reference attribution is in [Credits](../CREDITS.md) and
[Reference study](reference-study.md).
