# Missile update callback research

`func_80038830` is a complete 1,372-byte / 343-instruction callback at
`80038830..80038D8C`, ROM `39430..3998C`. Retail allocates a 448-byte frame.
Its seven-entry dispatch table occupies `80094BF0..80094C0C`, ROM
`957F0..9580C`. Ghidra's complete bytes agree with the supplied USA ROM.
Unmodified splat and SPIM output independently reassemble the full function
and all 28 table bytes, including seven `R_MIPS_32` relocations. The raw
objects contain four additional zero alignment bytes outside the function.

The readable candidate in `src/game/actor_projectiles/missile_update.c`
remains excluded from the source manifest. Pinned IDO produces the same
1,372-byte natural extent and the exact dispatch table, but a 72-byte frame
and 190 differing instruction words. It adds no instruction, initialized-data
or BSS ownership. [Issue #40](https://github.com/frankischilling/robotron64/issues/40)
tracks remaining actor behavior recovery.

## Confirmed CPU behavior

The callback captures the unsigned resource kind and its 92-byte resource
record before reading elapsed time. Expiry uses unsigned subtraction and
strict `elapsed > duration`; equality continues. Expiry sets the actor's
state byte to 2 and returns before dispatch. Kinds 0 through 3 have no further
effect. Kind 9 installs the draw callback only during initialization.

Kind 4 optionally calls the real object-state no-op, then reloads elapsed
time. It calls the second real no-op with `(elapsed / 100) & 7`, sets the
object angle to 2048, and writes the actor's full-width field at 0x4C from a
strict comparison against the wrapped `duration * 99 / 100` threshold.
Kind 5 installs the draw callback on initialization; subsequent updates
write a triangular phase to field 0x4C using the low byte of twice the age.

Kind 6 installs the draw callback and falls through to kind 10. Initialization
sets field 0x50 from the current clock and subtracts the signed RNG result
shifted right by three, modulo 250. An existing nonzero motion duration calls
the real blend helper. Otherwise, flag bit 1 forces a new heading; the random
path first requires a nonzero frame delta, then applies signed resource-period
remainder and unsigned division by that delta. The RNG takes no arguments.

New motion captures the current player's actor, reads signed resource speed,
and applies wrapped `speed * 5 / 10` when the option word is zero. The real
motion initializer updates flags, old/current speed, duration and old angle.
The heading helper uses the selected actor's position, and the blend helper
executes. The clock is reloaded afterward. A strictly greater-than-250 timer
updates field 0x50 and calls the child creator.

Kind 7 selects the current player's actor. Kind 8 runs the real nearest-actor
search with arguments `(position, 3, 0, 4, 0)` and falls back to that player
when the search returns null. Progress first performs signed division of
kind 7's duration by the global interval, then wrapped multiplication by
unsigned elapsed time and unsigned division by the captured duration. When
progress exceeds the actor's byte at 0x23, the callback stores its low byte,
quantizes heading with `0xFF00`, stores speed, and computes both velocity
components through the real short-trig helpers. Product division by 4096
truncates toward zero. The real object-angle setter executes afterward.

These observations preserve the binary's arithmetic and reload order.
They do not establish the original local declarations or justify unused
storage to reproduce its larger frame.

## Reproduce the guarded comparison

Use the pinned toolchain and a Python environment with Unicorn and Capstone:

```sh
make check-missile-update PYTHON=/root/robotron64-tools/.venv/bin/python
robotron-tools splat split config/analysis/missile_update.yaml
```

The checker freshly compiles, independently links and matches thirteen
complete support units / 5,364 instruction bytes. Real motion initialization,
blend, nearest search, RNG, heading, short trig, object angle and no-op
instructions execute. Two data-only units, the complete short-sine table and
the RNG seed also match; the direction and sine tables are checked against
separate mathematical formulas. Existing canonical headers supply the
124-byte actor, resource field views, 120-byte object, 3,508-byte player,
328-byte session and 24-byte options record. Resource views imply only the
fields actually accessed, not a larger allocation for the supplied resource.

All 1,592 retail/candidate pairs / 3,184 principal executions pass. Fixtures
cover eleven kinds, both initialization modes, strict time boundaries,
negative and extreme speeds, both option modes, both players, existing/new
motion, random periods and frame deltas, nearest-search success/fallback,
progress-byte wrap and child-call boundaries. An independent model checks
complete fixture memory, exact permitted writes, call arguments and actor
snapshots before calls. Every guest instruction, read and write is bounded.
Stack canaries, SP/GP, nine saved integer registers and twelve distinct
F20..F31 words are checked through actual guest instructions.

Nine compiled semantic faults, twelve saved-FPU corruptions, nine saved-integer
corruptions, GP corruption, two invalid accesses, two null-actor probes and
one escaped-code probe are rejected: 36 faults. Positive controls run for
each fault. Four separate executions verify the actual divide-by-zero
`break 7` instruction for zero-duration kinds 7 and 8 in both builds.

The child creator uses an explicit O32 boundary that clobbers sixteen caller
integer registers and F0..F19. Its allocations and memory effects are outside
this check. Successful fixtures cover bounded, distinct synthetic records
and nonzero divisors. Stack interiors are bounded and ABI-checked, without a
byte-identical claim. Arbitrary aliasing, invalid resource kinds, all caller
states, child allocation and full gameplay remain unverified. Passing the
guard does not establish an instruction match.

## Evidence and current limits

The [ledger](actor-missile-update-provenance.json) records complete ranges,
source/tool hashes, independent reference receipts, execution coverage and
fault controls. The public splat configuration includes the exact function
and table with address/size metadata; generated output stays in `.local/`.
Ghidra retains the canonical actor prototype, the verified no-argument RNG
prototype and a saved research bookmark describing the remaining differences.

asm-differ compares the complete linked function, and objdiff displays the
independently verified raw objects. Pinned objdiff rejects the linked ELF
with `Symbol address out of section bounds`; no linked-ELF viewer result is
claimed. The independent linked byte comparator still checks the entire
function and table. Viewer scores receive no source ownership credit.

The full pinned-IDO build matches all 8,388,608 retail bytes with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
That equality includes fallback. All 176 tests pass on Linux and Windows;
Windows skips nine Linux-only checks. Matching totals remain 1,430 C functions
/ 314,348 instruction bytes, twenty-nine assembly functions / 4,372 bytes,
37,843 initialized bytes and 879,157 BSS bytes. The game is not fully decompiled.
Commercial ROM data, generated assembly and binary artifacts remain outside
Git. References and tools are credited in [CREDITS.md](../CREDITS.md).
