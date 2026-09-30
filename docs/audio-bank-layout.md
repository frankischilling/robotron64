# Audio bank initialization

`audio_backend_initialize.c` reconstructs the complete 708-byte routine at
`0x8005B3A8..0x8005B66C`. Its private wave cursor occupies four bytes at
`0x80192ABC`. The source installs the context, instance, voice, and hardware
record pointers, then lays out and relocates the bank records used by the
audio driver.

## Packed records and alignment

The bank header is 28 bytes. Signed halfwords at `0x04`, `0x08`, `0x0C`, and
`0x10` hold the patch, region, wave, and drum counts. The pointer at `0x18`
identifies the first four-byte patch record. The initializer advances through
20-byte regions, 24-byte waves, four-byte drum entries, and an eight-byte loop
group. Each new section begins at the next eight-byte boundary.

The loop group records the raw and ADPCM loop counts. Raw loop structures
contain three words and use a 16-byte serialized stride. ADPCM loops add
sixteen signed state samples and use a 48-byte stride. The prediction-book
records follow these loops and occupy 264 bytes each. `audio_bank_layout_internal.h`
and `audio_patch_table_internal.h` express these layouts with fielded structures,
size checks, and the bank's eight-byte alignment rule.

## Wave relocation

For each wave, the initializer adds the installed sample base to its data
pointer, writes the observed flag value of one, and copies the serialized word
at `0x0C` into the runtime word at `0x14` before replacing `0x0C` with a loop
pointer. Type one selects a raw loop; other types use the ADPCM path. A loop
index of `-1` selects the corresponding default loop record. Other indices
select the raw or ADPCM loop using the padded stride. The ADPCM path also
installs the wave's prediction-book pointer.

The signed count tests, pointer update order, and retained private cursor
follow the target instructions. The source does not add bounds checks or
change malformed-bank behavior.

## Verification

The [provenance ledger](audio-bank-layout-provenance.json) records the retained
candidate, its current-header comparison, the complete code interval, and the
private BSS definition. IDO 5.3 emits all 708 code bytes exactly with the
established game profile. The compiler gives the private cursor a 16-byte BSS
section; the build removes only the twelve unused alignment bytes and retains
the complete four-byte definition at its observed address.

The function, section, extraction boundary, linker placement, build rule, and
independent runtime comparison are registered together. The bank contents and
sample data remain extracted input. No bank asset bytes contribute to this
source-recovery count. The full-ROM build and source provenance checks remain
required before this routine contributes to reported progress.

Robotron's instructions establish the layout, ordering, and relocation behavior.
The SDK audio record conventions and matching workflow were compared with the
N64 references recorded in [CREDITS.md](../CREDITS.md). This source preserves
Robotron's observed bank representation.
