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

## Pause, resume, properties, and owner control

The lower audio-control recovery contains 26 exact functions in 22 source
files. The retained `matches:true` probes account for 5,404 instruction bytes.
At base commit `4c1af63`, `func_80053CC0` already existed as the unlinked
`audio_instance_query.c` candidate. Its 236-byte range overlaps this batch, so
25 functions and 5,168 source bytes are new relative to that base while all 26
functions and 5,404 bytes are now linked and tracked as matching C. Two small
uncovered ranges stay extracted: `0x80054C44..0x80054C50` and
`0x80055758..0x80055760`. After `func_80055F24` ends at `0x80056124`, the
following audio range remains fallback until the already recovered command
lock at `0x8005895C`.

| Source | Runtime range | Functions | C bytes | Archived source SHA-256 |
| --- | --- | ---: | ---: | --- |
| `audio_instance_state_query.c` | `0x80053CC0..0x80053DAC` | 1 | 236 | `4ce1c7d4b25d466fffd592cf2257e002552f61685edea0249dce677d81387d33` |
| `audio_voice_pause_state.c` | `0x80054C50..0x80054CF0` | 2 | 160 | `c48d4197856e4db8fde7fcd3d7ec7d8bd8bba8dcbd147ea53e33086fb28fa34c` |
| `audio_pause_request.c` | `0x80054CF0..0x80054DB8` | 1 | 200 | `aee6471e96e3914afb4a6ae3436b00041209bcc36500404abca448f00821cb6a` |
| `audio_pause_decode.c` | `0x80054DB8..0x80054DF8` | 1 | 64 | `a24a5421db25cdf4055d80a3f658eefc33797bcf6e4adea0bc38c0c32a8620f1` |
| `audio_pause_apply.c` | `0x80054DF8..0x80054FC4` | 1 | 460 | `601092aff192be67ec6d0ac7b9e2f09b60494f17bf95ca728f0fe8284b604b72` |
| `audio_resume_request.c` | `0x80054FC4..0x8005507C` | 1 | 184 | `28c0540cc271799f12e813a0392dae22aea3c684cb3d77e9b27a1bdbf2966de3` |
| `audio_resume_decode.c` | `0x8005507C..0x800550AC` | 1 | 48 | `6cc7806f22ac6354bb1c6725065c1894ebd85353d84e0725c81b39cd21016a80` |
| `audio_resume_apply.c` | `0x800550AC..0x80055214` | 1 | 360 | `2962790705f2d38397361a04014e9ab71df4c188d9d5ceaca77a5a6852fee68e` |
| `audio_pause_all_request.c` | `0x80055214..0x800552CC` | 1 | 184 | `9cda1acf1d956f51eef5b899853dd207d0dc599fbc74a68d1a551bf06469b7d7` |
| `audio_pause_all_decode.c` | `0x800552CC..0x8005530C` | 1 | 64 | `b03776f310ec31aad5a5cdbd5dc716be7523f13df0fa3b318eba95b3cff9d994` |
| `audio_pause_all_apply.c` | `0x8005530C..0x800554F4` | 1 | 488 | `36bc3071ce895fec707576c9a4d4e4952ecd7eb34bce618223c8f34bb1f80e38` |
| `audio_resume_all_request.c` | `0x800554F4..0x8005559C` | 1 | 168 | `870a9714a2f67205662377e7961313c46bdbe099383970f635ee92250d33e149` |
| `audio_resume_all_decode.c` | `0x8005559C..0x800555CC` | 1 | 48 | `ccf33bedffa9ba3ed74dfbcc6d1e764ac3e280440bb32e16b91ef504a0f64329` |
| `audio_resume_all_apply.c` | `0x800555CC..0x80055758` | 1 | 396 | `410868834cbe59dd6113c6a2a13ba4e5c0bdf0df8fdbe76b0344c6679e9b814d` |
| `audio_voice_properties_initial.c` | `0x800557FC..0x80055A60` | 1 | 612 | `6cec27c961faf9da97d102aa6de0e0ae498a7d5a490428cba4a427acee843eb4` |
| `audio_owner_properties_request.c` | `0x80055A60..0x80055AAC` | 1 | 76 | `492725ad5d58e63dc6996144b76fb9ec5236debee39ed8f7b22ff2b91d25e7ee` |
| `audio_owner_properties_decode.c` | `0x80055AAC..0x80055AE8` | 1 | 60 | `e5d49f3a1a40d382546d238ad1f354b5fc21fcf8b3371494576e033ba4d0bf98` |
| `audio_owner_properties_apply.c` | `0x80055AE8..0x80055C6C` | 1 | 388 | `6fdfb0af1dd729d4a9cfd66f79eff6b162a527face9f307ce8ec61c2a08501fc` |
| `audio_owner_state_query.c` | `0x80055C6C..0x80055D58` | 1 | 236 | `7ac189018ca805708f9a61a7e874b4b686914f544bdffc37c01dfed9ff621f65` |
| `audio_owner_stop_request.c` | `0x80055D58..0x80055E68` | 1 | 272 | `a6a6654b190131e6f5c1382219d3ffcd71ea4af24cee0e7a8d8a89853b969dc1` |
| `audio_owner_stop_commands.c` | `0x80055E68..0x80055F24` | 4 | 188 | `fbc988ea41083f16027fcc0cdbf0de6bdf87293b800f3bda359c27c12ee1e53e` |
| `audio_owner_stop_apply.c` | `0x80055F24..0x80056124` | 1 | 512 | `b5d9b15ea86af2938af6dd7d70dca3d88e604e8ecb52a59333116423c9d8834c` |

The archived source files are copied byte-for-byte. They keep their original
`"audio_properties_internal.h"` include spelling through the forwarding header
in `src/game/`; the maintainable shared layouts and declarations live in
`include/audio_properties_internal.h`. The shared header's current SHA-256 is
`d7b771e3b62b292c940b98487ac76801cc146abd8ab171d4ccedeff196d6d9da`, and
the forwarding header's SHA-256 is
`20313fa777d05d3a0c4f8d3400f66c118c0786e04d2fb5699479f3811f232eb8`.
The historical probe records are retained as they were generated: 21 of these
objects, totaling 4,792 bytes, record the earlier shared-header SHA-256
`a86dbc926fb6d5d588f10b9f2b3d9a300a2a9e4dc8674d2522b9536dd8f5444e`;
`audio_voice_properties_initial.c`, totaling 612 bytes, records the current
shared-header hash. Fresh repository comparison recompiles the sources against
the current shared header.

## Queue and interrupt lock

The lock increments a nesting counter. Its outermost entry calls
`func_8005D9E0`, which clears the CPU status register's interrupt-enable bit
and returns its previous value. Its caller declaration is
`unsigned int func_8005D9E0(void)`. The matching unlock decrements the counter
and calls `func_8005DA00` only when it reaches zero; that caller uses
`void func_8005DA00(unsigned int state)`.

Both 32-byte routines are now registered matching assembly. Their target
SHA-256 values are `b5ec893cd5c1e37c723f982142b67fc24befcf35b6e48b596abbcca4c4d44560`
and `6604faa730644258db279f150ad1879e87c654324bea47e9ed0539864b787913`.
The source spells out the CP0 Status reads and writes, including the observed
hazard nops; the complete linked 64-byte unit is checked by
`tools/compare_assembly.py` and the full-ROM build.

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

`func_80053CC0` and the pause/resume, property, and owner-control functions
listed above now use their complete exact C ranges. The full bank loader and
other neighboring voice-control routines remain extracted. These boundaries
are reflected in the manifest and do not count as matching C.
