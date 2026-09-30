# Frame submission and matrix commands

The frame-end routine, projection refresh, and matrix-command helper reproduce three complete target functions with IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`.

| Source | Function | Runtime range | ROM range | Bytes |
| --- | --- | --- | --- | ---: |
| `src/boot/frame_render.c` | `func_800489F4` | `0x800489F4..0x80048B8C` | `0x495F4..0x4978C` | 408 |
| `src/boot/frame_projection.c` | `func_800493F4` | `0x800493F4..0x80049514` | `0x49FF4..0x4A114` | 288 |
| `src/boot/frame_matrices.c` | `func_80049514` | `0x80049514..0x800495BC` | `0x4A114..0x4A1BC` | 168 |

Ranges use exclusive end addresses. All three functions are included in the matching manifest. Their original callers and globals retain address-based names where the game-specific meaning has not been established.

## Ending and submitting a frame

When `D_80097640` is nonzero, `func_800489F4` emits six additional display-list commands: a pipe sync, blend and primitive-depth words, two other-mode commands, and a fill rectangle. It always appends full sync and end-of-display-list commands, then calls `func_80060720`.

The first submission sets `D_8007D918` to one. Later submissions wait through `func_80050084`. That matched helper waits for a type-2 completion message followed by a type-1 message, as described in [graphics task production](graphics-tasks.md).

The caller selects the `0x58`-byte task record `D_8013D8A0[D_8007D914]`. It passes the start pointer `D_80138278`, the byte difference between the current cursor and that start, the microcode selector `D_8007D8EC`, and scheduler flag `0x40` to `func_8005018C`. The source keeps the separate task local and the start-pointer assignment in the call expression. IDO then reproduces the target's pointer loads and temporary-register ordering. All 408 instruction bytes match, including the 32-byte stack frame and return sequence.

## Loading the frame matrices

`func_800493F4` converts its integer input into a field-of-view angle through
`func_8004CE08`, builds a perspective matrix at `D_8013823C + 0x100`, emits the
perspective-normalization word, and loads the projection and view matrices. The
local `fovy` precedes the real `unsigned short perspNorm`; that declaration order
places the halfword at the target stack offset `0x3A`. Reversing the two locals
moves it four bytes and changes two instructions. All `0x120` code bytes and the
12-byte literal pool at `0x80095498..0x800954A4` match the target ROM.

`func_80049514` first emits command `BC00000E` with the unsigned halfword at `D_8013D950`. It then emits matrix commands `01030040` and `01010040`. Their addresses use the current frame index times 64, plus the base pointer `D_8013823C`. The second address is 128 bytes after the first.

The source performs unsigned address arithmetic with offsets `0x80000000` and `0x80000080`. This preserves the target's conversion from its KSEG0 pointers and the compiler's shared construction of the two constants. The three commands advance the cursor by 24 bytes. The compiled function matches all 168 target bytes.

## Verification

`python3 tools/compare_runtime.py` compiles and compares all three ranges independently. It assigns addresses only to undefined references, leaving the source's function definitions intact. The ROM build maps the input objects to the same ranges and records their source, header, and object hashes for `make progress`.

IDO adds eight zero bytes after each function. The build removes only that trailing padding after checking that no live symbol or relocation overlaps it. `make verify` compares the complete output ROM, including the remaining extracted frame-begin code. Frame begin and the alternate pacing loop remain excluded candidates until their complete comparisons match.

## Alternate pacing loop revisit

The recovery evidence under `.local/recovery7-frame` substantially narrows `func_8004FEA8` without promoting an ambiguous source reconstruction. The target initializes `D_8008D574` to `-1` in `func_8004FE10`; the pacing loop later treats that negative state separately from the `0..30` state range. A source form that reuses one ordinary `int` for the received message type and then for the state value reproduces the target's use of `v1`. An unsigned `>= 31` guard followed by the positive-state switch reproduces the target's duplicated bounds-check structure.

IDO emits the ROM's 31-entry table only when the positive-state switch contains a sufficiently dense sparse set of no-op labels and a maximum label of `30`. Multiple different case sets produce the same machine code and the same table, so the exact original no-op case labels cannot be recovered from the table alone. The shortest tested sets that cross IDO's table-selection threshold are not uniquely distinguished by any target instruction. For that reason the maintained `src/boot/graphics_pacing.c` remains the simpler behavioral candidate rather than encoding arbitrary empty labels.

A private near-match uses real `-1` control flow, the shared message/state temporary, and one representative sparse case set. With IDO 5.3 `-O2 -G0 -non_shared -mips1 -32`, every reachable instruction from `0x8004FEA8` through `0x80050047` matches, and the 31-entry table at `0x80095BF0` matches byte-for-byte. The only residual is unreachable compiler output: the candidate places its restore epilogue at `0x80050048` with function size `0x1D4`, while the ROM contains two additional zero instructions and begins the same epilogue at `0x80050050`, giving size `0x1DC`. This produces 16 reported word differences because the identical restore sequence is shifted by eight bytes.

The residual does not change with IDO 7.1, `-O3`, explicit `default` labels, `for (;;)` versus `while (1)`, or the supported sparse case sets that retain the target table. `-O1` and `-mips2` lose the target allocation/table strategy. `-Wab,-r4300_mul` is byte-identical here and has no effect. No production padding, artificial locals, empty code-generation conditions, or copied instructions are used to close the unreachable eight-byte gap.
