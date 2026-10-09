# Renderer setup packets and mutable state

The default setup list has 23 eight-byte commands at `8007D5E8..8007D6A0`.
The tile-origin setup list has 16 at `8007C970..8007C9F0`. Both end with the
first `G_ENDDL` command; neighboring lists and scalar words are separate.
The matching callers at `80046608` and `80046C2C` submit these exact addresses.

The four words immediately before the default list hold cached mode -1 and
the light direction `(70, 50, -70)`. Matching light writers load full signed
words and narrow them into the directional-light bytes. The tint command can
change all three direction words, and frame reset writes the cached mode.
These remain mutable C definitions.

The two texture-image commands retain relocations to `8007CDD8` and
`8007C770`. Those image bytes remain extracted assets. Packet source owns
328 initialized bytes, including the four scalar words, and no asset bytes.
The scoped `FrameCommand` union retains its eight-byte size and alignment.

Nine individually declared cache/counter words at `80123B00..80123B24` and
five arena/vertex words at `80126B74..80126B88` own 56 BSS bytes. Complete
matching reset, counter, palette, lighting and reservation consumers establish
their four-byte widths. The declarations preserve existing public types and
claim no neighboring gaps or light-array extent.

The [verification ledger](renderer-setup-storage-provenance.json) records
complete pinned IDO section comparisons,
independent Splat and spimdisasm references, pointer relocations, canonical
Ghidra types, guarded consumer execution, fresh comparisons, and a clean ROM
build. Consumer execution checks submitted list addresses, tile packing,
light colors and directions, and frame snapshots. It does not execute the RSP or RDP.
Whole-ROM equality still includes fallback and is not full source completion.

The retail ROM is the source of truth. Local SDK GBI definitions supply command
field names; [CREDITS](../CREDITS.md) and the [reference study](reference-study.md)
identify the tools and inspected N64 projects. No texture or reference SDK
implementation is copied into these source units.
