# Actor movement handler

The complete handler at `0x80010A3C..0x80011028` matches all 1,516 bytes
(379 instructions) and its 32-byte frame with pinned IDO 5.3. Its generated
six-entry switch table matches all 24 bytes at `0x8008FBA4..0x8008FBBC`.
No instructions or table entries are patched.

| Source | ROM range | Linked ownership |
| --- | --- | --- |
| `src/game/actor_groups/movement.c` | `0x1163C..0x11C28` | `.early_actor_movement`, 1,516 instruction bytes |
| Generated switch table | `0x907A4..0x907BC` | `.early_actor_movement_switch`, 24 initialized bytes |

The raw object has 1,520 text bytes and a 1,516-byte function symbol, followed
by one zero alignment word. Its 32-byte rodata section contains the relocated
24-byte switch table followed by eight zero alignment bytes. The build trims
those verified tails. It owns no initializer or BSS bytes. The eight retail
bytes at `0x80011028..0x80011030` and the following rodata remain fallback.

`EarlyAnimationMovementSlot` gives the rate at offset four a signed integer
view. It shares the existing 12-byte slot union with unsigned weighted choices
and signed reset thresholds; the animation record remains 204 bytes. Rates
come from the current phase and movement slot. The enclosing retail table
extent and valid caller indices remain unknown.

Modes zero and one separately set the rate, calculate X/Y velocity and submit
the object angle. Modes two and three add rate times the global delta to the
short angle, narrow it before applying signed remainder by 4,096, and clear
velocity. Their trigonometric calls still execute despite the zero multiplier.
Mode four uses angle minus 1,024 with signed remainder; zero rate preserves
previous velocity, and this mode does not submit the object angle. Mode five
preserves the existing rate and velocity. Out-of-range modes clear them while
retaining trigonometric calls and angle submission.

A following switch on callback kind four overrides movement with slot zero
of the current phase, then calculates velocity and submits the angle. This
one-case switch reproduces IDO's register allocation. Rate, phase, movement
and record-pointer reads remain fresh after trigonometric calls.

The second argument is stored into its caller home slot at entry SP plus four
and never loaded. Ghidra's bounded listing and original ROM verify the complete
body, switch targets, frame and argument store. Its current xref query reports
no callers; that does not establish reachability.

Run the optional checker in the configured Unicorn environment:

```sh
python tools/check_actor_movement.py
```

It recompiles five complete code units, verifies the generated switch table
and the sine table's mathematical generator, and executes compiled and retail
handlers against guarded byte and call oracles. All 4,608 cases pass: 4,032
arithmetic cases and 576 mutation cases, with 10,464 real trigonometric calls
and 4,808 object-angle submissions. The matrix covers all six modes and three
out-of-range values, five synthetic phases, short-angle extremes, signed
remainder boundaries, zero/positive/negative/overflowing rates and delta extremes.

Synthetic mutations exercise current phase, movement, record pointer, rate,
angle and callback reads. Object-angle effects use ABI stubs. Trigonometry
executes matching code and its results pass through caller register clobbers
before the handler resumes. Every return checks guarded memory, integer saved
registers, stack restoration and F20 through F31 through real MIPS instructions.
The unused argument replaces four bytes of the seeded caller home area; its
other 28 bytes stay unchanged.

These cases characterize pinned IDO/MIPS signed overflow and narrowing rather
than portable ISO C. They do not establish complete gameplay, rendering,
actual caller behavior or full retail table extents.

The integrated checkpoint passes all 860 runtime, two startup, eighteen assembly
and 98 data-only comparisons, all 152 tooling tests and equality of the complete
8 MiB target ROM. Isolated clean-build results and input hashes are recorded in
[the provenance ledger](actor-movement-provenance.json). Whole-ROM equality
includes extracted fallback.

Matching C totals 1,377 procedures and 269,036 instruction bytes; initialized
ownership is 29,715 bytes and BSS ownership is 504,115 bytes. The provisional
CPU interval retains 181,160 fallback bytes in 213 ranges and 152 unclassified
bytes. Complete function and executable-byte denominators remain unverified.

Local SM64 compiler/build practice and the IDO temporary allocator informed
the matching workflow. Robotron's ROM remains the behavioral source of truth.
The ledger records reference revisions and hashes; no reference implementation
was copied.
