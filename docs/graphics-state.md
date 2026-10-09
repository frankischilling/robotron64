# Renderer state, lighting, and buffer accounting

This family reconstructs the renderer helpers at `0x800464F4..0x80047568`.
The recovered code emits display-list commands through the existing
`FrameCommand` and `FRAME_COMMAND` definitions, updates the directional-light
table, and accounts for display-list storage and vertex indices. Complete
comparisons use IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.

The accepted batch contains 30 complete functions, 3,916 code bytes, and
340 bytes of strings and generated tables. The tile-mode helper
`func_80046C2C` later matched all 204 instruction bytes and is now included
in current progress. [Setup storage](renderer-setup-storage.md) separately
owns both complete packet lists, four mutable defaults, and fourteen cache
and arena words; its finite execution checks cover the matching consumers.

## Display lists and render modes

`func_800464F4` terminates the current display list. `func_80046518` appends a
call to another display list without converting the caller's address. Both
advance `D_80138254` by one eight-byte command.

The helpers from `func_80046608` through `func_80046C2C` emit fixed sequences
of geometry-mode, combiner, render-mode, and texture commands. Their command
words are retained explicitly because the game distinguishes combinations
that otherwise look very similar. The separate packet scope in
`FRAME_COMMAND` preserves each cursor update and both command-word stores.

`func_80046C2C` also emits a tile rectangle using the signed word fields at
renderer-state offsets `0x180` and `0x184`. It adds `0x7C` to each coordinate
for the lower-right corner and masks every packed coordinate to twelve bits.
`GraphicsTileState` describes only that observed prefix; the preceding
storage has no inferred field meanings.

`func_8004729C` avoids redundant mode changes. Leaving mode 18 first disables
alpha comparison, then every actual transition emits a pipe sync and updates
the current mode. The original 24-entry switch table covers modes 1 through
24. Only ten modes have distinct cases; the remaining table entries use the
default setup. The compiler-generated table belongs to this source and must
match along with the entire function.

`func_800474B8` caches the environment alpha value and emits a black
environment color when that value changes. `func_800474F8` emits a supplied
RGB environment color with alpha 255, then selects mode 17. An all-zero RGB
input leaves the state unchanged, as in the target.

## Directional lights

`D_80123B28` is indexed in 16-byte records. Each light has three color bytes
at offset zero, their duplicate at offset four, and signed direction bytes
at offset eight. The recovered union supplies the format's doubleword
alignment without adding storage to any function's stack frame.

`func_80046CF8` and `func_80046DD0` read packed RGB from `D_8007BF34`.
The former retains its unused first parameter. `func_80046EA8` accepts the
three channel values directly. All three multiply each channel by 380,
shift right by eight, and cap values above 255. They write both color copies
and use `D_8007D5DC`, `D_8007D5E0`, and `D_8007D5E4` for direction. The
target does not apply a lower clamp to the direct-input form.

The lighting calls in `func_800107A0` select palette/light entry `0xBA` and
supply explicit RGB values. The palette-transition caller also uses the
direct-input form, supporting the color-channel interpretation independently
of the SDK layout.

## Resource and buffer lifetime

`func_8004653C` allocates `0x25FD0` bytes and loads
`textures\ROBO64.TGA` into the allocation. `func_80046580` frees that
pointer and clears it. The filename is a source-owned, twenty-byte string
including its terminator; the texture asset itself remains extracted input.

The display-list arena stores 32-bit byte addresses in `D_80126B78` (base),
`D_80126B74` (cursor), and `D_80126B7C` (limit). The accessor returns the cursor, the usage
query subtracts the base, and the reservation helper advances the cursor
before reporting an overrun. It returns the updated cursor even after the
diagnostic call. The initializer allocates `0x19000` bytes, rounds the base
down to an eight-byte boundary, reserves eight bytes at the end, resets the
renderer, and initializes 256 lights. A named `alignedBase` local preserves the
raw allocation store and the target's temporary-register order; the complete
136-byte initializer matches with zero differing words.

The static-vertex counter is limited to 2,000. The dynamic-vertex counter is
limited to 22,000, and its current-frame query returns `-1` after a warning
when usage exceeds 9,800. These limits and names are explicit in the retail
diagnostic strings. The source retains the original strings verbatim,
including their spelling, and owns their complete 224-byte range.

`func_8004717C` snapshots eight frame counters, resets the cached mode, and
chooses a dynamic-vertex starting index of 2,000 or 12,000. The snapshot is
an eight-element word array; entries whose meaning remains uncertain are
kept as indexed counters.

## Reference study and verification

The [`sm64` GBI header](https://github.com/n64decomp/sm64/blob/master/include/PR/gbi.h)
was inspected for the original Fast3D command layout, scoped packet macros,
environment-color packing, and the `Light_t`/`Light` layout. The game's
actual instructions and callers determine the recovered behavior. This work
reuses the project's independently written frame-command abstraction and
does not import an SDK implementation. The broader reference projects and
their pinned revisions remain listed in [CREDITS.md](../CREDITS.md).

Private source, header, compiler, symbol-layout, procedure-size, and
source-owned-section proofs are retained under
`.local/recovery55-prime/probes`, with the accepted integration snapshot in
`.local/recovery57-integration`. The comparison includes every instruction
in each source unit and every declared data section. Candidates enter the
matching manifest only after these complete comparisons pass.
