# Scene transitions and timer services

Ten complete functions add 776 bytes of matching game C. Their original
data and strings remain named references to the target's data regions.

| Source | Function | Code bytes |
| --- | --- | ---: |
| `scene_transition_open.c` | `func_80032830` | 80 |
| `scene_transition_close.c` | `func_80032880` | 96 |
| `scene_transition_draw.c` | `func_800328E0` | 288 |
| `scene_signed_shift.c` | `func_800338CC` | 36 |
| `scene_actor_parameter_reset.c` | `func_800354A4` | 36 |
| `scene_glyph_release.c` | `func_80036670` | 88 |
| `scene_service_noop.c` | `func_80036ED0` | 8 |
| `scene_timer_capture.c` | `func_80038570` | 40 |
| `scene_timer_initialize.c` | `func_800387C8` | 72 |
| `scene_timer_service.c` | `func_80038810` | 32 |

The transition entry points resolve the target resource names, issue the
observed commands `0x15` or `0x16`, set the transition state, and capture
the current game timer. The close transition restarts its timer only when
the state is not already three.

The update routine handles states one, two, and three. State one advances
to state two at a computed value of 300. State two draws the fixed target
label. State three adds 300 to the elapsed value, draws while it is below
640, and then clears the state. The elapsed expression preserves the
target's unsigned multiplication by 99 and division by 100.

The signed-shift helper takes the magnitude, shifts it, then restores the
sign, giving truncation toward zero for ordinary in-range inputs. Its
original integer operations remain intact. The actor helper clears the
object parameter through the existing object API and returns one.

Four glyph resources are released in their observed order. The timer
capture helper clears its flag and samples the existing timer service.
The initializer sets the timer scale to 1000, captures the sample, sets
the game flag to one, clears its companion flag, and starts the service.
The final wrapper forwards to the existing timer operation. The empty
callback at `0x80036ED0` retains its complete eight-byte return sequence.

## Evidence

Source candidates and complete comparisons are retained under
`.local/recovery68-scene-services`. Their independently compiled canonical
sources, transitive header snapshots, and procedure boundaries are verified
under `.local/recovery67-integration` with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. None of these functions defines initialized
data or BSS. The game establishes these behaviors; N64 compiler and workflow
references are credited in [CREDITS.md](../CREDITS.md).
