# Object transform helpers

The 32 functions at ROM `0x3A0C0..0x3A878`, RAM `0x800394C0..0x80039C78`, compile from `src/game/object_transforms.c` with IDO 5.3 and the project MIPS I flags. The range is 1,976 bytes. A linked comparison against the supplied US ROM matches every byte in the range. The manifest entries are contiguous, their linked symbol sizes agree with the target boundaries, and their total is 32 functions / 1,976 bytes.

The names `ObjectRecord`, `ObjectTransform`, `scale`, `angle`, and `position` are working reconstruction names. The accesses below establish offsets, widths, arithmetic, and relationships between fields. They do not establish the original source identifiers or the meaning of untouched fields in the partial structures.

## Recovered layout

Every indexed access to `D_800BF918` computes `(object * 15) * 8`, giving a record stride of `0x78` bytes. The record holds a pointer at offset `0x18`. The pointed-to transform has the following observed float fields:

| Offset | Observed use |
| --- | --- |
| `0x00` | One shared float written by all three per-axis scale setters and by the all-axis scale setter. |
| `0x04` | First angle-like float. |
| `0x08` | Second angle-like float. |
| `0x0C` | Third angle-like float. |
| `0x10` | First position-like float. |
| `0x14` | Second position-like float. |
| `0x18` | Third position-like float. |

The matching helpers expose these `ObjectRecord` offsets:

| Offset | Width | Observed use |
| --- | --- | --- |
| `0x04`, `0x06`, `0x08` | 16-bit | Three values written together by `func_80039C1C`. The stores do not establish signedness. |
| `0x0A` | 16-bit | Value written by `func_80039C5C`. Signedness is not established. |
| `0x12` | 8-bit | Value written by `func_80039BFC`. Signedness is not established by the byte store. |
| `0x18` | 32-bit pointer | Pointer to the transform described above. |
| `0x3C`, `0x40`, `0x44` | 32-bit | Three integer scale mirrors. Each per-axis setter updates one of these while writing the same transform float at `+0x00`. |
| `0x48`, `0x4C`, `0x50` | 32-bit | Three integer angle mirrors. |
| `0x54`, `0x58`, `0x5C` | 32-bit | Three integer position mirrors. |

The padding members in `include/object.h` preserve these offsets and the `0x78` stride. This block does not recover the contents of those padding regions or prove the semantics of fields it never touches.

## Position and scale conversions

`func_800394C0`, `func_8003956C`, and `func_800395C0` write one of the transform floats at `+0x10`, `+0x14`, or `+0x18`. They also multiply the input by `12.0f`, convert the result to a 32-bit integer, and store it at record offsets `0x54`, `0x58`, or `0x5C`. `func_80039614` performs the same operation for all three components from a three-float input array.

`func_8003978C`, `func_800397E0`, and `func_80039834` all write their input to the same transform float at `+0x00`. They multiply it by `4.0f` and update one integer word at `0x3C`, `0x40`, or `0x44` respectively. `func_800399E4` writes that same transform float and copies one converted integer to all three words. The single shared float is target behavior; the three record words are distinct.

For the float-to-integer conversions, the target saves FCSR, selects rounding mode 1, executes `cvt.w.s` or `cvt.w.d`, then restores FCSR. For ordinary finite values in signed 32-bit range, this is truncation toward zero and matches the C casts used by the reconstruction. The target sequence does not define portable C results for NaNs, infinities, or values outside the integer range.

## Angle conversions and masks

The first and third angle setters, `func_800396F4` and `func_80039740`, convert the integer argument to float, multiply by the corresponding target float constant, divide by `2048.0f`, and store the result at transform offsets `0x04` and `0x0C`. Their record mirrors are `value & 0xFFD` at offsets `0x48` and `0x50`.

`func_80039514` handles the middle component. It stores `(value - 1024) * D_FLT_80094C20 / 2048.0f` at transform offset `0x08`, while the integer mirror at record offset `0x4C` is `(1024 - value) & 0xFFD`.

The `0xFFD` mask is present in the target instructions. It keeps the low 12-bit range while clearing bit 1. It must not be replaced with `0xFFF` merely because the reverse helpers use `0xFFF`. The three reverse helpers at `0x80039A90`, `0x80039B00`, and `0x80039B74` multiply the transform float by `2048.0f`, divide by a double constant, truncate to an integer with the FCSR sequence described above, then mask with `0xFFF`. The middle helper adds 1024 before the mask.

The three setter-side floats at `0x80094C20`, `0x80094C24`, and `0x80094C28` decode as `3.141592025756836f`. The three getter-side doubles at `0x80094C30`, `0x80094C38`, and `0x80094C40` decode as `3.13159`. The target therefore does not use identical constants in the two directions. The reconstruction keeps those values separate instead of assuming an exact inverse conversion.

## Accessors and empty routines

`func_80039888`, `func_800398BC`, and `func_800398F0` each copy transform offset `0x00` through the caller's float pointer and also place that value in `$f0`. `func_80039924`, `func_80039958`, and `func_8003998C` do the same for transform offsets `0x04`, `0x08`, and `0x0C`. The first three therefore expose the same shared float even though there are three distinct integer scale mirrors.

`func_80039A40` returns the float at transform offset `0x18`, and `func_80039A68` returns the float at `0x10`. Direct callers use `$f0` immediately after these calls, which supports the current float return types.

Seven functions have only the target's empty-function sequence: `func_800399C0`, `func_800399CC`, `func_800399D8`, `func_80039BE4`, `func_80039BF0`, `func_80039C44`, and `func_80039C50`. Each stores `a0` and `a1` in the incoming argument home area and returns without changing object state. The one direct call found for `func_80039BE4` passes `3` as the second argument, but the callee still has no effect.

`func_80039BFC` stores the low byte of its second argument at record offset `0x12`. `func_80039C1C` stores the low halfwords of its three value arguments at record offsets `0x04`, `0x06`, and `0x08`. `func_80039C5C` stores the low halfword of its second argument at offset `0x0A`.

## ABI limits

The setter family uses provisional `ObjectTransform *` return declarations except for `func_800399E4`, which now uses `void`. In the target, those functions already need the transform pointer in `$v0` to perform their stores, and the direct callers found for `func_80039514`, `func_80039614`, `func_800396F4`, `func_80039740`, and `func_800399E4` do not rely on a returned pointer. The remaining setter helpers have no direct `jal` callers in the scanned CPU range. The matching callee bytes alone therefore do not establish that the original functions had pointer return types.

The complete brain behavior caller supplies further evidence for `func_800399E4`: its pointer-return declaration changes four selector-register instructions, while `void` matches all 988 bytes. The revised setter also matches the complete 1,976-byte transform source unit, and its eight previously accepted caller units remain exact. [Actor behavior recovery](actor-behavior-recovery.md) records the change and fresh combined comparisons.

The same limitation applies to the `ObjectRecord *` declaration of `func_80039C1C`. Its body needs the record address in `$v0` for the halfword stores, and both direct callers ignore the value after the call. A pointer return is possible, but it is not proved by the available caller evidence.

The six pointer-output accessors explicitly load `$f0` before returning, which is stronger evidence for a floating-point return than the incidental pointer values above. No direct callers to those six accessors were found in the scanned CPU range, so caller-side use of that return remains unconfirmed. The integer angle accessors explicitly construct their result in `$v0`, but likewise have no direct callers in the scanned range.

The static direct-call scan covers ROM `[0x1000, 0x70040)`, mapped to VRAM `[0x80000400, 0x8006F440)`. It searches `jal` targets and excludes indirect `jalr` calls. The scan does not establish whether calls exist outside this candidate CPU interval.

## Function inventory

| Function | Bytes |
| --- | ---: |
| `func_800394C0` | 84 |
| `func_80039514` | 88 |
| `func_8003956C` | 84 |
| `func_800395C0` | 84 |
| `func_80039614` | 224 |
| `func_800396F4` | 76 |
| `func_80039740` | 76 |
| `func_8003978C` | 84 |
| `func_800397E0` | 84 |
| `func_80039834` | 84 |
| `func_80039888` | 52 |
| `func_800398BC` | 52 |
| `func_800398F0` | 52 |
| `func_80039924` | 52 |
| `func_80039958` | 52 |
| `func_8003998C` | 52 |
| `func_800399C0` | 12 |
| `func_800399CC` | 12 |
| `func_800399D8` | 12 |
| `func_800399E4` | 92 |
| `func_80039A40` | 40 |
| `func_80039A68` | 40 |
| `func_80039A90` | 112 |
| `func_80039B00` | 116 |
| `func_80039B74` | 112 |
| `func_80039BE4` | 12 |
| `func_80039BF0` | 12 |
| `func_80039BFC` | 32 |
| `func_80039C1C` | 40 |
| `func_80039C44` | 12 |
| `func_80039C50` | 12 |
| `func_80039C5C` | 28 |

These sizes sum to `0x7B8` bytes. The next target byte is ROM `0x3A878`, RAM `0x80039C78`.
