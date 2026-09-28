# Movie commands and channel packing

The eighteen field, command, and channel helpers at `0x80002F28..0x80003A7C` compile to the complete
2,900-byte target range with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. The three source units each compare with
zero differing words, including their first and last instructions.

| Source | Runtime range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `movie_parameters.c` | `0x80002F28..0x80003040` | 2 | 280 |
| `movie_commands.c` | `0x80003040..0x800037F8` | 12 | 1,976 |
| `movie_channels.c` | `0x800037F8..0x80003A7C` | 4 | 644 |

The target's diagnostic strings identify this group as movie processing:
`Too many movie props`, `Too many priFrames from prop %d`,
`Too many color cycles in movie`, and `Too many Movie strings` occur at
`0x8008F840`, `0x8008F858`, `0x8008F878`, and `0x8008F898`. Function names
remain address labels. Fields whose role is not established retain offset
names in `include/movie.h`.

## Configuration records

The initializer clears the complete `0x72C`-byte configuration referenced by
`D_800B14A8`, sets the identifiers in five pair records beginning at `0x3C`
to `-1`, copies six command
arguments into the header, and resets the recorded counters. The command
handlers use a leading opcode word followed by integer argument words.

Ten `0x68`-byte prop records begin at offset `0x70`. Each contains a signed
16-bit identifier, a packed 15-bit mode and one-bit position flag, three
position words, and two ten-element primary-frame arrays. The prop adder
rejects a count of ten or more through the original diagnostic call. The
primary-frame adder checks equality with ten, calls the diagnostic, and then
continues to the original stores if that call returns. It retains the
original argument values across the call.

The three color-cycle slots consist of parallel word arrays at offsets
`0x484` and `0x490`. Their handler checks a count of three or more before
performing its original stores. The seven `0x1C`-byte string records begin
at `0x668`; their handler checks equality with seven. These checks have not
been broadened or converted into new error returns.

The indexed and color-record arrays have physical extents of thirty
`0xC`-byte records and three `0x14`-byte records between the established
neighboring fields. Three callback records follow the color records at
`0x648`; each contains a function pointer and a frame number. The indexed and color
handlers do not validate their array limits. The color
handler uses the existing four-byte `PaletteColor`, assigns its red, green,
and blue bytes, copies the complete record, and computes its rate from
`abs(0x19000) * field04 / (duration << 8)`. Its fourth color byte is not
initialized by this handler, matching the target's four-byte structure copy.

The final two-word setters and the completion handler retain their target
store order. Completion clears `D_800B1BE0` and sets `D_8009EFB4` to one.

## Constant fields and packed channels

The state pointer at `D_800972A0` selects a `0xCC`-byte track record. The loader's
copy length, twenty-five-record scan, and reset's `0x13EC`-byte clear establish
the complete record extent and pool size. The pool begins at `0x800B00B8`.
Channel indices occupy the first thirteen words, the identifier is at `0x34`,
and the active flag is at `0x74`. Counts and masks occupy `0x78..0x8C`, constant
positions and angles begin at `0x90`, and the integer/float channel pointers
are at `0xC4` and `0xC8`. Unidentified fields retain their byte-offset names.

The integer and float parameter helpers store the incoming value, use `-1`
or `-1.0f` as the initial-value sentinel, and detect a change from that first
value. The first change increments the corresponding variable-channel count
and clears the field's constant bit. The later channel helpers keep an
untracked or unset field as a constant; a tracked field whose constant bit
has been cleared receives the next packed-channel index.

The two packing loops copy one four-byte field from each source frame into
the integer or float channel buffer. Source frames advance by thirteen
words (`0x34` bytes), while destination spacing comes from the caller's
channel stride. A field still marked constant produces no copies. Both
loops reread the shared frame count after the copy call, as the target does.

## Preparation and playback services

The following additional complete units use the same IDO 5.3 O2/MIPS I profile.
Each is compiled and compared independently before integration.

| Source | Runtime range | Bytes | Behavior |
| --- | --- | ---: | --- |
| `movie_reset.c` | `0x80002EE0..0x80002F28` | 72 | Clear the track pool, movie configuration, and active flag |
| `movie_track_release.c` | `0x80003D74..0x80003ECC` | 344 | Release configured tracks and actor animation tracks, then clear resource ownership |
| `movie_sample.c` | `0x80004098..0x80004258` | 448 | Read six position/angle values from constant fields or packed channels |
| `movie_callback.c` | `0x8000440C..0x800044AC` | 160 | Append a frame callback with the original three-slot equality check |
| `movie_prepare.c` | `0x800044AC..0x800045E4` | 312 | Parse movie commands and request the configured camera/text tracks |
| `movie_start.c` | `0x800045E4..0x80004C3C` | 1,624 | Initialize camera selection, text, props, color events, and scene audio |
| `movie_status.c` | `0x80005354..0x8000544C` | 248 | Determine termination from the mode, elapsed frame and repeat count |
| `movie_cleanup.c` | `0x8000544C..0x80005560` | 276 | Restore camera settings, release text and actors, and stop scene effects |
| `scene_audio_request.c` | `0x8001F8E8..0x8001F90C` | 36 | Store the scene's five audio-request arguments |
| `command_machine.c` | `0x800327AC..0x8003282C` | 128 | Enable or disable execution for a script's machine selector |
| `string_resource.c` | `0x800383C4..0x800383F8` | 52 | Resolve an indexed string offset or return null for the `-1` sentinel |
| `palette_tint.c` | `0x800465B0..0x80046608` | 88 | Set three palette-adjustment values and update all 256 entries |

The resource field at offset `0x06` is a signed 16-bit flag word. Its high bit
marks loaded animation tracks. The allocator reads that whole word, while
the release helper clears only its high bit. A two-byte union exposes the
whole value and the one-bit field; IDO emits the target's byte load/mask/store
for the bit assignment. The shared `0x58`-byte resource also contains ten
animation pointers beginning at `0x28`. Its first pointer retains the text
renderer's signed-short object-index view through the same union storage.

Movie start copies each configured three-word prop position as a complete
record. Props without a position receive three zero coordinates. Resource
preloading returns an integer status: the target returns two for an already
loaded resource and one after completing a load. That shared declaration is
preserved even where a caller ignores the return value. The scene audio
call retains its observed extra third argument, which the recovered callee
does not read; its local legacy declaration records that original call shape.

## Script tables and source-owned data

`movie_prepare.c` defines the thirteen handler/argument-count entries at
`0x80078150..0x800781B8`, ROM `0x78D50..0x78DB8`. Each entry is eight bytes.
The complete 104-byte initialized table is linked from C and compared with
the target, including every function relocation and argument count.

`command_machine.c` compiles the eight-case machine switch into the target's
32-byte jump table at `0x8009416C`, ROM `0x94D6C`. Selectors 0, 1, 3, and 5
disable execution; 2, 4, and 7 enable it; other values take the diagnostic
path. The separately emitted success arms retain their actual destinations.
The table is word-aligned, so independent and production linking both preserve
its explicit address even though IDO gives the input section 16-byte alignment.

Exact source/header snapshots and reports remain under `build/sdk-options`
and the private recovery directories. Configuration storage, track buffers,
and diagnostic strings remain externally supplied target data. The larger
movie loader, update routine, camera application, and generic
script interpreter have reconstructed candidates whose remaining differences
are excluded from matching counts until their full comparisons pass.
