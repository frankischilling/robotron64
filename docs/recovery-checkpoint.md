# Recovery checkpoint

The source checkpoint contains 1,288 matching C functions covering 210,996 bytes.
It also contains twenty-nine assembly functions covering 4,372 live bytes, 9,359 bytes
of source-owned initialized data, and 21,629 bytes of source-owned BSS. The
previously published checkpoint `9efb6ef` contained 927 C functions covering
121,048 bytes and one 56-byte assembly procedure. The current source adds
361 complete C functions, 89,948 C bytes, twenty-eight assembly procedures with
4,316 live bytes, 7,711 reconstructed initialized bytes, and 17,539 BSS bytes.
Another 296 initialized bytes belong to the existing text implementation's
generated table, whose ownership is now explicitly checked and counted.

The complete ROM still uses extracted fallback ranges. The game is not fully
decompiled, and neither the total executable size nor the complete function
denominator is established. ROM equality does not measure source completion.

## Recovered behavior

The [Controller Pak notice](renderer-controller-pak-notice.md) adds one complete
C procedure with 284 instruction bytes and its 20-byte string block. Its
unsigned display window, doubled coordinate expression, per-character
spacing, skipped spaces, and final render-state call match the target.

[Scheduled groups and attached actors](early-parameter-slot-tick.md) add two
complete C procedures with 500 instruction bytes. The slot tick preserves
timer subtraction for exhausted slots and emits at most one group per call.
The parent follower preserves release and scale-decay transitions, rotates
the saved offset, submits the child's position and angle, and clears its
movement fields.

[Runtime tables and game services](game-runtime-tables.md) add eight complete
C procedures with 1,372 instruction bytes and 488 BSS bytes. Number drawing,
menu labels, actor pair insertion, random endpoint selection, input setup,
random actor creation and the value transition match complete target extents.
Four initialization spans establish the corrected session counter bounds and
its 328-byte storage definition.

[Menu transition and texture file cache](menu-transition-and-texture-cache.md)
add two complete C procedures with 292 instruction bytes, eight initialized
bytes and 2,152 BSS bytes. The menu state includes its typed callback and
cleanup flags; the texture cache uses the confirmed 32-by-32 RGBA16 layout.

[Game collision and selection services](game-collision-and-selection.md) add five
complete C procedures with 688 instruction bytes and 78 initialized bytes.
Render handler selection, collision dispatch, name lookup, session advance and
resource selection clearing include both complete relocated switch tables and
the original lookup diagnostic.

[Actor animation state and expiration](actor-animation-state.md) add five complete
C procedures with 852 instruction bytes. They recover both repeat handlers,
scene counter expiration, auxiliary animation setup and child creation with
callback replacement. Shared actor views expose the confirmed byte at `0x22`
without changing their size or other field offsets.

[Early session animation and actor counters](early-session-animation.md) add six
complete C procedures with 736 instruction bytes and twelve initialized bytes.
Callback replacement, session record indexing, actor counter decrement and the
original reset aggregate copy retain their shipped behavior. The canonical session
view now includes the independently confirmed 36-entry counter array.

The [PI manager, device loop, and disk interrupts](sdk-pi-manager.md) add three complete C
procedures with 3,260 instruction bytes, 68 initialized bytes, and 4,556 BSS
bytes. Complete transfer records and the seven-entry switch table are checked
alongside creation and DMA/disk completion paths.

[SDK initialization, Pak ID repair, and exception context](sdk-initialization-and-exceptions.md)
add two C procedures with 1,256 bytes, four native entries with 1,580 live
bytes, twenty initialized bytes, and four BSS bytes. The exception preamble,
main handler, event helper and coprocessor handler have distinct verified
extents within the complete contiguous exception/thread unit.

[Interrupt tables and kernel state](sdk-interrupt-storage.md) add four data-only
units with 240 initialized bytes and 4,528 BSS bytes. The complete CPU/RCP
tables, sentinel and queue pointers, callback array, scratch thread and disk
stack are verified without increasing function or instruction counts.

The audio work covers instance pause/resume and owner controls, handle and voice
properties, host file services, sequence calls/jumps/returns, voice capture,
hardware-voice allocation and release, pitch scaling, and sequence-table and
range loading. The compression work covers memory and cartridge input, the
refill buffer, aligned workspace allocation, block dispatch, fixed and stored-block decoding, table cleanup,
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
137 tooling tests and compares all 8,388,608 ROM bytes. Linked progress checks
the source inputs and complete procedure extents for all 1,230 counted C
functions. [Bank layout](audio-bank-layout.md),
[driver commands](audio-driver-commands.md), and [session setup](session-setup.md)
record the behavior, private storage, and retained candidate identities.

The [runtime helpers and hardware interfaces](runtime-helpers-and-hardware.md)
add complete pool, coordinate, selection, counter, scene mapping, rendering,
frame-slot, and audio query procedures. SDK recovery includes vertical video
scaling, interrupt mask updates, extended cartridge word access, queue lookup,
and thread yielding. Native assembly covers hardware register access, cache
invalidation, debugger mapping, square root, thread queue operations, dispatch,
and the thread cleanup trampoline. Together with stored-block decoding, this
batch contributes 23 C procedures with 2,040 bytes and ten assembly procedures
with 656 live bytes. No newly recovered initialized data or BSS is counted.

Ten further [transfer, thread, and short-math procedures](sdk-transfer-and-short-math.md)
add 1,524 C bytes. These include PI DMA submission and event notification, thread destruction, AI
frequency setup, signed short sine/cosine, player clearing, scene reactivation,
and renderer buffer services. Their complete compiler profiles and structure
layouts are independently verified. The [quarter-wave sine table](sdk-short-sine-table.md)
is now reconstructed mathematically, adding 2,048 initialized bytes without
increasing the function or BSS counts.

The [cache, cartridge, and float-math batch](sdk-cache-and-transfer.md) adds
five C functions with 1,588 bytes and five native assembly functions with
720 live bytes. It recovers extended PI DMA, float sine/cosine, renderer
reservation, sequence binding, cache operations, block clearing, and CPU/RCP
interrupt-mask application. Constants and handle storage remain fallback.

Four [task-loading and actor forwarding procedures](sdk-task-loading-and-yield.md)
add another 1,036 C bytes. RSP task preparation/loading and disk recovery now
use recovered source. Native context saving and overlap-safe block copying
add 1,028 live assembly bytes. Subsequent exception recovery establishes
separate complete extents for the event helper and coprocessor handler.

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

The controller and Controller Pak batch adds 44 procedures and 19,744 live C
bytes in 18 complete units. It covers polling, filesystem identification and
repair, allocation, reading, writing, deletion, file-state queries, motor
commands and CRC calculation. The sources own the four-byte initialization
guard and 784 bytes of persistent packet and timer storage. The reconstruction
preserves the target's unfilled local ID buffer and overwritten error results;
[controller and Pak storage](sdk-controller-pak-reconstruction.md) records the
instruction evidence, complete section placements and retained input identities.

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
make compare-data
```

The ROM comparison covers all 8,388,608 bytes. The target SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The runtime registry contains 776 complete source units. Startup/scheduler
comparison covers its two registered units; assembly comparison covers the
twenty-nine procedures and their source-owned alignment. Linked progress independently checks every counted
function, its procedure extent, section address, source/header/object hashes,
and generated data or private storage.

The tooling suite contains 137 tests. It can run without a commercial ROM or
the IDO compiler installation. `tools/audit_publication.py --files <inventory>`
checks an explicit JSON array of public file paths against the current build,
comparison reports, owned sections, and progress. It rejects stale source or
header evidence and does not count a partial or shifted function comparison.
Every counted C source must belong to a complete independent comparison;
data-only units require complete independent data proofs.
Successful linkage cannot substitute for a missing comparison. The runtime
tool can compile independent units concurrently while preserving registered
report order, distinct output directories and all input-integrity checks.

The source-specific JSON ledgers retain historical source and proof identities;
they are not substitutes for rebuilding the current checkout. Full local
reports and the ROM remain outside Git. All thirteen requested N64 reference
projects are recorded in [CREDITS.md](../CREDITS.md), and the Perfect Dark MIT
notice used for compression comparisons is retained in
[the license notice](licenses/perfect-dark.txt).

The [float constant recovery](sdk-float-math-constants.md) owns both complete
68-byte sine/cosine coefficient blocks. The
[video and device initialization](sdk-video-and-device-initialization.md)
recovery adds five complete SDK procedures, both video contexts, the video
manager and thread storage, and the cartridge/disk handles. These four new
runtime units retain their complete instruction and storage comparisons.

The [video timing and context swap recovery](sdk-video-modes-and-swap.md)
adds the complete 860-byte video register procedure and reconstructs all 42
SDK table modes and three defaults from confirmed timing parameters. Two
independent data comparisons verify their 3,600 bytes without increasing the
procedure count. Full startup and runtime comparisons validate the completed
`VideoMode` layout and preserve startup's first-field origin writes.

## Remaining work

Three central compression procedures still have compiler differences. The
full audio sequence reader, several sequencer
commands, and the main audio dispatcher also remain fallback code. Larger
early-game and actor routines, movie update, renderer polygon and mesh paths,
frame setup, text replacement, and further platform functions are unfinished.
Their complete candidate comparisons and source investigations remain available
locally, but their bytes are excluded from this checkpoint's source counts.

The combined graphics setup/pacing source now reproduces all 628 code
bytes and its 124-byte dispatch table and is included in this checkpoint.
The precise original selection of empty case labels is not uniquely recoverable
from the shared table destinations; the source retains equivalent empty cases
and the target's full dispatch bounds. [Actor following and graphics pacing](actor-follow-and-graphics-pacing.md)
also add both complete follower routines, for 944 new instruction bytes in total.

Reference-adapted SDK experiments remain separate local research. The
target-derived SDK runtime described above is part of this checkpoint; the
remaining SDK routines still require recovery. No commercial ROM, extracted
asset, object file, compiler executable, or generated disassembly is part of
the public source checkpoint.
