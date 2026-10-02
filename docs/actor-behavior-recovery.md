# Actor behaviors and spawn callback

Five complete actor procedures replace 5,328 fallback instruction bytes.
Their sources in `src/game/actor_behaviors/` match the US retail ROM with
pinned IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`. The hulk procedure also
owns its complete 40-byte compiler-generated switch table. A separate source
owns the 28-byte hulk diagnostic string, bringing new initialized ownership to
68 bytes. These sources emit no BSS.

| Function | Complete VRAM range | Instruction bytes | Source |
| --- | --- | ---: | --- |
| `func_8002AF2C` | `8002AF2C..8002B31C` | 1,008 | `duration.c` |
| `func_8002C0AC` | `8002C0AC..8002C4AC` | 1,024 | `hulk.c` |
| `func_8002CB48` | `8002CB48..8002CF24` | 988 | `brain.c` |
| `func_8002D3D4` | `8002D3D4..8002D918` | 1,348 | `spawn.c` |
| `func_80029760` | `80029760..80029B20` | 960 | `spawn_callback.c` |

## Resource duration

The 92-byte resource view retains the unsigned kind byte at `02` and signed
duration word at `58`. The shared actor layout establishes the clock origin
at `48`, movement at `2C`, movement target at `54`, heading at `08`, motion
components at `6C`/`70`, and state byte at `21`. These names describe the
routine's accesses; the same storage has other uses in neighboring callbacks.

Initialization for resource kind one selects object mode three. The function
subtracts the actor's clock origin from `D_8009EFA0` and compares that unsigned
elapsed value against the resource duration. Reaching the duration sets state
two and returns.

Kind three maps elapsed time to five phases, caps the signed phase at four,
and passes its low byte to the object helper. Kind two fades movement using
signed division, recomputes both motion components, updates the object heading,
then falls through to kind one's elapsed-to-256 progress calculation. It
rereads the resource duration and clock after helper calls. The default path
ramps movement during the first 100 ticks and then holds the configured target.
An already equal movement value leaves the motion and heading unchanged.

The source retains unsigned comparisons and progress division, signed movement
division, signed trigonometric products, and truncation toward zero for division
by 4,096. Replacing repeated resource reads with cached values changes the
target instructions. IDO emits the target division traps.

## Brain behavior

The brain procedure increments actor `54` by ten times the tick delta and uses
the sine helper to vary object scale. Resource kind eleven selects divisor six;
other kinds select three. Animations one and five return immediately, while
animation four returns to animation zero after 3,001 elapsed ticks.

The normal path finishes an active movement blend or periodically starts one
from the resource speed and signed range at `10`. It selects either a signed
random heading or a heading masked with `FC00`, then advances the blend with
`D_800B00AC`. The boundary expressions use logical negation of the X/Y position
words. The original instructions use `sltiu position,1`; the source preserves
that observed behavior.

After the unsigned elapsed time exceeds `D_800B00A0`, the routine stops motion,
selects animation five, calls any active previous callback, and installs
`func_80029B20` with timer four. Both trigonometric calls remain when their
products are zero. Callback flags are cleared before the previous callback and
reread afterward. The elapsed local and logical-negation expressions reproduce
the target register allocation and scheduling.

## Hulk behavior and switch table

Initialization chooses a signed random frame remainder and heading, restores
resource movement, and updates the object heading. Animation zero handles the
150-tick movement pause, active blending, and periodic target selection.
The routine retains the flags read before the random gate and refreshes them
after a successful random call. A nearest-actor result selects a random heading;
an empty result falls back to the active player. Game states four and seven
reverse a player-directed heading by XOR with `800`.

Animation three zeroes motion while retaining both trigonometric calls.
Animations one, four, and nine return without further work. Other values call
the hulk diagnostic with the animation value. Its literal string occupies
`80093988..800939A4` and is defined in `diagnostics.c`. A scalar X difference
preserves the target argument evaluation and 56-byte stack frame.

The ten-entry table occupies `80093A1C..80093A44`, corresponding to ROM
`9461C..94644`. All entries are generated from the C switch and compared after
linking at their original address. The compiler emits eight additional zero
padding bytes; the owned-section tool checks and removes that padding. Only
the forty live table bytes count as initialized-data recovery.

## Spawn behavior and callback

The spawn behavior initializes a signed random heading and resource movement.
Animation four returns to animation zero after 3,001 ticks. Animation five
ramps object scale for 200 ticks before restoring full resource scale and
animation zero. The ramp preserves unsigned multiplication and conversion to
float; its full-scale path preserves signed conversion.

An active movement blend advances with `D_800B14AC`. Flag two reverses the
heading and restores motion. Otherwise initialization or a successful periodic
gate starts a blend with a signed random quadrant heading. The source caches
the tick delta, refreshes it after random calls, and retains its resulting
lifetime across the remaining create checks.

After 4,001 ticks since the session timestamp at `68`, a separate resource
period at `58` can select animation two and install `func_80029760` with timer
nine. The sum of counters five and six must remain below `D_800AC978`. Actor
kind twenty-four also has a separate 1,000-value random gate that creates a
child from `D_8009F928`, zeroes its Z position, and invokes sound 63.

The callback handles resource kind twenty-four by checking `D_800C8B7C + 1`
against fifty and creating actor kind thirty-three or thirty-four. A successful
child receives a signed random heading and full resource movement before sound
99. Other resource kinds choose one child, or two for kind twenty-two, from
92-byte resource records five and six. Capacity is checked before every child.

Each allocated child selects animation six and replaces its previous callback
with `func_80029210`. Its heading derives from the parent's heading and loop
index, with an additional quarter turn for resource kind twenty-two. Difficulty
zero scales movement by four tenths. Resource record five receives the existing
drawing helper address at actor offset zero; the parent is stored at `3C`.
Resource kind twenty-three retains the existing no-op service call. The parent
finally reinstalls `func_80029210` with timer 999.

Private resource and prefix types record the 92-byte stride, signed period,
session timestamp, and four-byte helper pointer. Unknown fields retain padding.
The callback's resource-kind local, positive-count loop test, conditional
expression order, and flag lifetimes reproduce the target's 88-byte stack frame
and complete instruction sequence. Neither procedure emits initialized data
or BSS.

`func_8001AF44` now declares its returned actor pointer. The callback consumes
`$v0` and reads the child's observed actor fields. The creator itself returns
the allocation result in the target. Both previously accepted callers that
ignored the return remain exact after this shared declaration changes. The
creator's unrecovered body remains outside source-matching totals.

## Object scale setter interface

`func_800399E4` now has a `void` declaration and implementation. Its previous
pointer return type was provisional: the setter already needed the transform
pointer in `$v0` for its stores, and the examined callers did not consume a
returned pointer. The brain caller supplies additional compiler evidence: a
pointer-return declaration leaves four different selector-register words, while
`void` reproduces every word.

The revised setter accesses the object array directly and retains the same
scale conversion and stores. Its entire 1,976-byte transform source unit still
matches, as do the eight previously accepted source units that call it. Other
setter return declarations remain subject to the limits described in
[object transforms](object-transforms.md).

## Ghidra analysis and verification

Ghidra MCP reuses the verified `robotron64.elf` program and imported actor types.
Every loaded byte in the 454,720-byte provisional CPU range is compared directly
with the original ROM before analysis. The duration, brain, hulk, spawn behavior,
and spawn callback extents contain 252, 247, 256, 337, and 240 instruction words
respectively.

The original ELF import omitted the hulk table's fallback data. Loading its
verified forty bytes, applying an unsigned-word array type, and adding computed
jump references from the actual `jr` at `8002C1D4` restores the complete switch
body. The table load at `8002C1CC` has a read reference. All unique destinations
lie within the complete procedure. The project retains the corrected flow and
typed function prototypes after saving.

The duration decompiler's generic 88-byte resource view represents offset `58`
as a second array element. The dedicated 92-byte view records the observed word
without changing the shared actor layout. Decompiled output guides recovery;
full ROM instructions and linked comparisons establish matching.

The [provenance ledger](actor-behavior-provenance.json) records source and header
hashes, layout inputs, compiler identity, complete instruction/data comparisons,
Ghidra byte checks, and clean full-ROM verification. Existing tooling tests and
all independent runtime, startup, assembly, and data comparisons run again for
the combined change. Remaining actor work stays tracked in issue #40.

The local SM64 Makefile supplies the established IDO matching-build reference.
Ghidra and Ghidra MCP provide interactive analysis. The pinned references are
recorded in [CREDITS.md](../CREDITS.md). No reference game implementation was
copied into these routines.
