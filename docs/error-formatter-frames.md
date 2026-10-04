# Fatal and warning formatter frames

The complete fatal and warning procedures at `8001C0D0..8001C2C4` and
`8001C2C4..8001C49C` compile to the retail 500 and 472 bytes with the pinned
IDO 5.3 game profile. Both ranges replace extracted fallback. They introduce
no initialized data, BSS, dispatch table, or instruction patch.

Both procedures subtract `0x448` from the stack pointer, save their registers
at offsets `0x18..0x3F`, and address the message at offset `0x254`. The message
occupies the final 500 bytes of the frame. The argument homes begin immediately
above it. The recovered formatting loop, character promotion, string and number
calls, diagnostic strings, and variadic interface were already documented in
[the formatter notes](error-formatters.md).

An ordinary 500-byte C array produced a smaller frame, differing in 18 fatal
and 17 warning stack immediates. The reconstructed `ErrorMessageStorage` now
retains 504 unreferenced bytes before its 500-byte message member. IDO places
that storage at `sp + 0x5C`, producing the retail message offset and frame size.
This is a representation of the measured stack allocation. The original
declaration, type, and purpose of the unreferenced space remain unknown.
It is not identified as another message buffer, and it is never initialized.

The complete instructions make no reference to any of the 532 bytes between
the saved-register area and the message. The execution checker rejects any
write to that whole interval, including writes by called helpers, and verifies
its initial pattern after every bounded execution. The checker also verifies
the `0x448` allocation, preserved stack pointer, integer and floating-point
callee-saved registers, global pointer, input guards, stacked arguments, and
all output bytes.

## Independent comparisons

Separate splat/spimdisasm assembly references reassemble to all 972 retail
instruction bytes. Canonical reference and IDO objects agree at 100% for each
complete function and `.text` section in objdiff. Separate standalone
spimdisasm output is also assembled and compared with each complete ROM range.
Current m2c context includes the verified shared declarations. Fresh matching
and asm-differ comparisons check the complete source ranges.

The raw IDO objects contain only zero alignment after the declared function
ends. The existing normalizer removes those zeros while preserving every live
instruction, symbol extent, and relocation. The eight bytes before the fatal
function remain outside the recovered ranges.

## Execution scope

The guarded checker compares both recovered procedures and the existing
buffered formatter with original MIPS. It checks all character argument bytes,
all nonzero unknown specifiers, numeric boundaries, strings, stacked arguments,
literal high bytes, 499-byte output, and the buffered formatter's width rules.
Fresh matching C executes the string, integer-conversion, absolute-value, and
output-bridge helpers.

Console output and the fatal renderer reporter use recorded ABI-clobbering
stubs. The reporter returns synthetically so the fatal epilogue can be checked;
the game's full reporting and infinite-wait behavior are outside this checker.
Buffer overflow, dangling percent specifiers, and decimal `INT_MIN` remain
outside the bounded cases. The historical unbounded formatting behavior is
preserved.

Ghidra retains the unsigned-byte variadic prototypes and 500-byte message
locals. Its saved comments record the measured frame and unknown storage.
The reconstructed storage type is shared by the C definitions and current
decompiler context; it is not presented as an original developer type.

The [provenance ledger](error-formatter-frames-provenance.json) records the
current source, compiler, reference objects, tool output, and execution hashes.
Fresh comparisons pass for 877 runtime units, two startup units, 18 assembly
units, and 113 data units. All 155 tests and 3,588 guarded formatting cases
pass. A separate clean setup and rebuild reproduces all 8,388,608 ROM bytes.

The source checkpoint contains 1,395 matching C functions and 283,396 C bytes.
This change adds two complete functions and 972 bytes, with no new initialized
data or BSS. The fallback inventory retains 166,800 bytes in 206 ranges and
152 unclassified candidate bytes. The complete-function denominator remains
unknown. Whole-ROM equality still includes extracted fallback. This recovery
does not establish complete gameplay or decompilation.

The diagnostic work remains tracked in
[issue #103](https://github.com/frankischilling/robotron64/issues/103).
References and analysis tools remain credited in [CREDITS.md](../CREDITS.md).
