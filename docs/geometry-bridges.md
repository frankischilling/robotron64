# Geometry service bridges

Six functions connect game code to the existing geometry and debug services.
Their complete code matches the US target with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`.

| Source | Range | Functions | Code bytes |
| --- | --- | ---: | ---: |
| `geometry_debug_bridge.c` | `0x8003CC30..0x8003CC58` | 2 | 40 |
| `geometry_bridge_apply.c` | `0x8003D170..0x8003D20C` | 3 | 156 |
| `geometry_bridge_rotate.c` | `0x8003D20C..0x8003D2C0` | 1 | 180 |

`func_8003CC30` is empty. `func_8003CC38` calls `func_80048DC0` and returns.
The name of that downstream service remains unresolved.

`func_8003D170`, `func_8003D1A4`, and `func_8003D1D8` have identical bodies.
Each passes `D_800CA5A0` as both output and input to `func_8003FA18`, followed
by its own integer parameter and `D_8007CDC0`. The source preserves the
separate entry points and the in-place call. No distinction among the three
entry points is inferred from their names.

`func_8003D20C` creates two fixed-point matrices and a three-integer result
vector. It initializes the first matrix, then alternates the matrices through
`func_8004CF40`, `func_8004D0DC`, and `func_8004D154`, using successive angle
components. Each angle is masked with `0xFFD`, exactly as in the target.
It transforms the input vector with `func_8004D4B4` and copies all three
result components back to the caller's vector.

These functions use the matrix layout already established in
[fixed geometry](fixed-geometry.md). The new bridge header adds no alternative
matrix layout. No initialized data or BSS belongs to these six functions.

The first complete comparisons and source/header snapshots are under
`.local/recovery50-geometry/probes`. The integration checkpoint rechecks the
complete bodies and procedure boundaries independently under
`.local/recovery51-integration/probes`. Every claimed byte comes from compiled
source; the surrounding uncovered geometry functions remain fallback code.
