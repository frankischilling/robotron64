# Audio commands, instances, and voice dispatch

The recovered audio command sources use the same control state and records as
the [control helpers](audio-control.md). They retain the original byte and
word accesses, nested interrupt lock, command queue, and backend callbacks.
The independent comparison uses IDO 5.3 with the project's normal flags.

## Command entry points

| Source | Runtime range | Functions | C bytes |
| --- | --- | ---: | ---: |
| `audio_play.c` | `0x80053C50..0x80053CC0` | 2 | 112 |
| `audio_instance_stop.c` | `0x80053DAC..0x80053EBC` | 1 | 272 |
| `audio_stop_commands.c` | `0x80053EBC..0x80053F78` | 4 | 188 |
| `audio_voice_stop.c` | `0x80053F78..0x80054178` | 1 | 512 |
| `audio_instance_stop_all.c` | `0x80054178..0x80054268` | 1 | 240 |
| `audio_stop_all_commands.c` | `0x80054268..0x80054304` | 4 | 156 |
| `audio_voice_stop_all.c` | `0x80054304..0x800544F0` | 1 | 492 |
| `audio_level_commands.c` | `0x80054720..0x800547FC` | 4 | 220 |
| `audio_level_update.c` | `0x800547FC..0x800549DC` | 1 | 480 |
| `audio_level_commands_alt.c` | `0x800549DC..0x80054A48` | 2 | 108 |
| `audio_level_update_alt.c` | `0x80054A48..0x80054C24` | 1 | 476 |
| `audio_mode.c` | `0x80054C24..0x80054C44` | 2 | 32 |
| `audio_play_arguments.c` | `0x80055760..0x800557FC` | 2 | 156 |
| `audio_command_lock.c` | `0x8005895C..0x800589DC` | 2 | 128 |
| `audio_command_queue.c` | `0x800592C0..0x80059500` | 5 | 572 |

All sources are under `src/game/`. End addresses are exclusive. These
33 functions contain 4,144 matching instruction bytes. The queue block
also includes four original zero alignment bytes after `func_80059438`;
they do not contribute to the C-byte total.

The play wrappers pass the slot record, its index, and the supplied
arguments to `func_8005396C`. The index is live even in wrappers where
the target leaves the incoming argument register untouched. The byte-level
setters enqueue command two or three plus one payload byte. Their matching
getters return zero when the audio state is inactive. The independent
mode getter and setter read and write the byte at `D_8008DA24` directly.

## Instance flags and voice callbacks

`AudioInstance` has a 24-byte stride. Its first byte contains the flags,
followed by a state byte, a signed slot index, and a voice count. The pointer
at offset `0x0C` refers to byte-sized voice indices. The shared context has
an active-instance count at `0x04`, a voice-index limit at `0x0A`, the
instance-array pointer at `0x18`, and the voice-array pointer at `0x1C`.

The C bitfields reproduce the target's 32-bit flag reads and its separate
byte stores. Stop requests set bit `0x08` and clear bits `0x20` and `0x10`,
in that order. The instance limit is the low byte of configuration word
`D_8008D844`. Both the limit and the active-instance counter retain their
unsigned-byte arithmetic.

`AudioVoice` has an 80-byte stride. The byte at `0x10` selects an operation
table in `D_8008D800`. The stop handler uses its callback at offset `0x14`.
Voice-index byte `0xFF` denotes an empty entry. Other entries count toward
the instance's voice count, which the original handler promotes to a full
integer while iterating.

The per-index handler checks the requested slot and pending-stop flag before
dispatching voice callbacks. Its all-instance counterpart decrements the
active counter only after processing an instance with the stop flag set.
The source keeps that distinction. When a caller supplies a temporary
playback setting, the handlers save `D_8008DA28` through its getter, apply
the requested value, process the voices, and restore the saved setting.

The two level-update handlers select voice categories zero and one. For each
selected voice they temporarily replace its command pointer with a two-byte
stack packet: command twelve and the voice's parameter at offset `0x0D`.
They clear that parameter, call the backend's update callback at `0x30`, and
restore the previous command pointer. Both packets occupy stack offset `0x50`
in the original `0x68`-byte frames. The C declares the live packet beside the
saved command pointer and retains the target's intervening pointer reload.

The operation-table array also contains the context-release callbacks used
by `func_80052CF4`. Both control and command sources use the same declaration;
the two release calls address elements zero and one.

## Queue and interrupt lock

The lock increments a nesting counter. Its outermost entry calls
`func_8005D9E0`, which clears the CPU status register's interrupt-enable bit
and returns its previous value. The matching unlock decrements the counter
and calls `func_8005DA00` only when it reaches zero. Those two low-level
assembly routines remain extracted code.

The queue has a 512-byte command array and an 8,192-byte payload area. The
command count is volatile: the original reloads it at bounds checks and
updates rather than keeping a single cached value. A full command array
sets the overflow latch. A payload that does not fit removes the most
recent command when the count is positive, then sets the same latch.
Later writes are ignored while that latch is set.

The dispatcher clears the latch, resets the payload read pointer, and calls
the handler selected by each queued command byte. It rereads the command
count after every callback. After dispatch, it takes the nested lock, clears
the count, restores the payload write pointer, and unlocks. Payload reads
and copies retain the original ascending byte loop and pointer increments.

## Verification and remaining work

`python3 tools/compare_runtime.py` recompiles each included block and compares
all of its bytes with the validated USA ROM. `make progress` also checks
source/header/object provenance, input-object function sizes, linked
addresses, section placement, and complete ROM equality.

`func_80053CC0`, the instance-state query, is still a source candidate until
its complete comparison matches. The full bank loader and several neighboring
voice-control routines remain extracted. These boundaries are reflected in
the manifest and do not count as matching C.
