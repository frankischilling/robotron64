# Input, actor-contact and sound recovery

This recovery replaces four complete fallback procedures with matching C.
Each uses the pinned IDO 5.3 game profile. Independent comparisons check every
instruction byte before the linked build verifies the complete retail ROM.

| Source | Procedure | Instruction bytes |
| --- | --- | ---: |
| `early_player_input_sample.c` | `func_8001A1F0` | 212 |
| `early_relative_position.c` | `func_8000CD50` | 228 |
| `actor_contact_gate.c` | `func_8001669C` | 632 |
| `sound_request_dispatch.c` | `func_8003614C` | 176 |

The batch adds 1,248 C instruction bytes and the sound dispatcher's 32-byte
warning span. It introduces no BSS. The complete target still contains
extracted fallback; ROM equality does not establish source completion.
[Provenance](input-contact-sound-provenance.json) records the verified source
inputs, compiler identity, bounds and hashes.

## Controller sampling

[Input sampling](early-input-sequences.md#input-sampling) updates the session's
current and newly pressed masks, merges the alternate controller when the
observed menu-state checks permit it, and calls the recovered sequence
recognizer. A retained pointer to the same input prefix gives IDO the expected
register allocation without adding instructions.

## Relative fields

`func_8000CD50` captures the source word at offset `0x4C` and multiplies it by
sixteen for the existing scaled sine/cosine helpers. It computes both helpers
for each supplied scale. Destination offset `0x54` receives the second cosine
minus the first sine plus the source word at that offset. Offset `0x5C`
receives the second sine plus the first cosine plus the corresponding source
word. Mode one also copies the captured `0x4C` word; every mode except two
updates `0x58` from the source plus the vertical offset. Other fields remain
untouched. The offsets are confirmed; their broader role is not yet named.

All 228 bytes match. The order of the six scalar declarations preserves the
original 56-byte frame and saved-angle slot. No synthetic padding is added.

## Actor contact

The [contact gate](actor-contact-gate.md) orders two actor/position pairs,
filters the observed resource kinds, marks kind-five actors, checks vertical
separation and the two `0x28` fields, then invokes `func_80018E1C`. All 632
bytes now match, including the three previously differing branch words.

## Immediate sound requests

`func_8003614C` rejects signed sound indices outside `0..116`, prints the
retail warning, and returns zero. A valid index selects a twenty-byte
`SoundDefinition`. Its nonzero platform flag invokes the retained N64 stub
`func_8003BF9C(sound)`. Mode zero calls `func_800515B0(sound, value)`; other
modes call the retained `func_8003BF94` interface with sound, mode and value.
These latter arguments remain in `a1/a2` in the target. The fourth request
argument is homed and unused. Valid requests return one.

The optional stub call must retain mode and value for subsequent dispatch.
Declaring the other stub call with those observed arguments lets IDO preserve
the target's argument lifetimes and spill only around the optional call.
Every instruction now matches. The two N64 stub bodies are empty; the source
preserves the calls and their calling interfaces. The warning at
`0x800942C0..0x800942E0` includes the NUL and compiler alignment bytes.

The selected Robotron ROM supplies all behavior and comparison bytes. The
thirteen requested N64 reference projects and the local search tools are
credited in [CREDITS.md](../CREDITS.md). This work relates to controller issue
[#39](https://github.com/frankischilling/robotron64/issues/39), early actors
[#43](https://github.com/frankischilling/robotron64/issues/43), actor behavior
[#40](https://github.com/frankischilling/robotron64/issues/40), and game audio
[#34](https://github.com/frankischilling/robotron64/issues/34).
