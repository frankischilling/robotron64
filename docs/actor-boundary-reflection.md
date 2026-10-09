# Actor boundary reflection research

`func_800186D8` occupies the complete retail range
`800186D8..80018CC8` (ROM `192D8..198C8`): 1,520 bytes and an 88-byte frame.
The readable candidate in `src/game/actor_contacts/reflection.c` remains
excluded from the ROM build and source-ownership manifest.

Pinned IDO 5.3, O2, MIPS I produces exactly 1,520 natural instruction bytes,
without text alignment, initialized data or BSS. Two instructions differ:
the first absolute-coordinate result is saved and reloaded at stack offset
`0x34`, whereas retail uses `0x3c`. Their addresses are `80018A88` and
`80018A8C`. All other instruction words match after resolving relocations.
The entire extent must match before this procedure receives ownership.

The routine clamps both position axes against bounds derived from the signed
halfword at actor offset `0x06`, reflects the corresponding velocity components,
and submits object positions and headings. A separate state word at `800BA784`
enables the diagonal limit. That path subtracts the actor halfword twice and
retains the unusual heading cutoff of 3,096. Calls can change the position
before subsequent reads; the source preserves those reads and the original
two-component velocity stores. Address-based field names remain where their
broader meaning is not established.

## Reproduce the checks

With the documented toolchain and user-supplied target ROM:

```sh
make check-actor-boundary-reflection
python3 tools/compare_runtime.py --candidates --jobs 2
```

The first command checks execution behavior and writes
`build/actor-boundary-reflection/report.json` and its guard-control report.
A successful execution audit does not establish instruction matching.
The second command independently compares complete excluded ranges and exits
nonzero while their instructions differ. Neither command adds source ownership.

The current audit passes 1,818 retail/candidate pairs, or 3,636 principal
executions, including 36 adversarial position mutations at a submission call.
Six complete matching support units and their initialized data are freshly
compiled; reached angle, arithmetic, position and object-transform helpers
execute actual instructions. A separate integer and rounded-float model checks
actors, object records, transforms, callback arguments and return values.

Every guest instruction and memory access is bounded. The audit checks canaries,
GP, SP, saved integer registers and twelve distinct incoming F20..F31 words.
Three actual guest instruction/read/write faults are rejected after positive
controls. Separate current-source controls reject five semantic source changes
and twelve executed saved-FPU corruptions. These controls establish that the
checker detects the tested faults; they do not prove arbitrary inputs.

Negative object indices use a deliberately mapped synthetic record. Position
mutation fixtures model possible callback effects and do not assert that the
normal position helper changes the actor. Division exception delivery,
arbitrary aliasing and full gameplay remain unverified.

## Independent evidence

Fresh splat and SPIM reassemblies each reproduce all 1,520 retail bytes.
Ghidra's raw memory and complete instruction listing agree with that extent,
and its `ActorBehaviorActorInternal` prototype remains consistent with the
C headers and generated m2c context. asm-differ and raw/linked objdiff views
retain the two stack differences. Viewer scores are not acceptance evidence.
The [provenance ledger](actor-boundary-reflection-provenance.json) records
hashes, comparisons, execution counts and the current admission status.

The latest research batch compares 219 complete bodies: 76 wall/sign macro
forms, 64 consumed call-operand forms and 79 branch-predicate forms. These are
comparison counts, including repeated baselines, rather than a count of
distinct recovered procedures. None improves the two-word candidate.
No dummy arrays, unused storage, extra parameters or inserted instructions
were introduced. Private generated assembly and binary evidence remain outside
Git. Tool and reference credits are in [CREDITS.md](../CREDITS.md).

The next matching investigation is the original lifetime of the temporary
across the two absolute-value calls and the pinned compiler's spill allocation.
The existing whole-ROM match still includes this procedure's extracted fallback.
