# Continue-code character decoding

`func_80031034` covers `0x80031034..0x80031080`. Its complete 76-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. It emits no initialized data or BSS.
The source is `src/game/save_menu_continue_character.c`.

The helper subtracts `'a'` from its signed integer argument, then applies
one of four adjustments: subtract four for offsets at least fifteen,
three for offsets at least nine, two for offsets at least five, and one
otherwise. The matching encoder `func_80030FEC` maps nibble values 0–15 to
`bcdfghjklmnpqrst`; this helper maps those characters back to their values.

The helper performs no range check or letter normalization. It retains
signed comparisons and the original adjustment for every input. The
caller `func_80031080` performs its own vowel rejection before calling
this helper; those checks remain in the continue-code decoder.

Each conditional branch updates the argument before a single final
return. IDO places the first three returns in branch delay slots while
retaining the last decrement in the argument register. All instruction
words, including those scheduling details, are compared. The
[provenance ledger](continue-character-provenance.json) records the source,
compiler, transitive inputs, complete procedure bounds, and linked bytes.

Robotron's instructions and matching encoder establish the behavior.
All thirteen requested local and online N64 references, their pinned
revisions, and licenses remain in [CREDITS.md](../CREDITS.md). Further menu
and scene recovery remains tracked by
[issue #45](https://github.com/frankischilling/robotron64/issues/45) and
[draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
