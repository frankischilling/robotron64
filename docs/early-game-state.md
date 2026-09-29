# Early game state and actor recovery

This batch replaces 1,216 bytes of fallback code with eight complete IDO 5.3
functions in the early game region. The recovered routines cover bounded float
movement, selection/camera state, renderer reset, actor construction, actor
callback state, and a position-distance predicate.

| Source | Range | Functions | Bytes |
| --- | --- | --- | ---: |
| `early_float_step.c` | `0x80012690..0x800126E0` | `func_80012690` | 80 |
| `early_selection_state.c` | `0x8001276C..0x80012950` | `func_8001276C`, `func_8001288C` | 484 |
| `early_actor_create.c` | `0x80015184..0x800152E8` | `func_80015184`, `func_80015218`, `func_800152AC` | 356 |
| `early_actor_state.c` | `0x80015554..0x8001567C` | `func_80015554`, `func_80015614` | 296 |

`func_80012690` moves a floating-point value toward a target by at most the
supplied step. `func_8001276C` snapshots six camera values and, when requested,
advances the selection table with wraparound before updating the current player
record. Its direct caller at `0x8003C1A8` passes the advance flag. The adjacent
`func_8001288C` resets camera/object state; target callers occur at
`0x800214D4`, `0x8002205C`, and `0x80022D24`.

`func_80015184` creates kind-9 actors from the indexed resource table, invokes
the resource callback at offset `0x54`, sets the actor's Z position, configures
the object, and installs the callback at `0x80005560`. Direct target callers are
at `0x8000E108`, `0x8001631C`, `0x80016C1C`, `0x80017ACC`, `0x80017CDC`, and
`0x80017E50`. `func_80015218` performs the related fixed-resource creation,
normalizes the source angle with signed `% 0x1000`, and applies the angle to the
created object; its direct callers are at `0x80017E50` and `0x80038830`.
`func_800152AC` is a six-argument service forwarder whose target has no direct
`jal` caller in the cataloged CPU range.

`func_80015554` copies the full 12-byte position from the owner's linked actor,
updates the object position, handles flag `0x40` and the existing callback, then
installs `func_80029210` with timer 999. `func_80015614` compares either X or Y
distance depending on the first actor's angle field; its direct callers are at
`0x8001567C` and `0x80016950`. The recovered `EarlyGameActor` overlay preserves
the established 0x7C actor stride, the resource callback at `0x54`, the owner
link at `0x3C`, the callback at `0x44`, and the position at `0x60`.

The target procedures are bounded by the cataloged function starts and return
instructions, then checked against the US ROM with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
Canonical current-source verification is registered in `tools/compare_runtime.py`.
These four source blocks own no `.data`, `.rodata`, or `.bss`; all referenced
state remains at its established runtime address. The proof ledger and frozen
hashes are recorded in `early-game-state-proof-ledger.md` and
`early-game-state-provenance.json`.

Two adjacent routines remain fallback. `func_800126E0` has the exact 140-byte
extent and recovered table-search behavior but still allocates the table walk
across different registers. `func_80015130` has the exact 84-byte extent and
recovered clamp/subtract behavior but swaps the two live value registers. They
are excluded from the manifest until ordinary C reproduces the target code.
