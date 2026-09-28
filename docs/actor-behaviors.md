# Actor behavior recovery

This family covers actor behavior code from `0x8002A244` through `0x8002E65C`.
The recovered functions blend movement, manage animation callbacks, and
choose movement headings. Comparisons use the target ROM directly and
IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.

## Exact checkpoint

Fourteen complete functions, totaling 3,720 code bytes, match byte for byte:

| Function | Range | Size | Source | Result |
| --- | --- | ---: | --- | --- |
| func_8002A3E8 | 0x8002A3E8..0x8002A414 | 44 | actor_behavior_state.c | exact |
| func_8002A414 | 0x8002A414..0x8002A5DC | 456 | actor_behavior_blend_velocity.c | exact |
| func_8002A5DC | 0x8002A5DC..0x8002A808 | 556 | actor_behavior_blend_motion.c | exact |
| func_8002B31C | 0x8002B31C..0x8002B32C | 16 | actor_behavior_height.c | exact |
| func_8002B32C | 0x8002B32C..0x8002B570 | 580 | actor_behavior_extra_b32c.c | exact |
| func_8002B570 | 0x8002B570..0x8002B57C | 12 | actor_behavior_noop_b570.c | exact |
| func_8002B57C | 0x8002B57C..0x8002B7A4 | 552 | actor_behavior_extra_b57c.c | exact |
| func_8002B7A4 | 0x8002B7A4..0x8002B7B0 | 12 | actor_behavior_noop_b7a4.c | exact |
| func_8002B7B0 | 0x8002B7B0..0x8002B7BC | 12 | actor_behavior_noop_b7b0.c | exact |
| func_8002BF88 | 0x8002BF88..0x8002C0AC | 292 | actor_behavior_repeat.c | exact |
| func_8002D918 | 0x8002D918..0x8002DC20 | 776 | actor_behavior_extra_d918.c | exact |
| func_8002DC20 | 0x8002DC20..0x8002DCB8 | 152 | actor_behavior_countdown.c | exact |
| func_8002DCB8 | 0x8002DCB8..0x8002DD40 | 136 | actor_behavior_countdown_begin.c | exact |
| func_8002DD40 | 0x8002DD40..0x8002DDBC | 124 | actor_behavior_countdown_trigger.c | exact |

func_8002A3E8 clears flag bit 0x2, copies the scalar at +0x2C to +0x30, installs the new +0x2C and +0x38 values from its arguments, and copies the angle at +0x08 to +0x0A. func_8002B31C stores 1000 in the Z position at +0x68. The three 12-byte helpers are empty callbacks whose generated code consists of the ABI argument spills and return.

func_8002A5DC blends the previous and current heading/motion values over a duration, updates the motion components at +0x6C/+0x70, and applies the interpolated heading to the actor object. Its last four differences disappeared when the existing remaining local was declared before the other three meaningful scalar locals. That declaration order assigns remaining the target stack home at 0x3C without padding or dummy variables.

The first six proofs remain under `.local/recovery47-behaviors/frozen/` and
their integration checkpoint under `.local/recovery51-integration/`.
The eight newer functions have independent complete comparisons, source and
transitive-header snapshots, and compiler identity records under
`.local/recovery55-actors/` and `.local/recovery57-integration/`.

## Callback transitions

The four callback helpers optionally clear flag `0x40` and run the old
callback, then install flag `0x40`, the next callback, and timer 999. A
comma expression groups the three assignments into the original transition;
IDO then emits the complete target store order. The callback keeps its
typed actor parameter throughout the reconstruction.

func_8002BF88 also establishes that +0x4C is decremented by D_8009EF94 and that resource +0x08 supplies the movement magnitude used to derive +0x6C/+0x70. func_8002DC20 decrements +0x54; at zero it selects animation 7 and returns the actor to func_8001B324. func_8002DCB8 selects animation 6 and installs func_8002DC20. func_8002DD40 installs func_8002DCB8 and initializes +0x54 to 6.

## Movement and animation behavior

`func_8002A414` blends movement components between the previous and current
heading. It wraps headings across `0x1000`, decrements and clamps the blend
countdown, and combines the sine/cosine terms using the original signed
integer products and division. The four meaningful scalar locals reproduce
the target stack homes without extra storage.

`func_8002B32C` handles animation states 3, 6, and 7 separately, and selects
animation 1 when the unsigned elapsed-clock value reaches 10,001. Otherwise
it continues an active blend or chooses a heading toward the actor in the
active-player record. Adding `0x80` and masking with `0xF00` quantizes that
heading. The resource's movement value and period govern the update.

`func_8002B57C` randomizes the initial animation frame and starts with a
heading toward the origin. Its subsequent target heading uses an offset of
`0x100` and mask `0xE00`, with a blend duration of 200. Animation state 4
returns to state zero after an unsigned elapsed-clock value of 3,001.

`func_8002D918` combines a random initial heading, resource-driven movement
changes, animation-state handling, and a count-limited fallback transition.
The fallback clears movement components, sets animation 5, replaces the
callback with `func_80029CF4`, and records the current clock. The function
always sets the actor's Z position to 3,000 before returning. Its call order,
signed arithmetic, random range operations, and callback behavior are retained.

## Shared actor layout evidence

No shared header was edited. The behavior targets support these prime-owned actor.h refinements:

| Offset | Evidence |
| --- | --- |
| +0x08 | signed 16-bit current heading/angle |
| +0x0A | signed 16-bit previous heading/angle |
| +0x0E | signed 16-bit behavior timer, repeatedly set to 999 |
| +0x14 | 32-bit flags; bit 0x2 is cleared by 2A3E8 and bit 0x40 marks an installed behavior callback |
| +0x2C | current movement/scalar magnitude |
| +0x30 | previous movement/scalar magnitude |
| +0x38 | blend countdown/remaining parameter |
| +0x44 | behavior callback pointer called as callback(actor) |
| +0x4C | arithmetic behavior timer/countdown in 2BF88 |
| +0x54 | integer countdown in 2DC20/2DD40 |
| +0x60/+0x64/+0x68 | X/Y/Z integer position |
| +0x6C/+0x70 | derived motion/velocity components |

The current shared names history_index at +0x4C and history at +0x54 are too specific for these behavior callers unless those fields become context-dependent unions. Behavior code performs integer arithmetic directly on both offsets, so shared naming should be reconciled across actor families before changing actor.h.

## Remaining family boundaries

| Function | Range | Bytes | Checkpoint status |
| --- | --- | ---: | --- |
| func_8002A244 | 0x8002A244..0x8002A3E8 | 420 | pending |
| func_8002A808 | 0x8002A808..0x8002AF2C | 1828 | pending |
| func_8002AF2C | 0x8002AF2C..0x8002B31C | 1008 | pending |
| func_8002B7BC | 0x8002B7BC..0x8002BF88 | 1996 | pending |
| func_8002C0AC | 0x8002C0AC..0x8002C4AC | 1024 | pending |
| func_8002C4AC | 0x8002C4AC..0x8002CB48 | 1692 | pending |
| func_8002CB48 | 0x8002CB48..0x8002CF24 | 988 | pending |
| func_8002CF24 | 0x8002CF24..0x8002D3D4 | 1200 | pending |
| func_8002D3D4 | 0x8002D3D4..0x8002D918 | 1348 | pending |
| func_8002DDBC | 0x8002DDBC..0x8002E65C | 2208 | pending |

The remaining entries are outside this accepted checkpoint. Their saved
candidates and target evidence remain available for continued recovery.
