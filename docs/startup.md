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

These stack-top arguments are confirmed. Stack bases and sizes remain unknown.

## Thread 3 and the game loop

`func_800482A0` occupies `0x800482A0..0x80048460` (448 bytes). It uses a 24-byte frame and preserves the unused incoming argument's store. Its initialization proceeds in this order:

1. Calls `func_80048D90(2)`, which writes `D_8007D8F4`, and stores the two buffer addresses `0x801B5000` and `0x801DA800` in `D_80138260`.
2. Creates a one-message queue at `0x8013D7C8`, backed by `0x8013D828`.
3. Reads the TV type at `0x80000300`. Value 2 selects VI table entry 28; value 1 selects entry 0. Each path sets width to 320 and the first field origin to 640, multiplies the unsigned horizontal scale by 320, divides the stored product by 320, then calls `func_80050440(&D_801378D0, mode, 1)`.
4. Disables VI gamma and enables the dither filter through two calls to `osViSetSpecialFeatures` with values 2 and `0x40`.
5. Calls `func_8005109C(110, 1)`, `func_8004FE44(&D_801378D0)`, `func_8004C090()`, `func_800470F4()`, and `func_8002205C(D_80095420)`.
6. Calls `func_80048510()`, `func_80048DDC(D_8013823C)`, and `func_80005DEC()`, then repeatedly calls `func_80022D24()` from the loop at `0x8004842C`.

The two TV checks are independent. The second reloads the TV type after the first scheduler call; other TV values skip both scheduler calls and continue initialization. The multiplication and division remain separate unsigned operations. A 32-bit multiplication can wrap, so canceling these operations would change behavior.

The VI table at `0x8008E400` uses an 80-byte stride. Width, horizontal scale, and first field origin are at offsets `0x08`, `0x20`, and `0x28`. The scheduler's indexed mode selection independently confirms the stride. [Scheduler evidence](scheduler.md) records the six queues and three threads created by `func_80050440`.

Two later initialization calls establish additional connections. `func_8005109C` creates eight-message queues at `0x8018FF68` and `0x8018FF30`, backed by `0x8018FF80` and `0x8018FF48`. It creates a thread at `0x8018FFA0` with entry `0x80051380`, null argument, stack top `0x8018FF30`, and both ID and priority taken from its first argument: 110 on this startup path. These instructions are at `0x800512F8..0x8005135C`. Its broader subsystem initialization remains fallback.

`func_8004FE44` creates an eight-message queue at `0x801437A0` backed by `0x801437B8`, passes that queue and the record at `0x801437D8` to `func_800507F0`, and saves the scheduler's queue at offset `0x3C` in `D_80143990`.

`func_80022D24` remains fallback. The repeated call establishes the outer game-iteration entry; its complete state machine, nested loops, and rendering behavior remain to be recovered. The two buffer addresses lie beyond the entry's clearing range. Their allocation extents have not been established.

## Adjacent frame helper

`func_80048460` occupies `0x80048460..0x80048510` (176 bytes) and is called by the wrapper at `0x80048D70`. It calls `func_800489F4`, `func_80048510`, `func_80048DDC(D_8013823C)`, `func_800400D0`, and `func_800466E4`. It then writes the signed quotient `1000 / func_800495BC(D_80138248)` to `D_80138250`, increments `D_8007D8F0`, and calls `func_80048BF8` and `func_80045514`.

The divide and the compiler's zero-divisor/overflow checks are preserved. The quotient's unit and the counter's wider uses are not yet established.

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

## Matching source

`src/boot/startup.c` supplies four functions to the ROM build. IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` produces all 928 bytes at ROM `0x48D70..0x49110` without trimming or changing the object. This includes the original 304-byte PI-read/thread-handoff block and 624 newly reconstructed bytes. The linker applies 16-byte input alignment at the observed start address; accepting the object's 32-byte alignment would insert sixteen leading bytes. `make progress` verifies every function's size, object symbol, and linked bytes.

The PI loop declares its cartridge address, current output pointer, and end pointer before the sixteen-word buffer. All three scalar locals are used. The compiler reserves their source-local slots and places the buffer at `sp + 0x34`, with its end at `sp + 0x74`. It then keeps the address, current pointer, and end pointer in `s1`, `s0`, and `s2`. This source expresses the observed address and pointer increments directly and reproduces the original 128-byte frame. Exact matching supports these declarations as a reconstruction; it does not establish the original variable names or translation-unit boundary.

The second routine begins at section offset `0x94`. IDO emits `.align 5` after its infinite-loop branch and before an unreachable epilogue, producing twenty zero bytes at that position. Compiling the second routine alone produces eight padding bytes and a 144-byte function, with the same live instructions and epilogue. Keeping the two routines together preserves the target's 156-byte second function.

Thread 3 starts at section offset `0x130`. Its infinite loop is followed by twenty zero alignment bytes and an unreachable epilogue. Keeping it with the preceding startup functions preserves those bytes and the following helper's address. This is a matching source arrangement; it does not prove an original translation-unit boundary.

Run `python3 tools/compare_startup.py` for independent compilation and comparison of both the 928-byte startup block and the 496-byte scheduler block. The command records source, header, and symbol-file hashes and byte differences in `build/startup-comparison/report.json`, and fails if either block differs. The full build additionally checks their integration with the assembly entry and the complete ROM. The earlier PI reads' purpose, thread stack bases, and the bodies of the remaining initialization callees are still unresolved.
