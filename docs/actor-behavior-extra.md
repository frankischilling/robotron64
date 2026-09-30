# Additional actor behavior recovery

This batch extends the actor behavior work documented in `actor-behaviors.md`. The accepted checkpoint contains eight complete functions totaling 3,068 bytes of target code. Every accepted function was compiled with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32` and compared against the US baserom over the complete function range. None of these sources owns allocated data or BSS.

## Exact functions

| Function | Range | Bytes | Source | Result |
| --- | --- | ---: | --- | --- |
| `func_8002A414` | `0x8002A414..0x8002A5DC` | 456 | `actor_behavior_blend_velocity.c` | exact |
| `func_8002BF88` | `0x8002BF88..0x8002C0AC` | 292 | `actor_behavior_repeat.c` | exact |
| `func_8002DC20` | `0x8002DC20..0x8002DCB8` | 152 | `actor_behavior_countdown.c` | exact |
| `func_8002DCB8` | `0x8002DCB8..0x8002DD40` | 136 | `actor_behavior_countdown_begin.c` | exact |
| `func_8002DD40` | `0x8002DD40..0x8002DDBC` | 124 | `actor_behavior_countdown_trigger.c` | exact |
| `func_8002B32C` | `0x8002B32C..0x8002B570` | 580 | `actor_behavior_extra_b32c.c` | exact |
| `func_8002B57C` | `0x8002B57C..0x8002B7A4` | 552 | `actor_behavior_extra_b57c.c` | exact |
| `func_8002D918` | `0x8002D918..0x8002DC20` | 776 | `actor_behavior_extra_d918.c` | exact |

The frozen source and complete proof directories are under `.local/recovery55-actors/frozen/first-five/` and `.local/recovery55-actors/frozen/substantive/`. The proof directories contain the linked candidate, disassembly, source and transitive-header snapshots, input hashes, compiler identity, and strict comparison report.

`func_8002A414` blends the actor's previous and current heading while its blend timer counts down. It derives the X/Y motion fields from the interpolated heading and the stored movement values. Its earlier stack-home residual disappeared once the meaningful scalar locals were kept in the target lifetime order.

`func_8002BF88` advances the actor frame, counts down `+0x4C`, and returns the actor to its resource movement when that countdown expires. While active it reinstalls itself as the behavior callback with timer 999. `func_8002DC20`, `func_8002DCB8`, and `func_8002DD40` form a separate short countdown chain that selects animations 7 and 6 before returning to the common callback. Their final five-word residuals were all the same IDO scheduling pattern around flags, callback, and timer stores.

`func_8002B32C` follows the active player actor. Animations 3 and 6 hand the actor's `+0x3C` value to `func_80027A10`; animation 7 adjusts `+0x74` according to the actor's Z position. A 10,001-tick timeout selects animation 1 and installs the common callback. The normal path periodically starts a movement blend from resource `+0x08`, points toward the player with an angle quantized by `0xF00`, and uses the configured turn duration.

`func_8002B57C` initializes a random frame and a coarse heading toward the origin. Animation 4 returns to animation 0 after 3,001 ticks. Its normal movement path uses a 200-tick blend, periodically reads the resource movement value, points toward the active player with an `0xE00` heading mask, records the current time, and starts the new blend.

`func_8002D918` initializes a signed 12-bit random heading. Its active path chooses a randomized movement value from resource `+0x08` and signed range `+0x10`, picks one of four quadrant headings, and blends over `D_800B6FC8`. When the base tank create timer expires and the four session actor counts remain below `D_800B6FD8`, it stops movement, selects animation 5, installs `func_80029CF4`, clears the behavior timer, and records the current time. The routine always finishes with Z position 3000.

## Current work

`func_8002AF2C` at `0x8002AF2C..0x8002B31C` is semantically reconstructed and has the exact 1,008-byte target size. The current comparison has 27 differing instruction words. The known behavior is a resource-duration state machine: resource kind 1 configures the object mode, kind 3 maps elapsed time into phases 0 through 4, kind 2 fades movement over the resource duration, and the default path ramps movement over the first 100 ticks before holding the resource value. The remaining differences are register and load scheduling around the initial resource/duration values and two repeated duration-minus-elapsed expressions. No source-owned data has appeared.

The accepted private header `actor_behavior_extra_internal.h` is frozen with the eight exact functions. Additional recovery-only declarations live in `actor_behavior_extra_more_internal.h` so later work cannot change the transitive inputs of the accepted checkpoint.
