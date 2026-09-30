# Collision, selection and angle results

The complete callback at `0x80017CDC` matches all 372 instruction bytes with
the pinned IDO 5.3 game profile. Its compiler-generated jump table owns twenty
initialized bytes at `0x80090098`. The
[provenance ledger](collision-death-result-provenance.json) records the
complete procedure, table and relocated accesses. The session selection
lookup at `0x800126E0` matches another 140 instruction bytes, for a total
of 512 bytes. The wrapped-angle helper at `0x8000DF30` adds 128 bytes.
The ledger covers three complete procedures and 640 instruction bytes.

## Result and midpoint

Flag `0x100` on the first actor selects result two and skips all side effects.
With that flag clear, the callback invokes the shared two-actor service with
the first actor first, then computes a three-word midpoint from the supplied
positions. X and Y use signed division by two; Z is zero.

The result begins at zero on this path. A nonpositive second signed actor
value at offset `0x10` emits an effect and sets result `0x20`. A nonpositive
first value adds bit two. The return converts the accumulated result to an
unsigned byte. The source assigns result two in the flag-set branch, retaining
the target's complete shared return path.

## Effect dispatch

The second actor's resource kind selects the effect. The table covers kinds
four through eight, with the target addresses below.

| Kind | Effect | Additional call | Table destination |
| --- | ---: | --- | --- |
| 4 | 19 | None | `0x80017DAC` |
| 5 | 19 | None | `0x80017DC0` |
| 6 | 19 | Sound 15 with arguments 0, 1, 0 | `0x80017DD4` |
| 7 | 129 | Sound 15 with arguments 0, 1, 0 | `0x80017DFC` |
| 8 | 129 | Sound 15 with arguments 0, 1, 0 | `0x80017DFC` |

Other kinds use the same body as kind four. The distinct bodies for kinds
four and five remain in source because the target has both entries and
both complete call sequences. The sound result is ignored through the
existing four-argument interface. The table includes every entry and has
no newly claimed terminator or adjacent padding.

## Session selection lookup

The lookup scans the zero-terminated word list at `0x80073864`. It compares
each word with the current saved player's selection byte, using the verified
3,508-byte player stride and session current-player field. A match returns
the word at the same index in the parallel list at `0x80073850`.

The source has no return after the loop. The pinned compiler reproduces the
target's zero result for an initially empty list and its traversal cursor
in V0 when a nonempty list has no match. This fallthrough is undefined in
standard C and remains in the matching source. Adding an explicit zero return
changes the target instructions. The list lengths, valid selection range
and the caller's treatment of a missing entry remain unresolved. No new
array capacity or data ownership is claimed.

## Wrapped-angle approach

The angle helper subtracts the current angle from the target and uses the
existing normalizer to wrap that difference into `-2048` through `2047`.
It obtains the difference's absolute value, limits it to the supplied maximum,
then multiplies by the wrapped difference's sign and adds the current angle.
A zero difference leaves the current angle unchanged. The result itself is
not normalized again.

The source retains the signed maximum comparison. A negative maximum is
accepted and can reverse the direction of movement; no new nonnegative clamp
is added. The normalizer, absolute-value interface, complete sign selection,
low-word multiplication and final addition all match. This helper owns no
new storage.

## References and validation

The pinned local [IDO](https://github.com/n64decomp/ido) and
[Super Mario 64](https://github.com/n64decomp/sm64) compiler and matching-build
references provide the existing workflow basis. Robotron's complete
instructions establish these branches, midpoint arithmetic, unsigned-byte
return, all five jump-table destinations and the selection lookup's fallthrough.
They also establish the angle wrapper, signed limit and final addition.
All thirteen requested projects
remain recorded in [the credits](../CREDITS.md). No reference implementation
is copied into the callback.

Validation covers tooling tests, extraction and build, every runtime,
startup, native assembly and data comparison unit, complete linked procedure
extents, all twenty table bytes and the exact USA ROM. Publication also
checks a fresh committed archive and public source inventory. These recoveries
add no BSS allocation. The related animation and score callbacks are
documented in [collision callback state](collision-callback-state.md).
