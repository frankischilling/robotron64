# Recovery checkpoint

The source checkpoint contains 1,010 matching C functions covering 132,064 bytes.
It also contains eight assembly functions covering 388 live bytes, 1,356 bytes
of source-owned initialized data, and 4,187 bytes of source-owned BSS. The
previously published checkpoint `9efb6ef` contained 927 C functions covering
121,048 bytes. The current source adds 83 complete C functions, 11,016 C bytes,
four initialized bytes, and 97 BSS bytes to that checkpoint.

The complete ROM still uses extracted fallback ranges. The game is not fully
decompiled, and neither the total executable size nor the complete function
denominator is established. ROM equality does not measure source completion.

## Recovered behavior

The audio work covers instance pause/resume and owner controls, handle and voice
properties, host file services, sequence calls/jumps/returns, voice capture,
hardware-voice allocation and release, pitch scaling, and sequence-table and
range loading. The compression work covers memory and cartridge input, the
refill buffer, aligned workspace allocation, block dispatch, table cleanup,
and the original initialized tables and shared buffers. Individual functions
and complete byte ranges are documented in [audio properties](audio-properties.md),
[audio command controls](audio-command-engine.md), [hardware voices](audio-hardware-driver.md),
[sequence loading](audio-sequence-loading.md), and [compression runtime](compression-runtime.md).

The recent additions recover bank relocation, volume changes, pan updates,
pedal release, and the extra kinemation-definition command. Seven further
functions recover sequence-list sizing, loading and release, hardware-voice
initialization, gate and iteration resets, and the iteration setter. The gate
and iteration branch commands add another 460 code bytes and 24 BSS bytes.
These nine audio units pass complete independent comparisons. The full build
passes all 108 tooling tests and verifies all 8,388,608 ROM bytes. Linked
progress verifies the source inputs and complete procedure extents for all
1,010 counted C functions. [Bank layout](audio-bank-layout.md),
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

The eight assembly procedures comprise the startup entry, two audio interrupt
services, interrupt disable/restore, TLB probing, Count reading, and Compare
writing. Their complete extents are accounted separately from C source.

Shared audio declarations now describe one consistent set of records and
backend command interfaces. Early animation wrappers use the canonical actor
declaration. The comparison tools reject absolute fallback bindings for
source-owned functions, including bindings that happen to have the right
address. This prevents a stale linker assignment from hiding a source
definition after separate recovery batches are integrated.

## Reproduction and evidence

Supply the normalized USA ROM locally, then run:

```sh
make setup
make -j4
make test
make verify
make progress
python3 tools/compare_runtime.py
python3 tools/compare_startup.py
python3 tools/compare_assembly.py
```

The ROM comparison covers all 8,388,608 bytes. The target SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The runtime registry contains 562 complete source units. Startup/scheduler
comparison covers its two registered units; assembly comparison covers the
eight procedures and their source-owned alignment. Linked progress independently checks every counted
function, its procedure extent, section address, source/header/object hashes,
and generated data or private storage.

The tooling suite contains 108 tests. It can run without a commercial ROM or
the IDO compiler installation. `tools/audit_publication.py --files <inventory>`
checks an explicit JSON array of public file paths against the current build,
comparison reports, owned sections, and progress. It rejects stale source or
header evidence and does not count a partial or shifted function comparison.

The source-specific JSON ledgers retain historical source and proof identities;
they are not substitutes for rebuilding the current checkout. Full local
reports and the ROM remain outside Git. All thirteen requested N64 reference
projects are recorded in [CREDITS.md](../CREDITS.md), and the Perfect Dark MIT
notice used for compression comparisons is retained in
[the license notice](licenses/perfect-dark.txt).

## Remaining work

The five central compression procedures still have compiler differences. The
full audio sequence reader, several sequencer
commands, and the main audio dispatcher also remain fallback code. Larger
early-game and actor routines, movie update, renderer polygon and mesh paths,
frame setup, text replacement, and further platform functions are unfinished.
Their complete candidate comparisons and source investigations remain available
locally, but their bytes are excluded from this checkpoint's source counts.

Reference-adapted SDK experiments remain separate local research. The
target-derived SDK runtime described above is part of this checkpoint; the
remaining SDK routines still require recovery. No commercial ROM, extracted
asset, object file, compiler executable, or generated disassembly is part of
the public source checkpoint.
