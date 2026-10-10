# Renderer fatal formatter

`func_800496E0` occupies `800496E0..800498E0` (512 bytes), at ROM
`4A2E0..4A4E0`. Its complete pinned IDO 5.3 output matches, including the
infinite wait and unreachable epilogue. The source removes this one fallback
span. Neighboring functions and initialized data retain their existing owners.

The formatter copies ordinary bytes and accepts `%s`, `%d`, `%x`, `%c` and
`%C`. Both character conversions read the high byte of their four-byte o32
argument home, preserving the original big-endian behavior. Unknown conversion
bytes consume one argument without emitting text. It terminates the message,
calls the existing empty output boundary with `\n\n%s\n\n`, calls the diagnostic
report, and waits forever.

## Compiler context

IDO emits `.align 5` between the infinite branch and the unreachable restore
sequence. Compiling the formatter at section offset zero produces 496 bytes.
The complete contiguous C context `80048D90..800498EC` places the formatter at
offset `0x950`, so the same directive supplies the four observed NOPs.
Every one of the context's 2,908 live instruction bytes and 60 constant bytes
is compared with retail. The four final text zeros and four final constant
zeros also match, but add no ownership.

The formatter includes the already recovered neighboring bodies. The compiler
keeps its original output beside the build object, then `partition_context.py`
retains the formatter's entire 512-byte body. It rebases ELF symbols and
relocations, externalizes the neighboring global functions, and removes their
separately owned constants. It does not rewrite MIPS instructions. Calls into
the context must use a global function relocation with a zero addend. Changed
function extents, constants, live tails, unexpected allocated sections and
references into discarded data are rejected.

This reproduces the observed section-relative alignment. It does not establish
the exact original translation-unit boundary. A 256-byte message buffer and a
consumed length local reproduce the measured 360-byte frame and message address
at `sp + 100`. The length is used after each string/numeric conversion, and both
numeric arguments use consumed local values. The original declared capacity
remains unknown. No dummy local, inline assembly or compiler modification is required.

## Verification

`make check-renderer-fatal-format` freshly compiles the complete formatter,
string/memory helpers, numeric helpers, integer support, hexadecimal alphabet
and output template. Independent output and memory oracles cover 806 paired
retail/source cases, including every high-byte character value, unknown
specifier consumption, stacked arguments, numeric boundaries and messages
through 255 bytes. Five instruction faults must fail, with positive controls
around each fault. Checks cover permitted guest accesses, input and stack
guards, the saved-register image, GP, output-call arguments and ordering, and
repeated execution of the final wait.

The output and report boundaries use returning stubs that clobber integer
caller registers. Report internals, floating register effects, rendering and
complete gameplay are outside this checker. Overflowing output, dangling
percent specifiers and decimal `INT_MIN` are omitted.

The provenance ledger records the complete context comparison, independent
reference reassembly, Ghidra byte comparison and current acceptance checks.
Other renderer candidates remain tracked in
[issue #61](https://github.com/frankischilling/robotron64/issues/61).
