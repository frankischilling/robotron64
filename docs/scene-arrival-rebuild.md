# Arrival reconstruction from active actors

`func_80020F8C` spans `80020F8C..800214D4`, or 1,352 retail instruction
bytes. Its nine-entry dispatch table occupies all 36 bytes at
`800919E4..80091A08`. The table's unsigned guard accepts categories 0 through
8; the active cases are 0, 1, 3, 7 and 8. Separate Splat and spimdisasm
objects reproduce the complete code and table. Ghidra independently agrees
with the original bytes and the 200-slot, 124-byte actor pool at `800A4628`.
The list-head pointer follows that pool at `800AA708`.

The C candidate is in `src/game/scene_arrivals/rebuild.c`. It reconstructs
normal, scene and behavior arrivals from the active list. Normal kinds 9
through 12 group by their actor slot; kinds 13 through 16 with a nonzero
field at `3C` group by that referenced slot. The grouped values wrap as
unsigned bytes. The function clears normal counts 9 through 16 before
folding those groups back into kinds 9 through 12. Kinds 17 through 20
write secondary limits in list order. Grouped limits use ascending pool-slot
order. Category 8 changes actor state to 2 and schedules one player arrival.

The candidate's complete natural body is 1,376 bytes with a 936-byte frame;
retail allocates 936 bytes. The complete comparison differs in 235 code
words and two dispatch-table addresses. It remains excluded from the
matching function manifest and ROM link. No code, initialized-data or BSS
ownership is added. Padding locals and spare array elements are not used
to force the frame size.

The source uses a consumed pool-actor pointer for category-zero slot
calculations and reads category-three resource kinds directly in that case.
The [arrival-update candidate](scene-arrival-update.md) has a separate
guarded audit for active spawning and pending-arrival transitions.

Run `make audit-scene-arrival-rebuild` with the documented analysis Python
environment. An independent model checks 913 fixtures in two layers, for
3,652 executions. Boundary pairs observe all eight insertion arguments
while clobbering caller-saved integer and floating-point registers.
Integrated pairs execute the real matching insertion, copy, random and
diagnostic helpers. Both compare complete actor and resource fixtures,
scene storage, resource-limit arrays and random state. The checker enforces
scalar access widths, loaded code bounds, stack and memory guards, immutable
caller homes, and saved integer and floating-point registers.

Fixtures cover every byte-sized actor category, all 36 normal kinds, every
byte-sized category-1 kind, group aliases and byte wrapping, signed coordinate
and delay boundaries, 200-node lists, full arrival tables and 200 seeded
mixed lists. Eight source mutations and seven guest faults must fail between
passing baselines. These include category bounds, group values, parent kinds,
limit windows, actor state, coordinate arguments, delay scaling, saved
registers, forbidden reads and writes, code bounds, stack bounds and dispatch.

The fixtures use acyclic lists within the 200-slot pool and at most 50
grouped and secondary limit writes. They do not establish behavior for
invalid parent pointers, cycles, or writes beyond the declared limit arrays.
Diagnostic output uses explicit ABI observers; fatal display rendering
returns synthetically. Display hardware, terminal fatal handling and
unrestricted gameplay remain outside this audit. Full-ROM equality still
contains this function's fallback code and does not prove source completion.

The complete split configuration is
[`config/analysis/scene_arrival_rebuild.yaml`](../config/analysis/scene_arrival_rebuild.yaml).
Tool and reference credits are in [CREDITS.md](../CREDITS.md).
