# Text storage and character widths

`src/game/text_records.c` defines the thirty `TextRecord` objects at
`0x800B6FF8..0x800B8F60`. Each record occupies `0x10C` bytes, giving a complete
`0x1F68`-byte uninitialized section. The definition replaces the absolute linker
binding with C-owned BSS. It contributes no initialized ROM bytes or new C
functions to the progress totals.

Two adjacent tables have complete source definitions in `text_widths/`:
`D_80072B40[26]` at `80072B40..80072BA8` contains 104 bytes for lowercase
letters, and `D_80072BA8[10]` at `80072BA8..80072BD0` contains forty bytes
shared by ASCII digits and byte values 170 through 179. The complete matching
184-byte lookup at `80000460..80000518` establishes both index bounds and the
four-byte element stride. These definitions replace the absolute bindings and
contribute 144 initialized ROM bytes. Compiler alignment beyond each declared
array is independently checked and trimmed; the following 48 bytes remain
outside this ownership. The existing retail caller `8000177C` sums the helper's
results across the text and uses the sum in a scaled coordinate offset. This
supports the glyph-spacing interpretation. Its C candidate remains excluded;
the checked behavior here is the complete lookup plus one.

The matching reset routine at `0x800005E0..0x8000060C` passes the array address,
zero, and the complete 8,040-byte length to `func_8003B694`. The matching allocator
at `0x80000918..0x80000ACC` scans exactly thirty records with the same 268-byte
stride. Its accesses establish the flag word, mode, 64-byte text buffer at
offset `0x24`, scale fields at `0x68`, length at `0x74`, sixty signed object
indices at `0x78`, and the three sentinel words at `0x100`. Unnamed fields keep
their established offsets and are not assigned invented behavior.

The linker places the complete section as `NOLOAD` and asserts its address and
size. The independent data comparison compiles the definition with the pinned
IDO profile, checks its symbol and section type, and rejects additional
initialized or executable content. `tools/check_text_storage.py` separately
executes the original and freshly compiled reset and allocator with the
matching byte-clear, string-length and bounded-copy helpers. It checks the
whole guarded array, record selection, exhaustion, truncation, flags, sentinels,
object-index stores and preserved fields. Glyph construction and the exhaustion
message are recorded ABI boundaries; this checker does not simulate rendering.

The checker runs 744 paired allocation/reset cases for each image: all thirty
free-slot positions and exhaustion, six lengths around the sixty-character cap,
two initial array patterns and two signed scale/mode/options combinations. It
checks the independent model before comparing the two images, yielding 2,976
allocation/reset executions. Another 1,024 cases per image cover every byte-valued
character with zero, positive and two negative enabled values, giving 5,024
target-function executions overall. The width check executes both independently
compiled tables, preserves their guards, and permits only the observed incoming
A1 argument-home store at `SP+4`. Instruction and memory bounds, pool/string/stack
canaries, SP, GP and saved integer registers are checked. Five mutations are
rejected after an unmodified positive control: a short reset, an overlong reset,
omission of slot 29, clearing the active flag and shortening the length cap.

Run the independent checks with the optional analysis environment:

```sh
make analysis-setup
.venv/bin/python tools/compare_data.py
.venv/bin/python tools/check_text_storage.py --mutations
```

`make audit-text-storage PYTHON=.venv/bin/python` runs the guarded cases without
the isolated mutations. The [verification ledger](text-record-storage-provenance.json)
records the source, checker, layout and complete comparison hashes.

Ghidra's existing `TextRecord` type is applied to a thirty-element array in an
uninitialized, non-executable block with the same bounds. The original ROM and
MIPS accesses remain the evidence for the layout. A pinned IDO probe agrees on
the four-byte alignment, all sixteen ordinary field offsets and widths, and
the five flag masks. A clean build with this ownership still reproduces every
retail ROM byte. Analysis tools and reference
projects are credited in [CREDITS](../CREDITS.md).
