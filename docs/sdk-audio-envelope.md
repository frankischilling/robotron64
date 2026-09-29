# Audio envelope updates and command generation

`src/sdk/audio_envelope.c` reconstructs the complete envelope translation unit.
Seven procedures occupy `0x8006CDC0..0x8006DA14`, ROM
`0x6D9C0..0x6E614`, totaling 3,156 live code bytes. The three private helpers
retain their internal linkage and are compiled with their callers.

| Procedure | Target range | Object offset | Live bytes |
| --- | --- | ---: | ---: |
| `func_8006CDC0` | `0x8006CDC0..0x8006CDE8` | `0x000` | 40 |
| `func_8006CDE8` | `0x8006CDE8..0x8006CED4` | `0x028` | 236 |
| `func_8006CED4` | `0x8006CED4..0x8006CFB4` | `0x114` | 224 |
| `getRate` | `0x8006CFB4..0x8006D184` | `0x1F4` | 464 |
| `pullSubFrame` | `0x8006D184..0x8006D41C` | `0x3C4` | 664 |
| `getVolume` | `0x8006D41C..0x8006D4CC` | `0x65C` | 176 |
| `func_8006D4CC` | `0x8006D4CC..0x8006DA14` | `0x70C` | 1,352 |

## Control queue and subframes

The pull callback consumes parameter updates in sample-offset order. It stops
at an update beyond the requested output span, renders the intervening samples
before changes to volume, pan, effects, or playback state, and returns each
consumed update to the synthesizer's free list. A start-with-parameters update
installs the wavetable, unity-pitch flag and pitch, squares the requested
volume, and selects dry and wet amounts from the equal-power table.

The parameter callback appends updates, resets or starts playback, installs an
upstream filter, and forwards remaining parameters. The simple start record
has a separately checked 16-byte layout. It shares the existing parameter-list
header and wavetable declarations with the synthesizer and voice commands.

`pullSubFrame` asks the upstream filter to produce samples, then emits the
main and auxiliary buffer settings. On the first subframe after a change, it
computes left and right targets and rates, emits their initial volume and
rate commands, and initializes the RSP envelope state. Later subframes emit
the continuation command. The helper advances both the input address and the
envelope's sample delta. Zero-length requests and stopped voices emit nothing.

## Rate calculation and preserved arithmetic

`getRate` approximates the per-sample exponential transition from the current
volume to the target. It uses an eight-entry logarithm table, the exponent
helpers, and repeated squaring. A zero-length transition returns either the
maximum increasing rate or zero; other inputs are bounded at the target's
original minimum volume. `getVolume` estimates the accumulated volume in
groups of eight samples from the split integer and fractional rate.

The final three squarings retain the historical expression
`multiplier *= (multiplier *= (multiplier *= multiplier))`. This expression
has compiler-dependent evaluation behavior and is preserved for this matching
target. The pinned libreultra `src/audio/env.c` corroborates that source form.
Its placement in the reconstructed function lets IDO reproduce both the
operations and the original local stack slots. The source does not add an
unused variable or padding to obtain those offsets.

## Initialized storage

The complete `.data` section contains 320 bytes at `0x8008F3F0`, ROM
`0x8FFF0`. Its first 256 bytes are `equalPower[128]`, a source-static array of
signed shorts. The remaining 64 bytes are the initialized eight-double local
logarithm table, which IDO places in the same section. Paired ECOFF records
verify `equalPower` at offset zero; all 320 emitted bytes are compared.

The complete `.rodata` section contains 96 bytes at `0x80095F40`, ROM
`0x96B40`. Its floating-point constants and update-dispatch table are also
compared after relocation. The unit emits no BSS. These 416 initialized bytes
are accounted separately from the procedure bytes.

## Evidence and reproduction

Robotron's verified instruction stream determines the procedure boundaries,
callback arguments, updates, arithmetic and command packets. The pinned
libreultra `src/audio/env.c` was consulted for the SDK interface and the
historical rate expression; its revision and use are recorded in
[CREDITS.md](../CREDITS.md). The earlier reference-adapted experiment remains
described in the historical [filter study](sdk-audio-filters.md).

The retained `envelope-target-v6-assignment` comparison uses IDO 5.3 with
`sdk-o3-mips2-r4300-mul`. It matches all 3,156 procedure bytes with zero
differing words, verifies every public and private procedure extent, and
checks both allocated data sections against the target. Source, header,
compiler and comparison input hashes accompany that report. The production
registry independently compiles the complete unit with its registered
profile, symbols and ownership declarations. The twelve natural trailing
alignment bytes are checked before trimming and excluded from C progress.
The [provenance record](sdk-audio-envelope-provenance.json) retains the accepted
source and header hashes, procedure extents, section placements, and candidate
and canonical report identities without distributing the private build output.
