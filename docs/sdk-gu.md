# SDK GU matrix and camera helpers

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

Five complete source units recover twelve matrix, projection, highlight,
translation, and Euler-rotation functions. They compile with IDO 5.3 and:

```text
-O3 -G 0 -non_shared -mips2 -32 -Wab,-r4300_mul
```

The ordinary C definitions retain the source order of the corresponding
`src/gu` files in the credited local libreultra checkout. The compiler moves
the matrix conversion and identity procedures into the target order; the
source does not manually rearrange their emitted instructions.

| Source | Live runtime range | Functions | Live bytes | Following alignment bytes |
| --- | --- | ---: | ---: | ---: |
| `gu_perspective.c` | `0x80060750..0x800609D8` | 2 | 648 | 8 |
| `gu_lookathilite.c` | `0x800609E0..0x80061204` | 2 | 2,084 | 12 |
| `gu_translate.c` | `0x80061210..0x800612AC` | 2 | 156 | 4 |
| `gu_rotate_rpy.c` | `0x800612B0..0x80061444` | 2 | 404 | 12 |
| `gu_mtxutil.c` | `0x80068250..0x800684BC` | 4 | 620 | 4 |

Every live instruction matches. The 40 bytes of original object alignment
remain outside the 3,912-byte C total. Independent full-object comparisons
also reproduce those alignment bytes, but they are not additional functions.

## Matrix and lighting layouts

`sdk_gu.h` defines the 64-byte aligned fixed-point matrix, 16-byte light,
32-byte look-at record, and 16-byte highlight record. Their sizes are checked
at compilation. Float matrices retain the SDK's four-by-four layout.

The matrix conversion helpers split signed 16.16 values across the matrix's
integer and fractional halves and reconstruct them with the original signed
interpretation. The perspective helper preserves the floating-point
calculation order and normalization clamp. The look-at helper normalizes the
view, right, up, light, and highlight vectors, then writes both reflection
directions and the two highlight coordinates. Translation and roll/pitch/yaw
rotation retain their SDK float helpers and fixed-matrix wrappers.

## Header and compiler evidence

The local 007 `PR/gu.h` supplies two material macro variants also established
by the target instructions. `FIX32TOF` divides by `65536.0f`; the target matrix
decoder emits `div.s`. `FTOFRAC8` uses the double literals `128.0` and `127.0`;
the target look-at helper emits the corresponding double conversion,
multiplication, and comparison. Float-only alternatives from other reference
headers do not reproduce that complete function.

The assembler's `-r4300_mul` option is also material. Without it, otherwise
matching SDK C produces different multiplication scheduling and object sizes.
The accepted profile reproduces the complete procedures without source-level
delay-slot tricks. These findings establish this block's profile and macro
behavior; they do not identify one unique SDK release for the whole game.

The implementation references are libreultra's `perspective.c`, `lookathil.c`,
`translate.c`, `rotateRPY.c`, and `mtxutil.c`, together with the credited 007
header. OOT, Majora's Mask, Paper Mario, and Perfect Dark variants were compared
where they helped distinguish source and header differences. Exact checkout
revisions are recorded in [credits](../CREDITS.md).

## Constants and static storage

The perspective object owns 16 generated constant bytes at `0x80095CF0`.
The look-at object owns 32 at `0x80095D00`, and the Euler-rotation object owns
16 at `0x80095D20`. All 64 initialized bytes are independently linked and
compared with their target ranges.

IDO folds the rotation helper's static degrees-to-radians constant into the
generated constants while retaining a four-byte private `dtor` symbol in
BSS at `0x80194D10`. The original SDK declaration is retained, and its private
symbol offset is verified through the compiler's ECOFF metadata. That BSS
record consumes no ROM bytes and is not counted as executable code.

Canonical source/header snapshots, compiler identities, symbol maps, linked
objects, and zero-word-difference reports are retained locally under
`build/sdk-options/gu_*`, `.local/recovery9-gu`, and `.local/recovery12-integration`.
