# Scene definitions and arrival commands

The commands at `0x8001F350` through `0x8001F8E8` populate the scene definition
at `0x800B9A78`. They set spawn positions, resource limits, arrival records,
palette cycles, and scene flags. The preceding helpers create category-3 actors
and select the resource file associated with a level boundary.

## Shared layouts

`SceneDefinition` is `0xD14` bytes. Five positions begin at offset zero; their
enable bytes begin at `0x3C`. The arrival array begins at `0x44` and contains
256 entries of `0x0C` bytes. Each entry stores four unsigned bytes for its
trigger, state, resource index, and category, followed by signed halfwords for
delay, count, X, and Y. The live arrival count is at `0xCC8`.

Four palette-cycle pairs occupy the halfword arrays at `0xCB8` and `0xCC0`;
their count is at `0xCFC`. The remaining recovered fields retain offset-based
names where their meanings are not established. Command bodies and their
callers determine every declared field offset.

The resource-state view at `0x800B8F78` includes two 50-entry integer arrays.
The first starts at `0x10`, the second at `0xD8`. The default command fills
them from `0x800B00B0` and `0x800B14A4`, respectively. IDO unrolls the second
loop in groups of four after its first two writes; the recovered source uses
two ordinary loops over the flat arrays.

The live session begins with the existing `0x4C`-byte saved-session prefix.
Sixteen category-3 actor counters begin at live-session offset `0x100`.
`GameSessionState` describes this known prefix and these counters without
asserting the size of the entire live allocation. Save copies continue to
use `SavedSessionState` for their serialized extent.

## File selection and command behavior

The table at `0x800A42B0` contains 80 pairs of level boundaries and filename
identifiers. Its writer, `func_8001CBE8`, stores the boundary before the name
and increments the count at `0x800A4530`. `func_8001F2D8` starts at entry one;
when the requested level lies below that entry's boundary, it resolves the
preceding entry's filename and calls the file hook with mode 2. The retail
file hooks in this region are empty, and their original argument stores and
alignment remain accounted for.

Position commands capture their four arguments before changing the scene
record. X and Y are multiplied by 3,000 and offset by -30,000; Z is multiplied
by 3,000. The positioned-arrival command uses the same X/Y conversion. The
category-specific commands forward the observed category, resource, trigger,
delay, and count to `func_8001FCE4`.

The enemy-arrival command checks the two observed resource ranges against
their count limit, retains both diagnostics, and adds the live bonus count
for the first four enemy resources when trigger 2 is selected. Palette-cycle
insertion checks the four-entry limit and stores both halfwords. The apply
routine invokes the existing palette-cycle function for each recorded pair.

## Background image and palette loading

`func_8001F90C`, at `0x8001F90C..0x8001FCE4`, updates the background image.
Its diagnostics identify a failed background load and an unsupported background
mode. The state at `0x800B8F68` therefore has the name `SceneBackgroundRequest`;
the older `scene_audio.h` and `scene_audio_request.c` filenames are retained.
The 36-byte setter records the resource, flags, display mode, another halfword,
and the scrolling selector.

Flag 2 loads the image palette through `func_800314FC`; flag 1 loads and displays
the image through the platform interface. Mode zero uses the camera angles.
The scrolling path changes its speed according to the game mode, updates an
offset using the unsigned elapsed time, and wraps the horizontal position in a
480-unit range. Modes 9 and 10 use the fixed coordinates observed in the target.
The two source-owned float constants, `0.1f` and `0.6f`, occupy
`0x80091958..0x80091960` and match all eight bytes.

`func_800314FC`, at `0x800314FC..0x80031564`, obtains the palette through two
platform hooks, resets active palette transitions, and uploads all 256 entries
from `0x8009CD18`. Its complete body is 104 bytes. The background update is
984 bytes. Both use the same verified IDO profile as the command handlers.

Some retail platform hooks are empty even though their callers still pass
arguments or use a return register. Their declarations preserve those call
shapes, and the empty bodies retain the target instructions. An invented
return value would change the original behavior. The complete platform source
units were rechecked after correcting these declarations.

## Arrival insertion candidate

`func_8001FCE4` spans `0x8001FCE4..0x80020134`, or 1,104 bytes. Its ordinary-C
candidate covers trigger normalization, optional random delay, duplicate
arrival handling, insertion with an overlapping move, capacity reporting,
and coordinate conversion. The public candidate at `src/game/scene_arrivals/insert.c` has 55 differing
instruction words and remains outside the matching manifest and ROM link.
The [arrival audit](scene-arrivals.md) checks 3,713 paired executions and nine
source/message mutations; the complete scene BSS and diagnostic data are owned
separately.

Trigger 4 chooses a random delay after enforcing a minimum argument of 100;
trigger 1 scales the supplied delay by 100. Count and delay are checked with
the target's unsigned `0x8000` bound. In replacement mode, insertion can shift
later entries and mark subsequent duplicates with state 2. The ordinary path
uses the first empty entry and checks preceding entries for a duplicate.

For an immediate state-1 arrival, category zero obtains its default delay
from offset `0x64` in the `0x68`-byte resource record and divides it by 100.
Category 3 uses a delay of 10. The final X/Y stores preserve -1 as a sentinel
and otherwise divide by 256. Capacity checks remain in the order observed in
the target; the candidate does not add new range checks or alter the move.

## Verification and references

Accepted units use IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. Each complete source unit is compiled,
linked at its target address, and checked for code, function boundaries,
unexpected data/BSS, and current source/header/compiler identities before
integration. `config/functions.json` is the authority for accepted functions.
The command handlers and palette loader own no data or BSS. The background
update owns the two float constants described above.

Private target bodies, caller evidence, compiler reports, and archived input
snapshots are in `.local/recovery40-scene`. The related actor layouts are
described in [actor resources](actor-resources.md) and the serialized prefix
in [save data](save-game.md). The N64 compiler and decompilation references
are credited in [CREDITS.md](../CREDITS.md); Robotron's target supplies the
scene-specific structures, constants, and behavior.
