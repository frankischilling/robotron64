# SDK runtime source

This recovery adds 50 complete C functions in 35 translation units, covering
5,096 target code bytes. The random-number generator also owns its four-byte
initialized seed. Each unit was reconstructed against the selected Robotron
64 USA revision and compared through its final instruction, including the
compiler's procedure boundaries and generated data.

## Recovered services

The thread and message services initialize a thread's saved CPU context,
maintain its active and runnable queue membership, change a waiting thread
into a runnable thread, and preempt for a higher-priority runnable thread.
Message send and receive retain the target's blocking and nonblocking paths,
circular-buffer indexing, and wakeups of the opposite queue. Receive treats
any nonzero flag as blocking; send takes its blocking path only for flag one.

The VI routines update the next video context under interrupt protection.
They preserve the target order of mode, framebuffer, feature, black-screen,
and retrace-message updates. The feature setter retains the interactions
between the optional filter, antialiasing bits, and the selected mode.
Event registration records the message queue and message together.

PI and SI access queues provide the existing single-message serialization
protocol. The raw transfers preserve the observed busy tests, address masks,
direction selection, byte-count adjustment, and cache-maintenance order.
SP task startup, yielding, yield-result handling, status access, program-counter
updates, and transfers use the same target register operations. AI's FIFO
query checks the high status bit. Volatile accesses in these units describe
the hardware registers.

The audio heap uses sixteen-byte alignment and the target allocation bounds.
The ten integer helper procedures retain the original o32 calling convention
and MIPS III arithmetic, including the explicit signed-modulo correction.
The helper names and signedness are checked against their instructions and
callers. The random generator retains its unsigned recurrence and initial
value `174823885` at `0x8008F120`.

## Layout and compilation

The source reuses the existing thread, message-queue, task, and audio-heap
declarations. `sdk_thread_internal.h` describes the queue sentinel as the
actual eight-byte next-pointer/priority prefix. `sdk_video_internal.h` records
the twelve-byte scale record and forty-eight-byte video context. Compile-time
size checks accompany these declarations.

Thread creation sign-extends the original 32-bit entry argument, stack address,
and return address into the saved 64-bit register fields. Its saved stack is
adjusted by sixteen bytes. Thread startup expresses a waiting-queue transfer
as a direct pop-and-enqueue operation; this reproduces the target temporary
lifetime without adding storage or artificial control flow.

The OS and register services use IDO 5.3 with `sdk-o1-mips2`. The audio-heap
and random-generator units use `sdk-o2-mips2`; the integer helpers use
`sdk-o1-mips3`. `tools/compiler.py` records these choices. Its existing MIPS III
o32 handling changes the ABI metadata required by the linker and retains the
original compiler object separately. It does not patch the instruction stream.

`config/functions.json` identifies every accepted procedure and source unit.
`config/owned_sections.json` records the generator's actual initialized data.
The linker and extraction ranges replace only those verified code and data
extents. Alignment following the named queue and thread-creation procedures
remains outside their counted live code.

## Validation and reproduction

The retained candidate proofs compare each complete code range, check every
global procedure's ELF offset and size, and verify all emitted allocated
data sections. The seed comparison checks both its compiler symbol placement
and the original four target bytes. The integrated units are registered in
`tools/compare_runtime.py`, so the normal comparison and build commands cover
them:

```sh
make setup
make -j4
make test
make verify
make progress
python3 tools/compare_runtime.py
python3 tools/compare_startup.py
python3 tools/compare_assembly.py
```

The normalized target SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The full ROM comparison checks all 8,388,608 bytes; linked progress separately
checks the source, headers, objects, function extents, and owned data used for
source accounting. Remaining extracted code is excluded from that accounting.

The accepted batch passes all 35 integrated unit comparisons, all 108 tooling
tests, the full build, and the complete ROM comparison. Its linked checkpoint
contains 1,010 C functions and 132,064 C bytes. The
[source identity record](sdk-runtime-provenance.json) retains the exact source,
header, candidate, code, and validation hashes for these results.

## References

The implementation and its revision-specific choices are checked against
Robotron's target instructions and callers. The following libreultra files at
`1aca5c13ca041cef86f8dc194b727361dad9c09b` corroborated the recovered interfaces
and data:

- [`src/io/viint.h`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/io/viint.h)
  for the VI context and scale layouts.
- [`src/os/osint.h`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/os/osint.h),
  [`src/os/thread.c`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/os/thread.c),
  and [`src/os/createmesgqueue.c`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/os/createmesgqueue.c)
  for the short thread sentinel and queue-head interpretation.
- [`src/audio/heapinit.c`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/audio/heapinit.c)
  and [`src/gu/random.c`](https://github.com/n64decomp/libreultra/blob/1aca5c13ca041cef86f8dc194b727361dad9c09b/src/gu/random.c)
  for the alignment expression and static generator state.

[CREDITS.md](../CREDITS.md) records all thirteen requested N64 reference
projects and the compiler and analysis tools. Target-derived public source
and retained reference-adapted experiments have separate provenance and
acceptance records. The handwritten SDK procedures remain documented in
[the assembly investigation](libultra.md).
