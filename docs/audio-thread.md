# Audio task thread

`src/game/audio_thread.c` matches the complete 560-byte function at
`0x80051380..0x800515B0`, corresponding to ROM `0x51F80..0x521B0`.
IDO 5.3 produces every original instruction with the project's normal flags.

The thread registers an eight-byte `SchedulerClient` with the scheduler and
blocks on `D_8018FF30`. Each received message begins with a signed halfword
type. Type one performs the audio update and, when fewer than three tasks
are outstanding, requests an RSP task through `func_8005211C`.

A null task ends that message's processing immediately. Otherwise the thread
records elapsed ticks, selects `D_8014BF78[next % 3]`, and increments `next`.
Each ring element is the shared 88-byte `SchedulerTask`. The source clears
its linkage and completion-message fields, assigns completion queue
`D_8018FF68`, copies the complete 64-byte `RspTask`, and submits it to the
scheduler's audio queue. It then increments the outstanding count.

The type-one path waits for a completion message even when task submission
was skipped because the count was already three or greater. A receive result
other than minus one decrements the count. Type three sets the count to six.
Type ten leaves the loop and calls `func_800526D0`. Unknown message types
return to the receive loop. These branches retain the target's counter and
queue behavior.

The source gives the decoded message type and task-ring index separate local
names. IDO keeps both values in registers while retaining their declaration
homes in the stack frame. That source shape reproduces the original
`0x70`-byte frame, including the message at `0x58`, client at `0x48`, and
unused incoming argument's home at `0x70`. The client layout stays eight bytes.

`python3 tools/compare_runtime.py` independently recompiles this function and
compares its complete range. `make progress` checks source/header/object
hashes, input-object symbol size, linked placement, and final ROM bytes.
The preceding initializer also matches; its allocation, configuration, and
thread-stack evidence is recorded in [audio runtime](audio-runtime.md).
