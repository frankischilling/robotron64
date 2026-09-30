# Transfers, thread destruction, and short math

Ten complete C functions recover 1,524 code bytes. The target ranges are
recorded in `config/functions.json`; each unit passes its own complete linked
instruction comparison before entering the normal build.

## Game state and renderer buffers

The player reset clears the active flag and actor pointer in both 3,508-byte
player records. `SavedPlayerState` now names the confirmed pointer at offset
eight while retaining its 160-byte layout. Scene arrival reactivation scans the
current arrival count, changing state two to one only when the trigger is five.
The count is reloaded after the indirect byte store, as in the retail loop.

Renderer allocation requests `0xFA000` bytes and records the buffer start,
current cursor, and end. The runtime buffer clear zeroes `0xFB4` bytes at its
existing RAM address. These declarations reference existing storage and do not
claim new data or BSS bytes.

## SDK services

PI DMA submission returns minus one if the manager is inactive. Otherwise it
fills the confirmed 24-byte message with direction kind, priority, return queue,
RAM address, cartridge address, byte count, and a null handle. Priority one
uses queue prepend; other priorities use ordinary send. Both submissions use
the target's nonblocking flag and return the queue service's result.

PI event notification uses the eight-byte event record shared with the
recovered event setter. It ignores a null or full queue, writes the event
message into the circular buffer, increments the queue count, and moves a
waiting receiver to the ready queue. The target's separate full-queue exit
requires the queue fields to be reloaded before the buffer update.

Thread destruction disables interrupts and accepts a null pointer to select
the running thread. Explicit threads outside state one are removed from their
queue. It unlinks the thread from the active list and dispatches another thread
when destroying the current one. The target relies on a valid active-list head;
the source retains that behavior. The interrupt state is restored on the path
that returns.

AI frequency setup rounds the clock/frequency ratio through the target's float
to unsigned conversion. Dividers below 132 fail. The bit rate is the divider
divided by 66, narrowed to an unsigned byte, and capped at sixteen. It writes
the DAC divider, bit rate, and enable registers, then returns the integer
achieved frequency. The signed clock division and byte narrowing are preserved.
These four services use the verified `sdk-o1-mips2` profile.

The signed short sine routine discards four angle bits and mirrors the
1,024-entry quarter-wave table according to the next quadrant bit. The final
quadrant bit chooses the sign. Cosine calls it with a wrapped `0x4000` angle
offset. Both routines use `sdk-o2-mips2`; the MIPS I profile has instruction
differences. The table remained fallback data at this batch's checkpoint.
Its later [mathematical reconstruction](sdk-short-sine-table.md) adds 2,048
source-owned initialized bytes.

## References and verification

The recorded local [libreultra](https://github.com/n64decomp/libreultra) checkout
was consulted for `src/gu/sins.c` and `src/gu/coss.c` to identify the mathematical
interface. Robotron's instructions establish the accepted compiler profiles,
table placement, narrowing, and complete procedure sizes. The target-derived
transfer and thread sources use the already verified queue and thread layouts.
The local `include/2.0I/PR/os.h` confirms event eight as the PI interrupt event.
The broader reference collection is credited in [CREDITS.md](../CREDITS.md).

Current proof requires the independent runtime comparison, linked procedure
extents, object/input provenance, and full-ROM equality. Historical comparison
reports do not substitute for rebuilding the current checkout.

The [provenance ledger](sdk-transfer-and-short-math-provenance.json) records the
ten new procedures and the existing event setter after its shared declaration
changed. All 675 runtime units, both startup units, and twelve assembly units
pass current independent comparisons; all 114 tooling tests pass. The linked
ROM matches all 8,388,608 bytes of the normalized target. Shared player and
event layouts retain their verified sizes and offsets.
