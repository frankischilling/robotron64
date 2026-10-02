# Actor group setup

`func_8000E108` now owns its complete 544-byte procedure at
`8000E108..8000E328` (ROM `ED08..EF28`). Its source is
`src/game/actor_groups/setup.c`. It adds no initialized data or BSS.

The routine creates actors from the existing first-group entries, adding the
two supplied position offsets and setting the spawn Z coordinate to zero.
Entry zero selects the `8000E894` callback and becomes the parent before any
rotation or placement calls. The routine rotates the first two path points
in place, computes their direction, copies the first point into the actor's
position, and submits that position to the object and helper numbered 19.
Later entries select `8000DFEC`, retain their original group X/Y coordinates,
and receive the parent's pointer and angle. Every successful allocation stores
the parameter pointer and clears the three words at offsets `6C`, `70` and `74`.

The fifth and sixth arguments supply X and Y offsets respectively. The fourth
argument is unused, although the matching slot updater passes `value10` there.
Rotation reads `parameter->value10` directly. The shared header now declares
this six-argument interface for both the constructor and its existing caller.

The existing heap layouts establish twelve-byte first-group entries, a
124-byte first group, a 604-byte path group, a 36-byte parameter and the complete
9,096-byte pool. These types were imported into live Ghidra from the canonical
header and checked against the retail procedure and matching appenders. The
pool is heap storage; no static 9,096-byte runtime block was invented for it.

## Compiler and behavior assumptions

The established game profile is IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. The declaration order of the used locals and
the pointer used to fill and pass the spawn coordinates reproduce the retail
136-byte frame. The three buffers use the existing three-word position format;
the two rotation inputs initialize and consume only X/Y. Their third words are
never read by the complete retail rotation helper. No dummy variables,
padding records, inline assembly or register directives are needed.

The source preserves the original unchecked parent access: if entry zero
fails to allocate and a later entry succeeds, the later entry dereferences the
null parent. It does not add a guard or change allocation behavior. The group
count and path index remain unchecked.

The actor allocator `func_8001AF44` returns the existing
`ActorBehaviorActorInternal` view. The routine accesses it through the existing
`EarlyGameActor` view, whose observed
field offsets agree. Callback and parameter pointers occupy integer words in
that historical view. These assumptions depend on the pinned 32-bit target
ABI and compiler; they are not claims of portable ISO C aliasing or pointer
conversion. The callback dispatcher assumptions remain documented in
[palette fade and callback returns](palette-fade-and-callback-returns.md).

## Verification

The [provenance ledger](actor-group-setup-provenance.json) records the complete
procedure and object sizes, current source and header hashes, exact compiler
identity, canonical Ghidra layouts, and the full remaining-range inventory.
Live Ghidra's complete provisional CPU interval remains identical to retail.
Decompiler output guides the source; the original MIPS instructions and full
IDO comparison establish acceptance.

A clean extraction and build reproduce all 8,388,608 ROM bytes with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
All 151 tooling tests pass, and independent comparisons cover 849 runtime,
two startup, eighteen assembly and 86 data-only units. Matching C advances
from 1,365 procedures / 258,812 bytes to 1,366 / 259,356 bytes. Initialized
ownership remains 29,003 bytes and BSS remains 465,119 bytes. The provisional
CPU interval retains 190,840 fallback bytes in 218 ranges and 152 unclassified
bytes. Its complete executable and function denominators remain unverified.

Rotation helper candidates remain excluded until their complete instructions
match. Whole-ROM equality includes remaining fallback and does not establish
full source completion. Compiler and matching practices follow the project's
[N64 reference study](reference-study.md); no reference game code was copied.
