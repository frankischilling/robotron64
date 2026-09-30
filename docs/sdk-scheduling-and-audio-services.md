# SDK scheduling, audio services, and translation

Fourteen complete procedures reconstruct 1,292 code bytes. The audio lifecycle
and buffer-submission units also own their five bytes of initialized state.
Each function was reconstructed against Robotron's validated target and its
existing callers, then compared over its entire procedure extent.

| Source unit | Target code range | Functions | Code bytes | IDO 5.3 profile |
| --- | --- | ---: | ---: | --- |
| `timer_schedule.c` | `0x8006ABA0..0x8006AC74` | 1 | 212 | O1, MIPS II |
| `message_prepend.c` | `0x8006B420..0x8006B570` | 1 | 336 | O1, MIPS II |
| `video_context_get.c` | `0x8006AC80..0x8006AC8C` | 1 | 12 | O1, MIPS II |
| `audio_remaining_bytes.c` | `0x80065C20..0x80065C2C` | 1 | 12 | O1, MIPS II |
| `audio_link_nodes.c` | `0x80065AB0..0x80065B04` | 2 | 84 | O2, MIPS II |
| `audio_synth_lifecycle.c` | `0x80065B04..0x80065B70` | 2 | 108 | O2, MIPS II |
| `audio_synth_clear.c` | `0x8006B5A0..0x8006B5A8` | 1 | 8 | O2, MIPS II |
| `audio_callback_attach.c` | `0x80066310..0x80066360` | 1 | 80 | O2, MIPS II |
| `audio_copy_bytes.c` | `0x8006F3C0..0x8006F434` | 1 | 116 | O2, MIPS II |
| `audio_buffer_submit.c` | `0x80065B70..0x80065C18` | 1 | 168 | O1, MIPS II |
| `matrix_translate.c` | `0x80061210..0x800612AC` | 2 | 156 | O3, MIPS II, `-Wab,-r4300_mul` |

## Scheduling and queues

The timer scheduler initializes both list links, the repeat interval, the
destination queue, and the message. A zero initial delay selects the repeat
interval as the first expiration. After inserting the timer into the relative
deadline list, it programs Compare only when the new timer is the first entry.
The insertion and Compare helpers are documented in
[SDK time and thread priority](sdk-time-and-priority.md).

The front-of-queue message operation shares the queue layout and interrupt
protection used by the existing send and receive functions. A full queue
either blocks its sender or returns `-1`, according to the blocking flag.
Successful insertion decrements the circular first index, writes the message,
increments the count, and wakes a waiting receiver. The active video-context
getter returns the existing context pointer without modifying its state.

## Audio state and buffer submission

The lifecycle functions initialize the synthesizer only when the shared
synthesizer pointer is null. Closing an active synthesizer clears its callback
head and then the shared pointer. The list operations unlink a node or insert
it after another node, updating both neighbor directions. Callback attachment
records the synthesizer's current sample count and links the client under
interrupt-mask protection.

Buffer submission preserves the target's address-boundary adjustment. A flag
from the previous submission can move the DMA address back by `0x2000` bytes.
The next flag is set when the new buffer's end address has low fourteen bits
equal to `0x2000`. This flag update precedes the FIFO-busy check, including on
the `-1` return path. A successful submission converts the adjusted pointer to
a physical address and writes the AI address and length registers. The length
getter reads the current AI length register. The byte-copy function uses a
forward byte loop; IDO emits the target's four-byte unrolling.

| State | Owner | VRAM | ROM offset | Live bytes |
| --- | --- | --- | --- | ---: |
| Synthesizer pointer `D_8008F160` | `audio_synth_lifecycle.c` | `0x8008F160` | `0x8FD60` | 4 |
| Private DMA boundary flag `D_8008F170` | `audio_buffer_submit.c` | `0x8008F170` | `0x8FD70` | 1 |

Both definitions are explicitly initialized to zero and emitted in `.data`.
The private flag's original section offset is checked through IDO's ECOFF
metadata. Only trailing compiler alignment is removed; the five live bytes
are linked and compared with the target. These units introduce no BSS.

## Matrix translation and proof boundaries

The float translation helper initializes a four-by-four identity matrix and
sets its last row's first three values. Its fixed-point wrapper uses a local
float matrix and the existing float-to-fixed conversion interface. The
64-byte matrix union and its alignment are declared in `sdk_matrix.h` with a
compile-time size check. IDO O3 inlines the translation helper inside the
wrapper while preserving both complete exported procedures.

These eleven source units are registered for independent compilation in
`tools/compare_runtime.py`. The manifest records every function's actual
symbol offset and size, and the owned-section ledger records both data
objects. The canonical comparison and full-ROM build check those placements
together with the established callers. A matching translation wrapper does
not establish matching source for the separate matrix-conversion unit.

The N64 interfaces, compiler workflow, and prior SDK layout studies are
credited in [CREDITS.md](../CREDITS.md). The relevant reference notes are
[SDK runtime](sdk-runtime.md), [SDK audio frame](sdk-audio-frame.md), and
[GU matrix helpers](sdk-gu.md); their historical private reference studies
remain distinct from the independently reconstructed source listed here.
