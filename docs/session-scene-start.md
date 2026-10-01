# Session scene start and player selection

`func_80022528` covers `0x80022528..0x800226E8`, or 448 instruction bytes.
It selects a level, initializes the requested players, resets the current
selection, and starts the scene transition. The recovered menu callers
pass mode one for a single player or mode two for two players. Their extra
values are zero, one, and three. The mode-advance caller passes three zeros
and selects the routine's automatic path.

Mode zero becomes one. When `D_8009E57C` is zero, the level comes from
`D_80075FD0[D_80075FFC]`; the incremented counter wraps at unsigned eleven.
Otherwise, the previous counter becomes the level, and its incremented
value is reduced by signed remainder against `D_800BA7A0`. The automatic
path writes six to `D_800AD280`, while an explicit mode writes nine. The
complete level table extent and the broader roles of these globals remain
unresolved, so this routine claims no table or global storage.

The routine stores the level and extra value, calls the sound-label service
at the preserved points, clears the players, and stores the mode. Each
requested player gets a matching choice index and the existing player
setup call with arguments `(index, 1, 0)`. It resets the selection word at
session offset `0x34`, loads the first choice into the current-player word,
and calls `func_800214D4(1)`. The second player's words at `0xD6C` and
`0xD70` receive the scene words at `0xCCC` and `0xCD0`.

The shared save structures now expose the selection word, two player-choice
words, and extra value, preserving the 76-byte saved session and 328-byte
runtime session. The newly typed player word replaces four bytes of an
unknown region, preserving the 3,508-byte player stride. Existing size
checks also retain the 444-byte save slot and 4,096-byte save image. The
source makes no claim that modes beyond the recovered zero, one, and two
callers are valid.

## Complete comparison

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces the entire
448-byte procedure. Separate selection and current-player statements
retain the target's store and address-calculation ordering. The source
preserves the signed division checks, 40-byte frame, saved registers,
player setup loop, call ordering, and both scene-word stores.

Acceptance checks the full linked procedure type, size and placement,
every instruction word, current source/header/compiler inputs, all other
shared-header users, and whole-ROM equality. The recovery adds one
complete C procedure and no initialized data or BSS ownership. Complete
hashes and inputs are recorded in
[the provenance ledger](session-scene-start-provenance.json).

Robotron's instructions and recovered callers establish the behavior.
Pinned IDO and the N64 matching-workflow references are credited for local
and online use in [CREDITS.md](../CREDITS.md). Further scene and menu
recovery is tracked by [issue #45](https://github.com/frankischilling/robotron64/issues/45).
