# Actor-group path callbacks

The rotation candidates at `8000E720..8000E894` and the path callback at
`8000E894..8000EAE4` remain excluded from the matching build. Their complete
retail instructions guide reconstruction; Ghidra's pseudocode is checked
against the original ROM and compiled IDO output.

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

## Validation and remaining differences

The combined rotation object contains all 372 instruction bytes, with one
commuted multiply in each procedure still different. The path object contains
all 592 instruction bytes and differs in 88 words. Neither object is linked
into the ROM or counted as a recovered function.

The optional checker passes 8,512 rotation and 1,008 path cases: 336 complete
the path and 672 interpolate a segment. It covers all 4,096 masked angles,
wrapped angles, signed coordinates, overlapping buffers, paths of two through
five points, the first and last heap path slots, segment boundaries, multiple
segment crossings, and negative/zero/positive steps. Seven complete arithmetic
support units and the short-sine and tangent tables are freshly compiled and
matched before execution. Completion and object-angle submission use stubs
that record arguments and actor snapshots and clobber caller-saved registers.
The check preserves the pool, parameter and actor Z coordinate and verifies
the stack and saved registers. Invalid indices and zero distances are outside
its scope; it does not prove full-game behavior or instruction matching.

Run it after installing the optional analysis requirements:

```sh
make analysis-setup
.venv/bin/python tools/check_actor_group_path.py
```

The [provenance ledger](actor-group-path-provenance.json) records compiler and
input hashes, complete instruction differences, code hashes, the table
comparison and execution coverage. The live Ghidra project retains the verified
callback prototype, existing heap layouts and a typed 65-word tangent array.

A clean extraction and build reproduce all 8,388,608 bytes with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
Matching C remains 1,366 functions / 259,356 bytes; initialized ownership
advances from 29,003 to 29,263 bytes and BSS remains 465,119 bytes. All 152
tooling tests pass. Full-ROM equality includes fallback and does not establish
full source completion.

Independent comparisons also pass for all 849 runtime, two startup, eighteen
assembly and 87 data-only source units.
