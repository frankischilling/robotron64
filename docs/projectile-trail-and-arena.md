# Projectile trail and resource arena

The projectile draw callback at `8004E364..8004E7D4` now has a complete C
candidate in `src/game/actor_history/trail.c`. It remains excluded from
matching totals and the ROM link. The arena and heap state described below
are source owned; their existing consumers retain their matching code.

## Projectile ribbon

The matching projectile constructor installs this callback and assigns one
of 24 history slots. Each slot holds sixteen twelve-byte integer positions.
The matching update callback writes the positions through a ring index.

The draw callback returns zero while the game timing word is zero, the
slot's allocation flag is clear, or the object's visibility helper rejects
the object. It selects graphics mode one and asks for a vertex range.
Failure to obtain that range returns one. The successful path submits an
identity matrix with zero projected translation and reads palette entry one.
For the final twenty lifetime ticks, its color becomes red.

The number of positions considered is `400 / timing`, using unsigned
division, clamped to `5..14`. The callback visits history entries in reverse
order, masks each index with fifteen, subtracts the camera position, shifts
each coordinate right once, and transforms it with the camera matrix.
It duplicates the first and last transformed points at the ends of the
scratch sequence.

For each interior point, the sums of the adjacent x and y differences,
shifted right once, determine two perpendicular ribbon edges. The callback
joins each pair to the preceding pair with the existing quad helper. Color
components are multiplied by a fade value that starts at sixteen, shifted
right four bits, and reduced on each iteration. The final call releases the
number of vertices consumed.

The candidate preserves the early return after matrix submission when fewer
than two history samples exist. It adds no cleanup, bounds checks, or timing
guards beyond those in the target. The sixteen-point scratch capacity is
provisional; matching requires resolving the original stack layout as well
as the register choices and instruction schedule.

## Arena and heap storage

`D_8013D9C0`, `D_8013D9C4`, and `D_8013D9C8` are four-byte byte pointers
for the resource arena's current position, base, and limit. The matching
allocator obtains `0xFA000` bytes from the general heap, assigns the base and
current pointers, and sets the limit to base plus that size. Cache reset
restores the current pointer from the base. Metrics and diagnostics read the
same three words. The new storage owns twelve BSS bytes and does not include
the following alignment gap.

`D_8013EBF0` is the general heap's first block pointer, occupying four BSS
bytes. The matching allocation, free-space, and coalescing functions establish
its type and use. `D_8008D480` is a four-byte initialized zero word that guards
the first arena initialization. Its compiled data matches the target word.
The declaration does not assign a length to the neighboring fixed-math table.

The matching resource reservation helper advances the current pointer by the
requested byte count. It emits the original diagnostic if that pointer exceeds
the limit, then returns current minus the requested count. Its complete error
format, filename, terminators, and compiler alignment own 64 initialized
bytes at `800954F0..80095530`.

## Heap initializer candidate

`src/game/heap/initialize.c` reconstructs the complete initializer at
`8004DE8C..8004DED8`. It rounds the start upward and end downward to four-byte
boundaries, subtracts eight bytes, and clears the low two size bits. The first
block's header contains that size with the low free bit set. The word following
the payload receives the `-2` terminator. It preserves unsigned arithmetic and
the target's lack of a start/end validity check.

The trail checker also compares its complete ordered memory writes over 256
arena bounds with all start/end alignment residues. The separate
[heap initializer audit](heap-initializer-audit.md) extends this to 449 fixtures
with independent memory windows, access/code guards, integer and floating saved
state, and ten rejected controls. These checks do not establish instruction matching.

This initializer remains excluded. Returning a pointer, changing optimization
or instruction-set profiles, and grouping it with the preceding matching heap
functions did not establish a match. The resource loader also remains excluded
with eleven differing words; alternate mesh return declarations improved a
private score but remain unproven and were not accepted.

## Verification

With the optional dependencies from `requirements-analysis.txt` installed,
run `python3 tools/check_projectile_trail.py` after setting up the baserom
and compiler. The checker freshly compiles the candidate and executes both
versions through 5,040 cases. The cases cover disabled timing, both history
clamps, negative and short history counts, ring wrap, the lifetime color
boundary, slots zero/five/twenty-three, allocation flags, visibility, and
vertex-allocation failure. Callee stubs clobber caller-saved integer registers
and compare return values, meaningful call arguments, transformed geometry,
colors, vertex accounting, and unchanged history storage.

These checks pass for the current candidate. The stubs model supporting calls;
they do not run the graphics pipeline or establish full-game behavior. The
candidate still compiles to 1,120 bytes against 1,136 target bytes and differs
in 267 instruction words. The current initializer has a 76-byte natural body
and differs in thirteen words. The earlier provenance ledger records the
preceding initializer comparison; the new heap ledger records the current candidate.

The ribbon match is tracked in [issue #69](https://github.com/frankischilling/robotron64/issues/69);
heap and history work remains in [issue #36](https://github.com/frankischilling/robotron64/issues/36).

The accompanying provenance ledger records complete current comparisons for
the three new storage sections, reservation constants, two new candidates,
the existing resource loader, and supporting matching consumers. Full
comparisons, fresh extraction/build, ROM equality, tooling tests, publication
audit, and hosted CI are required before integration. Whole-ROM equality still
uses fallback for unrecovered procedures.

Robotron's instructions, matching callers, and consumers establish the behavior
and storage roles. The local N64 reference projects and pinned IDO toolchain
remain credited in [CREDITS](../CREDITS.md). No assembly or ROM data from private
experiments is part of the public source.
