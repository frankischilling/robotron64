# Actor runtime recovery

The target maintains a 200-record pool at `0x800A4628`, an active-list head at
`0x800AA708`, and a live-count word at `0x800A4620`. Each actor occupies `0x7C`
bytes. `0x800A4644` is the first actor's kind byte at offset `0x1C`, not the
pool base. The allocator's clearing length and address stride establish the
record extent independently of the lifecycle helpers.

Fourteen complete lifecycle and behavior functions compile with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`, producing 1,704 matching instruction bytes.

| Source | Runtime range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `actor_pool_reset.c` | `0x8002818C..0x800281C4` | 1 | 56 |
| `actor_cleanup.c` | `0x800281C4..0x80028274` | 2 | 176 |
| `actor_remove.c` | `0x80028274..0x8002836C` | 1 | 248 |
| `actor_sweep.c` | `0x8002836C..0x800283D4` | 1 | 104 |
| `actor_behavior_frame_sync.c` | `0x80029154..0x80029194` | 1 | 64 |
| `actor_behavior_motion_begin.c` | `0x80029210..0x800292BC` | 1 | 172 |
| `actor_behavior_motion_guarded.c` | `0x800292BC..0x8002937C` | 1 | 192 |
| `actor_behavior_motion_scaled.c` | `0x8002937C..0x8002945C` | 1 | 224 |
| `actor_behavior_animation_2945c.c` | `0x8002945C..0x800294A4` | 1 | 72 |
| `actor_behavior_callback_29544.c` | `0x80029544..0x800295CC` | 1 | 136 |
| `actor_behavior_spawn.c` | `0x80029B20..0x80029B80` | 1 | 96 |
| `actor_behavior_spawn_restore.c` | `0x80029CF4..0x80029D6C` | 1 | 120 |
| `actor_behavior_release_29d6c.c` | `0x80029D6C..0x80029D98` | 1 | 44 |

Pool reset clears the count and list head, then marks each pool record with
the original free-kind sentinel eleven. Full cleanup performs the original
preparatory service call, releases active text records, and removes every
actor from the list. It then clears eleven population counters, resets the
object subsystem, and clears the two recorded service counters. Its wrapper
performs the additional cleanup call at `0x800420B0` afterward.

Removal releases the actor's object, unlinks the exact record using the
supplied predecessor or list head, and decrements the live count. For the
history-owning resource kinds seven and eight within actor kind five, it
calls the shared history-release routine before updating that resource-kind
count and marking the pool slot free. The sweep removes actors with a nonzero
state field. It preserves the predecessor when it
removes the current record and advances it only when retaining that actor;
this handles consecutive removals and a removed head without skipping a node.

The nine recovered behavior helpers are small state transitions around the same actor record. `func_80029154` samples the actor's object state into the fixed-point frame field and sets flag `0x40`. `func_80029210` copies the resource movement value into the actor, resolves its two directional components, applies the angle, and selects animation zero. `func_800292BC` performs the same setup unless animation one is active, then clears the actor's Z position. `func_8002937C` performs the movement setup and additionally applies the resource scale through the object transform service. `func_8002945C` refreshes two timestamps and selects animation seven when the actor is not in animation one. `func_80029544` selects that animation, retires an already-installed callback when necessary, then arms the fallback callback at `0x800294A4` with timer 999. `func_80029B20` creates the resource-selected child while the object pool has capacity, otherwise it returns the actor to animation zero. `func_80029CF4` performs the same child creation with a temporary zero Z coordinate, restores Z, and selects animation zero. `func_80029D6C` runs the existing `0x8004EB60` service and marks the actor state byte as two.

`actor.h` shares the record with movie playback and history cleanup. The
object index is at `0x0C`, flags at `0x14`, kind at `0x1C`, state at `0x21`,
resource pointer at `0x24`, history bookkeeping at `0x4C..0x54`, position at
`0x60`, and next pointer at `0x78`. The resource's signed 16-bit loaded flag
and animation table are documented in [movie recovery](movie-commands.md).

The larger allocator and animation selector remain separate recovery work.
They are not counted merely because these callers and layouts are known.
Canonical comparisons preserve every source/header input, symbol extent,
relocation and instruction word before the functions enter the public build.
