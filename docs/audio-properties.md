# Audio handle, voice, and host properties

This recovery batch replaces 54 complete fallback procedures from
`0x80056480..0x800595D4` with 6,120 bytes of matching C. The retained gaps in
that address span remain ROM-backed, including the parser block at
`0x80056EF0..0x800576E0`, the host implementation at
`0x800583B4..0x80058890`, and the command queue surroundings.

The recovered code covers handle creation and release, state and property
updates, voice command dispatch, property capture and application, stream
storage, host callbacks, timing-rate conversion, and one stream-variable
decoder. `AudioInstance`, `AudioVoice`, `AudioProperties`, and the host-facing
records live in private internal headers with compile-time size checks. Unknown
fields retain address-based names until callers establish stronger semantics.

The historical recovery inputs are retained under
`.local/runtime/.local/recovery71-audio-properties` in the original workspace.
The [input ledger](audio-properties-provenance.json) records all 44 original
source hashes, their report hashes, and the header versions used by those
reports. Twenty-nine reports used earlier headers; matching copies of every
recorded header remain in the archive. Those reports describe their original
inputs. They do not establish matching for a later header revision.

The integrated sources change the quoted include paths and preserve the
function bodies. A fresh comparison of all 44 complete source units against
the target passed with the headers under `include/`. The local result is
`build/upper-audio-comparison/report.json`. The ordinary public verifier,
`python3 tools/compare_runtime.py`, recompiles these units with the rest of the
runtime and records current source, header, compiler, and symbol-layout hashes.

`make` builds the ROM. `make verify` compares all ROM bytes. `make progress`
also checks source/header/object provenance, function extents, and linked
placement. `make test` validates tooling and the manifest without requiring
the target ROM. The linker and extraction map retain every unrecovered gap.

The WESS reference in [DOOM64-RE](https://github.com/Erick194/DOOM64-RE/tree/6931e678a0b2958be1b49598f2fe60712c6596e1)
was consulted for record and event terminology. Its `wessapi.h`, `wessarc.h`,
`wesshand.h`, `wessseq.h`, `wesshand.c`, `wessseq.c`, and `wessshell.c` are
identified in the local reference manifest. Robotron's instructions establish
the functions and layouts recorded here. See [credits](../CREDITS.md) for the
reference revision and license notice.

## Exact source groups

| Source | VRAM range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `audio_handle_instance.c` | `0x80056480..0x800564E0` | 1 | 96 |
| `audio_handle_create.c` | `0x80056580..0x800565D8` | 1 | 88 |
| `audio_handle_state.c` | `0x800565D8..0x80056648` | 1 | 112 |
| `audio_handle_release.c` | `0x80056648..0x80056780` | 1 | 312 |
| `audio_handle_resume.c` | `0x80056780..0x80056898` | 1 | 280 |
| `audio_handle_resume_default.c` | `0x80056898..0x800568B8` | 1 | 32 |
| `audio_handle_voice_resume.c` | `0x800568B8..0x80056944` | 1 | 140 |
| `audio_handle_voice_resume_default.c` | `0x80056944..0x80056964` | 1 | 32 |
| `audio_handle_properties_capture.c` | `0x80056964..0x80056A54` | 1 | 240 |
| `audio_handle_properties_apply.c` | `0x80056A54..0x80056B44` | 1 | 240 |
| `audio_handle_stop.c` | `0x80056B44..0x80056C58` | 1 | 276 |
| `audio_handle_rate.c` | `0x80056C58..0x80056D88` | 1 | 304 |
| `audio_handle_validate_only.c` | `0x80056D88..0x80056DB0` | 1 | 40 |
| `audio_handle_rewind.c` | `0x80056DB0..0x80056EF0` | 1 | 320 |
| `audio_voice_command_parameter.c` | `0x800576E0..0x80057858` | 4 | 376 |
| `audio_voice_command_temporary.c` | `0x80057858..0x8005789C` | 1 | 68 |
| `audio_voice_properties_apply.c` | `0x8005789C..0x80057B08` | 1 | 620 |
| `audio_voice_properties_capture.c` | `0x80057B08..0x80057C64` | 1 | 348 |
| `audio_handle_parameter_57c70.c` | `0x80057C70..0x80057C9C` | 1 | 44 |
| `audio_handle_pair_request.c` | `0x80057C9C..0x80057D08` | 1 | 108 |
| `audio_handle_pair_decode.c` | `0x80057D08..0x80057D68` | 1 | 96 |
| `audio_handle_pair_apply.c` | `0x80057D68..0x80057E3C` | 1 | 212 |
| `audio_voice_command_18.c` | `0x80057E3C..0x80057E94` | 1 | 88 |
| `audio_handle_parameter_57e94.c` | `0x80057E94..0x80057EC0` | 1 | 44 |
| `audio_handle_parameter_57ec0.c` | `0x80057EC0..0x80057EF0` | 1 | 48 |
| `audio_voice_command_10.c` | `0x80057EF0..0x80057F48` | 1 | 88 |
| `audio_handle_parameter_57f48.c` | `0x80057F48..0x80057F74` | 1 | 44 |
| `audio_voice_command_11.c` | `0x80057F74..0x80057FCC` | 1 | 88 |
| `audio_handle_parameter_57fcc.c` | `0x80057FCC..0x80057FF8` | 1 | 44 |
| `audio_handle_parameter_57ff8.c` | `0x80057FF8..0x80058024` | 1 | 44 |
| `audio_handle_parameter_58024.c` | `0x80058024..0x80058050` | 1 | 44 |
| `audio_voice_command_14.c` | `0x80058050..0x800580A8` | 1 | 88 |
| `audio_handle_parameter_580a8.c` | `0x800580A8..0x800580D4` | 1 | 44 |
| `audio_voice_command_15.c` | `0x800580D4..0x8005812C` | 1 | 88 |
| `audio_handle_parameter_5812c.c` | `0x8005812C..0x80058158` | 1 | 44 |
| `audio_voice_command_16.c` | `0x80058158..0x800581B0` | 1 | 88 |
| `audio_handle_parameter_581b0.c` | `0x800581B0..0x800581DC` | 1 | 44 |
| `audio_handle_parameter_request.c` | `0x800581DC..0x80058248` | 1 | 108 |
| `audio_handle_parameter_decode.c` | `0x80058248..0x800582A8` | 1 | 96 |
| `audio_handle_parameter_apply.c` | `0x800582A8..0x80058314` | 1 | 108 |
| `audio_stream_storage.c` | `0x80058320..0x800583B4` | 4 | 148 |
| `audio_host_callbacks.c` | `0x80058890..0x8005891C` | 4 | 140 |
| `audio_timing_rate.c` | `0x800589DC..0x80058A58` | 2 | 124 |
| `audio_stream_variable_read.c` | `0x80059580..0x800595D4` | 1 | 84 |
