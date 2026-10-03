# Actor collision response

`src/game/collisions/response_gate.c` and `pickup_response.c` recover the
adjacent callbacks at `[0x80015BF8, 0x80015F00)` and
`[0x80015F00, 0x800162AC)`. Their complete 776 and 940 instruction bytes
match the USA ROM with pinned IDO 5.3 and the existing O2/MIPS I profile.
The gate generates its 33-entry, 132-byte switch table at `0x8008FE64`.
`pickup_order.c` defines the three integers `{1, 0, 2}` at `0x800739BC`.
These twelve initialized bytes match independently; neighboring words
remain separate ownership.

The collision matrix initializer selects the gate for actor kinds zero
and two, and the pickup callback for kinds two and three. The consumer at
`0x800194DC` supplies two actors and two position vectors. The gate leaves
both vectors unused but stores their incoming registers in their ABI home
slots. The pickup callback uses their first two signed coordinates and
sets the spawned midpoint's third coordinate to zero. It returns 32 after
collecting a resource kind below four and otherwise returns zero.

The gate rejects animation one and flags `0x4400` on the second actor.
Resource kinds six, seven and eight use the signed short direction result,
absolute angular difference masked to eleven bits, and inclusive limits
700, 1000 and 850. Kind one compares absolute Z against half the signed
width, with division rounded toward zero. Kind 33 preserves the unsigned
elapsed-time test above 500, animation exclusions, second-actor counter
increment, animation and trigonometry calls, zeroed movement components,
old callback cancellation and new callback/timer assignment. Callback
changes to flags and the counter are observed by subsequent reads.

The gate saves the second actor's owner before calling damage. A depleted
first actor or a global mode other than minus one triggers retirement.
In mode minus one, its signed resource halfword at offset four is credited
to that saved owner. The damage and retirement implementations remain
separate work; this recovery does not infer their complete behavior.

The pickup callback sets a zero menu halfword to minus one and advances
the three-resource sequence only when the next entry matches. It selects
sound and color by resource kind, issues the common cue and sound, adds
1,000 when the running value is below 5,000, and credits that value. This
is a conditional increment, so values such as 4,999 become 5,999. It can
allocate a midpoint label, invoke the label's resource callback, and issue
a second credit and label when the sequence reaches three. Game mode
three suppresses allocation. The second label's timestamp is reduced by
the signed delay divided by three. The final signed scene counter uses
the resource kind read after those calls and retains halfword narrowing.

Source line grouping matters to IDO's scheduling. The color assignments
use separate statements on separate lines; grouping them on one line
changes thirteen store instructions. No instruction patching, forced
registers, dummy padding locals or compiler-profile changes are used.
The caller preserves the retail argument eight supplied to the otherwise
argument-free cue routine through its unprototyped declaration.

`python tools/check_actor_collision_response.py` freshly compiles both
callbacks, the gate table, the order data and the existing absolute-value
helper, then compares retail and compiled execution in 3,636 cases against
independent arithmetic, call-order and guarded-state oracles. These cover
inclusive angle boundaries, short narrowing, integer extremes, animation
and flag guards, elapsed-time wrapping, callback mutations, allocation
failure, negative midpoint division, score increments, sequence states,
saved ownership and timestamp adjustment. Caller-saved integer and FPU
registers are clobbered at stubbed calls; stack and integer callee-saved
registers are checked on return. Calls to other game services use ABI
stubs. This checker does not establish their real side effects or complete
gameplay.

Ghidra MCP imported the canonical 124-byte actor and 88-byte resource
layouts, applied the four-argument callback signatures, examined the
matrix references and refreshed the decompiler. Its degenerate pickup
function body was bounded independently by the next function and verified
with retail instructions. The canonical header layouts and recorded
symbol ownership remain authoritative for compilation.

Private splat 0.50.0/spimdisasm 1.42.4 output was reassembled with MIPS
binutils and checked against every retail instruction and gate-table
byte. Objdiff and asm-differ were used alongside complete byte comparison.
m2c supplied a seed with IDO context; a stack-aware, two-worker permuter
search did not improve the candidate. The final match came from the
source line-grouping experiment. Generated assembly, reference objects,
decompiler output and ROM content stay in ignored local directories.

The [provenance ledger](actor-collision-response-provenance.json) records
the final inputs, complete comparisons, raw padding, execution checks and
clean-build evidence. [Issue #43](https://github.com/frankischilling/robotron64/issues/43)
tracks the remaining early actor recovery. The tools and
local reference repositories are credited in [CREDITS.md](../CREDITS.md).
