# SDK initialization, Pak ID repair, and exception context

Two complete C procedures add 1,256 instruction bytes. `osInitialize` at
`8005FC50` is 652 bytes; Pak ID repair at `800617A0` is 604 bytes. Both use
`sdk-o1-mips2`. Initialization also owns twenty initialized bytes and four BSS
bytes. Four newly recovered native assembly procedures add 1,580 live bytes.

## Initialization

Initialization sets the final-ROM flag, enables CP1, and installs the floating
point control word `01000800`. It retries serial reads and writes of the final
PIF word, setting bit three, then copies the complete 16-byte exception preamble
to the four hardware vectors. It writes back and invalidates their 400-byte
cache range, installs the debugger TLB mapping, and reads the cartridge clock.

The low clock nibble is cleared. A nonzero cartridge clock replaces the
initialized 62,500,000 value; the resulting 64-bit value is multiplied by three
and divided by four. Cold reset clears the 64-byte application NMI buffer.
PAL, MPAL and NTSC select video clocks 49,656,530, 48,628,316 and 48,681,812.
The original polling loops and ignored raw-read result remain in the source.

The clock, video clock, shutdown flag, and global interrupt mask occupy twenty
initialized bytes at `8008E3B0`; the mask starts at `003FFF01`. The final-ROM
flag owns four BSS bytes at `80193B30`. Full emitted bytes, symbol placements,
and zero-only compiler alignment are checked. No vector instructions are
embedded as data in the C source; it copies the authored assembly preamble.

## Pak ID repair

Repair selects bank zero when necessary and propagates selection/read errors.
It reads the 32-byte ID and checks both checksums. A failed ID lookup with
status ten invokes repair; other nonzero lookup errors return immediately.
An ID without its device bit is repaired again, with status eleven returned
if the bit remains clear. The accepted ID is copied byte by byte to the Pak
state, and its version, bank count, inode start, directory size and table
offsets are restored. Reading label block seven supplies the final error result.
These 604 bytes reuse the existing confirmed Pak and ID types.

## Complete exception and thread assembly

The complete native unit has nine procedures with 2,312 live bytes and eight
checked zero alignment bytes. Five previously recovered thread procedures
account for 732 of those live bytes. The four additions are:

| Entry | Role | Live bytes |
| --- | --- | ---: |
| `80066A50` | Exception vector preamble | 16 |
| `80066A60` | Main exception handler | 1,332 |
| `80066F94` | Nonblocking event notification | 180 |
| `80067048` | Coprocessor-unusable handler | 52 |

The SDK reference marks the preamble, main handler, event helper, and
coprocessor handler as separate assembly entries. The coprocessor handler
branches back into the main handler's fault or enqueue paths. The earlier
provisional 232-byte range at `80066F94` combined the event helper and that
handler and was never counted. The new extents have exact function symbols,
complete byte coverage, no overlap, and a complete independent reassembly.

The main handler preserves 64-bit integer registers, interrupt state, EPC,
cause and any active floating point context. It dispatches CPU and RCP
interrupts, invokes the cartridge callback with its original stack setup,
handles pre-NMI shutdown, records breaks and faults, and selects a runnable
thread. The event helper checks queue capacity, retains the original division
checks, enqueues a message, and wakes a blocked receiver. The coprocessor
handler enables CP1 lazily for the current thread or takes the fault path.

The existing yield, priority insertion, queue pop, dispatch and cleanup routines
now share this original contiguous unit. Their instructions and complete
procedure extents are unchanged. Keeping the complete exception/thread block
together also preserves its authentic tail alignment without modifying the
assembler or comparison rules. Interrupt tables and scratch storage remain
separate recovery work and are excluded from this batch's storage counts.

## References and proof

Pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/os/initialize.c`, `src/os/exceptasm.s`, `src/os/exceptasm.h`,
`src/io/pfsrepairid.c`, and the existing Pak references corroborate the
interfaces, control flow and native entry structure. Complete Robotron
instructions determine the accepted variant. [CREDITS.md](../CREDITS.md)
records those uses and all thirteen requested projects. The
[provenance ledger](sdk-initialization-and-exceptions-provenance.json) records
all complete extents, independently compiled/reassembled inputs, storage and
target hashes. Every counted source unit and the full ROM are verified before
publication. Executable game and compression fallback still remains.
