# Recovery checkpoint

The source checkpoint contains 1,107 matching C functions covering 157,808 bytes.
It also contains eight assembly functions covering 388 live bytes, 2,689 bytes
of source-owned initialized data, and 4,199 bytes of source-owned BSS. The
previously published checkpoint `9efb6ef` contained 927 C functions covering
121,048 bytes and one 56-byte assembly procedure. The current source adds
180 complete C functions, 36,760 C bytes, seven assembly procedures with
332 live bytes, 1,041 reconstructed initialized bytes, and 109 BSS bytes.
Another 296 initialized bytes belong to the existing text implementation's
generated table, whose ownership is now explicitly checked and counted.

The complete ROM still uses extracted fallback ranges. The game is not fully
decompiled, and neither the total executable size nor the complete function
denominator is established. ROM equality does not measure source completion.

## Recovered behavior

The audio work covers instance pause/resume and owner controls, handle and voice
properties, host file services, sequence calls/jumps/returns, voice capture,
hardware-voice allocation and release, pitch scaling, and sequence-table and
range loading. The compression work covers memory and cartridge input, the
refill buffer, aligned workspace allocation, block dispatch, fixed-block decoding, table cleanup,
and the original initialized tables and shared buffers. Individual functions
and complete byte ranges are documented in [audio properties](audio-properties.md),
[audio command controls](audio-command-engine.md), [hardware voices](audio-hardware-driver.md),
[sequence loading](audio-sequence-loading.md), and [compression runtime](compression-runtime.md).

The recent additions recover bank relocation, volume changes, pan updates,
pedal release, and the extra kinemation-definition command. Seven further
functions recover sequence-list sizing, loading and release, hardware-voice
initialization, gate and iteration resets, and the iteration setter. The gate
and iteration branch commands add another 460 code bytes and 24 BSS bytes.
These nine audio units pass complete independent comparisons. Validation runs
114 tooling tests and compares all 8,388,608 ROM bytes. Linked progress checks
the source inputs and complete procedure extents for all 1,107 counted C
functions. [Bank layout](audio-bank-layout.md),
[driver commands](audio-driver-commands.md), and [session setup](session-setup.md)
record the behavior, private storage, and retained candidate identities.

The game work extends actor animation and movement callbacks, early actor
creation and state changes, selection and value tables, Controller Pak menu
flows, and script animation resolution. Graphics work includes framebuffer
drawing and state helpers. See [actor motion](actor-motion.md),
[early game state](early-game-state.md), [transition and value lookup](early-game-medium.md),
[menu navigation](save-menu-navigation.md), [script services](script-services.md),
[model geometry](model-geometry.md), and [graphics runtime state](graphics-runtime-state.md).

Six additional early-game functions cover resource-state transitions, actor
updates, vector clearing, global reset, and guarded actor service. The resource
layout checks its complete 0x68-byte size and uses an integer declaration for
the backing tuning value. Complete comparisons passed for all 23 source units
affected by those additions and their shared resource header.

Further early-game parser, name-mask, and actor-pair balancing routines are
included in this checkpoint. The SDK recovery adds 50 complete C functions
and 5,096 code bytes in 35 independently compared units. It covers thread
creation and startup, blocking messages, event routing, video context updates,
PI/SI/SP transfers, task yielding, aligned audio allocation, integer arithmetic,
and the random-number generator. The generator owns its four-byte initialized
seed. [SDK runtime](sdk-runtime.md) records the behavior, actual layouts,
compiler profiles, and complete code/data proof identities.

Twenty-five further SDK functions recover the relative-deadline timer queue,
Count-based timekeeping, thread-priority changes, front-of-queue messages,
active video-context access, audio list and lifecycle operations, DMA buffer
submission, and matrix translation, identity, and signed fixed-point
conversion. They add 3,376 code bytes, five initialized bytes, and eight BSS
bytes. [Time and priority](sdk-time-and-priority.md),
[scheduling and audio services](sdk-scheduling-and-audio-services.md), and
[matrix conversion](sdk-matrix-conversion.md) record their complete placements
and behavior. The 496-byte fixed-block decoder is an additional game-code
procedure and uses the previously recovered compression workspace.

The SDK audio graph now reconstructs voice allocation and parameter commands,
synthesizer initialization and sample scheduling, filter construction, bus
mixing, resampling, stereo output, and PCM/ADPCM decoding. The complete
envelope and reverb additions alone account for 18 functions, 7,700 live code
bytes and 888 initialized bytes. They include the equal-power and logarithm
tables, six effect presets, floating constants and dispatch tables.
[Voice commands](sdk-voice-commands.md),
[synthesizer runtime](sdk-synthesizer-runtime.md),
[filter construction](sdk-audio-filter-construction.md),
[output](sdk-audio-output.md), [wavetable decoding](sdk-audio-decoder.md),
[envelopes](sdk-audio-envelope.md),
[effect construction](sdk-audio-effect-construction.md), and
[reverb](sdk-audio-reverb.md) describe the complete source and section proofs.

Six further game procedures recover actor callback installation, renderer
glyph mapping, active audio-instance counts and unique sequence/owner lists.
Their 1,472 code bytes are documented in
[game queries and glyph services](game-query-and-glyph-services.md).
The object-property setter's shared return declaration now agrees with its
existing definition. The current comparisons cover every registered caller.

The eight assembly procedures comprise the startup entry, two audio interrupt
services, interrupt disable/restore, TLB probing, Count reading, and Compare
writing. Their complete extents are accounted separately from C source.

Shared game-side audio declarations describe the recovered records and
backend command interfaces. Early animation wrappers use the canonical actor
declaration. The comparison tools reject absolute fallback bindings for
source-owned functions, including bindings that happen to have the right
address. This prevents a stale linker assignment from hiding a source
definition after separate recovery batches are integrated.

## Reproduction and evidence

Supply the normalized USA ROM locally, then run:

```sh
make setup
make -j2
make test
make verify
make progress
python3 tools/compare_runtime.py --jobs 4
python3 tools/compare_startup.py
python3 tools/compare_assembly.py
```

The ROM comparison covers all 8,388,608 bytes. The target SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The runtime registry contains 626 complete source units. Startup/scheduler
comparison covers its two registered units; assembly comparison covers the
eight procedures and their source-owned alignment. Linked progress independently checks every counted
function, its procedure extent, section address, source/header/object hashes,
and generated data or private storage.

The tooling suite contains 114 tests. It can run without a commercial ROM or
the IDO compiler installation. `tools/audit_publication.py --files <inventory>`
checks an explicit JSON array of public file paths against the current build,
comparison reports, owned sections, and progress. It rejects stale source or
header evidence and does not count a partial or shifted function comparison.
Every counted C source must belong to a complete independent comparison;
successful linkage cannot substitute for a missing comparison. The runtime
tool can compile independent units concurrently while preserving registered
report order, distinct output directories and all input-integrity checks.

The source-specific JSON ledgers retain historical source and proof identities;
they are not substitutes for rebuilding the current checkout. Full local
reports and the ROM remain outside Git. All thirteen requested N64 reference
projects are recorded in [CREDITS.md](../CREDITS.md), and the Perfect Dark MIT
notice used for compression comparisons is retained in
[the license notice](licenses/perfect-dark.txt).

## Remaining work

Four central compression procedures still have compiler differences. The
full audio sequence reader, several sequencer
commands, and the main audio dispatcher also remain fallback code. Larger
early-game and actor routines, movie update, renderer polygon and mesh paths,
frame setup, text replacement, and further platform functions are unfinished.
Their complete candidate comparisons and source investigations remain available
locally, but their bytes are excluded from this checkpoint's source counts.

The retained combined graphics setup/pacing experiment reproduces 628 code
bytes and its 124-byte dispatch table. Its sparse empty case labels remain
unexplained by the target's callers, so that pacing candidate is excluded from
this checkpoint. The existing 152-byte setup source remains counted; no
synthetic prefix or partial pacing extent is substituted for recovered source.

Reference-adapted SDK experiments remain separate local research. The
target-derived SDK runtime described above is part of this checkpoint; the
remaining SDK routines still require recovery. No commercial ROM, extracted
asset, object file, compiler executable, or generated disassembly is part of
the public source checkpoint.
