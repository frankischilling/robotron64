# Audio instance allocation and command tables

`func_8005396C` at `0x8005396C..0x80053C50` is the 740-byte instance
allocator. It selects the first inactive instance, scans the configured voice
pool, initializes each selected voice and records its index. A request can
succeed with fewer voices than requested. The configured limits and counters
are bytes; the original zero/negative requested-count behavior and byte-counter
wrap are preserved.

The complete function compiles with the pinned IDO 5.3 profile (`-O2 -G0
-non_shared -mips1 -32`) and independently matches retail ROM offsets
`0x5456C..0x54850`. Ghidra's contiguous function body and a separately
assembled splat/spimdisasm reference agree with those boundaries. The reference
procedure is 740 bytes; its assembler section's additional alignment bytes are
not counted as recovered code.

`tools/check_audio_instance_allocate.py` compares fresh compiled and retail
instructions against an independent array model in 354 cases. Cases cover
invalid sequence indices, occupied pools, sparse and partial allocation,
zero/negative requested counts, paused and playing flags, truncated configuration
limits, and counter wrap. The checker verifies complete guarded state, callback
arguments, the fifth stack argument, balanced interrupt-gating calls, and saved
registers. Sequence validation and voice setup/binding are recorded ABI stubs;
the check does not emulate the audio hardware or establish whole-game playback.

Two data-only C units recover 180 initialized bytes:

| Source | Runtime range | Bytes | Meaning |
| --- | --- | ---: | --- |
| `audio_command_lengths.c` | `0x8008D8D0..0x8008D8F4` | 36 | Encoded lengths for command indices 0 through 35. |
| `audio_engine_command_table.c` | `0x8008D920..0x8008D9B0` | 144 | Two context callbacks and 34 voice callbacks, including 17 sequence commands at offset `0x4C`. |

All 36 table targets are already recovered procedures. Independent compilation
and linking verifies every initialized byte and all 36 MIPS32 pointer
relocations. The table header preserves the different context and voice callback
signatures. The gaps around these tables remain explicitly extracted data.

The data-only validator now distinguishes undefined function references from
defined procedures. Typed function-pointer tables may contain `STT_FUNC` entries
with `SHN_UNDEF`; defined or absolute procedure symbols and allocated executable
content remain rejected. Synthetic tests include an assembled external callback
relocation, so public CI can check this distinction without a commercial ROM.

Ghidra uses the existing `robotron64.elf` analysis. Its audio layouts were checked
against `include/audio_properties_internal.h`; verified backend globals that
were previously outside its mapped memory were described as uninitialized RAM.
The entire loaded CPU image was compared with retail before and after type work.

Research used Ghidra MCP, splat, spimdisasm, m2c, asm-differ, objdiff, the pinned
IDO compiler, and Unicorn. DOOM64-RE's WESS implementation at revision
`6931e678a0b2958be1b49598f2fe60712c6596e1` informed the interpretation of
allocation and command-stream control flow. Robotron's original instructions,
data and caller behavior determine acceptance; reference-project source is not
substituted for a retail match. See [credits](../CREDITS.md) for tool and reference
repositories.

Independent checks for this group:

The fresh October 3 audit passed all 354 allocator cases: 166 returned zero
and 1,004 voices were allocated across successful cases. Both data units passed
independent compilation and linking. The command table object contains exactly
36 `R_MIPS_32` relocations. Ghidra's complete 740-byte allocator body also matches
the retail input. Input hashes, compiler identity, execution trace digest and
data hashes are recorded in
[the focused audit provenance](audio-allocation-and-commands-provenance.json).

```sh
python3 tools/check_audio_instance_allocate.py
python3 tools/compare_data.py
```

Full-ROM acceptance and final publication records are maintained with the batch
validation results. This group does not establish complete decompilation.

The related [sequence data loader](audio-sequence-data-load.md) recovers a further
1,044 bytes and has its own independent compilation and guarded execution proof.
