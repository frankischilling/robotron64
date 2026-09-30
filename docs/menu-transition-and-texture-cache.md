# Menu transition and texture file cache

Two complete game procedures match all 292 instruction bytes. Their source
owns eight initialized bytes and 2,152 BSS bytes. The pinned IDO 5.3 game
profile, complete procedure extents, storage symbols and full ROM hashes
are recorded in [the provenance ledger](menu-transition-and-texture-cache-provenance.json).

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_800278AC` | `0x800278AC` | 148 | Start a menu transition or perform immediate cleanup |
| `func_80042830` | `0x80042830` | 144 | Load a changed texture file and submit its cached image |

## Menu state

The existing menu state is a complete 100-byte view at `0x800AEE98`.
Its reset routine clears exactly `0x64` bytes. The transition routine
confirms three remaining fields: the restore-camera flag at `0x58`, the
release-preview flag at `0x5C`, and a `void (*)(void)` callback at `0x60`.
Existing session callers supply actual callbacks through the established
`save_game.h` interface. The state now has a source-owned BSS definition;
the shared view retains its size and every existing field offset.

An absent menu skips the transition. A present menu stores the callback
first. A null callback invokes `func_8002606C` immediately with the two
cleanup flags. A nonnull callback updates the selected text slot with
flag `0x100`, sets transition state 1, saves both cleanup flags and the
current `D_8009EFA4` timestamp, and calls `func_800315E4(4)`. No additional
selected-node check or callback invocation is inserted.

`D_800AEEB4` remains the existing word alias for the preview pointer at
state offset `0x1C`. Its cleanup writes are unchanged. Storage ownership
counts the whole state once rather than counting that interior alias.

## Texture cache

`D_800CD3C0` is a 32-by-32 image of 16-bit pixels. The existing texture
submission routine emits the RGBA16 image/tile commands, loads 1,024
texels and sets both tile dimensions to 32. These commands establish the
2,048-byte image layout. The selected file index at `0x800CDBC0` immediately
follows it, giving a complete 2,052-byte BSS definition. A size assertion
checks the image layout, and the linked verifier checks both symbol
placements and the complete section extent.

The initialized cache index at `0x8007CD8C` starts at -1. Its adjacent
counter at `0x8007CD90` starts at zero. Together they own eight `.data`
bytes. Every call with port 0 button mask `0x2000` set increments the
counter; the routine does not add button-edge detection.

A changed selected index loads its named file into the image buffer using
`func_8004EE9C`. The selected index is read again after the load and saved
as the cache index. The image address is submitted through `func_800463E8`
on every call, including calls that skip loading. Existing file indices,
loader results and buffer bounds receive no new checks.

## References and validation

The local libreultra `include/2.0I/PR/os.h` button definitions and the
Super Mario 64 GBI definitions provide N64 controller and RDP references.
The recovered Robotron texture commands and menu initialization determine
these layouts. The recorded [libreultra](https://github.com/n64decomp/libreultra)
and [Super Mario 64](https://github.com/n64decomp/sm64) revisions, together
with all other requested projects, are credited in [CREDITS.md](../CREDITS.md).

Both units include complete independent code and storage comparisons.
All existing callers and shared-header users are recompiled, and the full
ROM must remain exact. Pixel assets and the filename table remain extracted
or unowned input; this source defines the runtime cache rather than any
commercial texture payload.
