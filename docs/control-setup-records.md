# Control setup records

The control setup page owns 588 initialized bytes: four eight-byte choice
records, eight 40-byte labels, one 52-byte static page and 184 bytes of text.
The labels form a reverse chain from element seven to element zero. The two
numeric labels select the four choice records through the existing player
`saved.field34` integers. The page title and all thirteen strings retain their
retail bytes, terminators, spacing, backslash markers and compiler alignment.

The complete ranges are `80077088..8007721B` and `80093398..8009344F`.
No instruction or BSS ownership is added. The former fallback spans are split
at those boundaries, and linker assertions protect each source section's size.
The page's timeout callback is null. Its 52-byte extent does not extend the
separately constructed 48-byte options page.

Fresh IDO comparisons and independent spimdisasm and splat reassemblies check
all six ranges. Linked objdiff comparisons cover every byte. All pointer
relocations, record and array sizes, alignment, player stride and the offset of
`saved.field34` are checked against retail placement. Ghidra uses the canonical
eight-byte choice, 40-byte label and 52-byte page types. Two former standalone
pointer units are label fields at offsets 88 and 128; their symbols are retained
as aliases inside the verified label array.

`make check-control-setup-records` compares 1,008 cases and 2,016 executions
using the complete retail records and freshly compiled data. Existing matching
display and string helpers execute on all eight labels and every choice entry.
The independent trace checks creation order, suffixes, spacing, all fifteen
draw arguments, blinking conditions, protected memory and O32 preservation.
Three mutations to a choice pointer, a chain link and the title are detected.
Text conversion, decoding, handle creation, flags, randomness and drawing use
ABI boundary stubs; menu activation, callbacks and gameplay rendering are
outside this proof. The 2,320-byte menu-control source candidate remains excluded.

Validation inputs and results are recorded in
`docs/control-setup-records-provenance.json`. Whole-ROM equality still contains
extracted fallback code and assets, so this is a partial source recovery.

The original user-supplied US ROM is the behavioral and byte-layout reference.
Analysis uses Ghidra 12.1.4 and Ghidra MCP, pinned IDO 5.3, spimdisasm 1.42.4,
splat 0.50.0, MIPS binutils, objdiff, Unicorn, Capstone and pyelftools through
the installed `robotron-tools` workflow. Tool and repository references are
listed in `docs/toolchain.md` and `docs/reference-study.md`.

Initialization writes byte 15 in D_800933D0 and D_800933E8, changing the
control-stick digits. These two arrays use writable C storage. Their 44-byte
interval is placed separately between the 56-byte read-only prefix and the
84-byte suffix; all 184 original text bytes stay in their retail locations.
The six linker aliases used by the initializer refer to complete records and
pointer fields inside the one source-owned label array. Their offset and
size assertions grant no additional ownership. The current initializer and
fresh display evidence is in [game initialization](game-initialization.md).
