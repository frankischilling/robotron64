# Gameplay tweaks and resource strings

The routines at `0x800374D0..0x80038390` manage named gameplay settings. Script
commands define tweak pages and variables, bind the variables to live game
fields, and apply difficulty or level overrides. The neighboring string
routines resolve the names used by that system and other resource loaders.

## Tables and binding

The target has 20 page records of six bytes, 150 variable records of eight
bytes, and 60 difficulty records of six bytes. A page records a title, the
index of its first variable, and its variable count. Each variable has a
signed halfword initial value, a signed halfword string identifier, and a
pointer to its live word. A difficulty record identifies one variable and
holds the adjustments for easy and hard play.

`func_800374D0` clears the table cursors and selectors. `func_80037508` appends a
page, and `func_80037588` appends a variable and increments the last page's
count. The guards and diagnostic order match the target, including the
distinction between equality and a range comparison at the table limits.

`func_8003799C` resolves a name, scans the defined variables, stores the live
target pointer, and writes the initial value through it. A failed lookup emits
the diagnostic only when the target's reporting flag is enabled.
`func_80037A20` performs all 100 named bindings. Its complete 2,056-byte body
matches, including the enemy speeds, spawn timing, weapon settings, enemy and
pickup hit counts, and bonuses. The names come from the target's string region.

The binding calls establish a speed word at resource offset `0x08` and hit or
life values at offset `0x58` in the corresponding extended resources. The
LaserRepeatRate binding takes a word-sized local and then narrows it into the
target halfword. That local is used by the actual API and assignment.

`func_80037700` applies the easy adjustments for difficulty zero and the hard
adjustments for difficulty two or above. `func_80038228` then applies the ten
observed enemy-speed scale adjustments, preserving the target's multiplication
and signed division expressions.

The scene definition holds 25 pairs of signed halfwords at `0xC54`, with the
override count at `0xD00`. Each pair contains a variable index and a replacement
value. Level overrides exempt the five pickup hit-count fields before applying
difficulty and enemy-speed adjustments.

## String table files

`func_80038390` initializes all 1,000 string offsets to `-1`.
`func_800383F8` searches the loaded offsets with the game's case-insensitive
comparison and returns the matching identifier, or `-1` for a null or unknown
name. The existing `func_800383C4` performs the opposite lookup.

`func_80038498` loads the `.OFS` companion first. Its first signed halfword is
the string count; the remaining halfwords are copied into the offset table.
The source advances by one halfword after the count, matching the target's
two-byte header. It then loads the `.STR` companion into the character buffer.
Both allocations are released through the existing platform interface. The
100-byte path buffer and all four-byte return/pointer operations match the
complete 212-byte function.

The neighboring debug text helper at `0x80037420` skips spaces and underscores,
calls the platform character renderer for other bytes, and advances by the
font record's word at offset `0x0C`. Its character parameter retains the byte
conversion present in the target. The context setter at `0x80037408` stores and
returns the supplied context value.

## Verification and pending units

The accepted source units use IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. Full comparisons, transitive input snapshots,
compiler identities, and archived earlier candidates are under
`.local/recovery45-resources`. These units emit no initialized data or BSS;
their tables and diagnostic strings remain named references to the original
data regions.

| Source | Complete runtime extent | Bytes |
| --- | --- | ---: |
| `debug_context_set.c` | `0x80037408..0x80037418` | 16 |
| `debug_text_draw.c` | `0x80037420..0x800374C8` | 168 |
| `tweak_reset.c` | `0x800374D0..0x80037508` | 56 |
| `tweak_page.c` | `0x80037508..0x80037588` | 128 |
| `tweak_define.c` | `0x80037588..0x8003762C` | 164 |
| `tweak_difficulty_apply.c` | `0x80037700..0x800377E4` | 228 |
| `tweak_scene_apply.c` | `0x800377E4..0x800378CC` | 232 |
| `tweak_bind.c` | `0x8003799C..0x80037A20` | 132 |
| `tweak_bind_all.c` | `0x80037A20..0x80038228` | 2,056 |
| `tweak_scale_enemy_speeds.c` | `0x80038228..0x80038390` | 360 |
| `resource_string_reset.c` | `0x80038390..0x800383C4` | 52 |
| `resource_string_find.c` | `0x800383F8..0x80038498` | 160 |
| `resource_string_load.c` | `0x80038498..0x8003856C` | 212 |

Level-override application (`0x800377E4`) now matches all 232 bytes. Its
repeated indexed target reads reproduce the original allocation and memory
access order while preserving the five pickup-field exemptions. The canonical
comparison and procedure-boundary proof are under `.local/recovery67-integration`.

Difficulty-record insertion (`0x8003762C`) and level-override insertion
(`0x800378CC`) remain candidates with register-allocation and scheduling
differences. They contribute no matching source bytes until complete
comparisons pass.

The target establishes these game-specific tables and behaviors. The
[reference credits](../CREDITS.md) record the N64 compiler and SDK sources used
for the workflow. The `include/2.0I/PR/ultratypes.h` header in libreultra was also
checked for its `long`-based 32-bit types. Probes confirmed that changing those
local word spellings did not resolve the remaining instruction differences;
the source retains the established word types. No reference implementation was
imported for these game functions.
