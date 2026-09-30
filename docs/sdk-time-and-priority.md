# SDK time and thread priority

Seven complete procedures reconstruct 1,464 bytes of timer, clock, thread
priority, and cartridge-read code. All use IDO 5.3 with the recorded
`sdk-o1-mips2` profile. The timer initializer also owns the eight-byte system
time variable at `0x80196450`.

| Procedure | Target range | Code bytes |
| --- | --- | ---: |
| Cartridge word read | `0x8005FEE0..0x8005FF34` | 84 |
| Thread priority change | `0x80060370..0x80060450` | 224 |
| System time snapshot | `0x80061450..0x800614D4` | 132 |
| Timer initialization | `0x800684D0..0x8006855C` | 140 |
| Timer interrupt service | `0x8006855C..0x800686D4` | 376 |
| Compare programming | `0x800686D4..0x80068748` | 116 |
| Ordered timer insertion | `0x80068748..0x800688D0` | 392 |

The clock snapshot reads Count under interrupt protection, subtracts the
previous Count sample as an unsigned 32-bit difference, and adds that elapsed
interval to the saved 64-bit time. The target's local lifetimes reproduce the
complete stack layout with ordinary declarations.

The timer list stores relative intervals. Insertion subtracts the intervals
of earlier entries, records the remaining interval in the new timer, and
reduces the next timer's interval by the same amount. Equal deadlines retain
the target's strict comparison and insertion order. The interrupt service
consumes elapsed Count cycles, removes expired timers, delivers their messages
without blocking, and reinserts periodic timers. When the list empties during
service, it clears Compare and the saved timer Count.

The initializer resets the system time and its sampling counters, then links
the timer sentinel to itself. The recovered 64-bit time definition belongs
to this source unit: representing it only as an external declaration changes
IDO's instruction ordering and emits an extra address load. Owning its actual
eight-byte BSS object reproduces all 140 code bytes and the correct
object metadata. No extra storage is introduced for compiler matching.

Changing a thread's priority operates under interrupt protection. A null
thread argument selects the current thread. An active queued thread is
removed and reinserted at its new priority, then the running thread yields
when the head of the runnable queue has a higher priority. Stopped threads
are not placed into a queue by this operation. The cartridge word reader
waits for both PI busy bits to clear before reading through the uncached
cartridge mapping.

Each candidate is compared over its entire range and checked against its real
ELF procedure offset and size. The integrated build registers all seven
units in `tools/compare_runtime.py`, and `make progress` verifies the source,
headers, function extents, and BSS ownership used for source accounting.
Reproduction uses the standard commands in
[the recovery checkpoint](recovery-checkpoint.md).

These procedures were reconstructed from the verified Robotron target and
their existing callers. The established N64 interfaces and compiler workflow
are credited in [CREDITS.md](../CREDITS.md) and
[the SDK runtime notes](sdk-runtime.md).
