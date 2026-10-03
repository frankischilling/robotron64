# Credits and references

The [tweak insertion and storage recovery](docs/tweak-storage-and-ghidra.md)
uses the local Super Mario 64 build and pinned IDO references for compilation
and matching. [Ghidra](https://github.com/NationalSecurityAgency/ghidra) and the
local [Ghidra MCP extension](https://github.com/bethington/ghidra-mcp) provide
typed decompilation, disassembly, memory checks, and cross-reference analysis.
Robotron's target and verified consumers
determine the recovered command behavior, table layouts, and diagnostic text.

The [procedural grid and renderer setup recovery](docs/renderer-grid-and-setup.md)
uses the pinned local libreultra `2.0I/PR/gbi.h` for viewport and light layouts,
display-list termination, vertex loads, and other-mode bit fields. SM64 and
Zelda GBI headers provide supporting SDK references. Robotron's target determines
the complete command arrays, record values, grid arithmetic, and call order.
No reference game implementation was copied into the recovery.

The [early rendering and command-file recovery](docs/early-render-command-streams.md)
uses the local libreultra `2.0I/PR/gbi.h` for vertex-load and two-triangle
packet formats. Private decomp-permuter experiments helped identify IDO's
different scheduling for direct arena indexing and cached vertex pointers.
Robotron's complete instruction ranges and storage references determine
the accepted source. The [tube and star rendering reconstruction](docs/early-render-effects.md)
uses the same local GBI header for geometry-mode bits and packed triangle
indices. Its shared palette and complete procedure behavior come from the
Robotron target. No reference game or SDK implementation was copied.

The [fan, prism, and image setup recovery](docs/render-submission-effects.md)
uses those established GBI definitions for vertex loads, quad connectivity,
texture fields, and command packing. Local IDO compiler comparisons distinguish
exact storage ownership from the remaining procedure mismatches. All geometry,
colors, coordinate conversion, and initial values come from Robotron's target.

The [decimal parser and controller-state recovery](docs/float-parser-controller-state.md)
uses the pinned IDO and SM64 build references for compiler behavior and the
local libreultra controller header for pad layout. Robotron's instructions
establish the decimal arithmetic, access widths, and storage offsets.
No reference implementation was copied into these routines or definitions.

The [camera and input recovery](docs/camera-angles.md) uses the pinned local
Super Mario 64 camera source for angle conventions and libreultra controller
headers for pad fields and button bits. Robotron's complete instruction spans
determine the exact angle constant, mask, input mapping, and legacy call.
No reference implementation was copied into these game routines.

This project benefits from the work of the N64 decompilation community and
the maintainers and contributors of the projects below. Their public sources
and local checkouts provide references for N64 programming, SDK algorithms,
compiler behavior, data layouts, extraction, linking, and matching workflows.
Robotron's selected ROM is the final check for its own instructions, data,
calling conventions, and revision-specific behavior.

## Reference collection

These are the reference projects requested for this recovery. Revisions are
the local checkout commits recorded during the work; they do not assert that
every file in every project has been studied.

| Project | Recorded revision | Reference area |
| --- | --- | --- |
| [libreultra](https://github.com/n64decomp/libreultra) | `1aca5c13ca041cef86f8dc194b727361dad9c09b` | SDK audio, controller/Pak services, layouts and historical variants |
| [sdk-tools](https://github.com/n64decomp/sdk-tools) | `72bf503d2b00d322cb04d58ecdac70af93189bca` | SDK tools and their historical formats |
| [IDO](https://github.com/n64decomp/ido) | `d068e439f52615763a3facd6944873899ebad2fd` | Original compiler materials and conventions |
| [Super Mario 64](https://github.com/n64decomp/sm64) | `9921382a68bb0c865e5e45eb594d9c64db59b1af` | Matching build, linker placement, extraction, compiler-object handling, GBI command packing and vertex/light layouts |
| [Mario Kart 64](https://github.com/n64decomp/mk64) | `58cfcb022e10f83bc3b889d7e97508cae6837098` | SDK identification, including the older Pak page-clearing allocator |
| [Ocarina of Time](https://github.com/zeldaret/oot) | `1bef952ff61a6dd1945c7887c1babd94efe95f72` | Compiler signatures, SDK routines, ECOFF metadata and build tooling |
| [Majora's Mask](https://github.com/zeldaret/mm) | `56fa21dd0031a17cfc9e355f609542617598a265` | Segment layout, SDK variants and source-progress conventions |
| [Paper Mario](https://github.com/pmret/papermario) | `1104f1f71b824042a5fa1f958f2d861b603320fd` | Additional game and matching-build reference |
| [Mario Party](https://github.com/mariopartyrd/marioparty) | `26dca4f3cf2dab1839bc1de3579b7227b65b9ee6` | Additional game and SDK integration reference |
| [Pokémon Stadium](https://github.com/pret/pokestadium) | `0b614c210004d9b586897f11a7f820850e97f3d6` | Additional game and data-layout reference |
| [GoldenEye 007](https://github.com/n64decomp/007) | `c4356466796c697dfd298010b9bed261f9ed8c6a` | Older SDK motor command and response behavior |
| [Perfect Dark](https://github.com/n64decomp/perfect_dark) | `169ed48bdcbfb3b568b028bd5bebb27680073514` | Extraction structure, per-object compiler profiles, and controller initialization and query flow |
| [Banjo-Kazooie](https://github.com/n64decomp/banjo-kazooie) | `9db90a003fff15d13d29505d571aff2543b50383` | Additional game, SDK and matching workflow reference |

The GoldenEye GitHub repository identifies itself as a mirror of the
[GoldenEye source project](https://gitlab.com/kholdfuzion/goldeneye_src).

## Tools and additional references used

[decompals/ido-static-recomp](https://github.com/decompals/ido-static-recomp)
provides the executable IDO static recompilations used by this build. The
project pins release v1.2 archives and verifies the installed components.
This executable toolchain is distinct from the IDO archive in the reference
collection.

[decompals/ultralib](https://github.com/decompals/ultralib), inspected at
`e24c836796df4bf520ff8b11a5c9d2cea3a66cbd`, supplied additional SDK comparisons
and ECOFF format references. ZeldaRET's CC0 `tools/ido_block_numbers.py` and
ultralib's `tools/mdebug.py` helped establish the static-procedure metadata
format used by Robotron's independent verifier.

[m2c](https://github.com/matt-kempster/m2c) supplies private decompiler seeds.
[decomp-permuter](https://github.com/simonlindholm/decomp-permuter), inspected at
`059609d4aec73eb0650726772954e1ad575825f8`, supports local searches over C
declarations and expressions for remaining compiler-layout differences.
Search results undergo source review and the project's independent full-code
and generated-data comparisons before acceptance. Its local search tools are
not distributed with the public source checkpoint.
[spimdisasm](https://github.com/Decompollaborate/spimdisasm) and
[Rabbitizer](https://github.com/Decompollaborate/rabbitizer) support the local
instruction and provisional-function inventory. GNU Binutils provides the
MIPS assembler, linker and object inspection tools. Python and GNU Make run
the extraction, validation and build workflow.

## Attribution in recovery notes

The [scene frame timing update](docs/scene-frame-tick.md) retains the
pinned IDO and N64 matching-workflow references. Robotron's timing helper,
callers, instructions, and double constant establish its arithmetic and
platform return interface. No reference implementation is copied. The
requested repositories remain credited for local and online use.

The [actor pickup recovery](docs/actor-pickups.md) retains the same
pinned IDO and N64 matching-workflow references. Robotron's dispatch
table, instructions, matching setup routine, and bonus helper establish
the behavior and shared player view. No reference implementation is
copied; all thirteen requested repositories remain credited below.

The [early actor pair helper](docs/early-actor-pair-spawn.md) uses the
same pinned IDO and N64 matching-workflow references. Robotron's
instructions and existing matching actor helpers establish placement,
callback arguments, and the retained unwritten position coordinate.
No reference implementation is copied.

The [actor pool allocation](docs/actor-pool-allocation.md) uses the same
pinned IDO and N64 matching-workflow references. Robotron's complete
instructions, matching pool reset, object creation, resource loader, and
124-byte actor layout establish the allocator and its 200-entry BSS pool.

The [renderer projection and highlights](docs/renderer-projection-highlight.md)
use the same pinned IDO and N64 matching-workflow references. The credited
local libreultra `gu/lookathil.c` and SDK type definitions supply the matrix,
look-at, highlight, and argument-layout references. Robotron's complete
instructions and matching SDK callees establish the values and commands.

The [collision dispatch initialization](docs/collision-dispatch-initialization.md)
uses the same pinned IDO and N64 matching-workflow references. Robotron's
instructions, all three compiler tables, callback consumer, and neighboring
BSS address establish its symmetric dispatch and 400-byte storage.

The [audio memory-size calculation](docs/audio-memory-size.md) uses the
same pinned IDO and N64 matching-workflow references. Robotron's complete
instructions, matching file services, caller, and confirmed audio record
sizes establish its header checks, offsets, and alignment arithmetic.

The [audio voice defaults](docs/audio-voice-defaults.md) use the same
pinned IDO and N64 matching-workflow references. Robotron's complete
instructions, track loader, caller, and matching property consumers
establish the sequence-header layout and initialization behavior.

The [model file relocation](docs/model-file-relocation.md) uses the
same pinned IDO and N64 matching-workflow references. Robotron's complete
instructions and existing recovered object callers establish the header,
point and record strides, pointer relocations, and signed scaling.

The [renderer matrix submission](docs/renderer-matrix-submission.md)
uses the same pinned IDO and N64 matching-workflow references. Robotron's
instructions, matching callers, and recovered fixed-matrix converter
establish the packing, translation, command, and counter behavior. The
SDK matrix layout is checked against the credited local SDK sources.

The [object history renderer](docs/object-history-rendering.md) uses the
same pinned IDO and N64 matching-workflow references. Robotron's complete
instructions, matching object callers, and history writer establish the
record layouts and rendering behavior. No reference implementation is
copied.

The [continue-code character helper](docs/continue-character.md) uses the
same pinned IDO and N64 matching-workflow references. Robotron's complete
instructions and matching character encoder establish its adjustments
and alphabet. No reference implementation is copied.

The [continue-code decoder](docs/continue-code.md) uses the same pinned
IDO and N64 matching-workflow references. Robotron's instructions and its
matching encoder establish the bitfield layout, checksum, field limits,
diagnostics, and scene setup. No reference implementation is copied. Local
and online credits for all thirteen requested repositories remain below.

The [early scene animation advance](docs/early-scene-animation-advance.md)
retains the pinned local IDO and N64 matching-workflow references. Robotron's
instructions establish the child resource stride, actor fields, scale
arithmetic, animation selection, callback ordering, and reset-slot layout.
No reference implementation is copied into the procedure. Local and online
credits for all requested repositories remain in the reference collection.

The [session scene start](docs/session-scene-start.md) retains the pinned
local IDO and N64 matching-workflow references. Robotron's instructions and
the recovered menu callers establish the mode values, two-player storage,
automatic level selection, reset ordering, and scene words. No reference
implementation is copied into the procedure. All requested reference
repositories retain their local and online credits below.

The [model polygon normal dispatch](docs/model-normal-polygon-dispatch.md)
retains the pinned IDO and N64 matching-build references. A local
decomp-permuter search suggested source line grouping for the cursor
initialization and do loop; the complete two-procedure unit was then
checked independently. Robotron's instructions establish the index cache,
material variants, all four normal submissions, and primitive dispatch.
No reference implementation is copied into these procedures.

The [scene menu string setup](docs/scene-menu-string-schedule.md) retains
the pinned IDO and N64 matching-build references for local and online use.
Robotron's instructions establish the choice stride, selection index,
global flag, string calls, signed scheduled-frame expression, and callback
registration. No reference implementation is copied into this procedure.

The [movie string position submission](docs/movie-string-position-submit.md)
retains the pinned IDO and established N64 matching-build references for
local and online use. Complete Robotron instructions and the movie update
caller establish the argument slots, coordinate conversion, rotation
offset, double scale, and constant block. No reference implementation is
copied into this procedure.

The [scene menu string refresh](docs/scene-menu-string-refresh.md) retains
the pinned IDO and established N64 matching-build references for local and
online use. Complete Robotron instructions establish the choice stride,
five-slot traversal, found flag, string calls, and fallback path. No
reference implementation is copied into this procedure.

The [scene actor reset and fade setup](docs/scene-actor-reset-begin.md)
retains the pinned IDO and established N64 matching-build references for
local and online use. Complete Robotron instructions establish the player
byte clamp, actor filters, animation and frame writes, palette duration,
camera arguments, and state update. No reference implementation is copied
into this procedure.

The [early pool and camera reset](docs/early-pool-scene-reset.md) follows
the recorded IDO compiler materials and N64 matching workflows. Robotron's
complete instructions and the previously recovered services establish the
camera arguments, reset loops, shared state offsets, object enable writes,
and debug-context call. The documented prefix does not claim the complete
allocation or add unverified BSS ownership.

The [camera-relative square recovery](docs/renderer-camera-square.md) uses
the local and online Super Mario 64 and libreultra GBI definitions for the
existing vertex layout. Robotron's complete instructions establish the
corner expressions, signed shifts, matrix-call order, texture coordinates,
and alpha-160 quad call. Independent IDO compilation and whole-ROM checks
determine acceptance.

The [audio command callback scan](docs/audio-command-callback-scan.md) uses
the local and online decomp-permuter project to search equivalent C forms
for a remaining comparison operand difference. The accepted explicit member
access was independently rebuilt with the IDO compiler and checked across
the complete parameter and callback unit. Robotron's instructions establish
its eight-byte callback records, command value, stopping conditions, retained
state, and twelve-byte static BSS layout.

The [expanded textured triangle recovery](docs/renderer-expanded-triangle.md)
uses the same local and online GBI references for vertex and triangle
command layouts. Robotron's instructions and complete byte comparisons
establish the XZ centroid expression order, signed division, shared
translation, corner consumption, diagnostics, and compiler-supported local
vector representation.

The [image quad recovery](docs/renderer-image-quads.md) uses local Super Mario
64 `include/PR/gbi.h` and libreultra `include/2.0I/PR/gbi.h`, together with
their online sources, to decode indexed eight-bit and RGBA sixteen-bit
texture image, tile and load-block words. Robotron's complete instructions
establish its vertex store order, quad winding, address alignment, cache
writes, and allocation failure behavior. Its shared extent scalar is
reconstructed and checked against the target's complete four-byte value.

The [textured polygon submission recovery](docs/renderer-textured-submission.md)
uses the local Super Mario 64 `include/PR/gbi.h` and libreultra
`include/2.0I/PR/gbi.h`, together with their online sources, for hardware
vertex layouts and vertex, triangle, and quad command packing. Robotron's
own complete code and data comparisons establish the corner selectors,
position conversion, alpha writes, diagnostics, and cursor behavior.

The early session animation recovery uses the recorded IDO compiler materials
and Super Mario 64 build conventions for compiler and linker handling. Its
actor callbacks, 204-byte records and 36-entry counter array are reconstructed
from Robotron's instructions and initialization spans. The specific evidence
and complete comparison requirements are documented in
[early session animation](docs/early-session-animation.md).
The following [actor animation and expiration recovery](docs/actor-animation-state.md)
uses the same compiler references and records Robotron's complete comparisons
for repeat values, counter updates, auxiliary animation data and child setup.
[Game collision and selection services](docs/game-collision-and-selection.md)
continue those compiler comparisons and include complete relocated switch
tables reconstructed from their C control flow.
[Scene and actor transitions](docs/scene-and-actor-transitions.md) continue
the recorded IDO and Super Mario 64 build references for scene conversion,
actor creation, collision transitions and the early pool timer. Robotron's
complete instructions and two relocated switch tables determine the game
implementations and recovered record prefixes.
[Menu transition and texture cache recovery](docs/menu-transition-and-texture-cache.md)
uses libreultra button definitions and Super Mario 64 GBI definitions alongside
Robotron's menu initialization and complete RDP load/tile commands.

Perfect Dark's `src/inflate/inflate.c` and Huffman entry declarations at the
recorded revision supplied comparisons for the DEFLATE tables, bitstream, and
decoder research. The [compression runtime](docs/compression-runtime.md)
documents Robotron's complete matching support routines and source-owned
tables and buffers. The reference's [MIT notice](docs/licenses/perfect-dark.txt)
is retained; Robotron's particular instructions and addresses are checked
against its own ROM.

[Erick194/DOOM64-RE](https://github.com/Erick194/DOOM64-RE), inspected at
`6931e678a0b2958be1b49598f2fe60712c6596e1`, supplied a comparison for WESS
record and event terminology during audio recovery, and corroborated the
ten-byte temporary buffer used by the variable-length stream writer. The consulted files are
`doom64/wessapi.h`, `wessarc.h`, `wesshand.h`, `wessseq.h`, `wesshand.c`,
`wessseq.c`, `wessshell.c`, and `n64cmd.c`. The last file supplied supporting
hardware-voice, patch, capture, and pitch terminology during the later driver
recovery. The checkout identifies its license as GPL-3.0.
The [audio property notes](docs/audio-properties.md),
[host/stream notes](docs/audio-host-stream.md),
[command engine notes](docs/audio-command-engine.md),
[hardware driver notes](docs/audio-hardware-driver.md), and their input ledgers
separate the reconstructed Robotron source from that reference and retain the
historical input identities. The reference checkout is not included here.

The public libreultra `include/2.0I/PR/libaudio.h` was also consulted for the
28-byte SDK voice record, six-byte voice configuration, and synthesizer call
signatures used by the hardware driver. The Robotron instructions and complete
function comparisons determine which layouts and calls are used in this build.

The [SDK runtime recovery](docs/sdk-runtime.md) records the additional use of
libreultra's `src/io/viint.h`, `src/os/osint.h`, `src/os/thread.c`,
`src/os/createmesgqueue.c`, `src/audio/heapinit.c`, and `src/gu/random.c` at the
same recorded revision. These comparisons corroborated the video context,
eight-byte thread sentinel, heap alignment, and initialized generator state.
The target instruction stream and complete code/data comparisons determine
the accepted Robotron implementations and compiler profiles.

The [runtime helpers and hardware interfaces](docs/runtime-helpers-and-hardware.md)
also use the recorded local libreultra `src/os/setsr.s`, `src/os/getsr.s`,
`src/gu/sqrtf.s`, and `src/os/exceptasm.s` as references for native hardware
instructions and thread context layouts. Thread creation in Robotron confirms
the separate cleanup trampoline referenced by its return address. Complete
assembled procedure comparisons determine the accepted instruction order,
delay slots, and source extents. These native SDK routines are counted as
assembly. The stored-block decoder continues the credited Perfect Dark DEFLATE
study and preserves Robotron's own input, window, and output-limit behavior.

The [transfer and short-math notes](docs/sdk-transfer-and-short-math.md) record
the local libreultra `src/gu/sins.c` and `src/gu/coss.c` interface comparisons.
Their quarter-wave lookup and angular offset corroborate the target's signed
short trigonometric interface. Robotron's independent comparisons establish
the MIPS II profile and complete code extents. The later
[sine-table reconstruction](docs/sdk-short-sine-table.md) uses the mathematical
quarter-wave rule and compares every generated value with the target and the
local libreultra `src/gu/sintable.h` entries.

The [cache, cartridge, and float-math notes](docs/sdk-cache-and-transfer.md)
record local libreultra comparisons for raw extended DMA and handle timing,
float sine/cosine, data and instruction cache operations, block clearing, and
CPU/RCP interrupt-mask application. Robotron's complete comparisons establish
the VR4300 multiply scheduling profile for float math and the native assembly
extents. At that checkpoint, the coefficients, timing-handle storage, and
interrupt conversion table remained fallback data.

The [task-loading and yielding notes](docs/sdk-task-loading-and-yield.md)
record local libreultra comparisons for RSP task copying and address conversion,
disk error recovery, native thread context saving, and overlap-safe block copy.
The consulted files are `src/io/sptask.c`, `src/io/leointerrupt.c`,
`src/os/exceptasm.s`, and `src/libc/bcopy.s`. Robotron's complete instruction
comparisons determine the accepted source; native procedures and their
alignment are measured separately from C.

The [float constants](docs/sdk-float-math-constants.md) and
[video/device initialization](docs/sdk-video-and-device-initialization.md)
record further local libreultra comparisons with `src/gu/sinf.c`,
`src/gu/cosf.c`, `src/io/vi.c`, `src/io/vimgr.c`, `src/io/viint.h`,
`src/io/cartrominit.c`, and `src/io/leodiskinit.c`. These comparisons corroborate
numeric representations, SDK interfaces, and complete storage layouts.

The [video timing and swap recovery](docs/sdk-video-modes-and-swap.md) also
consulted local libreultra `src/io/viswapcontext.c`, `src/io/vitbl.c`, and
`src/io/vimodepallan1.c`, `src/io/vimodempallan1.c`, and
`src/io/vimodentsclan1.c`. The source generator expresses the confirmed region
timings and pixel/field rules; independent target comparisons cover all 45
complete mode records and the complete swap procedure.

The subsequent [timer and priority recovery](docs/sdk-time-and-priority.md),
[scheduling and audio services](docs/sdk-scheduling-and-audio-services.md), and
[matrix conversion](docs/sdk-matrix-conversion.md) build on these interface
studies. The retained libreultra and GoldenEye matrix-header comparisons
corroborate the signed fixed-point interpretation and division by `65536.0f`.
Robotron's complete target procedures determine the accepted code, storage,
and compiler settings; reference-adapted experiments remain local research.

The [voice-command reconstruction](docs/sdk-voice-commands.md) also checked
the online `src/audio/synallocvoice.c` at libreultra revision
`1aca5c13ca041cef86f8dc194b727361dad9c09b`. Its declarations and allocation-list
organization corroborate the target's natural source structure. The recovered
code and the shared game/SDK audio records are checked against complete
Robotron procedure bytes and existing callers.

The [synthesizer reconstruction](docs/sdk-synthesizer-runtime.md) and
[filter constructors](docs/sdk-audio-filter-construction.md) use the same
target-led process. The pinned libreultra `src/audio/synthesizer.c` declarations
corroborate the historical initialization locals, timing helpers, and command
cursor convention. All public and private procedure extents and both generated
double constants are checked against Robotron's target. The earlier adapted
SDK experiments remain separate private research.

The [audio output reconstruction](docs/sdk-audio-output.md) consulted
`src/audio/mainbus.c`, `auxbus.c`, `save.c`, and `resample.c` in the pinned
`decompals/ultralib` checkout for filter interfaces, command meanings, and
pitch terminology. The recovered bus loops, stereo output packets, fractional
sample state, and generated constants are verified against Robotron's complete
target procedures. The source-owned packet definitions share the synthesizer's
single-evaluation command cursor.

The [wavetable decoder reconstruction](docs/sdk-audio-decoder.md) also uses the
pinned `decompals/ultralib` `src/audio/load.c` as a reference for PCM and ADPCM
frame sizes, loop records, DMA alignment and RSP commands. Complete Robotron
instruction comparisons verify the recovered control flow, and IDO's private
procedure records establish the actual `decodeChunk` helper boundary and
calling convention.

The [envelope reconstruction](docs/sdk-audio-envelope.md) consulted the online
libreultra `src/audio/env.c` at revision
`1aca5c13ca041cef86f8dc194b727361dad9c09b`. It corroborates the update interface,
rate approximation and historical nested assignment expression. Robotron's
complete instruction stream and data sections determine the accepted source;
all seven procedures and both emitted tables/constants sections are verified.

The [effect construction](docs/sdk-audio-effect-construction.md) also consulted
the pinned online libreultra `src/audio/drvrNew.c` for preset field meanings,
delay units and low-pass coefficient construction. Robotron's instructions
and initialized data verify the reconstructed allocation flow, record layouts,
mixed-precision arithmetic and complete preset arrays.

The [reverb reconstruction](docs/sdk-audio-reverb.md) consulted the pinned
online libreultra `src/audio/reverb.c`, including its temporary-buffer swap,
historical local declarations and positive buffer-reuse pointer update.
Complete Robotron instruction comparisons establish all eight procedure
extents, circular-transfer branches, resampling arithmetic and command order.

The [camera and rotation reconstruction](docs/camera-projection-and-rotation.md)
uses the pinned libreultra `src/gu/perspective.c`, `lookathil.c` and
`rotateRPY.c` and the previously recorded 007 GU declaration variant. Online
inspection of `rotateRPY.c` confirms the initialized source-static angle
constant, and `lookathil.c` confirms the double threshold and highlight
fallback formulas. Robotron's complete instructions and generated storage
determine the accepted arithmetic, record layouts and procedure extents.

The [controller and Pak reconstruction](docs/sdk-controller-pak-reconstruction.md)
retains the reviewed sm64 CC0 and Perfect Dark MIT reference basis for its
controller, filesystem and packet routines. The pinned libreultra, mk64, 007
and decompals/ultralib comparisons identify historical SDK variants. Online
inspection of libreultra's `src/io/crc.c` also corroborates the final zero-byte
shift and its historical `temp &= -1` branch. Complete Robotron instructions,
procedure records and storage comparisons determine the accepted code,
including the target's ID-buffer and inode-repair behavior.

The [reference study](docs/reference-study.md) records concrete uses. Further
source-specific references are in the [SDK arithmetic](docs/sdk-arithmetic.md),
[audio effects](docs/sdk-audio-effects.md), [audio filters](docs/sdk-audio-filters.md),
[audio frame](docs/sdk-audio-frame.md), [controller Pak](docs/sdk-pfs.md),
[SDK math](docs/sdk-math.md), and [static-function verification](docs/ido-static-functions.md)
notes, together with [object definitions and shell menus](docs/session-setup.md),
[scene commands and background images](docs/scene-commands.md), and
[save menus](docs/save-menus.md), [gameplay tweaks and resource strings](docs/tweaks-and-strings.md),
[renderer state and lighting](docs/graphics-state.md), and
[renderer polygons and vertices](docs/renderer-geometry.md),
[model geometry and framebuffer services](docs/model-geometry.md),
[object creation](docs/object-creation.md), [scene services](docs/scene-services.md),
and [additional runtime recovery](docs/runtime-recovery.md).
Those documents distinguish target-confirmed facts from reference
comparisons and remaining hypotheses.

The [PI manager reconstruction](docs/sdk-pi-manager.md) consulted pinned local
libreultra `src/io/pimgr.c`, `src/io/devmgr.c`, `src/io/leointerrupt.c`, and
`include/2.0I/PR/os.h`. They corroborate creation, DMA/disk completion,
disk interrupts, and historical record layouts.
Complete Robotron instructions and relocated storage establish the message
constants, jump table, private thread/queue storage, and handle pointers.

The [initialization and exception recovery](docs/sdk-initialization-and-exceptions.md)
consulted pinned local libreultra `src/os/initialize.c`, `src/os/exceptasm.s`,
`src/os/exceptasm.h`, and `src/io/pfsrepairid.c`. They corroborate SDK startup,
Pak repair, context fields and the distinct native exception entries.
Complete Robotron instruction comparisons establish their accepted sizes,
control flow, initialized values and retained thread procedures.

The [interrupt storage recovery](docs/sdk-interrupt-storage.md) consulted pinned
local libreultra `src/os/setintmask.s`, `src/os/exceptasm.s`,
`src/os/exceptasm.h`, `src/os/thread.c`, `src/os/osint.h`, and
`src/io/leointerrupt.c`. They corroborate interrupt bit rules, priority and
handler ordering, the sentinel, scratch context and disk stack. Generated
declarations and complete relocated Robotron bytes establish all owned storage.

The [runtime table recovery](docs/game-runtime-tables.md) retains the pinned
local IDO and Super Mario 64 compiler/build reference basis. Complete Robotron
procedures and four initialization spans establish the accepted digit loops,
menu record stride, actor pair table and session counter bounds. Matching
caller and storage comparisons determine the source ownership claims.

The [actor and renderer services](docs/actor-and-renderer-services.md) consulted
the pinned local Super Mario 64 `include/PR/gbi.h` and its online counterpart
for F3DEX/F3DLP vertex and triangle formats and texture-state fields. Robotron's
complete instructions establish the accepted command words, dynamic heap
layout, counter switch table and preserved metric bounds. The reference
header implementation is not copied into these source units.

The [parameter and rendering recovery](docs/parameter-and-rendering-state.md)
consulted pinned local libreultra `src/gu/mtxutil.c` for matrix planes and
Super Mario 64 `include/PR/gbi.h` for tile-size masks and geometry command
fields. Complete Robotron instructions establish the recovered scheduling,
completion counters, history conversion and command behavior. The new
procedures retain the project's pinned IDO compiler and matching-build basis.

The [resource and cache state recovery](docs/resource-and-cache-state.md)
retains the pinned local IDO and Super Mario 64 compiler/build reference
basis. Complete Robotron append, scale and cache-reset instructions establish
the resource group entries, shared scale word and both cache strides.
Existing caller comparisons check the updated shared definitions.

The [callback and release recovery](docs/callback-and-release-state.md)
consulted pinned local libreultra `src/audio/synstopvoice.c` and
`src/audio/synfreevoice.c` for the SDK interfaces and stop/free ordering.
Robotron's complete instructions establish callback slot handling, hardware
voice ownership, collision results and the private storage boundaries.
The existing pinned IDO and Super Mario 64 matching-build references apply.

The [pan, patch and point recovery](docs/pan-patch-and-point-state.md)
consulted pinned local libreultra `src/audio/synsetpan.c` for the SDK pan
interface and update kind. Complete Robotron command and appender instructions
establish the private work areas, patch iteration and group distance tail.
The existing pinned IDO and Super Mario 64 matching-build references apply.

The [Pak, signature and argument recovery](docs/pak-signature-and-argument-state.md)
consulted pinned local libreultra `src/io/pfsfilestate.c` for file metadata
and name fields used by the existing Controller Pak services. Complete
Robotron procedures establish the menu stride, saved-image literals and
resource copy. The existing pinned IDO and Super Mario 64 matching-build
references apply. No reference implementation is copied into these routines.

The [audio DMA cache recovery](docs/audio-dma-cache.md) consulted pinned local
libreultra `src/audio/event.c` for SDK link-prefix use through explicit casts.
Complete Robotron procedures establish the cache ordering, transfer
submission, expiration rule and preserved error paths. The existing pinned
IDO and Super Mario 64 matching-build references apply. No reference
implementation is copied into these routines.

The [collision callback recovery](docs/collision-callback-state.md) retains
the pinned local IDO and Super Mario 64 compiler and matching-build reference
basis. Complete Robotron instructions establish the actor-kind switch,
score response, midpoint arithmetic and session word at offset `0x8C`.
No reference implementation is copied into these routines.

The [geometry scaling recovery](docs/geometry-scaling.md) retains the pinned
local IDO and Super Mario 64 compiler and matching-build reference basis.
Complete Robotron instructions establish the twelve-byte points, argument
order, separate and uniform factors, signed shifts and existing bridge calls.
No reference implementation is copied into these procedures.

The [collision death recovery](docs/collision-death-result.md) retains the
pinned local IDO and Super Mario 64 compiler and matching-build reference
basis. Complete Robotron instructions establish the midpoint, effect cases,
unsigned-byte result and all five jump-table destinations. No reference
implementation is copied into the callback or the accompanying selection
lookup, whose complete instructions establish the parallel word lists,
player stride and missing fallthrough return. The accompanying angle helper
retains the verified wrapper, signed limit and low-word arithmetic.

The [actor motion and callback recovery](docs/actor-motion-callback-state.md)
retains the pinned local IDO and Super Mario 64 compiler and matching-build
references. Complete Robotron procedures establish the list traversal,
callback flag reload, random motion, history-slot prefix and axis separation.
No reference implementation is copied into these procedures.

The [actor search and projectile fan recovery](docs/actor-search-and-projectile-fan.md)
retains the pinned local IDO and Super Mario 64 compiler and matching-build
references. Complete Robotron instructions establish the search filters,
signed distance, random fan count, capacity checks and forwarding interface.
No reference implementation is copied into these procedures.

The [actor animation and bonus pattern recovery](docs/actor-animation-and-bonus-pattern.md)
retains the pinned local IDO, Super Mario 64 and libreultra workflow references.
Complete Robotron instructions establish the wrapped elapsed-time subtraction,
session timestamp, callback arguments, signed remainder and child spacing.
No reference implementation is copied into these procedures.

The [controller setup and storage recovery](docs/controller-service-setup.md)
consulted local libreultra `include/2.0I/PR/os.h` for controller, Pak, motor,
and thread interfaces, and local Perfect Dark `src/lib/joy.c` for controller
initialization and query conventions. Robotron's instructions determine its
queue setup, repeated initialization call, error handling, and storage
boundaries. The reconstructed game procedures contain no copied reference
implementation.

Credit does not replace a component's license or original notices. Reference
repositories can contain different terms for different components. This
repository does not redistribute the reference checkouts, compiler executables,
commercial ROM, or extracted commercial assets. Matching source is evaluated
against the user's local input, with the provenance of consulted material
recorded alongside the reconstruction.

Renderer transform and graphics buffer recovery consulted local libreultra
include/2.0I/PR/ucode.h and sptask.h for RSP stack sizing, yield buffer sizing
and 64-bit alignment. The target supplies every routine, diagnostic string,
array bound and initial selector value. The pinned IDO and Super Mario 64
matching-build references continue to apply; no reference implementation was copied.

Renderer diagnostics and font recovery consulted local libreultra
`include/2.0I/PR/gbi.h` for the 16-byte vertex and 64-byte SDK matrix formats.
The target supplies the pool capacities, diagnostic messages, font commands,
color cases, HUD branches and failure behavior. The pinned IDO and Super Mario
64 matching-build references continue to apply. No reference implementation or
font image is copied into this recovery.

Controller polling and storage recovery consulted the local libreultra
`include/2.0I/PR/os.h` and `src/io/contreaddata.c` for pad widths and the
read/wait/unpack interface. Robotron's complete instructions establish the
game's access ordering, button edges, motor thresholds and phase arithmetic;
existing matching directory and clear routines establish the storage bounds.
The pinned IDO and Super Mario 64 matching-build references continue to apply.
No reference implementation is copied into these game routines or data units.

Fixed-alpha quad and mesh-command recovery consulted the local libreultra
`include/2.0I/PR/gbi.h` and Super Mario 64 `include/PR/gbi.h` for vertex-load
packing, rotated triangles, paired triangles, and line commands. Robotron's
complete target supplies the alpha values, diagnostics, command order,
opcode table, cursor movement, and color updates. The pinned IDO profile
and matching-build references continue to apply. No reference implementation
or commercial asset is copied into this recovery.

Projectile trail verification uses [Unicorn](https://www.unicorn-engine.org/)
as an optional MIPS execution engine. The checker runs the supplied target and
freshly compiled candidates, using supporting-call stubs for the ribbon. Robotron's
instructions and matching callers establish the ribbon behavior and arena
state; this work copies no reference game implementation.

Annular and tiled surface recovery uses Robotron's target instructions and
matching fixed/short trigonometry, geometry, state, and cache code. The local
libreultra `include/2.0I/PR/gbi.h` and SM64 GBI definitions supply packet
formats and SDK macro references. The optional Unicorn checker executes
the matching support code and its reconstructed initialized data; no reference
game implementation is copied into these surface candidates.

Actor-group path and bonus child research follows the local SM64 and IDO
compiler and matching workflows listed above. Runtime storage uses the
initialized/NOLOAD separation described in the Majora's Mask reference study.
The optional Unicorn checkers execute freshly matched arithmetic support and
numerical tables. Robotron's original instructions establish callback behavior
and storage extents; no reference game implementation was copied.

Actor effect drawing and object storage follow the local SM64 pinned IDO
matching workflow and Majora's Mask NOLOAD specification. Robotron's retail
allocator, reset routines and renderer establish the 300-record pool, 300
slot integers, effect search and matrix paths. The optional Unicorn checker
executes the matching callback and fixed-matrix helpers. No reference game
implementation was copied into these sources.

The supplied-matrix scale submitter uses the local SM64 pinned IDO comparison
workflow and the existing libreultra SDK matrix representation. Robotron's
retail code establishes row scaling, integer/fractional packing, clamping and
the post-write diagnostic. Its MIPS checker uses Unicorn and an independent
arithmetic oracle. No reference implementation was copied.

Indexed and RGBA image setup follows the local SM64 pinned IDO workflow.
The libreultra GBI definitions corroborate texture-perspective and texture-filter
fields. Robotron's retail instructions establish the wrapper ordering and
parameters. The optional Unicorn checker executes matching matrix, palette,
quad and allocation code against independent CPU-buffer expectations; it
does not execute graphics microcode. No reference implementation was copied.

Object-attached glyph recovery follows the local SM64 pinned IDO workflow and
libreultra vertex/GBI definitions. Robotron's complete instructions and matching
callees establish the gradient, matrix restoration, allocation and surviving
return register. The optional Unicorn checker exercises the glyph and its
object callback with real support code and independent memory/command oracles.
The unresolved C return contract remains documented; no reference implementation
or commercial font image was copied.

Menu-option construction follows the local SM64 pinned IDO matching workflow.
The IDO optimizer sources were consulted while investigating temporary storage
and register allocation. Robotron's complete instructions, existing callers
and label updater establish the records and runtime storage. The optional
Unicorn checker uses the matching string-length code and guarded memory
oracles. No reference implementation was copied.

Scene action recovery follows the local SM64 pinned IDO matching workflow.
The IDO temporary-storage allocator was consulted during frame and local
allocation analysis. Robotron's complete instructions, switch table and
callers establish the menu actions, pickup gates and four-byte counter.
The optional Unicorn checker executes the matching handler and menu caller
against guarded byte oracles. No reference game implementation was copied.

Boss-part creation and actor-boundary recovery follow the local SM64 pinned
IDO matching workflow. The IDO temporary-storage allocator was consulted
during frame and spill analysis. Robotron's complete instructions establish
the constructor, resource stride, timestamps and excluded boundary candidate.
The optional Unicorn checker executes freshly matched arithmetic helpers
against guarded byte and call expectations. No reference implementation was copied.

Boss trigger dispatch follows the local SM64 and IDO pinned compiler workflow.
Robotron's full instruction range and initialized records establish the gates,
callback ordering, timer reads and unspecified position word. The optional
Unicorn checker executes matching reset and arithmetic code, compares the sine
table with its mathematical generator, and checks floating-point saved
registers through real MIPS instructions. No reference implementation was copied.

Early actor decisions follow the local SM64 pinned IDO matching workflow.
The IDO temporary-storage allocator was consulted during local lifetime and
frame analysis. Robotron's complete instructions establish weighted choices,
reset thresholds, movement selection and shared layouts. The optional Unicorn
checker executes matching arithmetic and random-wrapper code against guarded
byte and call expectations. No reference implementation was copied.
