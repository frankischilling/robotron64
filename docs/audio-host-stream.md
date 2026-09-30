# Audio host services and stream positioning

This recovery adds 23 complete procedures, totaling 1,532 matching C bytes.
They complement the handle/property routines in [audio properties](audio-properties.md)
and the lower request/apply pipeline in [audio commands](audio-commands.md).

| Source | Complete target range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `audio_handle_voice.c` | `0x800564E0..0x80056580` | 1 | 160 |
| `audio_handle_seek_relative.c` | `0x80057358..0x800574B8` | 1 | 352 |
| `audio_handle_seek_absolute.c` | `0x800574B8..0x80057610` | 1 | 344 |
| `audio_handle_position.c` | `0x80057610..0x800576E0` | 1 | 208 |
| `audio_host_control.c` | `0x8005891C..0x8005895C` | 6 | 64 |
| `audio_host_files.c` | `0x80058ADC..0x80058C00` | 12 | 292 |
| `audio_stream_variable_write.c` | `0x800595D4..0x80059644` | 1 | 112 |

The voice lookup validates the handle and the instance/voice state before
returning a voice. The position query takes the maximum unsigned position
among an instance's indexed voices. Both seek wrappers pause each selected
voice before invoking its stream walker, retain the lock/unlock ordering,
and return the instance's resulting position. The relative wrapper computes
the requested position separately for each voice.

The host file cursor contains two 32-bit cartridge addresses: the original
base and the current read position. Reads use the existing audio transfer
routine, advance the current position, and return the requested byte count.
Seeking from origin zero uses the base; origin one advances the current
position. Other origins leave the cursor unchanged. The target's fixed
success results, null allocator, and empty host hooks are represented by
their actual C behavior and complete function extents.

The variable-length writer emits seven-bit groups in reverse order from a
local buffer. Every group except the last carries the continuation bit.
Its ten-byte buffer agrees with the WESS `Write_Vlq` reference and reproduces
Robotron's stack layout. That reference corroborates a source choice; the
complete 112-byte target comparison establishes the code match. Buffer size
is not inferred uniquely from a stack frame alone.

The sources were reconstructed from Robotron instructions and the retained
nonmatching candidates in `.local/runtime/.local/recovery71-audio-properties`.
The WESS stream representation and buffer declaration were checked against
`doom64/wessseq.c` in the credited DOOM64-RE revision. See [credits](../CREDITS.md)
and the [recovery input ledger](audio-host-stream-provenance.json).

`python3 tools/compare_runtime.py` recompiles all seven source units and
compares each complete range. It records the current source, transitive
headers, compiler identity, and symbol layout. `make test` checks tooling and
the manifest. `make progress` requires an exact full ROM and checks linked
function placement, complete extents, and source/header/object provenance.

The stream walkers at `0x80056EF0` and `0x80057124`, the stream allocation
routine at `0x800583B4`, and the timing callback at `0x80058A58` remain outside
matching progress. Their fallback spans, neighboring alignment bytes, and
all later unrecovered audio bytes remain in the extraction map.
