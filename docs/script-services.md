# Script services

This recovery covers the uncovered runtime functions from `0x8001C0D0` through
`0x8001CF68`. The target separates the range into four 16-byte-aligned code
objects. The padding gaps are `0x8001C734..0x8001C740`,
`0x8001CB48..0x8001CB50`, and `0x8001CD94..0x8001CDA0`.

The comparison profile is IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. The compiler SHA-256 is
`76d796c9591c9f5504949f85b29c32a6039a663791afe2f36f34ca18425b64d0`.
The current combined checkpoint is
`.local/recovery46-script/checkpoint.json`; every probe also contains the
complete transitive input snapshot and hashes.

| Source | Target range | Bytes | Current proof |
| --- | --- | ---: | --- |
| formatter target evidence | `0x8001C0D0..0x8001C734` | 1,636 | source still unresolved |
| `script_service_cache_reset.c` | `0x8001C740..0x8001C790` | 80 | 80/80, zero differing words |
| `script_service_files.c` | `0x8001C790..0x8001C8C4` | 308 | 308/308, zero differing words |
| `script_service_cache_access.c` | `0x8001C8C4..0x8001CB48` | 644 | 644/644, zero differing words |
| `script_service_commands.c` | `0x8001CB50..0x8001CD94` | 580 | 580/580, zero differing words |
| `script_service_platform.c` | `0x8001CDA0..0x8001CE70` | 208 | 208/208, zero differing words |
| `script_animation_resolve.c` | `0x8001CE70..0x8001CF68` | 248 | 248/248, zero differing words |

The exact command source SHA-256 is
`586ce10bb876408bd5f2ed35d75a034c96e59641d83191dfcf6fd0868512dda0`.
The exact platform-service source SHA-256 is
`baccfdc7e64c0ede0bc6874c48c403c4be39b137aa2491e7419ee504113cfeec`.
The shared internal header SHA-256 at this checkpoint is
`dbd1c1e75788351372596698cb05a80eb9698897a63a0e545555ad1783e25398`.

## Diagnostic formatting

`func_8001C0D0`, `func_8001C2C4`, and `func_8001C49C` receive a format-string
pointer directly. They are variadic formatters, not string-ID services. The
first two consume promoted arguments from the incoming argument home area and
recognize `%C`, `%c`, `%s`, `%d`, and `%x`. `%C` and `%c` both copy the low
byte of the promoted word. `%d` uses `func_8003B928` with base 10, `%x` uses
base 16, and `%s` copies the complete source string. An unrecognized
specifier contributes no output character.

`func_8001C0D0` prefixes the completed text with `FATAL ERROR: ` and then calls
the fatal reporter with `FATAL ERROR: %s %s %d\n`, the completed buffer,
`errors.c`, and line 77. `func_8001C2C4` prefixes the completed text with
`WARNING: `. `func_8001C49C` writes only the completed formatted text.

All three use a 500-byte output area. `func_8001C49C` places it at stack
offset `0x54` in a `0x248`-byte frame. The two diagnostic variants place it
at offset `0x254` in a `0x448`-byte frame. The extra `0x200` bytes in those
two frames are not referenced by target instructions. No ordinary source
evidence has established what source declaration caused that allocation, so
no dummy local was added to force an exact frame.

`func_8001C49C` also accepts `%2d`, `%3d`, `%4d`, and `%5d`. Those forms set a
decimal padding selector and insert leading spaces by moving the existing
string one byte to the right until its length is greater than that selector.
For example, `%2d` produces at least three characters. The target dispatches characters `0x32..0x43`
through an 18-entry, 72-byte jump table at `0x80090460..0x800904A8`:
`2`, `3`, `4`, and `5` select their respective widths, `C` selects the
character path, and the remaining entries select the default path. The
formatter source and that table remain unresolved rather than being
reconstructed with artificial control flow.

## Scripted-file records

The scripted-file table begins at `D_80097650` and ends at `D_8009A850`.
The `0x3200`-byte span and every indexed access establish 100 records of
`0x80` bytes. Indexed access shifts the handle by seven bits, while the scans
advance by `0x80`.

The flags word is at offset `0x00`. Target sign tests use bit 31 for the
registered state and a left shift followed by a sign test for bit 30, the
loaded state. The load size is at `0x04` and the allocated file address is at
`0x08`. Filename operations use offset `0x0C`; path operations use offset
`0x1A`. Those independently observed starts and the `0x80` record stride give
structural byte extents of 14 bytes for the filename field and 102 bytes for
the path field. These extents describe the record layout; they do not imply
that every producer enforces those lengths.

`func_8001C740` clears the registered bit in all 100 records. IDO unrolls the
simple loop four records at a time. It is independently exact in
`script_service_cache_reset.c` over all 80 target bytes. The source SHA-256 is
`62eaa169bfbe20e002a279724bfe6ff0dd32bd4bbec838717d4cbcc1e1b1a14f`.

`func_8001C790` takes a path, finds the basename after the last backslash,
checks existing registered names, then fills the first free handle with the
basename and full path. A full table returns `0xFFFF`. The complete 308-byte
function matches with a bounded `for` loop and three meaningful local
variables. That source produces the target's `0x30` frame and both scan
loops. The independent comparison checks the full procedure boundary and
all bytes; its frozen source and transitive headers are recorded under
`.local/recovery51-integration/ready-checkpoint`.

`func_8001C8C4`, `func_8001C968`, `func_8001C9FC`,
`func_8001CA78`, and `func_8001CAF4` form the complete contiguous
`0x8001C8C4..0x8001CB48` service group. They find a handle by basename, load
a registered file once, return a loaded address, free loaded data, and finally
delete the registration respectively. `script_service_cache_access.c` is
independently exact over all 644 target bytes. Its source SHA-256 is
`7cb62e0e488a9d9832784809c7b61b5181ebe7807ae59b80d84141deba0d18cb`.
Only `func_8001C790` remains in `script_service_files.c`; the original
1,032-byte combined candidate is preserved under
`.local/recovery46-script/checkpoint-source/src/game/script_service_files.c`.

## Script setup commands

`script_service_commands.c` is exact over the complete
`0x8001CB50..0x8001CD94` object. `func_8001CB50`, `func_8001CBB0`, and
`func_8001CCC0` resolve a string resource from command argument 1 and invoke
the command parser with `D_80078060`, `D_80078040`, and `D_80077E80`.
`func_8001CB50` also brackets the tweak reset with `D_800781C0`, sets
`D_8009EE04` to `-1`, and then parses the selected script.

`func_8001CBE8` appends an eight-byte scene-file boundary record. Its limit
is 80 and its diagnostic is `too many BFFs`. The record stores the current
level count followed by command argument 1. `func_8001CC5C` appends command
argument 1 to the level-name table, with a target limit check of 220 and the
diagnostic `Too many Levels defined\n`.

`func_8001CCF8` is an empty one-argument handler, while `func_8001CD00`
sets `D_8009EFB4` to one. `func_8001CD14` is an empty no-argument helper.
`func_8001CD1C` loads `STRINGS.STR`, calls that helper, and parses its input
through `D_80077EB8`. `func_8001CD60` resets both script counters and then
resets tweak and string-resource state.

The target strings used by this object begin at `D_80090690`,
`D_800906A0`, and `D_800906BC`. The candidate references the existing target
symbols and emits no `.rodata`, `.data`, or `.bss`; the comparator confirms
there is no undeclared source-emitted data section. Historical object
ownership of those neighboring target string bytes has not been claimed
without a source/data-boundary proof.

## Platform rectangle service

`func_8001CDA0` constructs two local coordinate pairs and calls
`func_8003C60C` four times for the four rectangle edges. The target calls
`func_8003C60C` with five arguments: two point pointers, the incoming value,
zero, and zero. The shared declaration therefore needs unspecified arguments
for the existing empty retail stub, which has been confirmed separately.

The target places the two point-record starts 12 bytes apart. The independently
exact stack layout and the callee-facing pointer stride establish a three-word
record even though this caller initializes only `x` and `y`; the third word is
therefore retained as `unknown08` without assigning it a speculative role.
That layout makes `func_8001CDA0` exact across all 200 bytes. The adjacent empty
`func_8001CE68` remains in the same source object, bringing the complete
platform-service comparison to 208/208 bytes with zero differing words.

## Animation resource path resolver

`func_8001CE70` resolves the animation identifier at offset `0x08` into a
100-byte path buffer, applies the target extension rules, and passes the path
through `func_8003CB10`. A nonnegative identifier stores the returned handle
at `ActorAnimation.loopIndex`; a `-1` result emits the retail diagnostic. For
negative identifiers, `-2` leaves the loop index unchanged and other values
copy the caller-supplied reference. The implementation reuses the established
`ActorAnimation` and `TextGlyphResource` layouts and matches the complete
248-byte target range with zero differing words.
Its current-source and canonical-comparison hashes are recorded in
[`script-animation-resolve-provenance.json`](script-animation-resolve-provenance.json).

The exact cache reset proof is
`.local/recovery46-script/probes/script_service_cache_reset-5.3-O2-mips1/report.json`.
The exact cache access proof is
`.local/recovery46-script/probes/script_service_cache_access-5.3-O2-mips1/report.json`.
The split comparison summary is
`.local/recovery46-script/cache-split.json`.
The exact command proof is
`.local/recovery46-script/probes/script_service_commands-5.3-O2-mips1/report.json`.
The exact platform proof is retained under
`.local/recovery46-script/archive/script_service_platform-5.3-O2-mips1`.
The complete registration proof is
`.local/recovery51-integration/probes/script_service_files-5.3-O2-mips1/report.json`.
The earlier two-word-point residual remains preserved in the recovery archive
as a record of the layout inference.
