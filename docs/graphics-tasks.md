# Graphics task production

The block from `0x8004FE10` through `0x8005043C` owns the graphics-side scheduler client, completion waits, RSP task construction, and a small RDP initialization list. `0x80050440` begins the scheduler block and is outside this file.

## Recovered functions

| Function | ROM | Size | IDO comparison | Role |
| --- | ---: | ---: | --- | --- |
| `func_8004FE10` | `0x050A10` | `0x34` | exact | Initialize completion message values and graphics state. |
| `func_8004FE44` | `0x050A44` | `0x64` | exact | Create the graphics queue, register its scheduler client, and cache the scheduler submission queue. |
| `func_8004FEA8` | `0x050AA8` | `0x1DC` | nonmatching | Alternate queue/event loop described below. Its behavior is recovered, but the original register allocation and switch layout are not. |
| `func_80050084` | `0x050C84` | `0xCC` | exact | Wait until a type-2 message has been seen and a later type-1 message arrives. |
| `func_80050150` | `0x050D50` | `0x08` | exact | Empty stub. |
| `func_80050158` | `0x050D58` | `0x34` | exact | Receive one queue message and return its signed 16-bit type. |
| `func_8005018C` | `0x050D8C` | `0x174` | exact | Build and submit one graphics task. |
| `func_80050300` | `0x050F00` | `0x08` | exact | Empty stub. |
| `func_80050308` | `0x050F08` | `0x134` | exact | Emit ten RDP setup/fill commands. |

The eight exact routines account for 1,104 matched function bytes. The selector setter `func_800498E0`, at ROM `0x4A4E0`, contributes another twelve bytes from `src/boot/graphics_ucode.c`. The `nop` at `0x8005043C` is alignment between `func_80050308` and `func_80050440`, not part of the recovered function.

For integration, the block is split into two matching objects and one excluded candidate:

| Source | Link address | ROM range compared | Compared bytes | Status |
| --- | ---: | --- | ---: | --- |
| `src/boot/graphics_setup.c` | `0x8004FE10` | `0x050A10..0x050AA7` | `0x98` | exact |
| `src/boot/graphics_pacing.c` | `0x8004FEA8` | `0x050AA8..0x050C83` | `0x1DC` | nonmatching; keep out of the matching manifest |
| `src/boot/graphics_tasks.c` | `0x80050084` | `0x050C84..0x05103F` | `0x3BC` | exact |

`graphics_setup.c` depends on `graphics_tasks.h` and `scheduler_runtime.h`. `graphics_tasks.c` and `graphics_ucode.c` depend on `graphics_tasks.h`. `graphics_pacing.c` uses the same two headers as setup. All reach the checked task record through `scheduler_task.h` and the basic OS queue declarations through `scheduler.h`. These transitive headers are prerequisites and hashed inputs in each matching object's build recipe.

## Scheduler setup and messages

`func_8004FE10` writes `2` to `D_80143994`, `4` to `D_80143996`, sets `D_8008D574` to `-1`, and clears `D_8014599C`.

`func_8004FE44` creates the eight-entry queue at `D_801437A0`, registers the client record at `D_801437D8` with `func_800507F0`, and stores `func_80050628(scheduler)` in `D_80143990`. The recovered scheduler code shows that `func_80050628` returns the scheduler queue at offset `0x3C`.

`func_80050084` blocks on `D_801437A0`. Message type `2` arms a local flag. A type-1 message exits only after that flag has been armed. Type `3` is ignored by this waiter. `func_80050158` is the one-message form of the same receive path.

`func_8004FEA8` performs the same queue/client setup and then receives forever. Type `1` checks `D_8008D574`: state `0` increments `D_8008D578` while its unsigned value is below `2`, state `1` increments it only when it is zero, and states `-1` and `2..30` leave it unchanged. Type `2` decrements `D_8008D578`. Type `3` calls `func_80064CE0(1.0f)` and then adds two. The ROM uses a 31-entry jump table for states `0..30` at `0x80095BF0` plus a separate `-1` test. The current C preserves these effects but does not reproduce that code shape.

## Graphics task layout

`func_8005018C` writes a `0x58`-byte scheduler record. The embedded RSP task begins at offset `0x10`.

The producer and scheduler use the same `SchedulerTask` definition; `GraphicsTask` is its alias. Compile-time size checks require a `0x40`-byte RSP payload and a `0x58`-byte complete record on the target ABI.

| Offset | Field | Value written by `func_8005018C` |
| ---: | --- | --- |
| `0x00` | next | `NULL` |
| `0x04` | scheduler state | not written here |
| `0x08` | scheduler flags | fifth argument |
| `0x0C` | framebuffer | `D_80138260[D_8007D914]` |
| `0x10` | task type | `1` |
| `0x14` | RSP task flags | `0` |
| `0x18` | boot ucode | `0x8006F440` |
| `0x1C` | boot ucode size | `0xD0` |
| `0x20` | ucode | selected from `D_8008D560` |
| `0x24` | ucode size | not written here |
| `0x28` | ucode data | selected from `D_8008D560` |
| `0x2C` | ucode data size | `0x800` |
| `0x30` | DRAM stack | `0x8012E890` |
| `0x34` | DRAM stack size | `0x400` |
| `0x38` | output buffer | `0x8012EC90` |
| `0x3C` | output-size pointer | `0x80136C90` |
| `0x40` | display-list/data pointer | second argument |
| `0x44` | display-list/data size | third argument |
| `0x48` | yield buffer | `0x80136CD0` |
| `0x4C` | yield buffer size | `0xC00` |
| `0x50` | completion queue | `&D_801437A0` |
| `0x54` | completion message | `&D_80143994` when flags contain `0x40`, otherwise `&D_80143996` |

After filling the record, the producer calls `func_800635A0(D_80143990, task, 1)`. If flag `0x40` is present it toggles both `D_8008D570` and the framebuffer index `D_8007D914`. It then advances `D_8014599C` modulo eight. The ROM performs that advance as two stores, an increment followed by `&= 7`, and the matching C retains that source shape.

The producer deliberately does not write the embedded `ucode_size` word at offset `0x24`. Its previous contents therefore remain part of the task record and should not be invented during integration.

## Microcode selection

`D_8008D560` is an array of two pointer pairs at ROM offset `0x8E160`. The fourth argument to `func_8005018C` indexes this table directly.

| Index | Ucode text | Ucode data | Embedded identifier |
| ---: | ---: | ---: | --- |
| `0` | `0x8006F510` | `0x80095FD0` | `RSP Gfx ucode F3DEX 1.21` |
| `1` | `0x80070940` | `0x800967D0` | `RSP Gfx ucode F3DLP.Rej 1.21` |

Both choices share the boot program at `0x8006F440`; its size is the difference to `0x8006F510`, or `0xD0` bytes. The two identification strings appear at ROM offsets `0x96E80` and `0x97680` respectively.

The frame-end caller `func_800489F4` passes `D_8007D8EC` as this selector. That caller uses a `0x58` stride through `D_8013D8A0`, passes `D_80138278` as the display-list start, passes `D_80138254 - D_80138278` as its byte count, and supplies scheduler flag `0x40`.

`func_800498E0` stores its argument directly in `D_8007D8EC`. The direct call at `0x80022F38` selects index one; the call at `0x800235C0` selects index zero. Both are supported by the argument in the call's delay slot. Scene names and indirect callers remain to be established; the source does not add selector bounds checks that are absent from the target.

## RDP setup list

`func_80050308` advances `D_80145998` through ten eight-byte commands. Reproducing the original block-local packet-pointer macro shape is necessary for the exact IDO output, including the temporary stack spill generated for the last pipe-sync command.

The command stream is:

1. `FE000000 00200000` — set depth-image address to `0x00200000`.
2. `E7000000 00000000` — pipe sync.
3. `BA001402 00300000` — select fill-cycle mode.
4. `FF10013F 00200000` — set a 320-pixel RGBA16 color image at `0x00200000`.
5. `F7000000 FFFCFFFC` — set fill color.
6. `F64FC3BC 00000000` — fill rectangle `(0, 0)` through `(319, 239)`.
7. `E7000000 00000000` — pipe sync.
8. `F7000000 00010001` — set the second fill color.
9. `F64FC3BC 00000000` — fill the same rectangle.
10. `E7000000 00000000` — pipe sync.

## Callers

A direct `jal` scan of the ROM disassembly found these callers in the current block map:

- `func_800482A0` calls `func_8004FE44`.
- `func_800489F4` calls `func_80050084` and then `func_8005018C` when ending a frame.
- `func_800496B8` calls `func_80050084`.

No direct `jal` was found for `func_8004FEA8`, `func_80050150`, `func_80050158`, `func_80050300`, or `func_80050308`. This does not rule out indirect calls or callback use.

## Verification

Run `python3 tools/compare_runtime.py` for independent compilation with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32`. The tool links the source at its original runtime address, resolves only undefined references, and compares the linked bytes against the validated local ROM. Results are written to `build/runtime-comparison/report.json`.

Linked at `0x8004FE10`, `graphics_setup.c` compares all `0x98` target bytes with zero differing words. Linked at `0x80050084`, `graphics_tasks.c` compares all `0x3BC` target bytes, including the alignment word before `func_80050440`, with zero differing words. IDO pads those object `.text` sections to `0xA0` and `0x3C0` respectively; the extra zero bytes are outside the mapped target ranges and are checked before removal.

`python3 tools/compare_runtime.py --candidates` reproduces the excluded pacing candidate comparison and exits nonzero while any selected candidate differs. Reports and extracted comparison bytes remain under ignored `build/` paths.

`func_8004FEA8` remains explicitly nonmatching. The simplified `graphics_pacing.c` candidate links to `0x190` bytes versus the target's `0x1DC` and differs in 108 compared words. The target keeps the queue, counter, state address, message constants `1/2/3/-1`, and `1.0f` live in saved registers and lowers the state handling through the 31-entry table. The candidate keeps the recovered behavior without duplicating the target's large switch solely to influence code generation. It should stay outside the matching manifest until a source form reproduces the full target range.
