# Early actor decision callback

The complete callback at `8000FBC0..80010460` contains 2,208 bytes and 552
instructions. Pinned IDO 5.3 reproduces every word and the 80-byte frame from
`src/game/actor_groups/decision.c`. Both direction-difference locals are used.
The source has no artificial padding, forced registers or patched words.

The shared 204-byte animation record now exposes an initial animation,
six movement choices, five weighted choices and three reset choices. A
12-byte union preserves the unsigned weighted flags and signed reset
threshold view. The already matching phase-advance routine clears the reset
view. The session remains 328 bytes and now names distance at `98`, movement
at `AC` and callback kind at `B0`.

The callback clears the three decision fields, computes integer distance,
and compares the current player's signed value divided by 256 with an
indexed threshold. The initial-animation branch reads its indexed value
byte from the static animation table even when the index is zero. It then
draws a signed random remainder before checking weighted choices.

Weighted choices preserve the strict distance bands, bonus-wave gating,
callback selection through the stored session kind, creation limit and
camera effect. A `DEADBEEF` animation rerolls after those effects. Reset
choices consume their flag before the animation call. If neither stage
selects an animation, direction is rounded, wrapped and checked through
repeated absolute-value calls before choosing a movement animation.

The optional MIPS checker passes 3,028 compiled/retail cases against guarded
byte and call expectations: 1,512 weighted-choice cases, 240 initial-phase
cases, 480 reset cases, 792 angle cases and four intentional division traps.
The matrix observes 4,482 random draws, 2,936 animation calls, 240 creation
calls, 168 spawn calls and 336 camera calls. It covers both players, five
phases, strict distance and angle boundaries, signed random remainders,
the spawn-count limit, unavailable movement choices and callbacks that
change session phase, decision state or bonus-wave counts.

Six freshly matched support units execute integer square root, direction,
absolute value and the random wrapper. Its SDK random leaf and animation,
creation, spawn and camera boundaries use integer and floating-point ABI
stubs. Required pointers refer to guarded synthetic buffers. The static
animation bytes are patterned inputs; the checker does not assert their
full retail initializer or enclosing extent. Direction inputs cover zero
and cardinals; arbitrary quantization and full gameplay remain outside
this proof.

Every normal return restores the integer saved registers, stack and F20
through F31. Real `mtc1` and `swc1` instructions seed and check the floating-
point registers. The callback writes its argument into the caller's first
stack home slot; the remaining 28 caller bytes stay unchanged. Complete
actor, player, session, record, threshold, static-table and control buffers
retain their guards. The two division traps stop at the observed `break 6`
or `break 7` instruction before restoration. Ghidra's full listing verifies
all eight division-guard break words, including unreachable constant guards.

Run the checker with Unicorn installed:

```sh
python3 tools/check_actor_decision.py
```

The integrated ROM matches all 8,388,608 target bytes. Complete independent
comparisons pass for 859 runtime, two startup, eighteen assembly and 98
data-only units; all 152 tooling tests pass.
An isolated extraction and clean rebuild reproduces the same complete ROM
and passes all 152 tests; 1,149 current comparison inputs are verified.
The 2,208-byte raw text section
contains no alignment tail, initializer, BSS or patched instructions.
[The provenance ledger](actor-decision-provenance.json) records current
inputs, compiler identity, linked ELF ownership, Ghidra evidence and limits.

Matching C totals 1,376 functions and 267,520 instruction bytes. Initialized
ownership remains 29,691 bytes and BSS remains 504,115 bytes. The provisional
CPU inventory retains 182,676 fallback bytes in 212 ranges. Complete code
and function denominators remain unknown.

The enclosing threshold and static animation-table extents remain unowned.
Required pointers and caller indices are unchecked. Signed overflow and
shifts characterize pinned IDO/MIPS rather than portable C. Ghidra imports
the canonical slot, record and session types and retains existing named
interior session globals.

Local SM64 and IDO references inform the compiler and comparison workflow;
their revisions and consulted file hashes are recorded in the ledger.
Robotron's retail instructions establish behavior and layout. The execution
checker uses [Unicorn](https://www.unicorn-engine.org/). No reference game
implementation was copied.
