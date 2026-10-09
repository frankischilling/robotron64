# Palette transition allocation and updates

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
/root/robotron64-tools/.venv/bin/python tools/check_palette_update.py
make verify progress test
```

The execution checker compares fresh compiled instructions and retail
instructions with an independent record oracle. It checks first-free-slot
selection, a full pool, signed and oversized palette indices, mode truncation,
signed phase/step boundaries, RGB loads, the four-byte color snapshot, padding,
unchanged later slots, input guards, stack writes, and integer ABI preservation.
The source-color fixture contains all 550 entries. Cases sample the final two
entries in both source positions.
Instruction mutations challenge the index mask, mode mask, step destination,
activation destination, and source-blue read. The input tables use deterministic
BSS images; complete gameplay and concurrent pool mutation are outside this
check.

The allocation checker passes 14,520 cases, including 2,904 full-pool cases.
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

`transition_update.c` recovers the complete per-frame routine at
`0x80031ECC..0x8003237C`, ROM `0x32ACC..0x32F7C`. All 1,200 instruction bytes
match pinned IDO 5.3 output. The raw object's function and `.text` sizes are
both 1,200 bytes, with no trailing alignment or generated data. The linker
asserts that complete size and the corresponding fallback span is removed.

The updater visits all 100 records and marks the destination of each active
transition. Modes 16 and 32 select source colors by signed division and
remainder; mode 32 adds the phase. Mode eight obtains the source index through
the verified seven-entry control table. Other modes interpolate each RGB
component using the signed position and `65536 - position`, preserving the
original word arithmetic and truncating division. The four-byte color is
copied into the local 256-entry buffer before color and lighting submission.

Position updates preserve the multiply-by-32/divide-by-32 expression. Its
32-bit intermediate can wrap, so replacing it with addition of the step would
change behavior. A negative result clears the active bit when mode bit four
is set; otherwise mode bit two selects reflection instead of wrapping. A
positive result above 65,535 also reflects or wraps according to bit two.
Bit four does not stop a positive overrun. The reflection code writes through
the record pointer and reads the normalized position through the indexed
pool. This preserves the target's instruction order without extra operations.

The color-submission call assigns the reloaded palette index in its first
argument and reads that local in the remaining arguments. These accesses are
unsequenced in ISO C. The pinned IDO output reloads the index before obtaining
the three color bytes, matching retail exactly. Moving the assignment to a
preceding statement changes three instructions. This compiler dependency and
the original signed overflow behavior are preserved; this source is intended
for the pinned matching toolchain. The original local names are unknown.

Uploads retain the overlapping suffix behavior. For changed destinations
10, 11 and 12, the updater submits `(10, 3)`, `(11, 2)` and `(12, 1)`, rather
than advancing the outer scan past the first upload. Duplicate transition
destinations use the latest color in the local buffer for these bulk uploads.

The update execution checker runs all instructions in the updater and freshly
matched memory, palette and lighting callees. Its independent oracle verifies
memory effects and ordered color, lighting and upload calls. It covers 909
cases: every destination index, all 128 mode values, signed arithmetic
boundaries, inactive and full pools, repeated destinations, contiguous changed
entries, and the final two source-color entries. It uses all 550 source colors
and the complete seven-entry control table. Invalid signed lookup indices
sample guarded neighboring fixture bytes. Read/write guards, stack boundaries,
SP, GP and saved integer registers are checked. Four instruction mutations
challenge step scaling, negative stop flags, reflection masks and upload
counts; all are detected. These deterministic BSS inputs do not establish
complete gameplay coverage.

Fresh splat 0.50.0 and spimdisasm 1.42.4 output independently reassembles to
the complete 1,200-byte retail range. Objdiff compares the whole function
and `.text` section at 100%; fresh matching-workbench and runtime comparisons
also report zero differing words. Ghidra retains the verified `void(void)`
prototype, shared record layout, direct caller `func_80038598`, and a plate
comment describing the accepted range and execution limits.

The [recorded proof](palette-transitions-provenance.json) contains the current
compiler identity, instruction hash, storage extents, mutation results, input
hashes, and complete-comparison results.
