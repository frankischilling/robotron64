# Collision callback state

Two complete collision callbacks match all 492 instruction bytes with the
pinned IDO 5.3 game profile. The [provenance ledger](collision-callback-state-provenance.json)
records their complete extents and independent comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_80017A2C` | 160 | Dispatch by actor kind and animation state |
| `func_80017E50` | 332 | Apply a score response or emit a midpoint effect |

## Animation dispatch

The first callback switches on the first actor's resource kind. Kind eleven
skips the response when animation byte `0x1F` is one. Otherwise it updates
the second actor and invokes the shared two-actor service. Other kinds pass
the original four callback arguments to the six-argument collision service,
with mode zero and enable one, then set bit two in the second actor's flags.
Every path returns zero.

The switch form reproduces the target's register allocation. The matching
source uses the verified actor and resource layouts and existing service
interfaces. No jump table or new storage is emitted by this single-case
switch.

## Score response

The second callback returns two on every path. Flag `0x100` on the first
actor suppresses its side effects. With that flag clear, the session word
at offset `0x8C` selects between two responses.

A zero session word adds one hundred through the first actor's owner counter,
divides the first signed halfword at offset `0x10` by five, and calls the
two-actor service with the second actor first. It computes a three-word
midpoint, invokes the first actor's effect service and changes the second
actor's object values to 150, 150 and zero. The shared word at `0x800739CC`
receives the current frame word. A nonzero session word computes the same
midpoint and emits effect nineteen. Both midpoint components use signed
division by two; the third component is zero.

The midpoint stores also occur in the zero-word path, where the following
service takes only the actor pointer. They remain in source because they
are present in the shipped instructions. The counter cast exposes a prefix
already verified for that service; it does not define a new owner allocation.

## Session layout

The word at `0x800AD1C4` belongs to the existing 328-byte session allocation
at `0x800AD138`. The shared definition now exposes it as `value8C`.
The early animation callback writes its fifth argument to this field;
the score callback reads the same field. Complete comparisons check the
writer and all other users of the session header. The allocation size and
all later field offsets remain verified. This recovery owns no additional
initialized data or BSS.

The value's full meaning remains unresolved. Its name records the confirmed
offset without assigning an unsupported gameplay purpose.

## References and validation

The pinned local [IDO](https://github.com/n64decomp/ido) and
[Super Mario 64](https://github.com/n64decomp/sm64) compiler and matching-build
references provide the existing workflow basis. Robotron's complete
instructions establish these callback branches, argument order, signed
arithmetic and session accesses. All thirteen requested reference projects
remain recorded in [the credits](../CREDITS.md). No reference implementation
is copied into these routines.

Validation covers tooling tests, extraction and build, every runtime,
startup, native assembly and data comparison unit, complete linked procedure
extents and the exact USA ROM. Publication also checks a fresh committed
archive and public source inventory. The separate
[death callback recovery](collision-death-result.md) records its own complete
procedure and jump table; it is excluded from this ledger's two-procedure totals.
