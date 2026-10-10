# Movie literals

Fourteen C arrays define 210 characters and first terminators from the movie
command, path loading, callback and update code. They live separately in
`src/game/movie_literals/`, so all inter-array and following zeros remain
fallback. Signedness follows the existing consumer declarations. The two
identical `.MOV` literals retain separate retail definitions.

Array extents are 21, 32, 31, 23, 7, 5, 5, 23, 5, 5, 5, 25, 10 and 13 bytes.
Ghidra string types independently support nine extents. Five extension addresses
were undefined in Ghidra; the retail first terminators and actual string-copy
calls establish their five-byte extents. Linker assertions require every C
definition at its original address. Four existing consumer blocks must retain
all 4,712 instruction bytes. No instruction or BSS ownership is added.

`make audit-movie-literals` freshly compares arrays and complete consumers and
executes bounded command, file-path, callback and update-label cases. Independent
whole-object, path and call oracles verify the selected behavior. File allocation,
release, fatal reporting, update labels and the early completion query use
explicit ABI boundaries. Fatal cases stop at the call before unsafe continuation.
Full movie playback, arbitrary aliases, malformed paths, out-of-range indices
and actual cartridge or filesystem I/O remain unproved.

The audit runs 321 paired cases with 28 character/terminator controls. Twelve
saved-FPU corruptions and three guest read, write and code escapes must fail;
positive retail and compiled runs bracket every fault. Returning calls preserve
distinct saved integer registers, the global and stack pointers, and twelve
saved FPU words. The bounded stack interior is not claimed byte-identical.

Separate Splat and spimdisasm references verify 28 complete aligned banks and
all 210 natural bytes. Thirty following zeros are checked but excluded. Only
the characters and first NUL receive credit. The USA ROM, Ghidra, pinned IDO,
Splat, spimdisasm, MIPS binutils and Unicorn supply the evidence. Tool and
reference credits are in [CREDITS.md](../CREDITS.md).

| Address | Natural bytes | Role |
| --- | ---: | --- |
| `8008F840` | 21 | prop limit |
| `8008F858` | 32 | primary-frame limit with prop argument |
| `8008F878` | 31 | color-cycle limit |
| `8008F898` | 23 | string limit |
| `8008F8B0` | 7 | path prefix |
| `8008F8B8` | 5 | replace the first extension |
| `8008F8C0` | 5 | append a missing extension |
| `8008F8C8` | 23 | exhausted track bank |
| `8008F8E0` | 5 | track-state extension |
| `8008F8E8` | 5 | integer-channel extension |
| `8008F8F0` | 5 | float-channel extension |
| `8008F8F8` | 25 | callback limit |
| `8008F914` | 10 | update label |
| `8008F920` | 13 | erase-screen label |

File fixtures execute the actual matching string helpers and track-state copy.
They cover slots zero and 24, cache hits in slots zero, 12 and 24, exhausted
banks, both first-dot replacement and extension append, and optional integer
and float channel loads. Host allocation boundaries check each complete path
and the writable size-output pointer. Update fixtures return at the checked
early-completion query after emitting the selected labels; they do not cover
the remainder of the update loop.

Ghidra retains its existing labels, including the two named update strings.
Their addresses, array types and plate comments agree with the C definitions;
all 210 program bytes remain unchanged. The five formerly undefined extensions
are documented as inferred types, rather than pre-existing string evidence.
