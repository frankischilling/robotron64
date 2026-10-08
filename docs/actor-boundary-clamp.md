# Actor boundary clamp

The complete `func_80018480` occupies `80018480..800186D8`, ROM
`19080..192D8`: 600 bytes and 150 instructions. The unchanged pinned IDO 5.3
game profile reproduces every instruction, the 72-byte frame and all stack
homes from `src/game/actor_contacts/boundary.c`.

The natural ELF function symbol is 600 bytes. The raw `.text` section contains
eight additional zero alignment bytes, which receive no instruction credit.
The function generates no game data, jump table or BSS. Its three external
references resolve to the existing object-position helper, integer absolute
value helper and diagonal-mode field. `D_800BA784` is the already owned
scene-arrival field at `D_800B9A78 + 0xD0C`; it adds no storage ownership.

The routine clamps Y lower, Y upper, X lower and X upper in that order.
Comparisons are inclusive. The signed halfword at actor offset `06` adjusts
the rectangular bounds from -30,000 to 30,000. Each clamp submits the updated
position using the signed object index at offset `0C` and sets the return flag.
When the diagonal field is nonzero, a sum of absolute X and Y above
`42000 - margin` triggers fixed-point slope division and one more submission.
X and Y signs are preserved; Z remains unchanged.

Five integer locals carry values consumed by the routine. The `value`
temporary supplies the object index in the upper-Y clamp, then holds the
absolute slope ratio in the diagonal branch. The final Y calculation consumes
the X absolute value directly. These lifetimes and expression order reproduce
IDO's frame, spill slots and registers without empty conditionals, unused
locals, explicit padding, instruction edits or compiler changes. Original
source spelling and variable names remain unproved.

Ghidra MCP confirms the existing actor pointer type, integer return type and
complete body ending at `800186D7`. The already matching boundary dispatcher
at `800190F8` contains two calls to this routine. Its actor layout and caller
contract are retained. Splat and spimdisasm independently disassemble and
reassemble the full body; both reproduce all 600 retail bytes. Fresh workbench,
asm-differ and objdiff views accompany the complete byte and symbol checks.
A bounded two-worker permuter search retained stack differences. The accepted
readable source was reconstructed from consumed values and compiled separately
after removing an empty conditional from the generated suggestion.

The checker runs 972 boundary cases per image: six signed margins, nine X
values, nine Y values and both diagonal modes. Independent expectations check
the full actor record, surrounding canaries, call arguments and order, global
preservation and the changed result. Actual guest accesses are limited to the
actor, diagonal word, verified support tables and stack; stores are limited to
X/Y and stack. Instruction bounds, stack canaries, saved integer registers,
GP, stack restoration and the return sentinel are checked.

Four complete freshly matched arithmetic units and the existing sine table
execute compiled support instructions. Object submission remains a recorded
ABI stub that clobbers caller-saved integer and floating-point registers.
Five isolated source mutations alter the inclusive comparison, rectangular
margin, diagonal limit, slope denominator and return flag. Each is rejected
after its retail/compiled positive control passes. Mutants retain their actual
natural sizes; a changed-size prefix is never accepted as matching.

The same checker retains 768 boss-constructor cases, including 192 negative
phases and 288 allocation failures stopped at the fatal diagnostic. Its boss
cases compare complete state and surrounding canaries; the boundary access
hooks apply only to the boundary cases. Together these are 1,740 cases and
3,480 paired executions. The original boss evidence remains in
[the earlier ledger](actor-boundary-and-boss-provenance.json).

The [current ledger](actor-boundary-current-provenance.json) records the clean
acceptance snapshot, independent comparisons, complete references, compiler
identity, mutations and source hashes. The linker owns only the complete
600-byte function; the adjacent 1,252-byte prefix and 1,520-byte suffix retain
extracted fallback. Size, address, ROM placement and entry-symbol assertions
protect the split. Matching totals become 1,427 C functions / 310,732 instruction
bytes, with initialized data and BSS unchanged. The whole 8,388,608-byte ROM
comparison still includes 139,452 fallback CPU bytes in 185 spans and 164
unclassified bytes. A complete executable denominator remains unknown.

Signed overflow and negative shifts characterize pinned IDO/MIPS behavior.
Selected cases do not reach a zero divisor after rectangular clamping, so
division exception delivery is outside this execution proof. Callee-saved
floating-point registers, actual object submission, aliasing, invalid actor
pointers, hardware effects and complete gameplay remain unverified.
The matching workflow follows the local SM64 and IDO references credited in
[CREDITS](../CREDITS.md), [the reference study](reference-study.md) and
[the toolchain notes](toolchain.md). No reference game implementation is copied.

Run the bounded checker with Unicorn installed:

```sh
python3 tools/check_actor_boundary_boss.py
```
