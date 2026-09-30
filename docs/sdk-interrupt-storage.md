# Interrupt tables and kernel storage

Four C units containing only data recover 240 initialized bytes and 4,528 BSS
bytes. They add no procedures or instruction bytes. Complete independent
compilation checks every owned section, symbol offset and initialized target
byte and rejects any executable content. All six data-only units, including
the two video timing units, are included in the publication audit.

| Storage | Address | Bytes |
| --- | --- | ---: |
| RCP clear/set mask table | `80095DD0` | 128 |
| CPU priority offsets | `80095E60` | 32 |
| CPU handler address table | `80095E80` | 36 |
| Hardware interrupt callbacks | `8008F180` | 20 |
| Thread sentinel and queue pointers | `8008F1A0` | 24 |
| Exception scratch thread and disk stack, BSS | `80196490` | 4,528 |

## Interrupt tables

The RCP table converts each of the 64 six-bit interrupt masks into twelve MI
clear/set bits. Each interrupt selects exactly one bit in its adjacent pair:
clear when disabled, set when enabled. The CPU table selects the highest
pending bit in either four-bit group and gives its byte offset into the nine
handler addresses. Those addresses resolve to exported branch labels within
the recovered exception assembly. The assembly input labels have `STT_NOTYPE`.
Their C byte-address declarations give them zero-sized `STT_OBJECT` symbols
in the combined link. Both forms and every address are verified; they add no
procedure counts.

`tools/generate_interrupt_tables.py` reconstructs the offsets and mask values
from these rules without reading a ROM. It also renders the verified symbolic
handler order. `--check` checks both committed declarations. Four tests cover
priority selection, all clear/set pairs, invalid masks, and reproducible source.

IDO emits the const-qualified address initializers and their relocations in
`.data`, while the offset bytes and RCP values occupy `.rodata`. The ownership
records preserve those input sections and place every byte at the original
target address. Twelve bytes after the handler table remain separately checked
alignment and are excluded from source counts.

## State and queues

The five-entry hardware callback array starts cleared. The exception scratch
context uses the complete 432-byte `OSThread`; its following 4 KiB disk stack
starts at `80196640`. The native cartridge-interrupt path retains its original
stack-end offset. The complete BSS extent ends at `80197640` and has no ROM
payload.

The eight-byte sentinel contains a null next pointer and priority minus one.
Both the ready and active queue pointers initially reference that sentinel.
Running and faulted thread pointers start null. Existing thread creation,
message queues, interrupt dispatch and scheduling use these actual C
definitions at their original addresses. Absolute aliases for the owned
storage are removed. Complete code comparisons are repeated after integration.

## Comparison and references

Adjacent data-only sections exposed an ABI metadata orphan in the independent
link. The comparison now discards `.reginfo` and `.MIPS.abiflags` after checking
the raw object's permitted sections. Every owned section still has explicit
VMA and ROM placement. Two additional tests cover adjacent placement and a
BSS-only unit; executable and unowned allocated sections remain rejected.

Pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/os/setintmask.s`, `src/os/exceptasm.s`, `src/os/exceptasm.h`,
`src/os/thread.c`, `src/os/osint.h`, and `src/io/leointerrupt.c` corroborate the
bit rules, table order, sentinel, context and stack. Complete Robotron bytes,
relocations and definitions establish the accepted storage. [CREDITS.md](../CREDITS.md)
records these uses and all thirteen requested reference projects. The
[provenance ledger](sdk-interrupt-storage-provenance.json) records all four
independent units and verifies the nine branch labels against the linked
exception code. Every counted source and the whole ROM are verified before
publication; game and compression fallback still remains.
