# Fixed geometry

`src/game/fixed_geometry.c` covers the two fixed-point geometry routines from `0x8004D59C` through `0x8004DB34`. Both compile byte-for-byte with IDO 5.3 using the project's `-O2 -G 0 -non_shared -mips1 -32` flags.

`func_8004D59C` spans `0x8004D59C..0x8004D884` and is 744 bytes. It applies a 3x3 Q15 matrix to an array of signed 32-bit XYZ vectors. Its scalar expressions use the same per-product right shift as the already matched `func_8004D4B4`; IDO unrolls the vector loop by two exactly as in the retail ROM.

`func_8004D884` spans `0x8004D884..0x8004DB34` and is 688 bytes. It multiplies two 3x3 Q15 matrices, accumulates each three-product dot product before shifting the sum right by 15, and writes the nine results in row order.

Neither routine references global data or rodata. Their only shared type dependency is `FixedMatrix` from `include/fixed_math.h`.

## Rotation setup and short vertices

`src/game/fixed_geometry_setup.c` supplies eight more matching functions in
the contiguous interval `0x8004CED0..0x8004D4B4`, totaling 1,508 bytes.

| Function | Bytes | Behavior |
| --- | ---: | --- |
| `func_8004CED0` | 32 | Forward a float angle to the existing cosine routine. |
| `func_8004CEF0` | 24 | Return the signed integer absolute value. |
| `func_8004CF08` | 56 | Divide the sine result by the cosine result. |
| `func_8004CF40` | 120 | Construct an X rotation and multiply it into a matrix. |
| `func_8004CFB8` | 292 | Transform short vertices and add an integer translation. |
| `func_8004D0DC` | 120 | Construct a Y rotation and multiply it into a matrix. |
| `func_8004D154` | 120 | Construct a Z rotation and multiply it into a matrix. |
| `func_8004D1CC` | 744 | Transform an array of short vertices. |

The short-vertex record is eight bytes: signed 16-bit X, Y and Z fields,
followed by a two-byte field these functions do not read. Each output record
contains three 32-bit coordinates. The matrix products are shifted right by
15 individually before addition. The translation step uses unsigned 32-bit
addition before storing the signed coordinate, preserving the target's
wrapping addition and the matching expression order. No translation is
applied in `func_8004D1CC`; its simple source loop compiles into the retail
two-vertex unroll.

Each rotation uses a real local `FixedMatrix`, with `0x7FFF` in the unchanged
axis and signed sine/cosine pairs in the other two axes. The matrix fields
and the saved cosine account for the observed stack frame without padding
locals. All eight function boundaries and every instruction word match.

## Earlier validation and remaining heap work

The versioned independent comparison is:

```sh
python3 tools/compare_runtime.py
```

The expected range is 1,432 bytes. The function reports are 744 bytes and 688 bytes respectively, with zero differing words for each function and for the whole range. The ELF binary section includes eight trailing alignment bytes after the last function; `last_symbol_end` is exactly 1,432 bytes, so those bytes are outside the compared function block.

`src/game/heap.c` contains the four contiguous heap routines at `0x8004DC70..0x8004DE8C`. `func_8004DC70` is 32 bytes and marks the block before a payload free by setting the low bit of its header. `func_8004DC90` is 80 bytes and totals the usable bytes in all free blocks. `func_8004DCE0` is 140 bytes and coalesces adjacent free blocks while returning the largest free payload size. `func_8004DD6C` is a 288-byte allocator that lazily initializes the arena, aligns requested sizes to four bytes, consumes exact-fit blocks, and splits larger free blocks. These routines use `D_8013EBF0`; the allocator also uses `D_8008D480` and calls `func_8004DE8C` on first use. They require no rodata.

The same versioned command checks this contiguous 540-byte run. All four
function boundaries and all instruction bytes match. `include/heap.h`
declares the recovered public heap entry points.

The eight-byte `func_8004DED8` at `0x8004DED8..0x8004DEE0` also matches as an empty function. It is isolated in `src/game/heap_empty.c`; the local continuation comparison reports an eight-byte function with zero differing words. Keeping it in a separate source file avoids coupling the exact empty function to the still-nonmatching initializer immediately before it.

`src/game/object_history.c` contains `func_8004E168` at `0x8004E168..0x8004E1C0`, an 88-byte history-slot cleanup routine. It derives the slot index from the object's history pointer relative to `D_8013EC00`. When that index is in the 24-slot table, it clears the corresponding byte in `D_8008D494` and resets the object's history index and state. Invalid indices leave all three values unchanged. Both symbols are data references; the routine uses no rodata.

The runtime comparison includes the cleanup function. `make progress` checks
the source/header/object hashes, function boundaries, section addresses, and
linked bytes of all three blocks.

The arena initializer at `0x8004DE8C` and the history-update routine at
`0x8004DEE0` remain excluded research. The best local initializer candidate
has the correct 76-byte size and 15 different words. The history update has
the correct 648-byte size and 56 different words, starting at `0x8004E038`.
Its prefix through `0x8004E034` matches. These partial comparisons are
evidence for continued work and contribute no matching-C bytes.

The continuation probes preserve both blockers under
`.local/continuation2-worker2-20260927`. The initializer search varies the
parameter representation, mask handling, staged size calculation, header and
sentinel temporaries, return form, and safe parameter reuse while retaining
ordinary heap semantics. The best 76-byte form reduces the remaining
register-allocation gap to 15 words. The earlier lower-scoring permuter outputs rely on compiler-shaping
constructs such as constant `do` or empty `if` blocks and are not recovered C.

`dee0_best_56.c` records the history-update source recovered from the target.
Its 648-byte comparison is exact through `0x8004E034`; all remaining
differences are in the coordinate-history tail. That tail records the current
XYZ position in a sixteen-entry ring, converts through the global float scale,
and performs the observed volatile intermediate stores before the final
times-twelve values. Declaration-order, local reuse, direct-global and scoped
forms preserve the behavior but do not reproduce the target register and FPU
schedule.
