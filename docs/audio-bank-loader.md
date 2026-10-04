# SN64 bank loader

`src/game/audio/startup/bank_load.c` reconstructs all 1,520 instruction bytes
at `0x8005303C..0x8005362C`, with the eight-byte SN64 signature at
`0x80095CB8..0x80095CC0`. The loader clears the supplied arena, checks the
engine state, reads a 32-byte header and 24-byte patch-bank header, then reads
the bank payload or delegates storage-mode decoding to the host callback.

The header identifies SN64 and version two. Its storage mode is the byte at
offset 16 and its payload size is the word at offset 24. Other header fields
remain unnamed. The existing 28-byte `AudioPatchBank` includes the reconstructed
payload pointer after its 24 serialized bytes. The 36-byte `AudioContext`
records the tick pointer, patch bank, instance and voice arrays, hardware status
records and callbacks. The voice's return-stack start, current pointer and end
are at offsets 60, 64 and 68; command byte count follows at 72. Existing default
setup copies the start to the current pointer and takes the byte count from the
track header, confirming these relationships.

The arena starts on an eight-byte boundary. The loader lays out 24-byte
instances, 80-byte voices, 20-byte status records and eight-byte callbacks.
Each instance receives gates, iterations and a voice-index array on four-byte
boundaries. Voice indices start at 255. Each voice receives a return stack and
an index truncated to one byte. Configured hardware voice, voice-index and
return-stack capacities are also truncated to one byte. Both backend
initializers run before the loader publishes its end pointer and loaded flag.

Allocation and control globals at `0x8008D7B0..0x8008D7D8` and nine configuration
words at `0x8008D844..0x8008D868` are initialized declarations. The record table,
patch bank and context occupy `0x80190280..0x801902EC`, including normal IDO
alignment between declarations. The context pointer occupies the following
four bytes in a separate unit. These objects add 84 initialized bytes and
112 BSS bytes. No padding variable or byte-copy fallback supplies their layout.

The original frame is 56 bytes, with the live length and cursor spills at
offsets 36 and 40 and an untouched 12-byte tail. An unused local reproduces
that tail; its original purpose and type remain unknown.

Error handling preserves the original behavior. A short header or payload
read reports error two; a failed open reports error one. Invalid signatures
or versions and failed host decoding return zero without inventing cleanup.
The matching host allocator returns null, so automatic allocation fails.
Malformed headers and undersized arenas retain their original unchecked
behavior. The complete instruction and owned-data ranges match independently assembled
references, including relocations and BSS declaration extents. The
[proof ledger](audio-bank-loader-provenance.json) records 126 guarded cases,
155 passing tests, fresh runtime/startup/assembly/data comparisons and
all 8,388,608 matching ROM bytes from a clean build. File and backend
callbacks use recorded ABI boundaries; this does not establish full gameplay
validation or complete decompilation.

The source was reconstructed from Robotron's instructions and data.
References and tools are credited in [CREDITS](../CREDITS.md).
