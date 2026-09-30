# PI manager and transfer records

Three complete C procedures replace 3,260 instruction bytes: `osCreatePiManager`
at `800601E0` is 392 bytes, and the device-manager loop at `80067BC0` is 1,168
bytes. The disk interrupt handler at `8006DC20` is 1,700 bytes. All three use
`sdk-o1-mips2`. Manager creation owns 40 initialized bytes and
4,556 BSS bytes; the loop owns its complete 28-byte relocated switch table.
Trailing alignment remains checked fallback and is excluded from source counts.

## Creation and storage

Creation returns if the manager is active. Otherwise it initializes the command
and event queues, ensures the PI access queue exists, registers event eight
with message `22222222`, and temporarily raises the caller's priority when
necessary. It installs the manager and DMA callbacks under an interrupt mask,
creates its thread with a 4 KiB stack, starts it, and restores mask and priority.

The initialized block at `8008E3D0` contains the 28-byte manager, handle-list
pointer, and two domain-handle pointers. The latter resolve to the recovered
cartridge and disk handles. BSS at `80193B40` contains the 432-byte thread,
4,096-byte stack, 24-byte queue, and four-byte message slot, ending at `80194D0C`.
The existing queue getter and DMA submission now access the shared manager's
typed fields; their complete 40-byte and 268-byte procedures still match.
The interior queue field no longer has an absolute linker alias.

## Transfers and completion

The 116-byte handle contains a typed 96-byte transfer record at offset `14`:
command, transfer mode, block number, sector number, device address, buffer
manager and sequence shadows, and two 36-byte block records. Each block contains
status, DRAM and correction pointers, sector size, error count, and four error
sector words. Compile-time size checks guard these layouts. The unused handle
word at offset `10` retains its unknown name.

The loop receives blocking command messages. Message type 10 is loopback, 11
is raw read, 12 is raw write, 15 is extended read, and 16 is extended write.
DMA acquires PI access, calls the installed callback, waits for the event on
success, sends the original message to its return queue without blocking, and
releases access. Unknown types fail. Both instructions and all seven jump-table
entries match; instructions alone would not establish the case labels.

Disk commands zero and one reset the sector number to minus one, adjust DRAM
unless the mode is three, acquire access, change the mask, and start the buffer
manager. Track reads can send two notifications. Error 29 resets and restores
the buffer manager, checks and clears mechanical status when requested, records
error four, clears the PI interrupt, and restores the disk interrupt mask.
The loop releases access and yields for block one. All branches and the original
unreachable epilogue are included. The unsigned message type follows the target
halfword load. Existing disk recovery retains its compatible smaller prefix.

## Disk interrupts

The handler derives the current transfer and block from the installed disk
handle. DMA busy records error 29 and notifies the event queue. Mechanical
interrupts wait for PI, clear their status, and return zero. Buffer-manager
errors record status 22, notify completion, clear the PI interrupt, and restore
its global mask. Command type two returns without another transfer.

Writes advance sector and DRAM state, transfer each requested sector, and
check the final count against the mode times 85. Reads track correction errors,
retain four sector indices, transfer the correction buffer at sector 87, and
switch to the second block for track mode. A first block with no recorded
errors checks the first four correction-buffer words before completion.
Unexpected request timing and counts preserve statuses 23 and 24 and call
the existing abnormal-recovery procedure. Unknown commands preserve status
four. The original fall-through after a correction-count error is retained.
Every polling load and all complete return paths match the target instructions.

## Reference and proof

Pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/io/pimgr.c`, `src/io/devmgr.c`, `src/io/leointerrupt.c`, and
`include/2.0I/PR/os.h` corroborate the
flow and structures. Complete Robotron instructions and relocated storage
establish the accepted variant. [CREDITS.md](../CREDITS.md) records these uses
and all thirteen requested projects. The [provenance ledger](sdk-pi-manager-provenance.json)
records complete extents, comparison inputs, storage ownership, and target hashes.
Every counted source unit and the complete ROM are verified before publication.
