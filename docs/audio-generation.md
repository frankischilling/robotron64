# Audio task generation

The audio generation control block at `0x800515B0..0x80051854` is recovered in
`src/game/audio_generation.c`. Its three functions total 676 matching bytes:
64 bytes for `func_800515B0`, 144 bytes for `func_800515F0`, and 468 bytes for
`func_80051680`.

`func_800515B0` translates indices below `0x88` through `D_8008D590` before
starting playback. `func_800515F0` polls the current generated-audio instance
and either clears it or restarts it after the countdown expires.
`func_80051680` allocates the temporary audio arena, normalizes the requested
index into `0x88..0x92`, waits for the previous instance to stop, sizes the
largest required sequence buffer, loads the selected sequence, starts it, and
releases the temporary arena.

The task builder at `0x800521C8..0x80052378` is recovered as 432 bytes of
matching C in `src/game/audio_task_build.c`.

The builder first runs the DMA-pool cleanup callback, converts the record's
audio-data pointer to a physical address, and queues the previous record for
audio-interface DMA when one exists. It derives the next sample count from
the audio interface's remaining byte count, clamps that count to
`D_801901F0`, and asks `func_80065D78` to generate
the command list into the active command buffer.

The returned command pointer becomes the task data length after rounding down
to an eight-byte boundary. The task uses the audio microcode boot image at
`D_8006F440`, the main microcode at `D_80071D10`, the data image at
`D_80096FD0`, and a fixed `0x800`-byte microcode-data size.

The local `remainingBytes` holds the result of `func_80065C20`, whose body
reads the audio length register at `0xA4500004`. The count calculation divides
that value by four, combines it with the two existing tuning values, rounds
to sixteen samples, and adds sixteen. Declaring this functional intermediate
before `address`, `end`, and `generated` reproduces the target's `0x40`-byte
frame and observed local homes. No unused stack-padding declaration is needed.

The shared `AudioRspRecord` has a data pointer at offset zero, a signed
sample count at offset four, and an `RspTask` at offset eight. It occupies
72 bytes. Both the ring selector and builder use that shared record type.
The previous-buffer call returns an integer DMA status that the game ignores;
the declaration preserves that return type.

The neighboring DMA transfer callback at `0x80052378..0x8005254C` and pool
cleanup routine at `0x80052580..0x800526D0` remain separate recovery targets.
Their preserved probes live under `.local/audio-generation-w1-20260927/`.
