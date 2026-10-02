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

## Direction and button mapping

`src/game/controller_input.c` reconstructs the complete matching 800-byte
function at `0x8003C1A8`. It polls controller state, suppresses a minor stick
axis when the other axis exceeds its magnitude by a factor of eight,
applies the 20-unit directional thresholds, and combines the original
button masks. It retains both shoulder-edge actions and the simultaneous
edge toggle. The mode branches preserve their different directional bits.

The complete match and the unspecified-argument polling call are described
in [controller-input-mapping.md](controller-input-mapping.md). Both game
polling callees now have complete excluded C candidates; their behavior,
shared storage, and remaining differences are recorded in
[controller-polling-and-storage.md](controller-polling-and-storage.md).
