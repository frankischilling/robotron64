# Actor-group callbacks and child storage

The [rotation helpers](actor-group-rotation.md) at `8000E720..8000E894`
are now included in the matching build. The path callback at
`8000E894..8000EAE4` remains excluded. Complete retail instructions guide
reconstruction; Ghidra's pseudocode is checked against the original ROM
and compiled IDO output.

The bonus child routine at `8000F030..8000F318` is also excluded. It allocates
resource record `kind` from the eleven-record child array, returns null on
failure, and places a successful child at Z = -1000. Record four uses the
draw callback selected by `8000CE34(4)`; record nine uses `80005560`, the
parent's heading and one quarter of the resource speed. Other records submit
twice the normal resource scale. The remaining children aim toward the
selected actor with signed random spread and index spacing, derive movement
from Manhattan distance, and submit their heading and mode three. The child
stores its parent pointer at byte `3C` and returns to the caller.

Two declarations own runtime storage without claiming ROM bytes:
`D_800AC998[11]` contains 1,012 bytes of 92-byte resource records, and
`D_800ACD90[11]` contains 44 bytes of per-kind counts. The source-matched
`8001D260` reset loop establishes the resource count and stride;
`800283D4` corroborates the stride, and the matched tweak bindings identify
the value at byte `58`. The `800281C4` cleanup clears exactly 44 counter
bytes; allocation increments and removal decrements an indexed counter.
The existing resource view retains unresolved fields. The four-byte gap
between the arrays remains unowned, and `800ACB08` remains a verified alias
for record four. Source definitions replace all absolute bindings for the
two array bases.

Both rotation helpers mask the angle to twelve bits, read X and Y before
writing either result, and divide signed products by 4096 toward zero.
They support overlapping input and output buffers and leave Z untouched.
`8000E720` first replaces the angle with `1024 - angle`.

The path callback reads the existing parameter and 604-byte pair-group
layouts. It converts `value0C` into a step with two signed divisions, crosses
completed segments, and invokes `8000E5C8(actor, 1)` when the final segment
ends. Otherwise it rotates the two segment endpoints in place, interpolates
X/Y, updates the object's angle, and clears the three movement words. The
second callback argument is saved on entry but never read. Path counts,
indices and nonzero segment distances retain the original unchecked behavior.

The supporting tangent table now has a C definition of 65 words at
`8007C338..8007C43C` (ROM `7CF38..7D03C`). All entries independently agree with
`round(tan(index * pi / 256) * 32767)`. The matching direction helper reads
entries 1 through 63 during its bounded search; the last word is the numerical
endpoint 32767. The twelve zero bytes following the definition remain fallback.
The table's complete 260-byte compiler output is compared independently.

The pinned IDO 5.3 game profile and source ownership workflow follow the
project's [N64 reference study](reference-study.md), including SM64 and IDO.
No reference game implementation was copied. Instruction mismatches remain
outside matching progress, even when execution agrees for tested inputs.

The revised path candidate represents its two endpoint temporaries with the
existing `GeometryPoint` type and exits segment traversal with a `break`. These
source forms reduce the complete comparison from 36 differing words to five.
The point view has three signed words, occupies twelve bytes and aligns to four;
a pinned IDO layout probe and the live Ghidra type agree on all field offsets
and widths. The two stack objects are typed in Ghidra, and the parameter pointer
remains typed after re-decompilation. Only X and Y participate in this callback;
Z remains untouched. The earlier private 27-word candidate is retained as a
research checkpoint, with no matching ownership.

## Validation and remaining differences

The combined rotation object matches all 372 instruction bytes and is linked
and counted as two recovered functions. The path object contains all 592
instruction bytes and differs in five words, all the endpoint-load base register:
retail uses V0 and the candidate uses V1. Its 96-byte stack frame and all spill
offsets agree. The routine remains excluded from the ROM link and matching
source progress.

The bonus child object contains all 744 instruction bytes and differs in six
words: stack size, the incoming index slot and the floating result register.
It is not linked into the ROM or counted as matching C.

The optional checker passes 8,512 rotation and 10,144 path cases: 1,728 complete
the path and 8,416 interpolate a segment. It covers all 4,096 masked angles,
wrapped angles, signed coordinates, overlapping buffers, paths of two through
five points, the first and last heap path slots, segment boundaries, multiple
segment crossings, negative/zero/positive steps, signed speed-product wrapping,
and every masked angle on the path callback itself. Seven complete arithmetic
support units and the short-sine and tangent tables are freshly compiled and
matched before execution. Completion and object-angle submission use stubs
that record arguments and actor snapshots and clobber caller-saved registers.
The check preserves the pool, parameter and actor Z coordinate and verifies
the stack and saved registers. Each retail and candidate path run also checks
a separate Python model of the complete actor image and call snapshots.
Instruction, read and write bounds, outer canaries and GP preservation are checked. Five deliberate changes to
segment equality, speed scaling, interpolation, completion arguments and
movement clearing were detected. Invalid indices and zero distances are outside
its scope; it does not prove full-game behavior or instruction matching.

Run it after installing the optional analysis requirements:

```sh
make analysis-setup
.venv/bin/python tools/check_actor_group_path.py
.venv/bin/python tools/check_actor_bonus_child.py
```

The bonus checker passes 1,668 cases: 810 allocation failures, 270 draw
callbacks, 270 fixed callbacks and 318 scale submissions. Cases include both
selected-actor slots, signed random remainders, negative/zero/positive speed,
heading wrapping, coincident and axis-aligned positions, and wrapped scale
products. Eight complete matching support units and two matching numerical
tables execute compiled code. Allocation, callback selection, RNG and object
submissions use ABI stubs that record arguments and child snapshots and
clobber caller-saved integer and floating registers. The allocator returns a
prepared child or null; it does not verify allocator or drawing behavior.
The check compares the child and its guards, verifies the returned pointer,
call order and scale bits, preserves the parent, selected actor, resources
and session inputs, and checks the stack and saved integer registers.
Invalid resource indices and allocator aliasing are outside its scope.

The historical [provenance ledger](actor-group-path-provenance.json) records
the PR #87 candidates, compiler and input hashes, complete instruction
differences, code hashes, table comparison and execution coverage. Current
rotation acceptance is recorded in its [own ledger](actor-group-rotation-provenance.json).
The [current path research ledger](actor-group-path-current-provenance.json)
records the complete comparison, reference assembly, independent model and
validation for the revised candidate. This work adds no matching code or data.
The live Ghidra project retains the verified
callback prototypes, existing heap layouts, a typed 65-word tangent array,
and the two uninitialized child arrays. Resource typing preserves the
existing interior field labels instead of clearing them. The current audit also
restores the complete `EarlyGameActor` definition after finding an empty one-byte
placeholder; pinned IDO and Ghidra agree on its 124-byte size, four-byte alignment,
and all 36 field offsets and widths.

At the PR #87 checkpoint, isolated extraction and rebuild reproduced all
8,388,608 bytes with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
Matching C totaled 1,366 functions / 259,356 bytes; initialized ownership
advanced from 29,003 to 29,263 bytes and BSS from 465,119 to 466,175
bytes. All 152 tooling tests passed. Full-ROM equality includes fallback and does not establish
full source completion.

Independent comparisons also passed for all 849 runtime, two startup, eighteen
assembly and 89 data-only source units.
