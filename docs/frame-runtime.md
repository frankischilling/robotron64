# Frame helpers and fixed-point arithmetic

These routines connect the thread-3 frame loop to the graphics completion queue and the game's fixed-point transform code. The target is the normalized USA revision-zero ROM recorded in `config/target.json`. Runtime addresses in this block map to ROM offsets by subtracting `0x80000000` and adding `0xC00`.

## Matching source

| Function | Size | Recovered behavior |
| --- | ---: | --- |
| `func_80048B8C` | `0x6C` | Subtract the three position values at `D_800C8BD8 + 0x1C`, shift each signed difference right by one, then apply the matrix at `D_800CD250`. |
| `func_80048BF8` | `0x178` | Emit twelve display-list commands for texture lookup, palette loading, texture state, render mode, and geometry mode. |
| `func_80048D70` | `0x20` | Call the existing frame helper at `0x80048460`. |
| `func_80048D90` | `0x0C` | Store the supplied value in `D_8007D8F4`. |
| `func_80048D9C` | `0x24` | Initialize the matrix at `D_800CD250`. |
| `func_800495BC` | `0xFC` | Convert the clock to nanoseconds, optionally update a previous sample, and return whole milliseconds. |
| `func_800496B8` | `0x20` | Wait for graphics completion through `func_80050084`. |
| `func_800496D8` | `0x08` | Empty target routine. |
| `func_8004D4B4` | `0xE8` | Apply a three-by-three fixed-point matrix to a three-component vector. |
| `func_8004DB34` | `0x2C` | Initialize a matrix with diagonal `0x7FFF` and zero off-diagonal elements. |
| `func_8004DB60` | `0x28` | Shift the input angle left four bits, truncate to sixteen bits, and call `func_8005FC20`. |
| `func_8004DB88` | `0x28` | Apply the same angle conversion before `func_8005FBB0`. |
| `func_8004DBB0` | `0x34` | Multiply `func_8005FC20`'s result by the supplied scale and shift right by fifteen. |
| `func_8004DBE4` | `0x34` | Apply the same scaled operation to `func_8005FBB0`. |
| `func_8004DC18` | `0x50` | Normalize an angle to nine bits and use a signed, reflected lookup in `D_8008D370`. |

The fifteen functions contribute 1,396 matching C bytes. Their source objects occupy four disjoint ranges:

| Source | Runtime interval | ROM interval | Bytes |
| --- | --- | --- | ---: |
| `src/boot/frame_helpers.c` | `0x80048B8C..0x80048DBF` | `0x4978C..0x499BF` | `0x234` |
| `src/boot/frame_timing.c` | `0x800495BC..0x800496DF` | `0x4A1BC..0x4A2DF` | `0x124` |
| `src/game/frame_transform.c` | `0x8004D4B4..0x8004D59B` | `0x4E0B4..0x4E19B` | `0xE8` |
| `src/game/fixed_math.c` | `0x8004DB34..0x8004DC67` | `0x4E734..0x4E867` | `0x134` |

## Arithmetic and state

The transform keeps the low 32 bits of each multiplication and performs a signed shift on each product before adding the three terms. Combining the products into a single wider accumulator would change the target behavior. Outputs are written one component at a time, in the original order. The matrix identity uses `0x7FFF`, not `0x8000`.

The clock routine calls `func_80061450`, multiplies its unsigned 64-bit return value by one billion, and divides by `D_8008E3B0`. With a non-null sample pointer, it saves the old value, writes the new nanosecond value, and returns the unsigned difference divided by one million. With null, it returns the absolute converted time in milliseconds. The final return keeps the low 32 bits. The C retains the target's multiplication before division, including unsigned wrap, rather than rearranging the expression.

The old sample has a local scope within the delta branch before transfer to the outer interval variable. That scope produces the original `0x28`-byte stack frame with IDO; flattening the locals changes four stack instructions. No padding variables or instruction changes are used.

`func_8004DC18` first computes `(angle >> 3) & 0x1FF`. Indices through `0x100` read the table directly. Larger indices return the negation of entry `0x200 - index`. The `0x8008DB70` address in the second branch is the table base plus `0x800`, not evidence for a separate table.

The two SDK routines used by the angle helpers remain fallback code. `func_8005FBB0` performs a signed sixteen-bit lookup with quadrant reflection; `func_8005FC20` adds `0x4000` to the angle before calling it. Their addresses and observed calling conventions are recorded without claiming a complete SDK identification.

## Display-list state

`FrameCommand` is an eight-byte command with a 64-bit alignment member. Each `FRAME_COMMAND` expansion has its own packet-pointer scope. This reproduces the original IDO store and temporary-register ordering.

`func_80048BF8` loads the palette at `D_8007D6D0` with command words `FD100000`, `F5000100/07000000`, and `F0000000/073FC000`, with the original tile/load/pipe synchronization commands between them. Its final state includes texture scales `0x8000/0x8000`, render-mode word `0x00553078`, and geometry bits `0x2005`. The literal values are preserved; they are not replaced with later SDK defaults.

## Verification

`make verify` links these source objects with the existing matching code and the remaining extracted ranges. The complete 8,388,608-byte result matches the target. `make progress` then verifies each function's symbol address and size, section runtime/load address, source/header/object provenance, and linked bytes. The Makefile removes only zero compiler padding beyond the mapped ranges. The linker rejects size changes and unexpected input sections.

Nearby frame setup and submission candidates are kept outside the measured total until their full instruction comparisons match. The alternate graphics pacing loop has a separate candidate and is described in [graphics task production](graphics-tasks.md).
