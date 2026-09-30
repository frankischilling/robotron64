# Scheduler creation and thread layout

The creation routines at the start of `src/boot/scheduler.c` reproduce the 496 bytes at ROM `0x51040..0x51230`, mapping to `0x80050440..0x80050630`. The same translation unit continues through `0x80050FB0` with the matched dispatcher bodies. IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` produces that complete `0xB70`-byte range. See [scheduler runtime](scheduler-runtime.md) for its task protocol, profiling records, and alignment evidence.

| Function | Bytes | Observed behavior |
| --- | ---: | --- |
| `func_80050440` | 480 | Initialize queues, select the VI mode, register events, and start three threads |
| `func_80050620` | 8 | Return the queue at scheduler offset `0x04` |
| `func_80050628` | 8 | Return the queue at scheduler offset `0x3C` |

Thread 3 calls the initializer with the scheduler at `0x801378D0`. The other arguments are unsigned bytes: target instructions reload them with `lbu` from the last byte of their argument slots. Mode 0 or 28 and one retrace are passed by the startup paths. The initializer does not range-check the mode index.

## Queues and events

Each queue has a 24-byte control block and eight four-byte message slots. Offsets below are relative to the scheduler. The initializer creates them in the order `0x74`, `0xAC`, `0xE4`, `0x3C`, `0x04`, `0x11C`.

| Queue offset | Buffer offset | Established connection |
| --- | --- | --- |
| `0x04` | `0x1C` | Returned by `func_80050620`; thread 18 receives here |
| `0x3C` | `0x54` | Returned by `func_80050628`; thread 17 receives here |
| `0x74` | `0x8C` | VI retrace message `0x29A` and pre-NMI message `0x29D`; thread 19 receives here |
| `0xAC` | `0xC4` | SP event 4, message `0x29B` |
| `0xE4` | `0xFC` | DP event 9, message `0x29C` |
| `0x11C` | `0x134` | Used by thread 17's task coordination; complete protocol unresolved |

After creating the queues, the initializer creates the VI manager at priority 254, selects `D_8008E400[mode]`, enables VI black, and sets the retrace notification interval. It registers SP, DP, and pre-NMI events before starting the three threads. The initial two halfwords become 1 and 3. It clears the current graphics task, current audio task, waiting graphics task, and client-list head, in that order. The word at `0x678` becomes 1 and is cleared after the first completed graphics task disables VI black. These fields use the pointer types established by the runtime.

## Threads

All three entry points receive the scheduler pointer. Creation and start are paired in this order:

| Thread ID | Control block | Entry | Stack-top argument | Priority |
| ---: | --- | --- | --- | ---: |
| 19 | `0x80137A28` (`+0x158`) | `0x80050630` | `0x801479E0` | 120 |
| 18 | `0x80137BD8` (`+0x308`) | `0x80050928` | `0x801499E0` | 110 |
| 17 | `0x80137D88` (`+0x4B8`) | `0x80050BD0` | `0x8014B9E0` | 100 |

The control blocks occupy successive `0x1B0`-byte storage slots. `include/scheduler.h` keeps their internal fields opaque. The observed scheduler accesses extend through offset `0x67B`; this establishes a minimum extent, not ownership of surrounding memory or the size of every original declaration. Stack-top arguments do not establish stack bases or allocation sizes.

All three dispatcher bodies now match. `func_80050630` receives from `+0x74` and distinguishes messages `0x29A` and `0x29D`. `func_80050928` receives audio tasks from `+0x04`, yields an active graphics task when needed, and waits for SP completion at `+0xAC`. `func_80050BD0` receives graphics tasks from `+0x3C`, uses `+0x11C` for audio handoff and framebuffer fencing, and waits for both SP and DP completion. [Runtime evidence](scheduler-runtime.md) documents the full control flow and shared task layout.

## SDK and layout evidence

| Address | SDK name | Target behavior supporting the name |
| --- | --- | --- |
| `0x800604E0` | `osViSetSpecialFeatures` | Applies feature-bit changes to the next VI context under an interrupt lock |
| `0x800640D0` | `osSetEventMesg` | Indexes an eight-byte event record and stores queue/message fields under an interrupt lock |
| `0x80064D40` | `osCreateViManager` | Creates the VI event queue and manager thread; subsequent mode/event setters use its context |
| `0x800650A0` | `osViSetMode` | Stores the mode pointer in the next VI context and loads its control word |
| `0x80065110` | `osViBlack` | Tests an unsigned byte and sets or clears context flag `0x20` |
| `0x80065180` | `osViSetEvent` | Stores the queue, message, and 16-bit retrace interval in the next VI context |

These names are supported by target instructions and the SDK interfaces in the inspected references. They do not establish a libultra release or count those SDK routines as reconstructed C.

The VI mode table stride is 80 bytes: the initializer calculates `(mode * 5) << 4`. The startup code independently accesses width at `+0x08`, horizontal scale at `+0x20`, and first field origin at `+0x28`. The partial `VideoMode` declaration retains those fields and leaves the others unnamed. The layout agrees with the declarations in the inspected [VI header](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/include/PR/os_vi.h).

## Reproduce the comparison

Run `python3 tools/compare_startup.py` to compile and link the startup and combined scheduler translation units independently at their target addresses. The scheduler range must have 2,928 bytes and no differing words. `python3 tools/compare_runtime.py` also checks its separate 236-byte tail. `make progress` checks every counted function symbol, source/header/object provenance, ELF placement, and the complete ROM.

The initializer's matching 56-byte frame follows directly from expressions such as `&scheduler->spQueue` and `&scheduler->thread158`. Introducing four explicit pointer locals enlarged the frame to 72 bytes while leaving the live instructions otherwise unchanged. The integrated source uses the field expressions and reproduces the original argument spills and compiler-managed temporary slots.
