# Actor boundary and boss creation

The complete boss-part constructor at `8001049C..800107A0` contains 772 bytes
and 193 instructions. The pinned IDO 5.3 game profile reproduces every word
and its 32-byte stack frame from `src/game/actor_groups/boss_create.c`.
Its local error string owns 24 initialized bytes at `8008FB8C..8008FBA4`.
Two timestamp definitions own eight bytes of BSS at `80097354..8009735C`;
they claim no ROM bytes.

The constructor first copies the current timestamp into both globals and
selects the resource and animation pointers. A negative phase then returns
zero without inspecting the position pointer. Phase zero resets the chain,
sets the animation limit to five and index to four, and stores 25,600 in the
current player's saved field at offset `24`.

For other phases, it retains the existing index and saved value. It writes
the supplied position as `(0, -20000, 0)`, then allocates actor kind eight.
The selected resource is record four when the animation index exceeds four;
otherwise the index is used directly. Negative indices remain unchecked.
Successful allocation sets angle 1,024, computes the two movement components
using the existing fixed trigonometry, submits angle and floating-point scale,
and clears position Z. The scale is the resource's integer field `0C` times
2,028, converted to float and divided by 40,960.

Retail retains the read and self-assignment of actor field `2C` at
`800105DC..800105E4`. The source preserves these instructions. Separate
timestamp assignments also preserve the two reads of the clock. Animation
eight is selected for phase zero; other nonnegative phases select zero.
The player's saved value narrows to the actor's signed halfword at offset `10`.
The ready flag becomes one, and equality of the animation index and limit
selects the existing advance routine instead of the reset routine.

Failed allocation calls the fatal diagnostic with the reconstructed string.
If that diagnostic returns, retail continues and dereferences the null actor.
The source preserves this behavior. The execution checker stops at the fatal
call and makes no claim about recovery after a returning diagnostic.

The shared player and session views expose saved-player `value24`, session
`animationReady90` and `animationLimitA0`. Their sizes remain 160, 3,508 and
328 bytes. The existing 96-byte scene-resource record now lives in the shared
session header; the complete 488-byte animation advance routine still matches.
The boss selector's multiply establishes a 1,004-byte resource-set stride.
Only the first five 96-byte records are interpreted; the remaining 524 bytes
retain an opaque view. The one verified animation selector at `8007356C`
points to `80073170`. Neither its full array extent nor valid caller indices
are established, and the selector retains its existing fallback ownership.

Ghidra MCP verifies the layouts, the complete constructor listing, its
prototype, the string, timestamp storage and references. The game-state
caller has a call at `80020B74`. The following routine at `800107A0` reads and
updates the first timestamp. These callers and the update routine retain
their current fallback status.

The actor-boundary clamp at `80018480..800186D8` is reconstructed separately in
`src/game/actor_contacts/boundary.c`. Its full 600-byte body and 72-byte frame
have two instruction differences:

| Address | Retail | Candidate |
| --- | --- | --- |
| `80018590` | `afa20030` | `afa2002c` |
| `80018594` | `8fa30030` | `8fa3002c` |

These store and reload the first absolute-value result at stack offset `30`
instead of `2C`. Every other word, including the division checks, agrees.
This routine remains an excluded candidate: it has no manifest entry or
linked source ownership and adds nothing to matching progress.

The boundary routine tests Y lower, Y upper, X lower and X upper in that
order, using inclusive comparisons and the signed margin at actor offset `06`.
Each clamp submits the updated position to the object helper. When the
diagonal mode is enabled, it restricts the sum of absolute X and Y using
fixed-point division, preserving the signs and setting the changed flag.
Ghidra records two calls from the routine at `800190F8`. This caller remains
unrecovered.

The optional MIPS checker compares compiled and retail execution against
independent guarded byte and call expectations. All 1,740 cases pass:
972 boundary cases and 768 constructor cases. Boundary inputs cover six
margins, nine X and Y values, and both diagonal modes. Constructor inputs
cover four phases, both players, four animation indices, three limits, both
allocation outcomes and four movement/scale profiles. They include 192
negative-phase cases with an unmapped position argument and 288 allocation
failures stopped at the fatal boundary.

Four freshly compiled, completely matching arithmetic routines and the sine
table execute real support code. Object submission, allocation, reset,
animation and diagnostic effects use ABI stubs that clobber caller-saved
integer and floating-point registers. Completed calls restore the stack and
saved registers and return to the sentinel. Fatal-boundary cases intentionally
stop before return. The checker verifies full actor, player, session, position,
resource and timestamp records with surrounding guards, call order and
arguments, signed narrowing and actual single-precision scale bits.

Only selector index zero and its one verified pointer are executed. The
selected boundary inputs do not reach a zero divisor after rectangular
clamping, so division exception delivery is not tested. Signed overflow and
negative shifts describe pinned IDO/MIPS behavior rather than portable ISO C.
Actual allocation, object rendering, animation effects, invalid required
pointers and complete gameplay behavior remain outside the execution proof.

Run the checker with Unicorn installed:

```sh
python3 tools/check_actor_boundary_boss.py
```

The integrated ROM matches all 8,388,608 target bytes. Complete independent
comparisons pass for 857 runtime units, two startup units, eighteen assembly
units and 96 data-only units. All 152 tooling tests pass.
An isolated clean extraction and rebuild also reproduces the full ROM and
passes all tooling tests with the same verified source and comparison inputs.
[The provenance ledger](actor-boundary-and-boss-provenance.json) records current
inputs, compiler identity, ELF ownership, Ghidra evidence and execution limits.
Raw objects contain twelve trailing zero bytes after the constructor, eight
after the string, and eight alignment bytes after the timestamp definitions.
Only verified compiler alignment is removed; no instructions or data are patched.

Matching C now totals 1,374 functions and 264,372 instruction bytes.
Initialized ownership is 29,407 bytes and BSS ownership is 504,115 bytes.
The provisional CPU inventory retains 185,824 fallback bytes in 213 ranges;
its complete function and executable-byte denominators remain unknown.

The compiler and matching workflow follow the local SM64 reference.
The IDO optimizer's temporary-storage allocator was consulted during frame
and spill investigation. Robotron's complete retail instructions establish
behavior and layout; no reference implementation was copied. The execution
checker uses [Unicorn](https://www.unicorn-engine.org/). Reference revisions
and consulted file hashes are recorded in the ledger.
