# Scheduler runtime

The scheduler runtime begins at VRAM `0x80050630` / ROM `0x51230`. The recovered scheduler translation unit continues through `func_80050EF0`, with the next function beginning at `0x80050FB0`. The small runtime tail then runs through `0x8005109C`, where `func_8005109C` begins.

The object layout matters to the generated code. `func_80050630`, `func_80050928`, and `func_80050BD0` contain unreachable epilogues whose alignment changes when the functions are compiled at a different offset inside an object. `src/boot/scheduler.c` compiles the creation routines and dispatcher bodies together, producing the target offsets:

| Function | Object offset | Target size |
| --- | ---: | ---: |
| `func_80050440` | `0x000` | `0x1E0` |
| `func_80050620` | `0x1E0` | `0x08` |
| `func_80050628` | `0x1E8` | `0x08` |
| `func_80050630` | `0x1F0` | `0x1C0` |
| `func_800507F0` | `0x3B0` | `0x54` |
| `func_80050844` | `0x404` | `0x90` |
| `func_800508D4` | `0x494` | `0x54` |
| `func_80050928` | `0x4E8` | `0x2A8` |
| `func_80050BD0` | `0x790` | `0x320` |
| `func_80050EF0` | `0xAB0` | `0xB8` body + `0x08` alignment |

With IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`, that combined object matches all 2,928 bytes at VRAM `0x80050440..0x80050FB0` / ROM `0x51040..0x51BB0`, with zero differing words. `src/boot/scheduler_runtime_tail.c` is a separate partition beginning at `0x80050FB0`; it matches all 236 bytes through `0x8005109C` / ROM `0x51C9C`, also with zero differing words. Keeping the split at `0x80050FB0` preserves the two zero words after `func_80050EF0` without adding source padding. `make progress` counts the 16 function bodies as 3,156 C bytes, excluding those eight alignment bytes.

## Records and scheduler fields

The task record is shared with the graphics producers through `scheduler_task.h`. Its layout is fixed by the dispatcher loads and stores:

| Offset | Field | Evidence in this runtime |
| --- | --- | --- |
| `0x00` | `next` | list linkage used by surrounding scheduler code |
| `0x04` | `state` | scheduler state word |
| `0x08` | `flags` | graphics completion tests bit `0x40` |
| `0x0C` | `framebuffer` | framebuffer fence and swap path |
| `0x10` | `RspTask task` | passed to the RSP load/start/yield helpers |
| `0x50` | `completionQueue` | completion message destination |
| `0x54` | `completionMessage` | completion message value |

The record is `0x58` bytes. Bit `0x40` in `flags` is the swap-buffer flag in this slice: the graphics dispatcher calls `func_80065620(task->framebuffer)` when it is set.

The five scheduler words at `+0x668..+0x678` now have concrete runtime roles:

| Offset | Role |
| --- | --- |
| `+0x668` | head of the `SchedulerClient` notification list |
| `+0x66C` | graphics task currently using or owning the SP path |
| `+0x670` | audio task currently using the SP path |
| `+0x674` | graphics task waiting for the audio/SP handoff |
| `+0x678` | one-time VI-black gate, cleared after the first completed graphics task |

`include/scheduler.h` names these fields `clients`, `graphicsTask`, `audioTask`, `waitingGraphicsTask`, and `firstGraphicsTask`. The first four use their recovered pointer types. Compile-time size checks verify the eight-byte client, `0x118`-byte profile, and shared task records on the target ABI.

The scheduler queues used here are `+0x04` for incoming audio tasks, `+0x3C` for incoming graphics tasks, `+0x74` for retrace/pre-NMI messages, `+0xAC` for SP completion, `+0xE4` for DP completion, and `+0x11C` for scheduler handoff/fence synchronization.

## Retrace and clients

`func_80050630` blocks on the retrace queue and increments `D_8008D580` for every message. Message `0x29A` broadcasts the scheduler pointer to every registered client. Message `0x29D` broadcasts `scheduler + 2`, matching the second two-byte scheduler message header.

On a retrace where `D_8008D588` is zero, the thread marks it active, rotates `D_8008D584` modulo four, moves the previous profile pointer to `D_8014BE44`, selects the new `D_8014BE40`, clears its graphics/audio counters, and records a converted timestamp. Each profile record is `0x118` bytes. The observed fields are two counters at `0x00/0x04`, the frame timestamp at `0x08`, three eight-entry graphics timing arrays at `0x10`, `0x50`, and `0x90`, and two four-entry audio timing arrays at `0xD0` and `0xF0`.

Timestamp conversion uses unsigned 64-bit multiplication by one million followed by division by `D_8008E3B0`. Ordinary C operators reproduce the original compiler-helper calls and all surrounding instructions. Multiplication precedes division, retaining the target's unsigned wrap behavior.

`func_800507F0` inserts an eight-byte client record at the head of `+0x668` with interrupts masked. `func_80050844` removes one client from that list under the same mask. `func_800508D4` walks the list and sends a nonblocking message to each client queue.

## Audio dispatcher

`func_80050928` receives a task from `+0x04`, performs the full cache writeback, and checks `+0x66C` for a graphics task already using the SP path. When one is present it requests a yield, waits for the SP event, and records whether the graphics task actually yielded. It then starts the audio task, stores it in `+0x670`, waits for SP completion, clears `+0x670`, and records the audio timing sample.

If a graphics task is waiting in `+0x674`, the audio thread sends the `+0x11C` handoff message. A yielded graphics task is loaded and restarted. The other yield result sends an SP completion message so the graphics side can continue its completion path. The audio task's completion queue/message at `+0x50/+0x54` is sent last.

The exact prologue depends on writing the loop as `for (state = 0;;)`. An equivalent separate `state = 0;` statement makes IDO reorder four otherwise identical prologue instructions. The loop-header form, at the real object offset `0x4E8`, matches all `0x2A8` bytes.

## Graphics dispatcher and framebuffer fence

`func_80050BD0` receives graphics tasks from `+0x3C`. Before starting one, `func_80050EF0` compares the task framebuffer against the two VI framebuffer pointers returned by `func_80065670` and `func_800656B0`. While either comparison matches, it temporarily registers a stack client on `+0x11C`, blocks for a handoff message, removes the client, and checks again.

If audio is active in `+0x670`, the graphics thread stores its task in `+0x674` and blocks on `+0x11C` until the audio dispatcher releases it. It then stores the task in `+0x66C`, loads and starts the RSP task, waits for SP completion, clears `+0x66C`, waits for DP completion, and records the three graphics timing points.

On the first completed graphics task, `+0x678` causes `osViBlack(0)` and is cleared. A task with flag `0x40` calls the framebuffer-swap helper and clears `D_8008D588`, which allows the next retrace to rotate the profiling record. The task completion queue/message is sent after these steps.

## Retained profile index

The profiling index is deliberately described here at the machine-code level because a conventional cleanup changes observable code generation. In the audio thread, saved register `$s7` is updated from `audioCount` only inside the first `audioCount < 4` guard; the later guard reuses that register. The graphics thread does the same with `$s3` and `graphicsCount < 8`. The later checks do not recompute the index.

On normal execution the counter remains above the limit if the first check was skipped, so the later timing store is skipped too. The retrace thread can replace/reset the current profile record between those checks. If that happens, the target reuses the index already retained in the saved register. The matching C therefore assigns `profileIndex` only in the first guard. Initializing it independently or recomputing it in the later guards changes the target code.

## Runtime tail

The separate tail contains six exact functions:

| Function | Size | Behavior |
| --- | ---: | --- |
| `func_80050FB0` | `0x20` | forwards its argument to `func_80053C50(value)` |
| `func_80050FD0` | `0x20` | calls `func_80054268()` |
| `func_80050FF0` | `0x24` | calls `func_80055214(1, 3)` |
| `func_80051014` | `0x20` | calls `func_800554F4(1)` |
| `func_80051034` | `0x10` | empty three-argument function |
| `func_80051044` | `0x58` | calls `func_8005FB08(arg1 + arg2, arg3, D_8014BE50, D_8014BE54)` and returns `-1` on failure, otherwise `0` |

`python3 tools/compare_runtime.py` independently compiles both scheduler objects and compares their full mapped ranges. `make progress` verifies the 16 function symbols, the complete ROM, section placement, and the current source/header/object hashes. Generated assembly and search output stay under `.local/scheduler-probes/` or `build/`.
