# Video timing tables and context swapping

The complete 860-byte context-swap procedure writes the video hardware from
the next context. It selects the current field, translates framebuffer origin,
applies horizontal and vertical scale changes, and retains the original
unsigned float-to-integer conversion. Black, repeated-line, and fade states
adjust the start, scale, and origin in the original order. It writes all
thirteen video registers, exchanges the current/next pointers, and copies the
complete 48-byte context into the newly available next slot.

`VideoMode` now describes the confirmed 80-byte layout: a mode type, nine
common register words, and two 20-byte field records. Existing startup writes
use `fields[0].origin` at the same offset `28`. The prior code matches remain
subject to complete comparisons after this header change.

## Timing reconstruction

The 42 writable SDK modes at `8008E400` occupy 3,360 bytes. Three independent
default modes at `8008F530` occupy another 240 bytes, ordered PAL, MPAL, NTSC.
`tools/generate_video_modes.py` reconstructs these records from the confirmed
region timings, pixel sizes, antialias flags, filtered-field offsets, and
resolution choices. The build checks the committed typed declarations against
the generator. The generator does not read a ROM.

The source distinguishes 14 variants per region. Low modes use a 320-pixel
line; high modes use the original width and field-origin combinations.
Filtered modes encode quarter- or half-line scale offsets. PAL and MPAL retain
their distinct burst and interlaced timing values. The startup modifications
to the first field origin remain separate runtime behavior.

The pinned local [libreultra](https://github.com/n64decomp/libreultra) files
`src/io/viswapcontext.c`, `src/io/vitbl.c`, `src/io/viint.h`, and the three
`vimode*lan1.c` files corroborate register meanings and timing parameters.
Complete Robotron target bytes determine the accepted records and procedure.
[CREDITS.md](../CREDITS.md) records the full local and online references.

## Data proof

The timing files contain no procedures. `tools/compare_data.py` compiles each
independently, rejects executable content and unowned allocated sections,
checks every definition, links each complete data section at its original
address, and compares every initialized byte. The publication audit requires
the current source inventory, compiler identity, input hashes, full ownership
records, and independently linked payloads. These units increase initialized
data ownership and do not increase function counts.

All 689 complete runtime units, both startup units, nineteen assembly units,
two data units, and 131 tooling tests pass. The complete 8,388,608-byte ROM
matches the normalized US target. The
[provenance ledger](sdk-video-modes-and-swap-provenance.json) records the full
procedure, all 45 mode records, source and generator hashes, compiler identity,
and separate data comparisons. Rebuild current inputs for current progress.
