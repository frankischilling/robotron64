# Palette transition allocation

`func_80031B28` selects the first inactive record in the 100-entry transition
pool at `0x8009D120`. Each record occupies 52 bytes. It stores the low eight
bits of the destination palette index, the low seven bits of the mode,
the two source indices, phase, step, and zero initial position. It reads six
RGB channel bytes from the source-color table at `0x800BB230` and snapshots
all four bytes of the destination's base color from `0x8009CD18`. It then
sets the active bit. A full pool returns without changing any record.

The complete range is `0x80031B28..0x80031C10`, ROM
`0x32728..0x32810`, or 232 instruction bytes. IDO 5.3 with the pinned game
profile produces that entire range. The build trims only the compiler's
verified trailing alignment, asserts the linked section size, and replaces
the corresponding extraction span. The allocator adds no initialized data or
BSS ownership. The two shared palette arrays and transition pool were already
declared in `include/palette_effects.h`.

The byte-sized temporary and separate array/record-pointer accesses preserve
IDO's field-load ordering and bitfield narrowing. The original local names
are unknown. The C preserves truncation rather than adding index validation.
`PaletteTransition` has the same checked 52-byte layout in Ghidra and the
header. Its allocation caller is `func_80031C44`.

Run these checks in the configured Linux/WSL checkout after setup:

```sh
python3 tools/compare_runtime.py -j 4
/root/robotron64-tools/.venv/bin/python tools/check_palette_transitions.py
make verify progress test
```

The execution checker compares fresh compiled instructions and retail
instructions with an independent record oracle. It checks first-free-slot
selection, a full pool, signed and oversized palette indices, mode truncation,
signed phase/step boundaries, RGB loads, the four-byte color snapshot, padding,
unchanged later slots, input guards, stack writes, and integer ABI preservation.
Instruction mutations challenge the index mask, mode mask, step destination,
activation destination, and source-blue read. The input tables use deterministic
BSS images; complete gameplay and concurrent pool mutation are outside this
check.

The allocation checker passes 9,680 cases, including 1,936 full-pool cases.
All five instruction mutation probes are detected. The independently linked
allocation reference and fresh C output also compare at 100% for the complete
function and `.text` section in objdiff.

`command_storage.c` defines the 15,648-byte BSS span
`0x800BB230..0x800BEF50`: 550 source colors, 550 24-byte transition commands,
30 8-byte ranges, and the two command counters. The adjacent addresses establish
the extents; the recovered command functions establish the field types and
strides. Each symbol's offset and the complete NOBITS size are checked in an
independent IDO object and the linked build. This storage contributes no ROM
bytes or initialized table contents.

The color command checks `index >= 551`, despite the 550-entry extent, and the
range command checks `index >= 31`, despite the 30-entry extent. Both write paths
remain unchanged: the extra index can overlap the following storage. These
diagnostics do not establish larger arrays.

`transition_order.c` defines the seven integer source-color indices used by
mode eight at `0x80077C20..0x80077C3C`, ROM `0x78820..0x7883C`. The update's
word-stride reference starts the table; the adjacent palette resource at
`0x80077C3C` is referenced by the bitmap setup and nineteen resource records.
The complete 28-byte index table is functional control data. Its neighboring
palette and bitmap assets remain extracted. Independent IDO compilation and
separate MIPS assembly verify every table byte.

Private splat 0.50.0 and spimdisasm 1.42.4 output reassembles to the complete
retail allocation range. The independently assembled instruction hash is
`ab64e2083057f75d9d379f5d694bf69d4d1c95246da3af8a923e3fa0eabe3940`.
Ghidra MCP provides the procedure, caller, memory, disassembly, and record-layout
evidence. m2c, asm-differ, objdiff, and decomp-permuter support candidate analysis;
the [credits](../CREDITS.md) list these tools and reference projects.

The per-frame routine at `0x80031ECC..0x8003237C` remains extracted fallback.
Its candidate C is excluded while instruction ordering is unresolved. Retail
submits overlapping palette uploads for consecutive changed entries; future
recovery must preserve that behavior.

The [recorded proof](palette-transitions-provenance.json) contains the current
compiler identity, instruction hash, storage extents, mutation results, input
hashes, and complete-comparison results.
