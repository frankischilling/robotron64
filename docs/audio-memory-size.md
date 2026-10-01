# Audio memory-size calculation

`func_80052D70` covers `0x80052D70..0x8005303C`. Its complete 716-byte
procedure matches the supplied USA ROM with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. The source is
`src/game/audio_memory_size.c`. The `SN64` C string owns eight bytes at
`0x80095CB0..0x80095CB8`, including alignment. It adds no BSS.

The matching startup caller passes the audio bank's byte address and uses
the returned size for allocation. A null address returns zero. Otherwise,
the routine opens the bank through the matching file service and stores
the cursor in `D_8008D7B0`. An open failure reports error one and returns
the existing audio error value. A short header or settings read reports
error two and returns zero.

The routine selects the context at `D_801902C8`, its table at
`D_80190280`, and its settings prefix at `D_801902A8`. It reads the first
32 table bytes, verifies the first word against the first four bytes of
`"SN64"`, and requires version two in the next word. It then reads 24
settings bytes and closes the file. The settings word at `0x18` becomes
eight. These are existing objects and confirmed views; this recovery
claims no ownership of their storage or any opaque fields.

Starting from the table word at `0x18` plus eight, the routine assigns
temporary offsets for the context's instance, voice, status, and callback
arrays. Their confirmed strides are 24, 80, 20, and eight bytes. It copies
configured counts through the observed byte fields, preserving their
truncation. These pointer fields hold offsets during this size pass;
the subsequent loading routine supplies the allocation.

Each instance contributes three working buffers. After each buffer, the
routine adds the current size's low bit, then adds its next bit. That
order rounds upward to a four-byte boundary. The final per-voice loop
adds four bytes for each configured return-stack entry. The result is
rounded with the same two additions and returned. The source preserves
unsigned loop comparisons, intermediate pointer-field stores, and the
original file-close and error paths.

The full comparison includes all instructions and the 24-byte stack
frame. The [provenance ledger](audio-memory-size-provenance.json) records
complete bounds, linked instructions, signature bytes, and compiler
inputs. All thirteen requested N64 references, pinned revisions, and
licenses remain in [CREDITS.md](../CREDITS.md). Further audio recovery is
tracked by [issue #34](https://github.com/frankischilling/robotron64/issues/34)
and [draft PR #46](https://github.com/frankischilling/robotron64/pull/46).

A clean Git archive of `219ba425aa9a691950587e69529e74d805c2c4c5`
passes fresh extraction and build, all 137 tooling tests, 802 runtime
comparison units, both startup units, eighteen assembly units, eight
data-only units, and linked progress verification. The complete rebuilt
8 MiB ROM equals the supplied target, SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The publication audit checks all 1,315 tracked files. The checkpoint has
1,319 matching C procedures and 226,496 matching instruction bytes;
unrecovered executable fallback remains excluded from those counts.
