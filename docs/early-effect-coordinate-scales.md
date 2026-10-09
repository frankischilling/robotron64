# Early effect coordinate scales

Six named `const float` definitions replace the complete 24-byte fallback
range at `8008F940..8008F958` (ROM `90540..90558`). Each value is 60,000.0,
the single-precision denominator used by one of the six early effect
renderers at `800077F4`, `80007D10`, `800083D4`, `80008AF0`, `80009078`
and `800096E8`. The original load instructions and Ghidra references
establish all six four-byte locations.

Pinned IDO emits 32 bytes in `.data`; the last eight bytes are zero alignment
and remain excluded. All six symbols have size four and offsets zero,
four, eight, twelve, sixteen and twenty. This unit emits no instructions,
BSS or relocations. Naming the constants does not establish their original
translation-unit boundaries. The renderer bodies remain unresolved fallback.

Separate splat and SPIM references reproduce the complete retail range.
The reproducible [split](../config/analysis/early_effect_coordinate_scales.yaml)
uses [verified symbols](../config/analysis/early_effect_coordinate_scales_symbols.txt).
Generated retail assembly stays under ignored `.local` directories.
The [acceptance ledger](early-effect-coordinate-scales-provenance.json)
records independent data compilation, final ELF symbols and whole-ROM
placement. Fresh checks cover 912 runtime units, two startup units,
eighteen assembly units and 200 data-only units. All 176 tests pass
on Linux and Windows; Windows skips nine platform-specific checks.
The full ROM matches all 8,388,608 bytes and still contains fallback. Tools and local N64 reference projects
are listed in [CREDITS.md](../CREDITS.md).
