# Palette storage

Five C definitions own 6,236 bytes of runtime palette storage. They use the
existing shared palette types and generate only BSS. The linker places each
complete object at its verified address with `NOLOAD`; no ROM bytes are added.

| Symbol | Runtime range, exclusive end | Bytes | Definition |
| --- | --- | ---: | --- |
| `D_8009CD18` | `8009CD18..8009D118` | 1,024 | `palette_effects/base_storage.c` |
| `D_8009D120` | `8009D120..8009E570` | 5,200 | `palette_effects/transition_storage.c` |
| `D_8009E570` | `8009E570..8009E574` | 4 | `palette_effects/fade_color.c` |
| `D_8009E578` | `8009E578..8009E57C` | 4 | `palette_effects/fade_progress.c` |
| `D_8009E580` | `8009E580..8009E584` | 4 | `palette_effects/fade_step.c` |

Sources live under `src/game/`. The eight-byte gap after the base palette and
four-byte gaps between the fade globals remain outside source ownership.
Separate objects preserve these gaps without inventing fields or padding.

## Layout and consumers

`PaletteColor` contains red, green, blue and unused unsigned bytes, in that
order. Its shared size assertion establishes the four-byte representation.
The matching palette loader iterates 256 entries, and the matching fade updater
reads their channels at that stride. Copying the original color preserves all
four bytes, including the unused byte.

`PaletteTransition` is 52 bytes. Its first two bytes hold the eight-bit palette
index, one active bit and seven mode bits. On the pinned big-endian target,
the active mask is `80` in byte one and the mode mask is `7F`. An unsigned
halfword follows, then eleven signed integers and the original color at
offset 48. The matching reset clears exactly 5,200 bytes; the matching range
handler iterates 100 records and reads the stored palette index, active bit
and original color. The unrecovered initializer's complete retail instructions
independently confirm the stride, field offsets and masks.

The matching fade controls copy the four-byte fade color and read/write the
progress and step as full signed integers. The matching fade updater consumes
those same globals. Their shared declarations and existing partial behavior
assumptions are unchanged.

## Ghidra and verification

Live Ghidra has the canonical four-byte color and 52-byte transition types.
The three known color/array ranges are uninitialized, writable, non-executable
runtime views. No initialized bytes were supplied to create them, and no
zero-filled runtime contents are claimed as observed data. Ghidra's layout
API omits numerical bit offsets; the original instructions and decompiler
byte masks corroborate the packed flag representation. Every previously
initialized program byte remains unchanged, and the full provisional CPU
interval remains identical to retail.

The [provenance ledger](palette-storage-provenance.json) records each pinned
IDO 5.3 object, full symbol size,
raw BSS alignment, final placement and current input hashes. A clean source
archive is extracted and built, every ROM byte is compared, all tooling tests
run, and all accepted executable and data-only units are independently checked.
The original startup and palette initialization routines remain at the same
addresses, preserving runtime initialization behavior.

The clean build reproduces all 8,388,608 ROM bytes with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
All 151 tooling tests pass, along with independent comparisons of 848 runtime,
two startup, eighteen assembly and 86 data-only units. Source-owned BSS is now
465,119 bytes. Matching C remains 1,365 functions and 258,812 instruction bytes;
source-owned initialized data remains 29,003 bytes.

This recovery adds storage ownership, not matching instruction credit. The
palette initializer, transition updater and effect-handler candidates remain
excluded until every instruction matches. Whole-ROM equality still includes
fallback ranges, and full source completion remains open.

Compiler and layout practices follow the project's
[N64 reference study](reference-study.md); retail instructions establish the
Robotron-specific layouts and behavior. No reference game code was copied.
