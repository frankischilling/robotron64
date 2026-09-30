# Video manager and PI device initialization

Five complete C procedures recover 1,652 instruction bytes. Video manager
creation and its event loop share one translation unit: their respective
392-byte and 460-byte extents form a complete 852-byte block. Video context
initialization is 316 bytes. Cartridge and disk initialization are 236 and
248 bytes. Every procedure uses the verified `sdk-o1-mips2` profile.

## Video manager

Creation initializes timer services, creates the five-message event queue,
and registers retrace and counter events. It temporarily raises the caller's
thread priority when necessary, installs the manager under an interrupt mask,
creates its thread with a 4 KiB stack, initializes video, and starts the thread.
The prior interrupt mask and any changed caller priority are restored.

The event loop receives blocking messages. Retrace events swap video context,
decrement the unsigned short retrace counter, optionally notify the current
context's queue, and update the interrupt count and elapsed 64-bit time.
Counter events service timers. Other message types continue the loop. The
original `first` flag starts at zero; its dormant time-reset branch remains in
the source and emitted code.

The C source owns the 28-byte initialized manager and the 4,626-byte BSS block
from `801950B0` through `801962C2`. The latter contains the 432-byte thread,
stack, queue, five message slots, two 24-byte event records, retrace counter,
and their internal alignment. No ROM bytes are assigned to BSS.

## Video contexts

Initialization clears both 48-byte contexts, resets the current/next pointers,
sets one retrace per context and the cached RAM base as initial framebuffer,
then selects the PAL, MPAL, or NTSC mode. It installs black state and the mode's
control word, waits for the current video line to reach ten or below, blanks
the hardware control register, and applies the next context.

The two zero-initialized contexts and two pointers occupy 104 initialized
bytes at `8008F1D0`. Their complete emitted bytes and relocations match the
target. IDO reports shortened object-symbol sizes for partial zero
initializers; ownership checks the complete emitted section and all declared
offsets. Compile-time type checks establish the full structure sizes.

## Cartridge and disk handles

Cartridge initialization returns an already initialized handle unchanged.
Otherwise it reads the cartridge's timing word, extracts the latency and
pulse bytes and the page/release nibbles, clears the transfer workspace, and
links the handle under an interrupt mask. The original raw-read return value
is ignored. Disk initialization installs the fixed domain-two timing values,
writes the corresponding PI registers, clears its workspace, links the
handle, and installs the pointer used by disk error recovery.

Each complete handle has 116 bytes, including the confirmed 96-byte transfer
workspace. The cartridge handle is at `80196310`; the disk handle and recovery
pointer occupy 120 bytes at `80196390`. Subsequent [PI manager recovery](sdk-pi-manager.md)
establishes the complete transfer layout. The unused word at offset `10`
retains its unknown name. Error recovery retains its confirmed partial view.

Definitions remain in their owning translation units. Their visibility affects
IDO's address scheduling and is required for the exact instruction matches.
The video manager's combined source also preserves internal instruction
alignment that differs when its event loop is compiled in isolation.

## References and proof

The pinned local [libreultra](https://github.com/n64decomp/libreultra) files
`src/io/vi.c`, `src/io/vimgr.c`, `src/io/viint.h`, `src/io/cartrominit.c`, and
`src/io/leodiskinit.c` corroborate the SDK interfaces and layouts. Complete
Robotron instructions, initialized bytes, BSS definitions and symbol offsets
establish the accepted code. [CREDITS.md](../CREDITS.md) records the full local
and online reference collection. The
[provenance ledger](sdk-video-and-device-initialization-provenance.json)
records all four source units and five procedure extents. All 688 runtime
units, both startup units, nineteen assembly units, and 118 tooling tests pass.
The rebuilt 8,388,608-byte ROM matches every normalized target byte.
