# Audio callback and task adapters

The following retail functions are reconstructed as separate C objects. The
alignment gaps between the last three functions remain extraction-owned;
they are not part of the functions' source or matching-byte counts.

| Source | Function | Bytes | Behavior |
| --- | --- | ---: | --- |
| `audio_task_select.c` | `func_8005211C` | 172 | Select a task from the three-record ring and update the command-buffer selector. |
| `audio_pool_callback.c` | `func_8005254C` | 52 | Initialize the DMA pool once and return its transfer callback. |
| `audio_shutdown.c` | `func_800526D0` | 44 | Reset audio control and close the synthesizer state. |
| `audio_callback_registration.c` | `func_80052700` | 84 | Initialize the callback record and add it to the synthesizer. |
| `audio_callback_return.c` | `func_80052754` | 32 | Service the audio callback and return `0x208D`. |

## Shared callback types

`include/audio_callbacks.h` records the callable types and the layouts used
by these adapters. The DMA callback takes an integer device address, an
integer byte length and a context pointer. Its factory returns that function
pointer directly. The recovered transfer body at `0x80052378` reads its first
two arguments and saves its unused third argument; an `int (void)` declaration
would lose that interface even though the factory's instruction bytes could
still match.

The DMA buffer has next and previous pointers at offsets zero and four, a
device address at eight, a frame stamp at twelve, and a data pointer at
sixteen. The twelve-byte pool state contains its initialized byte followed
by active-list and free-list pointers. The allocator at `0x80052378` removes
the head of the latter list when a cached range cannot satisfy a request.

The twenty-byte callback record contains a linked-list pointer, callback
argument, function pointer and two remaining integer fields. Registration
at `0x80066310` writes the owner's previous list head into offset zero and
then installs this record as the new head. Both the registration function
and the callback use the shared declarations. The synthesizer itself stays
opaque here because these adapters only pass its address.

## Ring behavior

`func_8005211C` returns null while the task subsystem is disabled. Otherwise it
calls the task builder with the current record, saves that record as the most
recent one, and advances the three-entry ring even when the builder returns
null. Only a non-null task toggles the two-entry command-buffer selector.
The builder at `0x800521C8` is reconstructed in
[`audio_task_build.c`](../src/game/audio_task_build.c); see
[audio task generation](audio-generation.md) for the record and sample-count
calculation.
