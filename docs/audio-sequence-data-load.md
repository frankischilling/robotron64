# Audio sequence data loading

`func_8005CE0C` owns the complete 1,044-byte range
`0x8005CE0C..0x8005D220`. It validates a sequence index and track limit,
reserves 12 bytes per track, rounds the following payload up to eight-byte
alignment, and loads that payload through file services or the DMA wrapper.
Each descriptor then points to a 20-byte header, its labels, and its commands.

The serialized entry count is unsigned 16-bit; each header's label count is
signed 16-bit. The command byte count is unsigned 32-bit. These interpretations
follow the retail load instructions. Negative label counts move the command
pointer backward; the reconstructed code preserves that behavior. The routine
does not validate payload bounds. The entry's descriptor pointer is written
before I/O, so it remains changed after an open, seek, read, or DMA failure.
File read failures report code 2, open failures code 1, and seek failures code 3.
The loader calls its close service only after a successful file read.

`tools/check_audio_sequence_data_load.py` freshly compiles the source with IDO
5.3 and compares its complete procedure to retail before executing either.
The October 3 audit passed 526 cases against an independent array model,
including zero through 16 tracks, four-track unrolling boundaries, unsigned
counts 32,768 and 65,535 rejected before allocation, all failure paths, storage
modes 0, 1 and 255, offset wrap, and signed label counts -5, -1, 0 and 3.
It checks the complete guarded destination and context, the entry table and
globals, callback arguments including the fifth stack argument, caller stack
guards, and preserved registers. Boundary stubs poison caller-saved registers.
Short-read and DMA failure fixtures also retain partial I/O writes.

Successful nonempty descriptor arrays use word-aligned caller memory, as required
by the retail MIPS word loads and stores. Both four-byte offsets within an
eight-byte boundary are tested. Zero-track successes and rejected inputs cover
all eight byte offsets. Negative label fixtures are bounded synthetic payloads;
arbitrary corrupt buffers and unaligned nonempty successes are outside the
execution check. File, DMA and validation services remain recorded ABI stubs;
this does not establish device behavior or whole-game playback.

Run with the project's analysis environment:

```sh
python3 tools/check_audio_sequence_data_load.py
```

The passing audit used Unicorn 2.1.0. Compiler identity, input hashes, checker
hash, helper hash and the execution trace digest are recorded in
[the focused provenance](audio-sequence-data-load-provenance.json).
Ghidra's entry, header and track layouts were synchronized with the canonical
header, including field offsets and signedness. The loader and validator
prototypes, context globals and loader's local entry pointer were also typed.
The file cursor global and file-service signatures use the header's opaque
`AudioFileCursor *`; no cursor fields or layout have been inferred.
All 454,720 loaded CPU bytes matched retail before and after these changes.
Ghidra still reports an overlapping-instruction warning at the branch delay
slot `0x8005D074`; the complete retail comparison and execution checks cover
that instruction and both track-loop paths. The warning does not indicate a
byte mismatch in the reconstructed procedure.
Full batch clean-build verification and CI remain separate acceptance gates.
