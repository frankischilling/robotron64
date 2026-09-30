# Palette conversion

The four functions in `src/game/palette.c` cover
`0x8003BFEC..0x8003C180`, totaling 404 bytes. Each function has the retail
size and instruction bytes when built with the pinned IDO 5.3 configuration.

`func_8003BFEC` converts three integer color components into a 16-bit packed
color. It shifts each component right by three, masks to five bits, and
places red in bits 11–15, green in bits 6–10 and blue in bits 1–5. Bit zero
is always set. Its 52-byte body preserves the target's separate shift and
mask operations, including behavior for values outside the byte range.

`func_8003C020` copies a run of colors into `D_8007BB34` and generates the
corresponding packed colors in `D_8007D6D0`. Its source advances through
four-byte input records while indexing both output tables with `start + i`.
The 188-byte compiled loop preserves the target's count check and pointer
increments. A nonpositive count writes nothing.

`func_8003C0DC` updates one entry in both tables; `func_8003C14C` reads the
three color bytes of one entry. They are 112 and 52 bytes respectively.
The fourth byte in each `PaletteColor` record is untouched by all three
table-access functions. The shared record has a compile-time size check.
