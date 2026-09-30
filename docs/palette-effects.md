# Palette effects and script commands

The effect system uses one hundred `0x34`-byte transition records at
`0x8009D120..0x8009E570`. Each record contains a palette index, an active bit,
seven mode bits, a step, two source indices, a position, a phase, six integer
color components, and the original four-byte color. The allocator and update
loops establish the record stride and pool extent. `include/palette_effects.h`
records that layout and checks its size at compile time.

Transition configuration records are `0x18` bytes, with six word fields in
the same order as the allocator's arguments. Eight-byte range records select
a first configuration and a count. The script handlers populate these two
tables and the source-color table.

## Matching controls and range application

Four complete fade controls at `0x80031564..0x800316AC` match all 328 target
bytes in `palette_fade_controls.c`. They clear the fade position, configure
the two signed fade directions, or copy a requested color and position. The
configuration routine clears the step while performing the initial update,
then stores the requested step and returns the resulting position. The
direction wrappers retain division by the duration shifted left eight bits.

The 52-byte reset at `0x80031C10..0x80031C44` clears the configuration count
and all 5,200 bytes of transition storage. `palette_transition_range.c`
matches the complete 648-byte function at `0x80031C44..0x80031ECC`. A nonzero
release mode visits active records, blends their saved colors when a fade is
active, and clears the active bit unless the mode is two. A nonnegative range
then starts each configured transition through the original six-argument call.
The two loops use their observed table indices; the range count is reread
after each call.

## Matching command units

The five complete handlers in `palette_commands.c` occupy
`0x8003237C..0x80032534`, a 440-byte range. IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32` produces zero differing instruction words.

The color handler reads a palette index and three component values. Its
argument order is green, red, blue. It writes the color before checking the
index against 551 and invoking the original diagnostic. The range-header
handler checks its index against 31, selects the range, records the current
configuration count as its start, and clears its length. The transition
handler checks the configuration count against 550, writes all six input
words, and increments the current range length and global count. These
checks retain the target's comparisons and behavior after diagnostic calls.
The remaining handlers are an empty command and a command that sets the
script-stop flag.

The separate `command_enable.c` function at `0x80032540..0x80032550` sets the
execution flag. Its complete 16 bytes match. The twelve zero bytes between
the stop handler and this function are alignment padding and are not counted
as a recovered function.

`game_number_convert.c` covers the complete 252-byte function at
`0x80032550..0x8003264C`. It writes zero directly, records the sign of a
negative input, collects at most ten remainder digits, and copies them in
reverse order to the destination. Each remainder is added to `'0'`; the
routine does not substitute alphabetic digits for larger bases. It retains
the target's signed arithmetic and original handling of exceptional inputs.

These units own no initialized data or BSS. Their complete comparisons and
source/header/compiler hashes are retained under `build/sdk-options`.

## Transition candidates

The recovered transition allocator and update sources are still checked
independently before admission to matching progress. The target
supports four update paths: interpolation, two arithmetic palette-index
cycles, and a cycle through an index table. It restores or blends the original
color when a range is released. Position arithmetic includes the original
shift/divide normalization and wrap/reflection behavior.

The update routine marks changed colors and uploads each changed entry's
contiguous suffix. It does not skip the remaining entries of a suffix after
uploading it. The fade update computes a local 256-color buffer without a
palette-upload call in its target body. These observed behaviors are preserved
in the candidates.

Original candidates, full target-function boundaries, callers, and later
source-level comparison records are kept under `.local/recovery29-palette`
and `.local/recovery27-movies`. The ROM remains the authority for this game
code; the reference projects and tools used by the recovery are credited in
`CREDITS.md`.
