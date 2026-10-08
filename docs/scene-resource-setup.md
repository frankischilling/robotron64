# Scene resource setup candidate

`src/game/scene_resources/setup.c` reconstructs the complete procedure at
`8001D3F0..8001DE54`. It remains excluded from the matching build and adds
zero instruction, initialized-data or BSS bytes. Pinned IDO emits 2,688
natural code bytes against 2,660 retail bytes: 349 instruction words and
six of ten generated dispatch words differ. Matching the 64-byte frame
alone does not establish source recovery.

The ten-entry table occupies `800907C8..800907F0`, separate from the
32-byte diagnostic literal at `800907A8`. Both the runtime comparison and
matching workbench now link the full table there, validate all ten
`R_MIPS_32` relocations and compare every entry. They reject incomplete
code ranges, extra procedures, live trailing instructions and table-only
mismatches. The literal remains extracted fallback and is not source-owned.

Run `make audit-scene-resource-setup` with the documented toolchain,
Python environment and local baserom. It freshly compiles the candidate,
matching byte-copy and animation-resolver support, and 42 layout probes.
The guarded checker compares 319 paired cases / 638 executions, with
28,894 recorded calls per image. It checks call order and arguments,
intermediate flags and counter values, complete fixtures and canaries,
non-stack store traces, instruction/memory bounds, saved O32 registers,
SP and GP. Mode, counter and short arithmetic boundaries, all ten
categories, out-of-range categories, fixed resource loops, group/chain
sentinels and callback-driven changes to indices, counts and pool pointers
are covered. Boundary calls clobber caller GPR/FPR and HI/LO.

Five controls compile isolated source mutations or alter one dispatch
entry, after passing a candidate/retail baseline for each fixture:

- Preincrementing the animation-load counter instead of testing its old value.
- Keeping a stale resource index after a loader callback.
- Caching the arrival count across loader calls.
- Omitting the flag-`10` branch that loads the second category-three resource.
- Redirecting category one to category nine in the generated table.

Each mutation is rejected. Generated m2c initially used the wrong
preincrement form; the retail instructions and Ghidra confirm postincrement.
The explicit unsigned mask preserves both high flag tests without a signed
left shift. Canonical 88-, 92-, 96-, 104-, 124- and 1,004-byte layouts come
from the existing verified headers; this candidate does not expand ownership.

Execution has measured limits. Loading, scene service and diagnostics use
recorded ABI boundaries. Copying and animation resolution execute matching
MIPS code, but these animation fixtures cover negative references only.
Default diagnostics are modeled as returning; actual fatal-service behavior
and complete gameplay are not established. Group indices above zero use
isolated fixtures, not additional source-owned BSS.

Splat and spimdisasm independently reproduce all 2,660 retail instruction
bytes and the complete 72-byte literal/table interval. Ghidra's existing
`robotron64.elf` confirms the counter, callback reloads, chain strides and
both flag tests. Its overlapping-delay-slot warning is retained. asm-differ,
objdiff and bounded permuter research supplement the complete byte comparison;
their scores do not add matching credit. Tool and reference attribution is
in [CREDITS](../CREDITS.md) and [reference study](reference-study.md).

The [verification ledger](scene-resource-setup-provenance.json) records
source hashes, complete comparison boundaries, guarded results, controls,
independent references and full acceptance. Whole-ROM equality still contains
fallback. Full matching source recovery remains the goal.
