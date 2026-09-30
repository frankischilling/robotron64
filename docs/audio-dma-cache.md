# Audio DMA cache

Two complete procedures match all 804 instruction bytes with the pinned
IDO 5.3 game profile. Their diagnostic literals own 24 initialized bytes.
The [provenance ledger](audio-dma-cache-provenance.json) records complete
procedure extents, source inputs and storage comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_80052378` | 468 | Find a cached ROM range or submit an aligned DMA transfer |
| `func_80052580` | 336 | Consume transfer completions and recycle expired buffers |

## Cache lookup and insertion

The reader traverses active buffers in address order. It stops before the
first buffer whose ROM address exceeds the requested address. A range that
fits an existing buffer refreshes its frame stamp and returns the physical
address of the requested byte. The start comparison is unsigned; the
computed end comparison retains the target's signed word interpretation.

A miss removes the first free buffer and inserts it after the preceding
active buffer, or at the active head. The source captures the previous
head before replacing it so both forward and backward links remain valid.
The first eight bytes of each twenty-byte buffer provide the SDK's link
interface. Explicit casts expose that confirmed prefix to the shared link
helpers.

The reader captures the data pointer before calculating the odd-address
offset, rounds the device address down to an even byte, records the current
frame and submits a transfer using the next 24-byte PI message. It increments
the transfer count at submission. The returned physical address includes
the saved odd-byte offset. The callback state argument remains unused.

If no free buffer exists, the reader reports `DMAPTRNULL` and returns the
physical address of the active-list head itself. The source preserves this
shipped fallback, including the case of an empty active list.

## Completion and expiration

The recycler attempts one nonblocking receive for every pending transfer.
A failed receive reports `DMANOTDONE` and continues. It then traverses the
active list, capturing each next pointer before a possible removal.

A buffer expires when its frame stamp plus the configured lifetime is
strictly less than the current frame. The arithmetic remains unsigned.
Removing the head first updates the active head from the node's link.
The shared SDK helpers unlink the node and insert it after the free-list
head. An empty free list receives the node with both links cleared.
Finally the routine clears the pending transfer count and increments the
frame counter. No new locks or completion waits are introduced.

## Shared types and literals

The existing audio transfer request now aliases the shared SDK PI message
type. Its verified 24-byte layout and seven-argument submission interface
serve both the synchronous audio reader and the DMA cache. Complete
comparisons check all existing users of the changed header.

Each diagnostic occupies twelve read-only bytes, including its terminator
and word alignment. They begin at `0x80095C90` and `0x80095C9C`.
Additional alignment before the following constants remains outside these
ownership claims. The runtime buffer, message arrays, queues and counters
are referenced through their existing addresses; this recovery claims no
new BSS allocation.

## References and validation

The pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/audio/event.c` corroborates use of the SDK link prefix through explicit
casts. Robotron's complete procedures determine the DMA ordering, range
comparisons, expiration rule and preserved error paths. The pinned IDO and
Super Mario 64 matching-build references remain credited in
[the credits](../CREDITS.md). No reference implementation is copied into
these routines.

Validation covers tooling tests, extraction and build, every runtime,
startup, native assembly and data comparison unit, linked procedure extents,
both complete literals and the exact USA ROM. A clean committed archive and
publication audit independently check the public sources.
