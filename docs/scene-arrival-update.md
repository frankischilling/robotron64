# Arrival update and spawn scheduling

`func_80020134` spans `80020134..80020F24`, or 3,568 retail instruction
bytes. Four dispatch tables occupy all 132 bytes at `80091960..800919E4`.
Their entry counts are ten, six, seven and ten. Independent spimdisasm and
Splat objects reproduce the complete code and tables. Ghidra agrees with
the original bytes. The caller at `800248E0` calls this function without
arguments and branches on the 32-bit `v0` result at `800248E8`.

The readable candidate is `src/game/scene_arrivals/update.c`. It counts
active normal actors, evaluates arrival states and triggers, chooses spawn
positions, dispatches six resource categories, invokes initialization
callbacks, and activates the next pending arrival of the same category.
Its result includes eligible active actors and selected pending counts;
it is not simply the number of successful constructor calls.

The candidate has 3,536 natural instruction bytes and a 312-byte frame.
Retail has a 288-byte frame. Complete comparisons differ in 739 code words
and fifteen dispatch addresses. The source remains excluded from the
matching manifest and ROM link. No instruction, initialized-data or BSS
ownership is added. The neighboring rebuild candidate has 1,376 natural
bytes and the retail 936-byte frame, with 235 code words and two dispatch
addresses still different. A matching frame alone establishes no ownership.

## Verified decisions

State zero skips an arrival. State two contributes selected pending counts.
State one evaluates the trigger and current category counter. Trigger five
attempts the recorded count and moves the arrival to state two. Trigger two
attempts one spawn. Category eight also attempts one spawn. Failed position
selection and null constructor results preserve the remaining count.
Successful attempts decrement it except for trigger five. A completed arrival
activates the first later state-two entry with the same category; trigger-one
entries receive the elapsed unsigned time divided by 100 in their signed
halfword delay.

The retail coordinate branch tests X against minus one twice. When X is
minus one, it copies both coordinates without scaling, even when Y differs.
Otherwise it shifts both by eight. Position selection runs only when both
resulting coordinates are minus one. Its spacing changes from one to two
at 501 elapsed ticks. Category-seven resources have a 92-byte stride;
category-one, category-three and category-nine resources use 88 bytes.

Trigger four calls the real random helper when the rate is nonzero. It uses
the positive random value shifted by three, signed remainder by the arrival
delay, multiplication by 100, and unsigned division by the rate. Zero
remainder divisors are excluded from the returning audit. Trigger three
checks score, previous totals, scene counters, player presence, behavior
counters, resource flags, or the selected player's active word, depending
on its signed halfword delay.

## Execution audit and limits

Run `make audit-scene-arrival-update` with the documented analysis Python
environment. The independent model checks 3,447 retail/source pairs,
or 6,894 executions. Fixtures cover the valid constructor resource ranges,
all six triggers, signed counters and coordinates, timer wraparound, capacity
boundaries, success and failure returns, callback arguments, sound gating,
cascades, every byte-sized category in passive states, diagnostic states,
and 128 seeded mixed lists. Nine source mutations and seven guest faults
must fail between passing baselines.

The checker recompiles the complete source and independently compares all
code and dispatch bytes. It executes the matching clear and random helpers,
checks complete fixture regions, and enforces scalar access widths, bounded
code and memory access, stack guards, immutable caller homes, and preserved
integer and floating-point registers. Adjacent rate and clock globals share
one guarded fixture region; the checker rejects overlapping fixture guards.

Constructors, position selection, callbacks, sound and fatal display calls
use explicit returning O32 observers that clobber caller-saved integer and
floating-point registers. Their internal game-world effects are outside
this audit. Invalid state-one categories leave an uninitialized retail
counter if fatal display handling returns, so those inputs are excluded.
Fixtures use valid resource indices and acyclic lists within the 200-slot
actor pool. The audit does not prove unrestricted gameplay or source matching.
The rebuilt ROM still uses the original fallback for both update and rebuild.

The complete split configuration is
[`config/analysis/scene_arrival_update.yaml`](../config/analysis/scene_arrival_update.yaml).
Tool and reference credits are in [CREDITS.md](../CREDITS.md).
