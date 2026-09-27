# Text run properties

Three functions in `src/game/text_properties.c` match all 776 bytes at ROM `0x1FD0..0x22D8` using pinned IDO 5.3 and the normal project flags.

| Function | Bytes | Behavior |
| --- | ---: | --- |
| `func_800013D0` | 300 | Apply successive property bytes to numeric runs and count those runs |
| `func_800014FC` | 316 | Apply indexed property entries to non-space runs and count all runs |
| `func_80001638` | 160 | Store a record property and apply its low byte to every valid glyph object |

`TextRunProperty` records the four-byte layout used by the first two routines: a signed 16-bit run index at offset zero, an unidentified byte at offset two, and an unsigned property byte at offset three. The numeric routine uses only the final byte and advances by array index. The non-space routine also reads the signed index. The property's visual meaning remains unverified; these routines call `func_80039E80` rather than implementing rendering themselves.

## Numeric runs

Numeric bytes are ASCII `0` through `9`, or encoded bytes `0xAA` through `0xB3`. Adjacent bytes from either range belong to the same run. For each numeric byte with a nonnegative object index, the function applies `properties[run].value`. A nonnumeric byte ends an active run and increments the run counter. The return value includes an unfinished final run, including when its objects were invalid. Negative record indices return zero.

## Indexed non-space runs

Only byte `0x20` separates runs. Every other byte counts as part of a run. For valid objects, the property is applied only when the current run number equals the current entry's signed run index. At the end of a selected run, the property pointer advances by four bytes; the run count advances at the end of every run. The function returns the total number of runs, not the number of entries applied. It does not receive an entry count or check an end marker. Callers' array ordering and termination conventions remain to be established.

## Whole-record property

For a nonnegative record index, `func_80001638` stores the complete integer argument at record offset `0x64`, even if the text is empty. It then applies the argument converted to an unsigned byte to every nonnegative glyph object index. Negative record indices do nothing. The original routines do not validate an upper record bound.

## Integration

The compiled section occupies RAM `0x800013D0..0x800016D8`; CPU fallback resumes at ROM `0x22D8`. The padding tool removes eight zero alignment bytes after the last symbol without changing instructions. This separate object is a build choice, not evidence of an original translation-unit boundary.

Linked-byte comparisons and input-object-symbol checks verify all three functions' addresses and sizes. Full-ROM comparison matches all 8,388,608 bytes, and all nine tooling tests pass. Matching C increases from seventeen functions / 3,356 bytes to twenty functions / 4,132 bytes. The unresolved text replacement routine remains fallback; whole-game code totals remain unknown.
