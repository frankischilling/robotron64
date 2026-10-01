# Actor history allocation and model transforms

The recovered routines use the established IDO 5.3 game profile. Each complete
procedure is registered for independent compilation and linked-byte comparison.

| Function | Instruction bytes | Observed operation |
| --- | ---: | --- |
| `func_8000F7D8` | 60 | Clear the first word of each 28-byte chain entry until the `-1` sentinel, then snapshot `D_8009EFA0`. |
| `func_8003F314` | 364 | Compose a model node's rotation and translated position with its parent and recursively visit its children. |
| `func_8004E1C0` | 420 | Allocate a projectile and one of 24 position-history slots. |
| `func_8004DEE0` | 648 | Update projectile lifetime, steering, and its sixteen-entry position history. |

The model routine tests all three signed halfword angles, uses the identity
matrix for zero rotation, transforms the node position, adds the parent
translation, and multiplies the matrices before visiting children. Its fifth
argument passes through the recursion. This procedure does not submit geometry.
The single-pass scope around the child loop preserves IDO's pointer lifetimes.

The projectile allocator searches the 24 occupancy bytes in order. It returns
null when the slots are full or the actor allocation fails. A successful actor
receives its parent's position, the requested angle offset, two planar velocity
components derived from the integer trigonometry helpers, and both callbacks.
It sets the lifetime to 180, the history index to zero, and the history state
to one. The third incoming argument is unused. The recovered prefix identifies
field offsets, not an original developer type name.

`actor_history_data.c` defines the 24 initialized zero occupancy bytes at
`0x8008D494` and 4,608 bytes of BSS at `0x8013EC00`: 24 slots of sixteen
three-word positions. Independent data comparison checks the initialized bytes
against the ROM and checks the BSS size, placement, and symbol ownership.
The existing release helper shares this declaration and retains its signed
pointer-difference arithmetic and bounds check.

The update callback runs only when `D_8009EF94` is nonzero. It decrements
the lifetime and, on reaching zero, clears the primary callback and invokes
the existing actor cleanup helper. During the last 119 ticks it adjusts the
angle every second update, adding or subtracting 300 according to the signed
angle result from `func_8000A2E0`. It masks the angle to twelve bits and
recomputes the two velocity components at speed 30.

The history writer selects the index modulo sixteen, converts the actor's
coordinates in X/Z/Y order using `1400.0f / 60000.0f`, truncates each result
to an integer, then multiplies each by twelve. It overwrites the middle
coordinate with 400 and advances the history index. The source preserves
the intermediate stores, including the scaled middle coordinate that is
subsequently overwritten. A single-pass scope retains those stores under
IDO optimization. Byte-based indexing preserves the target's addition
operand order; the record size is checked in the shared header.

The compiler emits the four-byte `60000.0f` constant at `0x80095B30`, ROM
`0x96730`. Its owned section is independently compared, and the build removes
only checked trailing object alignment. No instruction or constant bytes are
patched after compilation.

Run `python3 tools/compare_runtime.py --jobs 4`, `make compare-data`,
`make verify`, and `make progress` to reproduce current evidence. Remaining
history drawing functions still use fallback instructions. These four
procedures replace 1,492 bytes of fallback instructions; the full-ROM match
also includes substantial remaining fallback code.

The N64 references are credited in [CREDITS.md](../CREDITS.md). The local
libreultra matrix utilities provide SDK fixed-point context; these game routines
are reconstructed from Robotron's own instructions and use its existing custom
matrix interface. No reference implementation was copied.
