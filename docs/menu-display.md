# Menu display

`func_8002741C` submits the active page title and walks its linked label records.
The complete retail range is `8002741C..800278AC`, or ROM
`0x2801C..0x284AC`: 1,168 instruction bytes with a 248-byte frame.
Both calls from `func_80022D24` use its no-argument interface.

Selected labels can use alternate text. Flags select on/off suffixes, numeric
suffixes, or an eight-byte choice record indexed by the selection word. The
numeric value 105000 displays `never`; other values display the selection plus
one, with 122 added to each decimal byte. The function checks the string length
again after each changed byte. The selected label can also acquire text flag
0x10 through the retail signed remainder and unsigned division calculation.

The recovered on/off table has two eight-byte records, each containing a text
pointer and the initialized word 68. The second word's meaning is unresolved.
The table, its `off` and `on` strings, and the eight-byte `never` storage own
32 initialized bytes. The two navigation coordinate fields at offsets 0x44
and 0x4C refine the existing 100-byte state; they add no BSS ownership.

The `long` Y local is four bytes under the pinned IDO O32 profile. The source
uses a 100-byte number workspace and reproduces the complete retail frame.
The assembly establishes the workspace address and access pattern, rather than
an independently recoverable original C array declaration. Every declared
local is used; the source adds no dummy stack padding or compiler overrides.

Evidence uses the original ROM, the existing `robotron64.elf` Ghidra analysis,
independently reassembled splat and spimdisasm references, m2c context, asm-differ,
objdiff and a constrained decomp-permuter search. The final public source is
compiled and compared independently after reviewing the search result.

The guarded checker compares 338 cases and 676 executions using retail and
freshly compiled code. Real matched string and number helpers execute; text
services and randomness use recorded O32 stubs that clobber caller-saved
registers. It checks all fifteen draw arguments, trace order, protected memory,
callee-saved registers and stack restoration. Three data mutations are detected.
Cases cover selection, alternate text, flag combinations, numeric and dictionary
suffixes, signed randomness and the zero-divisor short circuit. Numeric cases
exercise the supported formatting range; invalid dictionary indices and
multi-label gameplay rendering remain outside this fixture.

Validation and guarded execution results are recorded in
`menu-display-provenance.json`. Whole-ROM equality still includes extracted
fallback code and assets, so the game remains incompletely decompiled.
