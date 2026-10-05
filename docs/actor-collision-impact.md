# Collision impact handler

`func_80016C1C` is the impact callback installed by the recovered collision
matrix initializer for classes zero and four. Its complete C body replaces
1,864 fallback instruction bytes. The generated switch and the shared RGB
palette add 248 initialized bytes of source ownership.

| Owned unit | Runtime range | ROM range | Bytes |
| --- | --- | --- | ---: |
| Impact handler | `80016C1C..80017364` | `1781C..17F64` | 1,864 |
| Generated 35-entry switch | `8008FFAC..80090038` | `90BAC..90C38` | 140 |
| 36 RGB triples | `80073950..800739BC` | `74550..745BC` | 108 |

The handler returns zero or bit `0x20`. A second actor already carrying
flag `0x100` returns `0x20` immediately. Otherwise it computes a signed
midpoint, dispatches by the first actor's resource kind, and either applies
the special kinds five through eight response or checks the animation,
frame, height and second-kind gates before the general damage response.

The special response can replenish health, decrement the session word at
`0x58`, score and allocate a bonus actor, reset a kind-three second actor,
apply motion impulses, turn and slow the second actor, and update its
timestamp and flag. The general response can retire a depleted actor or
submit its RGB color and effect. Kinds two and 26 through 28 reset motion,
cancel a prior callback, and install the recovery callback with timer 999.
Other surviving kinds advance the object frame by one third of its count.

Ghidra MCP confirmed the function boundary, its matrix references, both
palette uses and the generated switch reference. The following recovered
24-byte function starts at `80017364`. Canonical Ghidra and C types retain
124-byte actors, the existing 92-byte resource view with its signed word at
`0x58`, and the 328-byte session view with a neutral `value58` field. The
resource type has a small shared header so it can be reused without the
unrelated resource loader declarations. The initializer uses the matching
four-argument prototype; its complete 808-byte output remains unchanged.
The canonical session type is imported in Ghidra. Applying it to the whole
global would discard six existing subfield labels, so those labels and the
existing byte-array global view are retained.

The IDO 5.3 game profile reproduces all instructions, the 80-byte stack
frame and all relocated switch words. The angle expression captures the
first angle before computing the signed half difference. Duration arithmetic
uses an explicit 32-bit unsigned difference converted back to the signed
timestamp view. Both callback installations preserve the three sequenced
updates. No padding locals, forced registers, identity expressions or
instruction edits are present. Bonus allocation uses `D_800B1BE8[10]`, the
existing 88-byte-stride resource entry at `800B1F58`; it adds no ownership
claim for that resource array.

splat and spimdisasm generated private retail references. MIPS binutils
reassembled all 1,864 instructions, 140 switch bytes and 108 palette bytes
and compared each complete range with the original ROM. IDO emits eight
trailing text bytes and four trailing bytes for each initialized section;
all are zero compiler alignment and are trimmed outside the declared
ownership. The independent reference objects and extracted bytes remain
ignored. After normalizing the equivalent `D_800B1F58` resource reference to
`D_800B1BE8 + 10 * 88` and rechecking all bytes, objdiff reports 100 percent
for the complete procedure; asm-differ reports zero instruction differences.
Linked switch and palette bytes are
checked separately from objdiff's raw symbol matching.

`python tools/check_actor_collision_impact.py` freshly compiles the full
body, switch and palette, then checks retail and compiled MIPS against an
independent state model. Its 5,214 cases comprise 2,592 dispatch cases,
1,440 gate cases, 240 bonus cases, 576 arithmetic boundary cases, 360
callee-mutation cases and six cases outside the switch. It checks guarded
memory before each call and on return, argument and vector bytes, call
order, the return byte, saved registers, stack restoration and caller home
slots. Mutations cover fresh global/resource reads, owner capture,
allocation callbacks and cancellation before callback replacement.

Called game services use integer and floating-point ABI stubs. These
checks establish the recovered handler's behavior at those boundaries;
actual damage, allocation and rendering effects, invalid palette indices,
complete caller bounds and full gameplay remain unproved. The neighboring
separation candidate and the separate damage candidate remained excluded at
this checkpoint. The subsequent [damage recovery](actor-damage.md) matches the
complete damage handler and checks it with its real balance and value helpers.

The isolated extraction and rebuild reproduce all 8,388,608 ROM bytes.
All 152 tooling tests pass. Fresh independent comparisons cover 866
runtime, two startup, eighteen assembly and 101 data-only units. The
preceding collision checkers retain their 3,636 and 2,570 passing cases;
both recovered rotations retain 8,512 passing cases. The separate 1,008
path cases exercise an excluded candidate.

Matching C totals 1,384 functions and 274,480 instruction bytes.
Initialized ownership totals 30,311 bytes; BSS remains 504,115 bytes.
The provisional CPU interval still contains 175,716 fallback bytes in
210 spans and 152 unclassified bytes. Executable and function denominators
remain unknown. Whole-ROM equality includes fallback and does not establish
full decompilation. The [provenance ledger](actor-collision-impact-provenance.json)
records current inputs, compiler identity, section extents and checks.
[CREDITS](../CREDITS.md) retains the small software and source list.
