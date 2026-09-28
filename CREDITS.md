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
[spimdisasm](https://github.com/Decompollaborate/spimdisasm) and
[Rabbitizer](https://github.com/Decompollaborate/rabbitizer) support the local
instruction and provisional-function inventory. GNU Binutils provides the
MIPS assembler, linker and object inspection tools. Python and GNU Make run
the extraction, validation and build workflow.

## Attribution in recovery notes

The [reference study](docs/reference-study.md) records concrete uses. Further
source-specific references are in the [SDK arithmetic](docs/sdk-arithmetic.md),
[audio effects](docs/sdk-audio-effects.md), [audio filters](docs/sdk-audio-filters.md),
[audio frame](docs/sdk-audio-frame.md), [controller Pak](docs/sdk-pfs.md),
[SDK math](docs/sdk-math.md), and [static-function verification](docs/ido-static-functions.md)
notes, together with [object definitions and shell menus](docs/session-setup.md),
[scene commands and background images](docs/scene-commands.md), and
[save menus](docs/save-menus.md), [gameplay tweaks and resource strings](docs/tweaks-and-strings.md),
[renderer state and lighting](docs/graphics-state.md), and
[renderer polygons and vertices](docs/renderer-geometry.md).
Those documents distinguish target-confirmed facts from reference
comparisons and remaining hypotheses.

Credit does not replace a component's license or original notices. Reference
repositories can contain different terms for different components. This
repository does not redistribute the reference checkouts, compiler executables,
commercial ROM, or extracted commercial assets. Matching source is evaluated
against the user's local input, with the provenance of consulted material
recorded alongside the reconstruction.
