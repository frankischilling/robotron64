# Front menu records

Seven C data units reconstruct 832 initialized bytes for the load, main and
audio menus: twelve 40-byte labels, three 52-byte static pages and 196 bytes
containing fifteen strings and their alignment. The complete ranges are
`80076CD0..80076F4B` and `80093254..80093317`. No instruction or BSS ownership
is added. Extraction and linker placement exclude these ranges from fallback
data, with assertions for each source section's full size.

Each page starts at the last element of its four-label reverse chain. Callback
addresses, selection pointers, flags, sounds, spacing and title placement
retain their retail values. The main page includes its timeout callback at
offset 48. The audio page selects the music track and two volume globals.
`D_80076EC0` is an alias for the music label's `value20` field; it does not
define separate storage. The music callback clamps the selection through an
alias to its own global before testing that selection again.

Fresh pinned IDO comparisons and independent splat and spimdisasm
reassemblies check every byte. Linked objdiff comparisons cover the complete
sections. Every compiler pointer relocation is resolved and compared with
retail data. Ghidra uses the canonical 40-byte label and 52-byte page types,
the verified string lengths and callback prototypes, and retains the interior
field alias. String types exclude compiler alignment.

`make check-front-menu-records` checks 1,578 cases and 3,156 executions against
independent traces and protected memory. It executes matching display, string
and numeric helpers, navigation cleanup, preview release, transition setup
and all three audio callbacks on the complete retail and compiled records.
The checks cover traversal, title and label creation, every draw argument,
numeric suffixes, selection boundaries, cleanup, audio arguments and O32
preservation. Five mutations to record pointers, a callback, the title and
the timeout word are detected.

Text services, drawing, randomness, camera submission and audio hardware use
ABI boundary stubs. The timeout word is compared, but its deferred control
flow is not executed. Menu activation, general menu control, other label
callbacks and full-game rendering remain outside this proof. The excluded
menu-entry and menu-control candidates receive no instruction ownership.

Current inputs and results are recorded in
`docs/front-menu-records-provenance.json`. Whole-ROM equality still contains
extracted fallback code and assets, so the game remains incompletely
decompiled.

The original user-supplied US ROM is the byte and behavior reference.
Analysis uses Ghidra 12.1.4 and Ghidra MCP, pinned IDO 5.3, splat 0.50.0,
spimdisasm 1.42.4, MIPS binutils, objdiff, Unicorn, Capstone and pyelftools
through `robotron-tools`. References are listed in `docs/toolchain.md` and
`docs/reference-study.md`.
