# Scene menu string setup and scheduled flags

`func_80022858` covers `0x80022858..0x80022A08`, or 432 instruction bytes.
It sets `D_800B6FEC` to one, refreshes five movie string slots from the
two-choice table at `D_80076014`, and schedules the existing text flag
callback `func_800227F4`.

The choice table uses the same verified 12-byte record layout as the
neighboring string refresh routine: text, value, and destination slot.
This routine selects its group through `D_8009EFA8`. Both choices are
checked for each slot. A matching choice remaps digit glyphs, replaces the
string, sets the found flag, and writes the associated value. Missing
slots use `D_800925E4`. The complete table extent and the broader role of
the selection index remain unresolved, so the source claims no table
ownership.

The scheduled frame is `D_800B14A8->field2C * 3 / 4`. The source preserves
the multiply before division and truncation toward zero for negative
values. The callback visits five string handles and sets flag `0x100`
through the already recovered text service. The existing callback
signature and movie callback registration interface establish the call.

## Complete comparison

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces all 432 bytes,
including the 64-byte frame, global flag write, both loops, found flag,
string calls, value stores, fallback path, signed scheduled-frame division,
and callback registration. Acceptance checks the full linked procedure
type, size and placement, every instruction word, current source/header/
compiler inputs, and whole-ROM equality. The choice structure has a
compile-time 12-byte size check. This recovery adds one complete C
procedure and no initialized data or BSS ownership.

Complete procedure hashes and inputs are recorded in
[the provenance ledger](scene-menu-string-schedule-provenance.json).
Robotron's instructions and the existing string and movie callback
services establish the behavior. The pinned IDO and N64 matching workflow
references are credited for local and online use in
[CREDITS.md](../CREDITS.md). Further scene and menu recovery remains
tracked by [issue #45](https://github.com/frankischilling/robotron64/issues/45).
