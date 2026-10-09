# Palette color tables and formatting constants

The tables at `8007BB34..8007BF34` and `8007BF34..8007C334` each contain
256 four-byte RGB records. Every fourth byte starts at zero. The first entry
is black, entry 254 is blue, and the remaining entries include white defaults
and groups of color ramps. Both tables have identical initial bytes, but they
occupy separate writable storage. Their complete 2,048 bytes are represented
in `src/game/palette_effects/color_tables.c` with a shared initializer list.

The first table uses the existing `PaletteColor` layout. The matching palette
setters write its three RGB bytes and update the corresponding RGB5551 entry
in `D_8007D6D0`; its getter leaves the destination's fourth byte untouched.
Polygon consumers select a color with a masked eight-bit index and load the
complete packed word. Those consumers now explicitly view the same canonical
record as a big-endian word. The second table supplies packed colors to the
directional-light routines and byte colors to the object drawing helper.
Its packed `int[256]` declaration is shared by these consumers.

The table boundaries agree with the 256-entry index domain, four-byte stride,
the distinct second-table references, and the controller mask at `8007C334`.
That mask remains outside this recovery. The initialized records are CPU
renderer state; this change does not recover texture or image files.

The numeric conversion alphabet at `8007BB1C` contains the sixteen characters
`0123456789ABCDEF` and a NUL. Its complete C string and three compiler alignment
bytes occupy 20 bytes. Matching integer and float conversion routines reference
this table. Four bytes between it and the palette remain outside ownership.

The fatal formatter's output template at `8009542C` is `\n\n%s\n\n`, including
its NUL and one compiler alignment byte: eight bytes. Its caller remains
excluded. The current formatter has a complete 512-byte retail reference,
including unreachable instructions after its infinite wait, while its public
candidate produces 496 bytes and differs in 31 words. Independent research
reproduces its stack layout but still misses 16 bytes in that tail. None of
those CPU bytes are credited by this data recovery.

`config/analysis/palette_color_tables.yaml` bounds all three data sections.
Generated assembly and extracted bytes stay in ignored local directories.
Separate spimdisasm and splat reassemblies reproduce every owned byte, and
objdiff reports 100% for each complete data section. IDO emits 32 raw read-only
bytes for the alphabet and 16 for the fatal template; checked zero alignment
tails are trimmed to their bounded 20- and eight-byte owned ranges. Its two
color symbols have offsets zero and 1,024 within the complete 2,048-byte section.

`make check-palette-color-tables` requires the optional Unicorn analysis
environment. It runs 1,071 cases using freshly matched palette and directional
light instructions with the source-defined initial tables and no supporting-call
stubs. Every index is checked for RGB5551 packing, getter/setter writes, separate
storage, lighting intensity, copied colors, direction truncation, reserved bytes,
memory/code bounds and integer ABI preservation. Three deliberate instruction
mutations are detected. Additional range cases cover nonpositive counts and
bounded uploads through 256 entries; invalid pointers and gameplay remain
outside this check.

`tools/check_error_formatters.py` now compiles, completely matches and supplies
the source-defined alphabet to the matching numeric helpers. Its 3,588 bounded
cases retain output and fatal-report ABI stubs; the fatal reporter returns
synthetically. This does not execute the excluded renderer fatal formatter or
establish its infinite-wait behavior.

Ghidra uses the canonical four-byte `PaletteColor` layout and separate bounded
arrays. Its two string types exclude compiler alignment bytes. The fatal
formatter's variadic prototype and behavioral notes agree with the C headers;
its reachable Ghidra body still omits the retail unreachable tail, so complete
assembly comparison uses the independently verified 512-byte range.

Fresh consumer comparisons, complete independent comparisons, clean full-ROM
validation and tooling-test results are recorded in
`palette-color-tables-provenance.json`. This recovery adds 2,076 initialized data
bytes and zero CPU instruction bytes. Whole-ROM equality includes extracted
fallback and does not establish completion of the game decompilation.

The ROM and matching consumers establish these values and layouts. The pinned
tools and local N64 reference projects are credited in [CREDITS](../CREDITS.md).
