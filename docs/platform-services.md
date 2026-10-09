# Platform service adapters

`src/game/platform_empty.c` reconstructs the 144-byte interval at
`0x8003BF5C..0x8003BFEC`. Fourteen of these functions are empty in the retail
executable: each consists of a return and its zero delay slot. The remaining
function, `func_8003BFA4`, returns the existing frame-completion helper's
integer result with a null timestamp pointer. The helper returns elapsed
milliseconds; both scene timer capture and initialization consume that
result. Its shared declaration and explicit return preserve all 32 adapter
instruction bytes. Each boundary and all 144 bytes match independently.

`func_8003BF84` has an integer return declaration and an unspecified argument
list. The three calls in the still-unrecovered `func_80026B0C` pass a sound word
in A0 and consume the unchanged incoming V0 word as the future-sound queue's
fifth argument. The leaf reads neither register and consists of `jr ra; nop`.
Its empty integer-return body deliberately falls off without a return. This
reproduces the pinned IDO 5.3 output and has no portable ISO C return-value
guarantee. A named parameter, including a `register` parameter, makes IDO emit
an A0 stack spill in the delay slot and does not match retail.

Run `make check-platform-empty` with the analysis Python environment to check
all 144 platform bytes, 392 leaf executions and 1,260 executions of the three
retail caller slices. The leaf preserves every seeded GPR, HI and LO word and
accesses no data memory. The caller slices verify sound arguments, choice
selection, the fifth stack argument, SP, GP and saved registers, with bounded
code and memory access. Three instruction mutations must be detected. The
interface probe also compiles a C caller through the shared declaration.
Caller slices start after playback and stop before the queue body. This check
does not establish full menu-control or gameplay recovery, and the declaration
correction adds no instruction, initialized-data or BSS ownership.

[The platform ABI evidence](platform-empty-provenance.json) records the
complete IDO comparison, independent spimdisasm and splat reassemblies,
Ghidra caller references, execution results and source input hashes. The tools
are [spimdisasm](https://github.com/Decompollaborate/spimdisasm),
[splat](https://github.com/ethteck/splat),
[Unicorn](https://github.com/unicorn-engine/unicorn),
[Capstone](https://github.com/capstone-engine/capstone) and
[pyelftools](https://github.com/eliben/pyelftools). The local
`n64-sources/ido/src/uopt/uoptreg2.c` reference informed the separate register
allocation investigation; no reference code was copied into the game source.

`src/game/platform_io.c` covers `0x8003C5C4..0x8003C6B8`, totaling 244 bytes.
Fourteen functions in this interval are also retail no-ops. `func_8003C624`
forwards to the object update entry, `func_8003C64C` loads a named resource into
a newly allocated heap block, and `func_8003C698` forwards to heap release.
These three adapters contribute 132 bytes; all seventeen functions match.

The resource adapter queries the size using the original filename argument,
writes that size through its second argument, allocates the block, and calls
the existing resource loader with the filename and allocation. It returns the
allocation. The target has no allocation-failure guard, and that behavior is
preserved. The resource loader and size-query declarations are shared through
`include/rom_files.h`; they both consume a filename pointer.

The empty functions are reproduced because those bodies are present in this
version of the game. They are counted separately here from the active adapters
so the function count does not imply thirty-two substantial recovered systems.

The game initializer passes 1 in A0 to func_8003C5CC. Its empty leaf
reads no argument and remains jr ra; nop. The C declaration and definition
use an unspecified argument list. A named integer parameter adds an A0 stack
spill to the return delay slot under pinned IDO 5.3 and changes a retail word.
Ghidra records the observed integer argument for caller analysis. The complete
244-byte unit is independently compared, and the real leaf executes inside
make audit-game-initialization; this interface correction adds no ownership.
