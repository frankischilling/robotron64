# Reference study

The following checkouts were inspected locally. References guide infrastructure; Robotron's binary remains authoritative for game behavior. No reference implementation code was copied.

| Project | Inspected commit | Relevant files and choices |
| --- | --- | --- |
| [SM64](https://github.com/n64decomp/sm64) | `9921382a68bb0c865e5e45eb594d9c64db59b1af` | `Makefile`, `sm64.ld`, `extract_assets.py`, SDK assembly. Separate ROM load addresses and runtime addresses, extract from user input, verify target hash, use compiler flags per object. |
| [Ocarina of Time](https://github.com/zeldaret/oot) | `1bef952ff61a6dd1945c7887c1babd94efe95f72` | `Makefile`, `tools/Makefile`, compiler signatures, requirements, CI. Pin compiler downloads and verify checksums. Its ROM CI uses a private container; this project's public CI uses no commercial inputs. |
| [Majora's Mask](https://github.com/zeldaret/mm) | `56fa21dd0031a17cfc9e355f609542617598a265` | `Makefile`, `spec/spec`, `tools/progress.py`. Segment descriptions separate initialized and NOLOAD regions. Progress uses map sizes and assembly status; this bootstrap measures verified object bytes and leaves unknown totals unset. |
| [Perfect Dark](https://github.com/n64decomp/perfect_dark) | `169ed48bdcbfb3b568b028bd5bebb27680073514` | `Makefile`, `tools/extract`, `LICENSE`. Extraction follows discovered segment formats; different objects can use different compilers and optimization levels. Robotron's compression remains unknown. |

SM64 includes CC0 terms; Perfect Dark includes MIT terms. Other projects contain component-specific licenses. Inspect each component's terms before importing it; studying architecture does not grant a blanket code license.

For this small initial layout, an explicit linker script and standard-library Python extraction are sufficient. Generated binary fallbacks stay in `build/`. Function names remain address-based until stronger evidence supports a name. A future segment map should replace the large unclassified remainder as analysis establishes boundaries.
