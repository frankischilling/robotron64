# Credits and references

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
| [Perfect Dark](https://github.com/n64decomp/perfect_dark) | `169ed48bdcbfb3b568b028bd5bebb27680073514` | Extraction structure and per-object compiler profiles |
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
extents. The coefficients, timing-handle storage, and interrupt conversion
table remain fallback data in this checkpoint.

The [task-loading and yielding notes](docs/sdk-task-loading-and-yield.md)
record local libreultra comparisons for RSP task copying and address conversion,
disk error recovery, native thread context saving, and overlap-safe block copy.
The consulted files are `src/io/sptask.c`, `src/io/leointerrupt.c`,
`src/os/exceptasm.s`, and `src/libc/bcopy.s`. Robotron's complete instruction
comparisons determine the accepted source; native procedures and their
alignment are measured separately from C.

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

Credit does not replace a component's license or original notices. Reference
repositories can contain different terms for different components. This
repository does not redistribute the reference checkouts, compiler executables,
commercial ROM, or extracted commercial assets. Matching source is evaluated
against the user's local input, with the provenance of consulted material
recorded alongside the reconstruction.
