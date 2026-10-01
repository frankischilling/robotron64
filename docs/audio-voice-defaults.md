# Audio voice defaults

`func_8005362C` covers `0x8005362C..0x800538F8`. Its complete 716-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. The source is
`src/game/audio_voice_defaults.c`. It emits no initialized data or BSS.

The routine takes an eighty-byte `AudioVoice`, a twelve-byte
`AudioSequenceTrack`, and optional twenty-byte `AudioProperties`.
The caller indexes tracks with a twelve-byte stride and passes the
same track to the matching sequence-binding helper. The sequence loader
and binding helper independently establish the twenty-byte header,
label count at `0x0E`, command-byte count at `0x10`, and track pointers.

The recovered first fourteen header bytes contain category, a byte
parameter, two signed short properties, two byte parameters, one opaque
byte, control mask, and two signed short properties. The named fields
replace the existing opaque prefix without changing any offsets or the
header's size. They remain conservative names for confirmed accesses.

Initialization sets `flag80` and `pedalReleased`, clears `flag08`,
`flag04`, and `commandRedirect`, selects backend one, and clears the
hardware voice count and three working words. It resets the return-stack
cursor from the stored address at `0x3C`, copies the category, timing
property, label count, command-byte count, and control mask from the
header, and then applies defaults or overrides.

The optional field mask selects overrides at bits `0x01`, `0x02`,
`0x04`, `0x08`, `0x20`, and `0x100`. Unselected fields come from the
sequence header. Bit `0x10` tests the selected bit of the voice's control
mask and sets or clears `flag40`. The routine always recalculates
`property1C` through the matching short-valued timing functions.
Bit `0x40` supplies an offset from the cleared position and sets
`flag08`; otherwise that flag stays clear. Bit `0x80` controls `flag04`.
The routine preserves the individual flag stores and their order.

The original signed short loads, unsigned property load at `0x0C`,
variable shift, pointer reloads, nested tests, timing calls, and
40-byte stack frame all match. The
[provenance ledger](audio-voice-defaults-provenance.json) records the
source, complete bounds, compiler inputs, and linked instruction bytes.
All thirteen requested N64 references, pinned revisions, and licenses
remain in [CREDITS.md](../CREDITS.md). Further audio recovery is tracked
by [issue #34](https://github.com/frankischilling/robotron64/issues/34)
and [draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
