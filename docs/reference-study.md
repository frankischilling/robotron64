# Reference study

The following checkouts were inspected locally. References guide infrastructure
and SDK reconstruction; Robotron's binary establishes its own behavior and
instruction matches. [Credits](../CREDITS.md) records the complete requested
reference collection, exact checkout revisions, and additional tools used.

| Project | Inspected commit | Relevant files and choices |
| --- | --- | --- |
| [SM64](https://github.com/n64decomp/sm64) | `9921382a68bb0c865e5e45eb594d9c64db59b1af` | `Makefile`, `sm64.ld`, `extract_assets.py`, SDK assembly. Separate ROM load addresses and runtime addresses, extract from user input, verify target hash, use compiler flags per object. |
| [Ocarina of Time](https://github.com/zeldaret/oot) | `1bef952ff61a6dd1945c7887c1babd94efe95f72` | `Makefile`, `tools/Makefile`, compiler signatures, requirements, CI. Pin compiler downloads and verify checksums. Its ROM CI uses a private container; this project's public CI uses no commercial inputs. |
| [Majora's Mask](https://github.com/zeldaret/mm) | `56fa21dd0031a17cfc9e355f609542617598a265` | `Makefile`, `spec/spec`, `tools/progress.py`. Segment descriptions separate initialized and NOLOAD regions. Progress uses map sizes and assembly status; this bootstrap measures verified object bytes and leaves unknown totals unset. |
| [Perfect Dark](https://github.com/n64decomp/perfect_dark) | `169ed48bdcbfb3b568b028bd5bebb27680073514` | `Makefile`, `tools/extract`, `LICENSE`. Extraction follows discovered segment formats; different objects can use different compilers and optimization levels. Robotron's compression remains unknown. |
| [libreultra](https://github.com/n64decomp/libreultra) | `1aca5c13ca041cef86f8dc194b727361dad9c09b` | Audio filters, reverb, synthesizer initialization, controller/Pak layouts, allocator and read/write variants. Complete reconstructed units are compiled and compared with Robotron's target. |
| [Mario Kart 64](https://github.com/n64decomp/mk64) | `58cfcb022e10f83bc3b889d7e97508cae6837098` | `src/os/osPfsSearchFile.c` and `osPfsAllocateFile.c` corroborate the older explicit page-clearing allocator. |
| [GoldenEye 007](https://github.com/n64decomp/007) | `c4356466796c697dfd298010b9bed261f9ed8c6a` | `src/motor.c` identifies the older fixed-CRC rumble commands and the single device probe found in Robotron. |
| [decompals/ultralib](https://github.com/decompals/ultralib) | `e24c836796df4bf520ff8b11a5c9d2cea3a66cbd` | SDK sine/cosine algorithms and `tools/mdebug.py` procedure/end records. OOT's CC0 symbol-table reader provides an additional metadata-layout reference. |

SM64 includes CC0 terms; Perfect Dark includes MIT terms. Other projects contain component-specific licenses. Inspect each component's terms before importing it; studying architecture does not grant a blanket code license.

The build uses explicit source and fallback ranges, verified source-owned
data/BSS, and per-source compiler profiles. Generated binary fallbacks stay in
`build/`. Function names remain address-based where stronger naming evidence
is absent. The large unclassified remainder still needs a complete segment
map and source recovery.
