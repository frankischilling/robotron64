# Audio command engine and capture

This batch recovers 43 complete functions and 6,032 code bytes
in 19 source units. Six units also define their original private
scratch variables, owning 112 bytes of BSS at their observed addresses.

| Source | Complete target range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `audio_diagnostics.c` | `0x80058C00..0x800592C0` | 5 | 1,728 |
| `audio_engine_setup.c` | `0x800596C4..0x8005971C` | 5 | 88 |
| `audio_engine_voice_stop.c` | `0x8005971C..0x80059898` | 1 | 380 |
| `audio_engine_parameters.c` | `0x80059898..0x80059964` | 13 | 204 |
| `audio_engine_tempo.c` | `0x80059E2C..0x80059FC8` | 1 | 412 |
| `audio_engine_sequence_call.c` | `0x80059FC8..0x8005A180` | 1 | 440 |
| `audio_engine_sequence_jump.c` | `0x8005A180..0x8005A310` | 1 | 400 |
| `audio_engine_sequence_return.c` | `0x8005A310..0x8005A448` | 1 | 312 |
| `audio_engine_sequence_stop.c` | `0x8005A448..0x8005A6D8` | 1 | 656 |
| `audio_engine_voice_tempo.c` | `0x8005A6D8..0x8005A73C` | 1 | 100 |
| `audio_engine_voice_call.c` | `0x8005A73C..0x8005A7C4` | 1 | 136 |
| `audio_engine_voice_jump.c` | `0x8005A7C4..0x8005A830` | 1 | 108 |
| `audio_engine_voice_return.c` | `0x8005A830..0x8005A88C` | 1 | 92 |
| `audio_engine_voice_end.c` | `0x8005A88C..0x8005A9AC` | 2 | 288 |
| `audio_rate_scale.c` | `0x8005AD50..0x8005AD88` | 1 | 56 |
| `audio_voice_capture_control.c` | `0x8005AD88..0x8005ADD0` | 3 | 72 |
| `audio_voice_capture_resume.c` | `0x8005ADD0..0x8005AEA8` | 1 | 216 |
| `audio_voice_capture_append.c` | `0x8005AEA8..0x8005AFE4` | 1 | 316 |
| `audio_voice_argument.c` | `0x8005AFE4..0x8005B000` | 2 | 28 |

The diagnostic helpers report active instances, voices, and status records in
bounded character buffers. The engine setup stores the current audio context
and its voice and instance arrays. The voice stop routine maintains the paused,
running, and active counts, removes the voice index when appropriate, and clears
the timed-stop flag. The recovered empty engine hooks are actual complete
return-only procedures in the target.

The sequence controls dispatch a tempo change, label call, label jump, return,
or stop across an instance's active voice indices. They retain the index-list
capacity bound and the separate active-voice bound. Label calls save return
positions; jumps clear the delay and mark the command as redirected. Their
static scratch declarations reproduce the compiler's stores and original BSS
placement without exporting aliases for private variables.

The per-voice controls implement the same label and tempo operations on one
voice. Return reads the variable-length delay before clearing it as the target
does. The end command either restarts a looping voice from its data or invokes
the backend stop operation, preserving the distinct command-redirection rules.

Voice capture keeps up to 32 records, filters the requested categories, and
stores the instance/voice indices and playback arguments. Resume consumes the
matching records by clearing each restored record pointer. The shared capture
header checks the 16-byte record and 520-byte capture structure.

## Evidence and reproduction

Each retained candidate was compiled with the pinned IDO 5.3 game profile and
linked at the real function and data addresses. Every complete candidate range
in the table matched the USA ROM. The private-symbol checks also inspected IDO's
local debug symbols and the generated BSS size before accepting those units.
Only unused final section alignment was trimmed; no function instructions were
inserted or changed after compilation.

The [input ledger](audio-command-engine-provenance.json) records the candidate
source and comparison report hashes, the promoted source hash, and each private
storage range. These are historical input identities. Current proof comes from
`python3 tools/compare_runtime.py`, which rebuilds the registered units against
the current headers and symbol layout, and `make progress`, which requires the
complete ROM to match before counting linked functions and owned sections.
`make test` checks the tools and source/manifest consistency.

At this batch's checkpoint, all 19 registered comparisons pass with zero
differing words. `make test` passes all 105 tests and validates 816 function
records and 18 owned sections. `make progress` verifies all 8,388,608 ROM bytes
and counts 815 C functions covering 109,232 bytes. The ROM SHA-256 remains
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

The sources were reconstructed from Robotron 64 instructions and callers. The
WESS sequence and capture representation was checked against the DOOM64-RE
revision listed in [CREDITS.md](../CREDITS.md). The credited N64 decompilation
projects and IDO work provide the compiler, layout, and verification references.
Their sources are not used as a substitute for a Robotron comparison.

The status callback at `0x80059964`, gate and iteration handlers in
`0x80059A88..0x80059E2C`, variable-length size calculation at `0x80059644`, and
main engine dispatcher at `0x8005A9AC` remain outside this batch. Their complete
comparisons still have differences. Their fallback spans and all other gaps
remain in the extraction map and do not count as recovered source.
