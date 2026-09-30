# Disabled diagnostic output

`src/game/game_debug_format.c` reconstructs the 476-byte formatter at
`0x8003CF88..0x8003D164`. It accepts `%C`/`%c`, `%s`, `%d`, and `%x`, writes the
result to a 500-byte stack buffer, then passes that message through the two
retail diagnostic entry points. An unsupported conversion still consumes one
integer argument. The target has no destination-size check.

The formatter reads o32 argument homes through `include/game_stdarg.h`. Its
12-byte trailing stack workspace is retained as `unknownStack`: it is never
read, but its independently exact placement is required for the target's
`0x238`-byte frame. The complete procedure matches 476/476 bytes under IDO 5.3.

`src/game/debug_noop.c` reconstructs the 28-byte output function at
`0x80048DC0..0x80048DDC`. It accepts a format pointer and variadic arguments
but has an empty body in the retail build. IDO emits the original eight-byte
stack frame and stores the four incoming argument registers before returning.

The variadic interface is supported by those argument-home stores and by
call sites with different numbers of values, including the active-object
list's format-and-index call. `include/debug_output.h` supplies the shared
declarations. The formatter's complete proof is retained under
`.local/recovery73-object/probes/debug_cf88_marker-5.3-O2-mips1`; the normal
build independently recompiles it and verifies the whole ROM.
