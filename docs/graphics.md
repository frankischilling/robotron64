# Graphics evidence

The normalized ROM contains two readable microcode identification strings:

| ROM offset | Identifier | Version |
| --- | --- | --- |
| `0x96E80` | `RSP Gfx ucode F3DEX` | `1.21` |
| `0x97680` | `RSP Gfx ucode F3DLP.Rej` | `1.21` |

Both strings credit Yoshitaka Yasumoto and Nintendo. The task producer at `0x8005018C` now establishes their use: it indexes the two pointer pairs at `0x8008D560` and places the selected text and data pointers in the RSP task. Index zero selects F3DEX; index one selects F3DLP.Rej. Both use the boot program at `0x8006F440`, ending at `0x8006F510`.

The matching setter at `0x800498E0` writes the selector used by the frame-end caller. Direct calls at `0x80022F38` and `0x800235C0` select one and zero respectively. Scene names and the full renderer architecture remain unresolved. See [graphics task production](graphics-tasks.md) for the pointer table, complete task record, completion messages, callers, and independent comparison commands.

The [startup](startup.md) and [scheduler](scheduler.md) evidence records VI mode selection and notification queues. Matching [frame helpers](frame-runtime.md) cover palette commands, completion waits, clock conversion, and the fixed-point matrix operations used by the frame path.

The excluded [actor ring callback](actor-ring.md) fills 32 vertices and emits
sixteen quads in both winding orders. Its CPU-side vertex, matrix and command
effects pass a guarded execution comparison with the matching helpers. Its
instructions still differ, and the check does not execute RSP/RDP graphics.
