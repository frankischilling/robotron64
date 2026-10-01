# Early actor pair spawning

`src/game/early_actor_pair_spawn.c` reconstructs the complete 628-byte
`func_8000F564` procedure at `[0x8000F564, 0x8000F7D8)`. It compiles with the
established IDO 5.3 game profile. The complete procedure is compared against
the supplied USA ROM; no data or BSS ownership is added.

The helper stores its incoming word in `D_80073588` and selects a position
relative to the actor at `D_800AD1B8`. When `D_80097350` is zero, each axis
uses a fresh random value, shifted right by three, modulo 10,000, then
offset by -5,000. Otherwise, the owner's signed 16-bit angle is combined
with `D_80073574[D_80097350]`. Fixed-point cosine and sine place the pair
8,000 units away, with separate random offsets modulo 1,000 minus 500.
The division by 4,096 retains signed truncation toward zero.

Both allocations use kind 9, resource `D_800B4B00`, and the same local
position. If the first succeeds, field `0x54` is cleared and the matching
`func_8001B3DC` helper runs. The second allocation is attempted even if
the first fails. On success, its resource callback receives `(actor, 1)`,
its third position coordinate is cleared, field `0x54` receives the incoming
word, and `func_80009F90(actor, 0)` runs twice. The procedure returns the
second allocation result, including null on failure.

The caller writes only the first two words of its three-word position
array. The allocator at `func_800283D4` reads all three at offsets 0, 4,
and 8 before updating the render object. The original therefore consumes
an unwritten stack word before this helper clears the second actor's third
coordinate. The matching C preserves that behavior; initializing the third
word would add a store absent from the retail procedure. This is observed
retail behavior, not a proposed initialization rule for other callers.

The existing `EarlyGameActor` layout supplies the signed angle at `0x08`,
the resource pointer at `0x24`, field `0x54`, and the position at `0x60`.
The existing typed resource callback at `0x54` and matching spawn/motion
helpers establish the call interfaces. The meaning of the incoming word
and the complete angle-table extent remain unresolved. These symbols retain
their address names and fallback storage.

The source uses Robotron's instructions as its behavioral evidence. All
thirteen requested local and online N64 reference projects, their pinned
revisions, and licensing notes remain in [CREDITS.md](../CREDITS.md).
The [provenance ledger](early-actor-pair-spawn-provenance.json) records
complete source, instruction, compiler, and input identities.
