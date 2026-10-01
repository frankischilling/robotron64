# Platform service adapters

`src/game/platform_empty.c` reconstructs the 144-byte interval at
`0x8003BF5C..0x8003BFEC`. Fourteen of these functions are empty in the retail
executable: each consists of a return and its zero delay slot. The remaining
function, `func_8003BFA4`, returns the existing frame-completion helper's
integer result with a null timestamp pointer. The helper returns elapsed
milliseconds; both scene timer capture and initialization consume that
result. Its shared declaration and explicit return preserve all 32 adapter
instruction bytes. Each boundary and all 144 bytes match independently.

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
