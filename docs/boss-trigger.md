# Boss trigger dispatch

The complete dispatcher at `8000F814..8000FBC0` contains 940 bytes and 235
instructions. The pinned IDO 5.3 game profile reproduces every word and its
128-byte frame from `src/game/actor_groups/trigger.c`. The initializer in
`trigger_records.c` owns ten 28-byte records at `80073590..800736A8`, including
the complete seven-word sentinel. `trigger_state.c` owns the four-byte initial
value one at `80073588..8007358C`. The intervening timestamp at `8007358C`
retains fallback ownership.

The dispatcher first applies a temporary object color when the start timestamp
at `800739CC` is nonzero and unsigned elapsed time is below 500. Both color
channels receive the remaining duration scaled by 200 and divided by 500.
A local duration value preserves retail's division and zero-divisor check,
including the unreachable `break 7` at `8000F89C`. Ghidra's flow pseudocode
omits that word; the bounded listing and full comparison include it.

The record loop stops at a first word of -1. Other nonzero first words skip
their record. A zero word requires unsigned elapsed time above 1,000 and an
animation gate: the session index must be below the record's index, or equal
with matching actor animation and a frame strictly above the record's frame
shifted left eight. The clock and shared timestamp are read again for each
record. Signed comparison and unsigned elapsed-time wrapping are retained.

An actor-resource index other than -1 requests kind nine. Its position is
the session's current actor position plus the supplied actor's fixed
trigonometry scaled by 8,000. Retail initializes only X and Y in the local
three-word position array. The third word remains uninitialized; the source
preserves this behavior. Required source, session and player pointers remain
unchecked.

Successful allocation updates the shared timestamp, scales the new object
using the resource's field `0C` times 20,280 divided by 40,960, applies the
two 255 color channels, and marks the record used. It aims the new actor
toward the current player's actor, stores movement value 50 and computes
the two fixed-point movement components. Failed allocation leaves the record
and timestamp unchanged. An extra-resource index other than -1 then calls
the existing arrival scheduler, even after failed or skipped allocation.
A record that only schedules an arrival remains unused and can run again.

The shared 28-byte chain view now exposes the animation index, animation,
frame and extra count fields. Existing resource-index offsets and record
size remain unchanged. The reset helper still matches all 60 bytes and
clears each first word until the sentinel, then copies the clock. The existing
constructor continues to match all 772 bytes. The following global at
`800736A8` lies outside the ten-record initializer and retains fallback.

Ghidra MCP verifies the complete listing, prototype, record layout, table
bytes, initial state and references. The unrecovered update routine calls
the dispatcher at `80010904`. The dispatcher and reset helper read and write
the record table and shared timestamp. The existing creation routine writes
the initial-state global, and the update routine reads it. Ghidra keeps the
existing interior session names; its canonical 328-byte session layout is
verified without replacing those names.

The optional MIPS checker passes 2,592 compiled/retail comparisons against
independent guarded byte and call expectations: 1,344 cases using the retail
records, 576 direction/scale cases, 576 synthetic record cases and 96 that
execute the real reset helper before dispatch. Inputs cover both players,
strict time and frame boundaries, unsigned clock wrapping, record skipping,
empty tables, disabled child/extra resources, allocation outcomes and order,
and repeated scheduling without a created actor.

The matrix observes 5,024 allocation attempts, 677 successful creations,
3,180 arrival calls and 1,949 color calls. It deliberately advances the clock
in 245 callbacks to verify subsequent timestamp reads and gate decisions.
Seven freshly matched arithmetic units execute real support code. The sine
table also agrees with an independent mathematical generator. Direction
expectations cover zero, cardinals and equal-magnitude diagonals.

The checker verifies complete source, center, player, child, resource, session,
clock and record buffers with surrounding guards, call order, all eight
scheduler arguments and actual single-precision scale bits. Real `mtc1` and
`swc1` instructions seed and check F20 through F31. Every case restores the
integer saved registers and stack and returns to the sentinel. It seeds the
uninitialized third position word and confirms that it reaches allocation
unchanged; this characterizes stack state rather than a portable C value.

Object effects, allocation and arrival scheduling use integer and floating-
point ABI stubs. Actual allocation semantics for the unspecified position
word, invalid required pointers, arbitrary direction quantization, rendering,
arrival effects and complete gameplay are outside this execution proof.
Signed overflow and shifts describe pinned IDO/MIPS behavior rather than
portable ISO C.

Run the checker with Unicorn installed:

```sh
python3 tools/check_boss_trigger.py
```

The integrated ROM matches all 8,388,608 target bytes. Independent complete
comparisons pass for 858 runtime units, two startup units, eighteen assembly
units and 98 data-only units. All 152 tooling tests pass.
An isolated extraction and clean build reproduces the same complete ROM and
passes the 152 tests with all 1,148 current comparison inputs verified.
[The provenance ledger](boss-trigger-provenance.json) records current inputs,
compiler identity, exact ELF ownership, Ghidra evidence and execution limits.
The raw objects contain four trailing zero alignment bytes after the
dispatcher, eight after the records and twelve after the four-byte state.
No instructions or initialized values are patched.

Matching C totals 1,375 functions and 265,312 instruction bytes. Initialized
ownership totals 29,691 bytes; BSS remains 504,115 bytes. The provisional CPU
inventory retains 184,884 fallback bytes in 213 ranges. Complete executable
and function denominators remain unknown.

The compiler and complete comparison workflow follow the local SM64 and IDO
references. Robotron's retail instructions and initialized records establish
behavior and layout. No reference implementation was copied. The execution
checker uses [Unicorn](https://www.unicorn-engine.org/); reference revisions
and consulted file hashes are recorded in the ledger.
