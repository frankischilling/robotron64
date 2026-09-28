# Audio runtime

The audio initializer and task thread at `0x8005109C..0x800515B0` now have
matching C source. `func_8005109C` covers 740 bytes through `0x80051380`, and
`func_80051380` covers the following 560 bytes through `0x800515B0`. IDO 5.3
with `-O2 -G 0 -non_shared -mips1 -32` reproduces both ranges with zero
differing words.

## Initializer stack layout

`func_8005109C` keeps the value `2` in a local named `messageType`. The value is
used for `AudioSettings.effectType` and later for each of the three
`AudioTaskRecord.messageType` fields. IDO keeps the value in `$s0`, but its
declaration home is still part of the stack layout. Declaring it before
`AudioSettings` places the configuration at `sp + 0x4C`, the settings at
`sp + 0x88`, and produces the target `0xA8`-byte frame.

The matching source supports an inferred 0x2000-byte thread-stack region
beginning at `0x8018DF30`. The audio memory block passed to `func_800656F0`
starts at `D_8014C080` and has size `0x41EB0`, so it ends at `0x8018DF30`.
Adding 0x2000 reaches `0x8018FF30`, the initial stack pointer passed to
`osCreateThread`. `D_8018FF30` is also the address of the audio message queue,
which is consistent with that queue sitting immediately above a
downward-growing stack.

Keeping those as distinct source expressions is required by the target code.
The initializer creates the queue with `&D_8018FF30`, then passes
`D_8018DF30 + 0x2000` as the thread stack top. IDO therefore reloads the stack
top after the queue call and retains `&D_8018FFA0` in `$s0` across
`osCreateThread` and `osStartThread`, matching the original tail exactly.

## Audio task thread

`func_80051380` uses separate `messageType` and `taskIndex` locals for the
received signed-halfword message type and `next % 3`. Both values stay in
registers, while their declaration homes expand the frame from `0x68` to the
target `0x70`. The rest of the function was already instruction-exact, so
these recovered intermediates change only the prologue, incoming-argument
home, and epilogue.

The shared `SchedulerClient` remains eight bytes. Its placement at `sp + 0x48`
and the message slot at `sp + 0x58` agree with the target, and the already
matching scheduler runtime independently confirms the client layout.

## Verification

Run the independent comparison from the repository root:

```sh
python3 tools/compare_runtime.py
```

Reports are written under `build/runtime-comparison/`. Both functions have
the target size and zero differing words. The main build records
`D_8018DF30` at `0x8018DF30` in its runtime symbol map. `make progress`
checks both functions' source and header hashes, object symbols, linked
placement, and bytes in the complete ROM. See [audio task thread](audio-thread.md)
for the recovered message and task behavior.
