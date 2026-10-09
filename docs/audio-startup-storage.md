# Audio startup storage

The complete audio startup at `0x8005109C..0x80051380` supplies a
270,000-byte synthesis heap and an 8,192-byte downward-growing thread stack.
The three 96-byte completion records and three 88-byte scheduler records
end exactly at the synthesis heap. Two 24-byte queues each have eight
four-byte messages, followed by the complete 432-byte thread record.

Ten C translation units define 279,320 bytes of BSS. The four bytes at
`0x80190154..0x80190158` remain unowned. This change adds no initialized data
or instructions; the complete startup, thread and allocation consumers
were already matching C.

| Source | Start | Bytes |
| --- | --- | ---: |
| `temporary_allocation.c` | `0x8014BE50` | 8 |
| `task_records.c` | `0x8014BE58` | 288 |
| `scheduler_records.c` | `0x8014BF78` | 264 |
| `synthesis_heap.c` | `0x8014C080` | 270,000 |
| `thread_stack.c` | `0x8018DF30` | 8,192 |
| `message_queues.c` | `0x8018FF30` | 112 |
| `thread_state.c` | `0x8018FFA0` | 432 |
| `bank_cursor.c` | `0x80190150` | 4 |
| `heap_state.c` | `0x80190158` | 16 |
| `generation_mode.c` | `0x80190168` | 4 |

The sources are in `src/game/audio/startup/`. IDO and Ghidra agree on eight
record types, including every ordinary field, size and alignment: 200
checks over 92 fields. Ghidra stores all fourteen globals at their complete
typed extents. Splat and spimdisasm each reproduce all 740 startup bytes, 560
thread bytes, 468 generation-selector bytes, 52 heap-initializer bytes and 84
heap-allocation bytes, with naturally emitted function extents. m2c contexts,
objdiff, asm-differ and fresh/cached workbench views remain private research
artifacts; complete linked bytes determine acceptance.

The [checker](../tools/check_audio_startup_storage.py) passes 786 paired cases
(1,572 retail/source executions) and rejects eight isolated source mutations.
Cases cover the three task slots, queue arguments, thread-stack top, every
heap alignment, exact fit/exhaustion, signed message types, null tasks,
completion failures, pre-NMI suppression, clock wrap, and generation-mode
storage. Every byte of all ten objects, the unowned gap and adjacent guards
is compared. CPU stores, service order/arguments, code/read/write bounds,
stack guards and saved O32/FPU registers are checked independently.

```sh
python3 tools/check_audio_startup_storage.py --mutations
```

SDK heap initialization/allocation, message queue initialization and game
heap allocation/free execute matching instructions. The game heap fixture
is already initialized; the excluded initializer is not used. Audio engine,
loader, thread, scheduler, queue transport and clock services have recorded
ABI boundaries. Loader data is synthetic. OS thread creation does not run
the new stack or populate its register context. Generation fixtures select
the already-current sequence; they verify mode storage and index wrapping
without executing sequence replacement. These checks do not establish audio
playback, hardware behavior or complete gameplay.

The [evidence ledger](audio-startup-storage-provenance.json) records current
input hashes, complete object placement, all 905 runtime, two startup,
eighteen assembly and 179 data-only comparison units, and the clean
8,388,608-byte ROM match. Totals are 1,423 matching C functions / 308,272
instruction bytes, 36,351 initialized bytes and 870,293 BSS bytes. The build
still includes 141,912 declared CPU fallback bytes in 187 spans and 164
unclassified bytes; full source recovery remains incomplete.
