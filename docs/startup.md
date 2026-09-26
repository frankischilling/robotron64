# Startup and initial threads

## Entry

`src/boot/entry.s` reproduces the 56 instruction bytes at ROM `0x1000..0x1038`, followed by 24 observed zero alignment bytes. Whole-ROM verification also checks the alignment bytes. Reconstructed assembly is reported separately from matching C.

The entry loop clears eight bytes per iteration over RAM `[0x80097290, 0x80197640)`. The loop count is `0x1003B0`. Its signed `addi` instructions are preserved. It sets `sp` to `0x8013A280` and jumps to `0x80048170` without setting a return address. These addresses establish a clearing range, not the allocation of every object inside it.

## Initial C control flow

`func_80048170` occupies `0x80048170..0x80048204` (148 bytes):

1. Calls SDK initialization at `0x8005FC50`.
2. Reads sixteen 32-bit words with the raw PI routine at `0x8005FEE0`, from offsets `0x00FFB000` through `0x00FFB03C` inclusive.
3. Writes results at `sp + 0x34` through `sp + 0x70` in its 128-byte frame. No subsequent instructions in this routine read the buffer. The purpose is unknown; the offsets exceed the supplied 8 MiB image. Preserve the reads rather than replacing them with baserom accesses.
4. Creates thread ID 1 at priority 10, control block `0x80139280`, entry `0x80048204`, null argument, stack top `0x8013B430`.
5. Starts that thread through `0x80060090` and contains a return sequence. Startup enters with a jump; no higher-level return behavior has been inferred.

`func_80048204` occupies `0x80048204..0x800482A0` (156 bytes):

1. Creates the PI manager at priority 150, command queue `0x8013D7B0`, eight-message buffer at `0x8013D790`.
2. Creates thread ID 3 at priority 10, control block `0x8013A430`, entry `0x800482A0`, forwarded argument, stack top `0x8013C5E0`.
3. Starts thread 3, changes the current thread's priority to zero, then loops at `0x80048274`.

These stack-top arguments are confirmed. Stack bases and sizes remain unknown. Thread 3 begins further initialization, including a one-message queue at `0x8013D7C8` backed by `0x8013D828`; its full control flow remains under analysis.

## SDK name evidence

| Address | Name | Supporting instruction behavior |
| --- | --- | --- |
| `0x8005FC50` | `osInitialize` | Sets CP0 CU1, FPCSR `0x01000800`, performs PIF handshake, installs exception preamble words |
| `0x8005FEE0` | `osPiRawReadIo` | Polls PI status bits 0 and 1 at `0xA4600010`, reads through cartridge base at `0x80000308` in KSEG1, stores output, returns zero |
| `0x8005FF40` | `osCreateThread` | Stores ID at `0x14`, priority at `0x4`, PC at `0x11C`, argument at `0x38`, SP minus 16 at `0xF0`, cleanup RA at `0x100`; links active thread under interrupt lock |
| `0x80060090` | `osStartThread` | Starts stopped/waiting threads through run queues and dispatch/yield logic |
| `0x800601E0` | `osCreatePiManager` | Creates command/event queues, registers PI event 8 with message `0x22222222`, configures device manager and starts its thread |
| `0x80060370` | `osSetThreadPri` | Resolves null to running thread, changes priority field at `0x4`, reorders queues and yields |
| `0x80060450` | `osCreateMesgQueue` | Initializes waiter pointers, zeroes counts, stores capacity and message buffer |

Names are supported by target behavior and the corresponding SDK routines in the inspected SM64 reference. Complete SDK byte matches and release identification remain unproven. Thread creation spills/reloads arguments repeatedly, unlike the optimized game routines; investigate optimization per library object.

## Candidate and remaining difference

`src/boot/startup.c` is excluded from the ROM build. Run `python3 tools/compare_startup.py` to compile it with IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`, link observed external addresses, and compare all 304 bytes. Candidate input alignment is 16 bytes; this does not establish an original translation-unit boundary.

Two instruction immediates differ: at `0x80048190` the candidate buffer base is `sp + 0x40` instead of `sp + 0x34`; at `0x80048194` its end is `sp + 0x80` instead of `sp + 0x74`. The second function's 156 bytes match in this experiment, but neither candidate function contributes to the integrated matching-C count. Original local declarations and remaining stack use need evidence before integration.

Further local experiments did not resolve that difference. IDO 7.1 at `-O2` gives the same `0x40/0x80` offsets for this source. Moving `int i` before the array gives `0x3C/0x7C`; adding `register` or changing `int` to `long` does not change those results. Both compilers at `-O1` produce a different 104-byte frame and a spilled loop index. Pointer arithmetic, byte-offset iteration, and a short loop index change the instruction sequence rather than reproducing the target. The retained candidate remains the closest tested form without speculative extra locals.
