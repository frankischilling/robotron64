# Early session animation and actor counters

Six complete game procedures now compile with the pinned IDO 5.3 game
profile and match all 736 instruction bytes. The reset routine also owns
its complete twelve-byte initialized aggregate. Current comparison inputs,
procedure extents, data placement and ROM hashes are recorded in
[the provenance ledger](early-session-animation-provenance.json).

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_8000E328` | `0x8000E328` | 140 | Clear the transition word and four eight-entry arrays |
| `func_8000E6F0` | `0x8000E6F0` | 48 | Decrement the resource-kind counter and set actor state 2 |
| `func_8000ECE4` | `0x8000ECE4` | 252 | Set animation, replace a callback, and record the current time |
| `func_8000EDE0` | `0x8000EDE0` | 104 | Apply the indexed session record and set session animation state 4 |
| `func_8000F4E0` | `0x8000F4E0` | 132 | Restart the actor service and install the default animation callback |
| `func_80010460` | `0x80010460` | 60 | Retain the aggregate copy and conditionally clear the reset parameter |

## Callback replacement

The fifth argument is stored in `D_800AD1C4` before the animation call.
The animation argument is narrowed to an unsigned byte by the existing
`func_80027AB8` interface. If flag `0x40` is already set, the routine clears
it and invokes the previous callback before installing its replacement.
The callback can change the actor, so the subsequent flag update uses the
reloaded value.

A nonnull callback receives the supplied timer, narrowed to the actor's
short field. A null callback selects `func_8000FBC0` and timer 999. The
comma expression in that default assignment preserves the original IDO
scheduling, as in the already recovered callback installers. Neither path
adds a null check for an existing callback. Both paths finish by copying
`D_8009EFA0` into actor field `0x48`.

The restart routine calls `func_80009F90(actor, 0)` and follows the same
previous-callback replacement rule before selecting `func_8000FBC0` and
timer 999. The larger default callback remains in fallback and is bound to
its original address; recovering its callers does not count its body.

The array reset clears `D_800972C0`, three eight-entry short arrays and one
eight-entry integer array. The loop remains ordinary C; IDO supplies the
four-iteration unrolling found in the target. These external arrays are
not included in this batch's storage ownership claim.

## Session layout

The canonical `GameSessionState` now exposes the index at `0x9C`, state at
`0xA8`, record pointer at `0xB4`, and signed short counters beginning at
`0xB8`. The counter array has 36 entries: initialization at `0x80021874`
clears exactly `0x48` bytes from `0x800AD1F0`, ending where the existing
scene counters begin at session offset `0x100`. The session view extends
through its initialized counter arrays to `0x148` bytes; its saved prefix
remains `0x4C` bytes. The scene, intermediate and random-spawn counter
arrays have eight, eleven and sixteen short entries. Initialization clears
`0x10`, `0x16` and `0x20` bytes at their respective offsets `0x100`, `0x110`
and `0x126`. These spans establish the array bounds and correct the earlier
sixteen-entry scene-counter view.

Record indexing has stride `0xCC`. The wrapper reads the animation word
at record offset `0x0C` and an unsigned byte at `0x15`, then supplies null
callback and zero timer. Remaining record fields retain conservative
names and padding. No record bound or counter floor is added.

## Reset aggregate

`D_800736AC` is the twelve-byte integer aggregate `{20000, 20000, 0}`.
The original routine copies it to an unused stack local before checking
its argument. That copy is retained. The aggregate's role is unresolved;
its values are verified without assigning a gameplay interpretation.
The owned `.data` section ends at `0x800736B8`; compiler alignment bytes
are excluded from the twelve-byte ownership claim.

## References and validation

The local [IDO materials](https://github.com/n64decomp/ido) and
[Super Mario 64 matching build](https://github.com/n64decomp/sm64) remain
the compiler and build references. Robotron's instructions, record reads
and initialization span establish these game-specific layouts. All
thirteen requested reference projects and their recorded revisions are
credited in [CREDITS.md](../CREDITS.md).

Independent complete procedure comparisons, linked storage checks and the
full ROM comparison are required before these additions count toward
progress. The larger session controller and remaining game routines
continue to use fallback; this batch does not establish full game recovery.
