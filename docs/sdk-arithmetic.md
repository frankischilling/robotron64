# SDK arithmetic helpers

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

`src/libultra/compiler_arithmetic.c` recovers the contiguous IDO 64-bit
arithmetic helper unit at `0x800614E0..0x800617A0`. The block is 704 bytes and
contains ten functions in the same order as the local libultra `libc/ll.c`
reference.

| Function | VRAM range | Bytes | Operation |
| --- | --- | ---: | --- |
| `__ull_rshift` | `0x800614E0..0x8006150C` | 44 | Unsigned 64-bit right shift |
| `__ull_rem` | `0x8006150C..0x80061548` | 60 | Unsigned 64-bit remainder |
| `__ull_div` | `0x80061548..0x80061584` | 60 | Unsigned 64-bit division |
| `__ll_lshift` | `0x80061584..0x800615B0` | 44 | 64-bit left shift |
| `__ll_rem` | `0x800615B0..0x800615EC` | 60 | Remainder with an unsigned divisor conversion |
| `__ll_div` | `0x800615EC..0x80061648` | 92 | Signed 64-bit division |
| `__ll_mul` | `0x80061648..0x80061678` | 48 | Low 64 bits of a 64-bit product |
| `__ull_divremi` | `0x80061678..0x800616D8` | 96 | Quotient and remainder by a 16-bit divisor |
| `__ll_mod` | `0x800616D8..0x80061774` | 156 | Signed modulo with divisor-sign correction |
| `__ll_rshift` | `0x80061774..0x800617A0` | 44 | Signed 64-bit right shift |

The target uses native MIPS III 64-bit instructions throughout this block,
including `ld`, `sd`, `ddiv`, `ddivu`, `dmultu`, `dsllv`, `dsrlv` and `dsrav`.
That instruction set fixes the ISA profile at `-mips3`; MIPS I/II is not an
equivalent source profile for this object.

Both pinned compilers produce the complete target block byte-for-byte with:

```text
-O1 -G 0 -non_shared -mips3 -32
```

IDO 5.3 and IDO 7.1 each emit 704 text bytes, the same ten symbol sizes and
zero differing words across `0x800614E0..0x800617A0`. This object therefore
does not distinguish those compiler versions. IDO 5.3 is a reasonable build
default because the project already uses it elsewhere, but the evidence for
this translation unit supports both versions equally.

At `-O2`, both compiler versions emit a 656-byte object. The first seven
helpers through `__ll_mul` still match individually, while optimization changes
the final three functions and their placement. The retail source-unit profile
is therefore O1 rather than O2.

The helper names and source behavior are supported independently by the local
OOT/libultra `src/libultra/libc/ll.c` reference. Existing frame and scheduler
code also calls `__ll_mul` at `0x80061648` and `__ull_div` at `0x80061548`
for 64-bit time conversion. The source contains no target opcodes, inline
assembly, padding locals or artificial control flow.

Private zero-difference reports and exact source snapshots are stored under
`.local/continuation2-sdk-arithmetic-worker2`. Integration into the build,
manifest and shared symbol configuration is intentionally left to the prime
worker.
