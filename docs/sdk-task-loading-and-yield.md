# RSP task loading and native yielding

Four complete C procedures recover 1,036 bytes. The complete native
save-and-yield and block-copy procedures recover another 1,028 assembly bytes. Neither the
scratch task nor disk-handle storage is newly source-owned.

## RSP task preparation

The address conversion routine copies the 64-byte RSP task to the existing
scratch record. It converts seven nonnull addresses to physical addresses:
microcode, microcode data, DRAM stack, output buffer, output-size pointer,
command data, and yield data. Boot microcode retains its original address for
the subsequent DMA service. The shared `RspTask` layout already describes all
sixteen target words.

Task loading reuses yield data when flag one is set and clears that flag in
the caller's task. Flag four additionally reads the microcode pointer from the
yield buffer's `0xBFC` footer through its uncached alias. It writes back the
scratch task, applies SP status `0x2B00`, waits for PC setup, loads the task at
SP address `0x04000FC0`, waits for the SP, then loads boot microcode at
`0x04001000`. Failed setup and DMA attempts retain the original retry loops.

## Disk error recovery

The disk helper waits for PI idle, writes the buffer-manager shadow with reset
bit `0x10000000`, waits again, then restores the shadow. It delivers the PI
event, clears the PI interrupt, and reenables mask `0x100401` in the global
interrupt mask. A volatile status local preserves the retail stack rereads.
The partial disk-handle declaration confirms the transfer prefix at offset
twenty and its buffer-manager shadow sixteen bytes later. It does not claim
the unexamined remainder of the handle.

## Native thread save and yield

The native procedure saves the preserved 64-bit CPU registers and return PC.
Threads that have used floating point also save the six preserved FP pairs
and control register. CPU and RCP masks retain interrupt bits suppressed by
the global mask. A nonnull queue receives the running thread; execution then
jumps to the already recovered dispatcher. MIPS III and 64-bit register mode
preserve the native doubleword stores within the 32-bit object ABI.

## Native block copying

The copy service accepts source, destination, and byte count, and returns the
original destination. It copies backward when the destination overlaps the
source at a higher address. Matching source and destination alignment permits
word, 16-byte, and 32-byte transfers; other cases use byte transfers. Initial
byte and halfword copies align the addressed end in either direction. The
original signed address comparisons, trapping additions, branch-likely delay
slots, repeated size checks, and final twelve zero alignment bytes are retained.
The RSP task preparation routine uses this complete native service.

## Game actor wrapper

The actor wrapper forwards its arguments with constants 100 and one
to `func_80018E1C`. It calls the existing `func_80035244` service when animation
is not one and neither flag `0x400` nor `0x4000` is set. It returns zero on all
paths. The wrapper's name describes forwarding and its guard; the two service
roles still require further analysis.

## References and boundaries

The pinned local [libreultra](https://github.com/n64decomp/libreultra) files
`src/io/sptask.c`, `src/io/leointerrupt.c`, `src/os/exceptasm.s`, and
`src/libc/bcopy.s` were
consulted for task, disk, and thread interfaces. Full Robotron comparisons
establish the accepted `sdk-o1-mips2` profile for the three SDK C routines and
the game profile for the actor wrapper. [CREDITS.md](../CREDITS.md) records the
reference collection and revisions.

Boundary research also found that the provisional event-send catalog range
at `80066F94` includes a separate exception-handler fragment at `80067048`.
No partial event-send or exception extent was counted in this batch.
Subsequent [complete exception recovery](sdk-initialization-and-exceptions.md)
establishes the preamble, main handler, 180-byte event helper and 52-byte
coprocessor handler as distinct entries in the verified contiguous native unit.

## Verification

All 684 runtime units, both startup units, and nineteen assembly units pass
complete independent comparisons. All 114 tooling tests pass. The full linked
ROM matches the normalized target, including native procedure alignment. The
[provenance ledger](sdk-task-loading-and-yield-provenance.json) records source
and comparison identities for these six units. Current progress requires
fresh comparisons against the current source and configuration.
