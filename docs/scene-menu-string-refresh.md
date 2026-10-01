# Scene menu string refresh

`func_80022A08` covers `0x80022A08..0x80022B78`, or 368 instruction bytes.
For each of five movie string slots, it checks two choices from the table
at `D_800761AC`, using the current index at `D_8009EFB0`. Each choice has
a text pointer, a value word, and a destination slot word, for a 12-byte
stride. Each table group therefore occupies 24 bytes. The complete table
extent and the meaning of its index remain unresolved.

When a choice has text and selects the current slot, the routine passes
its text to `func_80000518`, which remaps ASCII digits to glyph bytes
170 through 179, then replaces the string through `func_80000F48`,
marks the slot found, and copies the choice value to the string word at
offset `0x18`. Both choices are tested even after a match. A second match
can replace the same string again. If neither choice matches, the routine
uses the fallback text at `D_800925E8`.

The existing `MovieConfig` and `MovieStringRecord` layouts establish the
string handle at movie offset `0x66C`, its value at `0x680`, and the 28-byte
record stride. The routine reloads the table index and movie pointer after
external calls, as the target does. The local found flag is assigned after
the replacement call; IDO schedules it into the preceding normalization
call's delay slot. That source ordering reproduces the complete procedure
without instruction edits or register-specific code.

## Complete comparison

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces all 368 bytes,
including the 64-byte frame, five-slot and two-choice loops, table loads,
found flag, string calls, and fallback path. Acceptance checks the linked
procedure type, full size and placement, every instruction word, current
source, local headers and compiler inputs, and whole-ROM equality. The
12-byte choice structure has a compile-time size check. The source adds
one complete matching C procedure and claims no table, initialized data,
or BSS ownership.

A clean archive of `acbc5f0` passes fresh extraction and build, all 137
tooling tests, 787 complete runtime comparisons, both startup units,
eighteen assembly units, and eight data-only units. Linked progress records
1,303 matching C procedures and 218,216 instruction bytes. The complete
ROM matches the supplied USA target, SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The publication audit checks all 1,269 public files.

Complete procedure hashes and compiler inputs are recorded in
[the provenance ledger](scene-menu-string-refresh-provenance.json).
Robotron's target instructions establish the behavior. The pinned IDO and
established N64 matching workflows are credited for local and online use
in [CREDITS.md](../CREDITS.md). Further scene/menu recovery is tracked in
[issue #45](https://github.com/frankischilling/robotron64/issues/45).
