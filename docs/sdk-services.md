# SDK services

> Local reference study: most SDK implementation described below remains in
> ROM extraction. The small handwritten CP0/TLB routines listed in
> [SDK assembly identification](libultra.md) are distributed matching assembly
> and are counted separately from matching C.

The recovered PI, VI, SP, thread and message-queue services use IDO 5.3 with
`-O1 -G 0 -non_shared -mips2 -32`. The game continues to use its separately
verified O2/MIPS I profile. Each source file is compared at its original
address before integration. The independent runtime comparison and full-ROM
build then check the selected profile, function boundaries and linked bytes.

## Thread and queue layouts

`include/scheduler.h` now records the thread header and saved register context.
The retail restore routine at `0x800671D4` reads the integer registers from
`+0x20..+0x110`, status at `+0x118`, program counter at `+0x11C`, RCP mask at
`+0x128`, floating-point control at `+0x12C`, and sixteen doubleword
floating-point slots at `+0x130..+0x1A8`. The complete thread is `0x1B0` bytes;
existing scheduler storage and offsets retain their sizes.

Creation sign-extends the entry argument and stack address into their saved
64-bit registers, reserves 16 bytes below the initial stack pointer, and
links the new thread into the active list with interrupts disabled. Starting
and reprioritizing threads preserve the original ready/waiting transitions
and priority preemption checks.

The queue tail at `D_8008F1A0` is an eight-byte prefix containing a null next
pointer and priority `-1`. Its neighboring ready and active list heads begin
at `D_8008F1A8` and `D_8008F1AC`; it is not declared as a complete thread.
Message queues retain their 24-byte layout. Send and front-insert block only
when the flag equals one; receive blocks for any nonzero flag. Empty/full
nonblocking operations restore interrupts before returning `-1`. Successful
operations preserve the original signed remainder and wake an eligible
thread from the opposing queue.

## Video and device access

`include/sdk_video.h` shares the 48-byte VI context between the mode, feature,
event and framebuffer helpers. Field offsets through `+0x14` are established
by those functions. The following six words remain unnamed. Current and next
contexts are distinct pointers at `D_8008F230` and `D_8008F234`.

The special-feature setter applies each requested bit in source order,
including both halves of conflicting on/off requests. Disabling the dither
filter restores anti-alias bits from the selected mode. Mode and blanking
setters update the pending context under the original interrupt mask.

Virtual-to-physical translation masks both direct-mapped kernel segments to
29 address bits and calls the TLB probe for other addresses. Raw PI reads
wait for both PI busy bits to clear, combine the cartridge base with the
device address, and read through the uncached segment. SP DMA rejects a busy
device, translates the DRAM address, and writes the original direction and
length registers. SP and AI busy queries retain their specific status masks.

The AI buffer setter preserves the original 0x2000-byte address adjustment
at the 0x4000-byte boundary and updates the remembered adjustment flag before
checking whether the AI FIFO is full. The remaining-length helper performs
one volatile register read.

Function addresses and exact sizes are recorded in `config/functions.json`.
The audio heap and framebuffer block has additional profile evidence in
[SDK audio helpers](sdk-audio.md). Most SDK interrupt/context-switch assembly
remains extracted fallback. The registered CP0/TLB service routines in
[SDK assembly identification](libultra.md) are the explicitly verified
exception; these C routines do not claim their bytes.
