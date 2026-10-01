# Continue-code encoding and decoding

`func_800312B0` at `0x800312B0..0x80031420` encodes the game's ten-character
continue code. The complete 368-byte function matches the US target with
IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`. It emits no initialized data
or BSS.

The first packed word uses the following big-endian bit fields:

| Bits | Width | Stored value |
| --- | ---: | --- |
| 31..29 | 3 | Sum of the other five fields, reduced modulo eight |
| 28..14 | 15 | Player `saved.value18 / 1000` |
| 13..11 | 3 | Option `field08` |
| 10..7 | 4 | Option `field0C` |
| 6..0 | 7 | Player `saved.active` |

The next byte contains the session's saved level. The unused 24 bits in that
second word are cleared. Assignments to the unsigned bit fields preserve the
original truncation before the checksum reads them back; the source does not
introduce range checks or saturation. Two preceding local storage words remain
uninterpreted because the target accesses only the packed code that follows.

The function visits those five bytes in address order. For each byte it sends
the low nibble to `func_80030FEC` first, then the high nibble, and finally writes
the string terminator. The existing nibble encoder supplies the alphabet.

## Decoding and scene restoration

`func_80031080` covers `0x80031080..0x800312B0`. Its complete 560-byte
procedure now matches with the same IDO 5.3 profile. The encoder and decoder
share the verified 8-byte `SaveMenuContinueCode` bitfield type in
`include/save_menu_internal.h`. The encoder's preceding local storage words
remain private to its source; the decoder uses only the packed code itself.
Moving the bitfield declaration preserves every encoder instruction.

The decoder rejects a string containing any character in `D_8009404C`, whose
target contents are `aeiou`. It retains the repeated string-length call
around the character search. It then reads ten characters as five pairs,
decoding the low nibble first and adding the second nibble shifted left by
four. The existing numeric service `func_80031034` supplies each nibble.
That service remains executable fallback and is not counted as recovered C.

The checksum sums the five stored fields and masks the result with seven.
The target compares an unsigned calculated checksum with the stored three
bits. A mismatch prints the stored checksum followed by the calculated
checksum. The two decimal placeholders in `D_80094064` and the argument
registers establish both diagnostic arguments. A matching checksum is
followed by these field checks:

| Field | Accepted value |
| --- | --- |
| `value1C` | Nonzero and below 127 |
| `level` | Below 210 |
| `option08` | Below three |
| `option0C` | Below ten |

Success calls menu cleanup, player-field clearing, and player-zero setup in
that order. It assigns the decoded level to both session and player with a
chained assignment, restores `value18 * 1000`, `value1C`, and both options,
clears the session selection, reads the selected player choice, and sets
mode one. It prints the success diagnostic, starts the scene transition,
and copies `0xD14` bytes of scene state into player zero at offset `0xA0`.
It returns one on success and zero on every failure path. The source
preserves the target's reads and checks, including its lack of a separate
input-length check.

## Complete comparison

Both complete procedures contain 928 matching instruction bytes, with no
initialized data or BSS ownership. The decoder adds 560 new C bytes. Its
96-byte frame places the code at stack offset `0x58`; the homed player
argument remains at `0x60`. Matching follows from the unsigned checksum,
the two diagnostic arguments, and the chained level assignment. No added
workspace, unused argument, return-type change, assembly, or instruction
patch is used.

Acceptance checks complete function bounds, symbol type, linked placement,
all instruction words, current source/header/compiler inputs, every shared
header user, and whole-ROM equality. The shared layout preserves all
verified session, player, save-slot, and save-image sizes. The complete
proof is recorded in [the provenance ledger](continue-code-provenance.json).

The accepted source and first complete proof are preserved under
`.local/recovery61-menu/accepted/func_800312B0`. Independent canonical-source
comparison, complete procedure bounds, compiler identity, and current
transitive-header evidence are under `.local/recovery61-integration`.

Robotron's instructions establish the decoding behavior. The pinned IDO
and all thirteen requested N64 reference projects remain credited for local
and online use in [CREDITS.md](../CREDITS.md). Scene and menu recovery
continues under [issue #45](https://github.com/frankischilling/robotron64/issues/45)
and [PR #46](https://github.com/frankischilling/robotron64/pull/46).
