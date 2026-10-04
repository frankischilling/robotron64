# Audio playback setup and dispatch

The playback setup at `0x8005B064..0x8005B3A8` is reconstructed in
`src/game/audio/backend/playback.c`. Its complete 836-byte function, two
eight-byte pitch-bend constants, and seven private state fields are owned by
source. The state occupies `0x80192A9C..0x80192ABC`, including normal alignment
between the short pan, configuration record, and word fields.

Playback combines voice velocity, region volume, track volume and the category's
master volume, then applies attack volume. Pan follows the existing enable flag
and clamps to `0..127`. Positive and negative bend use the region's separate
signed factors and the target's double `0.0122` scale. The routine clamps SDK
priority, allocates the SDK voice, computes tuning from key, root key, bend and
detune, then starts the wave with the observed attack time and effect byte.

`src/game/audio/dispatch.c` owns all ten backend pointers at
`0x8008D800..0x8008D828`. Slot one selects the hardware driver; the other nine
select the existing engine table. `src/game/audio/backend/commands.c` owns the
driver's nineteen callbacks at `0x8008D9D0..0x8008DA1C`. Context initialization,
shutdown, frame update, reserved commands, stop, pause and twelve encoded voice
commands retain the observed order. `AudioOperations` now declares its
initializer and reserved callbacks explicitly. The empty command at
`0x8005C32C` takes the voice pointer used by this table and still matches all
eight bytes.

The source was reconstructed from Robotron's instructions and data. SDK voice
and configuration layouts use the existing verified headers. Reference projects
and analysis tools are credited in [CREDITS](../CREDITS.md).

Complete independent comparisons, relocation checks, guarded execution and
fresh build results are recorded in the [proof ledger](audio-playback-and-dispatch-provenance.json).
The [voice release and pitch command](audio-voice-release-and-pitch.md),
[stream walkers](audio-seeking.md) and
[sequence tick](audio-timing-and-sequence-tick.md) have since been recovered
with their own complete comparisons and execution checks.
