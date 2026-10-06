# Pak confirmation records

Five C units define 192 initialized bytes for the Pak delete confirmation:
two 40-byte labels, a 52-byte page, 16 label-text bytes, the 28-byte initialized
title span and a 16-byte formatting span. The complete ranges are
`8007721C..8007729F`, `80093450..8009347B` and `80093828..80093837`.
No instruction or BSS ownership is added. The surrounding fallback ranges
and linker assertions preserve each exact placement.

`MenuScalarLabelRecord` shares the verified 40-byte label layout. Its word at
offset `14` is an integer callback argument. Delete passes `1`; cancel passes
`0`. Both labels call the already-matching `func_80026674(int deleteSelected)`.
Their reverse chain starts at the cancel label. Numeric labels retain the
existing pointer-argument view. The page uses the canonical 52-byte
`MenuStaticPage` type and has a null timeout callback. The matched name-selector
and page comparison sources use the canonical page declaration.

The title source defines the exact initialized 28-byte span at `80093460`.
This does not establish the original array declaration or capacity. The
independently owned `yes` string begins immediately afterward at `8009347C`.
The source retains the retail placeholder, backslashes, terminators and
alignment. Compiler padding outside an owned range receives no storage credit.

The matched filename decoder writes a space for the encoded zero before it
stops. Entry formatting adds a dot and one extension character. In successful
synthetic directory fixtures containing 15 or 16 encoded `A` characters and
extension `A`, `delete\ %s ?` produces 29 or 30 bytes including its terminator.
Those writes alter the following `yes` string to `00 65 73 00` or
`3F 00 73 00`, respectively. A full 16-byte name reads zero-filled record
padding. The guard preserves these observed machine effects; it does not
establish portable C array bounds, overflow behavior or actual gameplay.

`make check-pak-confirmation-records` checks 507 cases and 1,014 executions:
216 two-label displays, 256 cleanups/transitions, 18 scalar callback cases
and 17 filename-formatting cases. Complete freshly matching support blocks
execute with retail and source-built records. Independent trace and memory
oracles check both labels, drawing arguments, cleanup, callback branches,
formatted output and the adjacent-string writes. Six data mutations must be
detected. The harness also checks bounded code and memory access, protected
fixture bytes, stack guards, SP, GP and saved registers.

Text services, drawing, RNG, Pak deletion/directory refresh, glyph lookup and
page activation use explicit O32 boundary stubs. The harness reads callback
addresses and scalar argument words from the real records; the complete
menu-control caller remains outside this guard. Gameplay and RSP rendering
are unverified.

Fresh IDO data comparisons, both complete independent spimdisasm and splat
reassemblies, linked objdiff, compiler layouts and pointer relocations are
recorded in [the provenance ledger](pak-confirmation-records-provenance.json).
The target ROM remains the behavioral and layout reference. Analysis uses
Ghidra and Ghidra MCP, pinned IDO 5.3, MIPS binutils, spimdisasm, splat, objdiff,
Unicorn, Capstone and pyelftools. Tool and source references are listed in
`docs/tool-references.md` and `docs/reference-repositories.md`.

The local libreultra `src/io/pfsfilestate.c` was consulted for its fixed-array
directory-name copy. It informs the fixture layout; Robotron's complete matched
decoder and entry-formatting routines determine the observed output. No code
was copied from that reference.

Whole-ROM equality includes extracted fallback code and assets. Full source
recovery remains incomplete.
