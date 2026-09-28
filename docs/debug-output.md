# Disabled diagnostic output

`src/game/debug_noop.c` reconstructs the 28-byte function at
`0x80048DC0..0x80048DDC`. It accepts a format pointer and variadic arguments
but has an empty body in the retail build. IDO emits the original eight-byte
stack frame and stores the four incoming argument registers before returning.

The variadic interface is supported by those argument-home stores and by
call sites with different numbers of values, including the active-object
list's format-and-index call. `include/debug_output.h` supplies the shared
declaration. This function performs no formatting or output in the retail
ROM; it is counted as a matching disabled diagnostic, not as a recovered
formatter implementation.
