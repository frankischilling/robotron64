# Recovery checkpoint

The source checkpoint contains 934 matching C functions covering 123,276 bytes.
It also contains the 56-byte assembly entry, 1,352 bytes of source-owned
initialized data, and 4,135 bytes of source-owned BSS. The published checkpoint
`9efb6ef` contained 927 C functions covering 121,048 bytes. The current source
adds seven complete functions, 2,228 C bytes, and 45 BSS bytes to that checkpoint.
The preceding recovery from `84e19bf595301bbcc6f4cef99d3267f8ae510afd` contributed
274 complete functions, 35,020 C bytes, 376 initialized bytes, and 4,090 BSS bytes.

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

The latest additions recover bank relocation, volume changes, pan updates,
pedal release, and the extra kinemation-definition command. The four complete
source units pass their independent current-input comparisons. The full build
passes all 108 tooling tests and verifies all 8,388,608 ROM bytes. Linked
progress verifies the source inputs and complete procedure extents for all
934 counted C functions. [Bank layout](audio-bank-layout.md),
[driver commands](audio-driver-commands.md), and [session setup](session-setup.md)
record the behavior, private storage, and retained candidate identities.

The game work extends actor animation and movement callbacks, early actor
creation and state changes, selection and value tables, Controller Pak menu
flows, and script animation resolution. Graphics work includes framebuffer
drawing and state helpers. See [actor motion](actor-motion.md),
[early game state](early-game-state.md), [transition and value lookup](early-game-medium.md),
[menu navigation](save-menu-navigation.md), [script services](script-services.md),
[model geometry](model-geometry.md), and [graphics runtime state](graphics-runtime-state.md).

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
The runtime registry contains 502 complete source units. Startup/scheduler
comparison covers its two registered units; assembly comparison covers the
entry and its alignment. Linked progress independently checks every counted
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
full audio sequence reader, list-based loading helpers, several sequencer
commands, and the main audio dispatcher also remain fallback code. Larger
early-game and actor routines, movie update, renderer polygon and mesh paths,
frame setup, text replacement, and further platform functions are unfinished.
Their complete candidate comparisons and source investigations remain available
locally, but their bytes are excluded from this checkpoint's source counts.

SDK implementations researched from references remain a separate scope when
their redistribution basis has not been established. No commercial ROM,
extracted asset, object file, compiler executable, or generated disassembly is
part of the public source checkpoint.
