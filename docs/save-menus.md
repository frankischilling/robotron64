# Save menus

The save-menu code at `0x800305F8..0x800314FC` sits directly after the save-file
helpers described in `save-game.md`. It drives slot selection, reports Pak and
save-file failures through menu pages, applies audio options, converts the
ten-character continue code, and finds the nearest palette color for menu
rendering.

The recovered sources use IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. Matching claims below refer to complete
function comparisons against the US target ROM, including generated switch
tables where a function owns them.

## Slot selection and write prompts

`func_80030798` reloads the save image before writing the selected slot. A
device-state change opens the corresponding error page and clears the cached
status. Otherwise it captures the live session into the selected slot, marks
that slot occupied, writes the save image, and chooses the menu page for the
write result.

`func_800308AC` closes the current selector and returns to the page stored in
`D_800BB220`. `func_800308E8` and `func_80030958` open eight-entry save-slot
selectors with the same select and cancel callbacks; the latter also performs
the write immediately after constructing the selector. `func_800309D0` records
the chosen slot and either opens the occupied-slot confirmation page or writes
an unused slot directly. `func_80030A3C` restores the save-menu root page and
enters the status handler at `func_80030C3C`.

`func_800305F8` restores an occupied save slot and then rebuilds active player
scene state. The current candidate is the complete 416-byte function, with its
remaining comparison differences confined to the saved-register allocation of
the loop limit and step. It remains excluded from matching counts until that
source-level difference is resolved.

## Save-status dispatch

`func_80030A80` calls the save reader with option restoration enabled. A
successful read opens the eight-slot selector. Negative results choose the
appropriate error page; repeated device failures alternate through two pages
using `D_80077C0C`. Its six-entry switch table covers return values `-4` through
`1` at `0x80094084..0x8009409C`.

`func_80030C3C` clears the transient device flag and reads without restoring
options. Successful reads and the recoverable open results enter the slot
selector, checksum/device errors select their menu pages, and repeated device
failures use `D_80077C10`. Its six-entry switch table immediately follows at
`0x8009409C..0x800940B4`.

## Option and code helpers

The audio callbacks operate on the menu selection and the live option fields.
`func_80030EAC` clamps `field04` to the detected maximum with the target's
ordinary ternary expression, resets the selection when that maximum shrinks,
and applies the one-based audio index. The neighboring preview/apply callbacks
update the corresponding live audio globals and call the original audio
service routines.

`func_80030FEC` and `func_80031034` translate a four-bit value to and from the
continue-code alphabet. The two larger routines at `0x80031080` and
`0x800312B0` decode and encode the five packed bytes used by the ten-character
code. Their packed fields include the player level, two option values, a
seven-bit player field, another player value stored in thousands, and a
three-bit checksum.

`func_80031420` compares RGB Manhattan distance against all 256 palette entries.
If the source color's fourth byte is nonzero, it searches from black instead of
the source RGB values. It returns the index with the smallest distance.

## Matching evidence

Strict comparison reports and frozen source/header inputs are stored under
`.local/recovery39-save-menus/probes`. The following units are complete matches
with the compiler profile above:

| Source | Runtime range | Bytes |
| --- | --- | ---: |
| `save_menu_slot_write.c` | `0x80030798..0x800308AC` | 276 |
| `save_menu_cancel.c` | `0x800308AC..0x800308E8` | 60 |
| `save_menu_slot_prompt.c` | `0x800308E8..0x800309D0` | 232 |
| `save_menu_slot_callback.c` | `0x800309D0..0x80030A3C` | 108 |
| `save_menu_open.c` | `0x80030A3C..0x80030A80` | 68 |
| `save_menu_status.c` | `0x80030A80..0x80030DC0` | 832 |
| `save_menu_audio_index.c` | `0x80030EAC..0x80030F20` | 116 |
| `save_menu_sound_preview.c` | `0x80030F20..0x80030F50` | 48 |
| `save_menu_audio_apply.c` | `0x80030F50..0x80030F94` | 68 |
| `save_menu_audio_secondary.c` | `0x80030F94..0x80030FB8` | 36 |
| `save_menu_write_return.c` | `0x80030FB8..0x80030FEC` | 52 |
| `save_menu_palette_index.c` | `0x80031420..0x800314FC` | 220 |

Both status handlers are integrated. Their complete 832-byte text and the
48-byte pair of switch tables match the target. Independent integration proofs
and transitive source/header snapshots are under `.local/recovery40-scene/`.
The continue-code and save-slot-selection candidates remain outside this
public checkpoint until their complete comparisons and integration are verified.
