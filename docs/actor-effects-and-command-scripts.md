# Actor effects and command-script execution

Three complete C procedures replace 1,832 fallback instruction bytes. The
effect configuration and script diagnostics add 1,276 initialized bytes.
All use pinned IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`. Sources are
grouped under `src/game/actor_effects/` and `src/game/command_scripts/`.

| Function | Complete VRAM range | Instruction bytes | Source |
| --- | --- | ---: | --- |
| `func_800366C8` | `800366C8..800369C8` | 768 | `src/game/actor_effects/scatter_spawn.c` |
| `func_80036B00` | `80036B00..80036DC8` | 712 | `src/game/actor_effects/fragment_spawn.c` |
| `func_8003264C` | `8003264C..800327AC` | 352 | `src/game/command_scripts/execute.c` |

## Scatter effects

The scatter helper makes three allocation attempts using resource `D_800B5C30`
and the incoming actor's position. Successful allocations use the existing
`EarlyGameActor` layout and callback at offset zero. Each success consumes
eight RNG values, adjusts the signed integer at offset `48`, selects an angle,
sets vertical motion and lifetime, offsets both horizontal position fields,
and computes sine and cosine motion with independent random scales. It then
updates object heading and retains the two no-op object service calls with
unused arguments three and four. Failed allocations consume no RNG values.
The loop advances after either result.

## Fragment effects

The fragment helper makes five allocation attempts from `D_800B1BE8[kind]` at
the incoming actor's position. Each success installs the same typed callback,
calls the no-op object service with argument four, and consumes five RNG
values for its signed field, angle, lifetime, and horizontal motion. The sine
and cosine components retain their multiply, addition, and signed division
order. An optional two-element
integer impulse adds each component divided by 20. The helper finishes each
success with the no-op object service call passing three. The verified
retirement caller passes kind 190 and a null impulse.

Both functions retain arithmetic right shifts, signed remainders, signed
division truncated toward zero, and signed short field stores. These follow
the pinned N64 compiler and existing partial actor representations. The loop
count locals represent the actual three- and five-attempt bounds.

The subsequent [callback return audit](palette-fade-and-callback-returns.md)
corrects the installed interface to `int(EarlyGameActor *)`: the object loop
consumes its result. The unrecovered renderer body remains in fallback, and
its private reconstruction still differs in two frame-size instructions.
The early and dispatcher parameter views remain incompatible ISO C types;
the audit records the retained historical ABI assumption.

## Effect configuration

`draw_config.c` owns all 31 records at `80072C00..800730D8`, exactly 1,240
bytes. The retail search loop establishes the count and 40-byte stride. Each
record contains eight signed integers, a palette pointer, and a resource
pointer. The header records frame/scale interpolation, height, renderer flag,
and billboard selection fields without changing the callback interface.

All 57 nonnull pointer relocations resolve to the verified targets. Resource
entries use the existing 88-byte glyph and 92-byte actor resource arrays,
converted explicitly to the existing actor resource view. Five resource
entries remain null. The two palette targets stay external. These pointer
views follow the pinned N64 representation; portable aliasing equivalence is
not established. The raw 1,248-byte data section has eight zero alignment
bytes removed. The following source-owned object begins at `800730D8`.

## Command-file execution

The dispatcher changes the caller's filename extension to `.TOK`, loads its
word stream, and checks the raw `-1` sentinel before masking the opcode to
15 bits. An eight-byte `CommandScriptEntry` provides a handler and signed
argument count. A handler runs when present and either execution is enabled
or the masked opcode is zero. The argument count is reloaded after the
callback, preserving changes to the table made during dispatch.

The stop flag is retained on entry. Successful file loading reaches cleanup,
which releases the allocation, clears that flag, and returns one. A missing
file reports the diagnostic and returns zero. The unused mode argument and
the retail's incremented signed halfword counter remain present. Reusing the
raw opcode for its masked value preserves the original temporary lifetimes.
The existing handler type and all five typed callers need no source changes.

`diagnostics.c` owns exactly 36 bytes at `80094110..80094134`: the terminated
extension, three intervening zero alignment bytes, and the terminated load
error. IDO naturally places the second string at offset eight. Twelve trailing
zero compiler alignment bytes are removed; the following `PSX` marker stays
outside this ownership. The procedures themselves generate no data or BSS.

## Validation and remaining work

Validation evidence is recorded in `actor-effects-and-command-scripts-provenance.json`.
The retail ROM and live Ghidra program are the instruction and behavior
references; compiler and source hashes identify the exact build inputs.
Fresh extraction and build match every byte of the 8 MiB ROM. All 151 tooling
tests and independent comparisons pass for 847 runtime, two startup,
eighteen assembly, and 81 data-only units. Ghidra retains the complete typed
procedures, actor/configuration/handler layouts, and verified data references.
Every loaded CPU-range byte remains identical to retail.

This checkpoint contains 1,364 matching C functions and 257,664 instruction
bytes, plus 29,003 initialized and 458,883 BSS bytes. Assembly remains
29 procedures / 4,372 bytes. The provisional CPU interval has 192,532
fallback bytes in 219 ranges and 152 unclassified bytes.
Whole-ROM equality includes extracted fallback ranges. The game is not fully
decompiled, and no complete function or executable-byte denominator has been
established.

The 284-byte damage handler remains private with six differing instruction
words. The 2,208-byte actor handler at `8002DDBC` remains private with 27.
The 524-byte HUD submission routine at `800371FC` is also under study; its
248-byte frame and one-player uninitialized argument require further recovery.
These candidates receive no matching credit.
