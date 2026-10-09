# Scripted file diagnostics

Nine C arrays own the complete 480-byte range `0x800904B0..0x80090690`,
stored at ROM `0x910B0..0x91290`. Six already matching service procedures
reference every array. Registration, lookup, loading, address lookup, release
and deletion keep their existing behavior and instruction extents.

| Symbol | Bytes | Caller |
| --- | ---: | --- |
| `D_800904B0` | 32 | Registration diagnostic |
| `D_800904D0` | 64 | Registration report |
| `D_80090510` | 60 | Successful handle lookup |
| `D_8009054C` | 56 | Failed handle lookup |
| `D_80090584` | 52 | Load report |
| `D_800905B8` | 64 | Successful address lookup |
| `D_800905F8` | 56 | Failed address lookup |
| `D_80090630` | 48 | Release report |
| `D_80090660` | 48 | Deletion report |

The declarations preserve all terminators, newlines and trailing zeros,
including the `AddScriptedFileFile()` spelling. The unchanged formatter
skips the unsupported `%l` conversion and prints the following `d` literally.
It consumes no argument for `%l`; the next supported conversion therefore
uses the same argument. These strings preserve that retail behavior.

Pinned IDO 5.3 emits exactly 480 initialized bytes, with no instructions,
BSS, relocations or extra alignment bytes. Fresh splat and spimdisasm
reassemblies independently reproduce the complete range. Its SHA-256 is
`68bb2e578b50280d00b28ccbc2933d4634fab638f6744875b525e1db7e86b389`.
The linker checks the complete section and all nine source definitions.
The adjacent eight bytes and unrelated diagnostics remain extracted fallback.

Run `make audit-scripted-file-diagnostics` to execute the complete arrays
with the actual matching formatter and numeric/string helpers. Output and
the fatal reporter remain recorded ABI boundaries. File I/O, script
interpretation and gameplay are outside this bounded validation.

The selected USA NRXE ROM supplies the byte and caller evidence. Tools and
N64 reference projects are credited in [CREDITS.md](../CREDITS.md).

The [acceptance ledger](scripted-file-diagnostics-provenance.json) records all
27 validation stages, 27 diagnostic pairs and ten negative controls. The
registry audit passes 630 pairs and seven source controls; the complete
formatter regression also passes. Whole-ROM equality still includes fallback.
