# Controller queries

Three controller-query functions are reconstructed with exact retail bytes:

| Source | Function | Bytes |
| --- | --- | ---: |
| `controller_button.c` | `func_8003C180` | 40 |
| `controller_axes.c` | `func_8003C4C8` | 76 |
| `controller_axes.c` | `func_8003C514` | 176 |

The first reports whether bit `0x2000` is set in the first controller's
button word. The two axis queries use the same button bit as an update
gate. When the gate is clear, they return the previously stored axis values.

`func_8003C4C8` scales the first controller's vertical input by
`(value << 11) / 80`, stores the result in both output globals, and returns
the first. `func_8003C514` updates the first output from vertical input and
the second from horizontal input, then returns the second. Both retain the
target's signed division behavior. The global controller arrays and the
query interfaces are declared in `include/controller_input.h`.

## Direction and button mapping candidate

`src/game/controller_input.c` reconstructs the 800-byte function at
`0x8003C1A8`. It polls controller state, suppresses a minor stick axis when
the other axis exceeds its magnitude by a factor of eight, applies the
20-unit directional thresholds, and combines the original button masks.
It also retains the two shoulder-edge actions and the simultaneous-edge
toggle. Its two mode branches preserve the game's different directional
bit assignments.

The candidate is excluded from the ROM build and matching counts. The
current IDO output has the correct size but differs in 19 instruction words,
principally argument-register allocation and prologue scheduling. The
polling callee reads its incoming integer argument; the candidate retains
that argument rather than weakening the declaration to obtain a match.
