# Model file relocation

`func_8003C6B8` covers `0x8003C6B8..0x8003C94C`. Its complete 660-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. The source is
`src/game/model_file_relocate.c`. The diagnostic at `0x80094C50` owns
48 bytes, including its compiler alignment. It adds no BSS.

The existing `ObjectRecoveryDatFile` view is a forty-byte header. Four
eight-byte sections contain an offset and count information. The final
two words select a record and supply a fifth data offset. The routine
adds the header address to all four section offsets and the final data
offset, then returns that same header pointer.

The fourth section packs a signed sixteen-bit record count followed by
a signed sixteen-bit scale. A nonpositive scale becomes one. The first
section contains eight-byte points with three signed short coordinates.
For each point, the routine reads its three coordinates and the scale,
multiplies each coordinate by the scale, and divides each result by
eight before writing any coordinates back. Signed division truncates
toward zero.

The fourth section contains 100-byte records. Their first three signed
words are coordinates; the remaining 88 bytes stay opaque. For each
record, the routine multiplies all three coordinates in place before
dividing all three by eight. It then clears the three coordinates of
the selected record. The target reloads the data pointer and selected
index between those stores. The source preserves those reloads through
the original typed accesses.

When the point count exceeds 950, the routine calls the diagnostic
formatter with the point data pointer and 950. The string expects an
integer point count, but the instructions pass the pointer. The source
retains that behavior and the original spelling `Too may points`.
The diagnostic does not stop the point loop. The routine also retains
the lack of bounds checks for the selected record.

The source checks the eight-byte point, 100-byte record, and forty-byte
header sizes at compile time. These are recovered views rather than
surviving original type names. The
[provenance ledger](model-file-relocation-provenance.json) records the
complete instructions, linked diagnostic bytes, compiler inputs, and
matching ROM hash. All thirteen requested N64 references, pinned
revisions, and licenses remain in [CREDITS.md](../CREDITS.md).
Further model work is tracked by
[issue #35](https://github.com/frankischilling/robotron64/issues/35)
and [draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
