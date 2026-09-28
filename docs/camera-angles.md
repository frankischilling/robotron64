# Camera angle conversion probes

The two camera-angle gaps use the same conversion pattern with different
fixed-angle Y handling and different scale globals.

| Function | VRAM range | Bytes | Scale | Fixed Y |
| --- | --- | ---: | --- | --- |
| `func_80039FCC` | `0x80039FCC..0x8003A070` | 164 | `D_FLT_80094C48` | `(y + 0x800) & 0xFFD` |
| `func_8003A128` | `0x8003A128..0x8003A1C8` | 160 | `D_FLT_80094C4C` | `y & 0xFFD` |

Both write the three fixed angles in `D_800C8BD8`, convert X, Y and Z through
the float scale and `2048`, write the results to `D_800C8B88.angle24`, and
copy those values to `D_800C8B88.angle04`. The existing candidates preserve
that behavior but remain excluded from matching integration. Under IDO 5.3
with `-O2 -G 0 -non_shared -mips1 -32`, using integer literal `2048` preserves
the intended division and prevents IDO from strength-reducing the expression
to a reciprocal multiply. With that source form, `func_80039FCC` is 152 bytes
against the 164-byte target with 35 differing words, while `func_8003A128` is
148 bytes against the 160-byte target with 34 differing words.

The retail functions contain three additional scheduler stalls beyond those
ordinary candidates. Source-order, temporary-float, pointer-local, explicit
cast, global-qualifier, and compiler-profile probes did not reproduce that
schedule with source-meaningful C. IDO 7.1 emits the same 148-byte
`func_8003A128` result for the baseline expression, `-mips2` increases the
word differences without fixing the size, and `-O1` expands the function well
beyond the target.

A diagnostic decomp-permuter run proves the schedule is compiler reachable:
wrapping the normal `func_8003A128` body in a constant `if (1)` produces an
exact 160-byte function with zero differing words. A plain lexical scope does
not; it remains 148 bytes with 34 differing words. The constant branch is a
code-generation artifact with no source or behavioral evidence, so it is
retained only as probe evidence and is not accepted as recovered C. A second
permuter run with constant-control-flow, no-op arithmetic, padding variables,
fake references, duplicate assignments and similar shaping passes disabled
found no acceptable improvement.

Caller inspection does not support narrowing any angle parameter to 16 bits.
For example, the direct FCC call at `0x80026140` loads its Y argument with a
full 32-bit `lw` from offset `0x3C` of the caller's record. The sole direct
A128 call at `0x80004080` forms its Y argument by adding `0x800` to another
32-bit value. Permuter candidates that introduce `short` temporaries are
therefore retained only as rejected probe evidence.

The saved comparison artifacts are under
`.local/continuation2-worker2-20260927`, including `camera_fcc_baseline`,
`camera_a128_baseline`, `a128_target.s`, `fcc_target.s`, and the rejected
exact diagnostic in `camera_a128_if_only`.
