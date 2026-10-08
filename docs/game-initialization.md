# Game initialization

The startup literals own 96 initialized bytes at 0x8009224C..0x800922AC
(ROM 0x92E4C..0x92EAC). The level filename table owns 880 BSS bytes at
0x800BA7A8..0x800BAB18. No instruction ownership is added. The complete
1,228-byte candidate for func_8002205C remains excluded: eleven instruction
words still differ, all in stack offsets. Both the function and its literals
are compared in full.

Independent splat and spimdisasm assemblies reproduce every byte of the
complete original body and literal interval. The natural body ends after
the return delay slot at 0x80022524; the next function starts at 0x80022528.
There is no omitted function tail or alignment inside that 1,228-byte claim.
asm-differ and objdiff inspect the complete function. Their similarity
scores do not grant source ownership.

## Data and interfaces

Seven aligned literal objects preserve AM, the two shell resource paths,
LEVELNOS.DAT, robo64, rb, and PALETTES\\GAMEPAL.BMP, with their original
terminators and zero bytes. The local mode initialization copies exactly
three bytes (AM and its terminator). The C candidate retains this observed
store even though the function never reads that local value.

The initializer copies 0x370 bytes from LEVELNOS.DAT into D_800BA7A8.
The matching level lookup returns a pointer from this same table. The next
recorded global starts at 0x800BAB18, exactly 880 bytes after its base.
GameLevelFilenameTable therefore has 220 four-byte pointers, four-byte
alignment and an independently checked 880-byte compiled NOBITS allocation.
Only that complete interval receives BSS ownership.

Retail passes 1 in A0 to the empty func_8003C5CC leaf. An unspecified C
argument list preserves the eight retail bytes while allowing that call.
A named parameter makes pinned IDO insert an argument spill in the return
delay slot. Ghidra records the observed integer argument; it is ignored by
the leaf. The initializer's robo64 pointer is passed as the legacy integer
device argument of func_8004C3AC, as the retail instructions require.

Startup changes byte 15 of D_800933D0 and D_800933E8, the two control-stick
labels. They use writable C arrays in a separate 44-byte interval between
the existing 56-byte text prefix and 84-byte suffix. All 184 text bytes and
their original addresses remain unchanged. Six linker aliases refer to
verified records and pointer fields inside the existing 320-byte label
array, with offset assertions. These corrections add no data ownership.

## Execution and remaining differences

Run make audit-game-initialization with the analysis Python environment.
The audit compares 919 complete initializer pairs, with 1,838 initializer
executions and 4,112 level lookup executions. The first pair reads every
table entry through the real matching lookup; later pairs read two entries.
Cases cover all sixteen low controller-bit combinations, Pak status codes,
handle failures, directory/page thresholds, saved flags, signed arithmetic
limits, signed-short limits, file extents, and 500 seeded mixed inputs.

The real matching resource adapters, memory copy, empty platform leaves
and level lookup execute as MIPS code. Other startup services, file queries,
heap allocation, resource transfer, release and Pak services use O32 boundary
stubs. The audit checks call order and arguments, all fixture bytes, exact
write fields, scalar read widths, code limits, stack guards, SP, GP and saved
integer registers. Nine deliberate code or data mutations must fail.

The current control-page display also passes its 1,008 complete cases,
2,016 executions and three mutation controls with the split text storage.
The layout probe checks the full table, each literal extent, both mutable
label extents, the 40-byte label size and its two pointer field offsets.

Retail allocates a 272-byte frame; the current natural C frame is 64 bytes.
The binary does not explain the unused gaps well enough to reconstruct
their source declarations. The candidate remains excluded while those
eleven stack words differ. Padding declarations are not accepted as
recovery evidence.

Ghidra uses the canonical pointer table type, exact literal and mutable
array types, initializer argument and verified service interfaces. The
older analysis has no mapped block for the level table, and its fallback
blocks mark the mutable labels read-only. Those blocks are preserved.
Inline scripts are disabled by the running MCP server, so the scoped
memory-permission correction remains unavailable. Original instructions
and bounded execution establish the writes despite those decompiler warnings.

The current acceptance ledger is game-initialization-provenance.json.
The original user-supplied USA ROM is the byte and behavior reference.
Tools are Ghidra 12.1.4 and Ghidra MCP, pinned IDO 5.3, splat 0.50.0,
spimdisasm 1.42.4, m2c, asm-differ, objdiff, MIPS binutils, Unicorn,
Capstone and pyelftools. References are in docs/toolchain.md and
docs/reference-study.md. Extracted reference code and bytes remain local.
Full-ROM equality still includes fallback code and assets; source
recovery remains incomplete.
