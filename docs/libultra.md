# Initial SDK identification

The target contains these instruction sequences from the non-iQue assembly in SM64's libultra tree:

| Candidate | ROM offset | Runtime address | Evidence |
| --- | --- | --- | --- |
| `__osDisableInt` | `0x68160` | `0x80067560` | Eight instructions reading CP0 status, clearing IE, writing status, and returning the old IE bit |
| `__osRestoreInt` | `0x68180` | `0x80067580` | Seven instructions reading CP0 status, ORing the argument, writing status, and returning |
| `osGetCount` | `0x690C0` | `0x800684C0` | `mfc0 v0,$9`, return, zero delay slot |

These identify behavior and conventional SDK names. They do not identify a libultra release: small assembly routines are shared between releases. They remain binary fallback and are not counted as matching C.

References inspected: [disable interrupts](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/__osDisableInt.s), [restore interrupts](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/__osRestoreInt.s), and [read count](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/osGetCount.s). No implementation was copied into this project.
