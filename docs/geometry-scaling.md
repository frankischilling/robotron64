# Geometry scaling

Two complete geometry procedures match all 940 instruction bytes with the
pinned IDO 5.3 game profile. The [provenance ledger](geometry-scaling-provenance.json)
records complete linked extents and independent comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_8003FA18` | 508 | Apply separate axis factors and a Y offset |
| `func_8003FC14` | 432 | Apply one factor to all three axes |

## Point layout and arguments

Both procedures read and write consecutive twelve-byte points. The shared
`GeometryPoint` definition exposes signed word components X, Y and Z and
checks the complete size. The third argument is a signed point count; the
fourth is the scaling value. A nonpositive count leaves the arrays untouched.
The source loop advances both pointers by one complete point per iteration.
The compiler emits its original remainder loop and four-point unrolling.

The three existing bridge wrappers pass their own argument as the count and
the shared word at `0x8007CDC0` as the scaling value. They operate on the
same input and output buffer. Complete caller comparisons retain all of
their instructions. The explicit point casts expose the confirmed layout
of that buffer through its existing byte view. The buffer's capacity and
allocation remain outside this recovery's claims.

## Arithmetic and store order

For `func_8003FA18`, a scaling value V supplies factors `256 + 2*V` for X,
`256 + 3*V` for Z and `256 - V` for Y. The low signed word product shifts
right by eight. Y then adds the word at `0x800CD2A0`. Stores occur in X, Z,
Y order. The shared Y offset is read for each point, as in the target.

`func_8003FC14` uses `256 - V` for every axis and stores X, Y and Z in that
order. It adds no offset. Both procedures preserve signed arithmetic shifts;
they do not substitute signed division by 256 or clamp component values.
The multiplication operands and all remainder and unrolled iterations match.

The existing compiler profile reproduces the shipped low-word arithmetic,
including out-of-range products. No wider intermediates or overflow checks
are introduced. The point type supports the existing in-place bridge calls;
the source does not claim that arbitrary partially overlapping arrays are
safe.

## References and validation

The pinned local [IDO](https://github.com/n64decomp/ido) and
[Super Mario 64](https://github.com/n64decomp/sm64) compiler and matching-build
references provide the existing workflow basis. Robotron's complete
instructions establish the point stride, argument order, factors, signed
shifts and stores. All thirteen requested projects remain recorded in
[the credits](../CREDITS.md). No reference implementation is copied into
these procedures.

Validation covers tooling tests, extraction and build, every runtime,
startup, native assembly and data comparison unit, complete linked procedure
extents and the exact USA ROM. Publication also checks a fresh committed
archive and public source inventory. These procedures add no initialized
data or BSS; the adjacent depth interpolation procedure remains unrecovered.
