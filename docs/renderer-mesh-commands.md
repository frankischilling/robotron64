# Mesh command interpreter

`func_80045A08` now owns the complete 1,336-byte range at
`0x80045A08..0x80045F40` and its compiler-generated 68-byte switch table at
`0x800951DC..0x80095220`. The corresponding ROM ranges are
`0x46608..0x46B40` and `0x95DDC..0x95E20`. Both former fallback spans are removed.

The input is a signed 16-bit command stream. The interpreter returns its vertex
load cursor. Vertex copying advances a separate cursor and executes the existing
matched color and normal copy routines. The used pointer to the copy cursor is
a matching C representation; the binary does not prove the original declaration.

| Opcode | Behavior |
| --- | --- |
| `0x7000` | Return the load cursor. |
| `0x7001` | Copy a signed vertex range, using normals when lighting is enabled. |
| `0x7002` | Emit vertex loads in batches of at most 32; advance the load cursor. |
| `0x7003` | Emit a triangle and increment triangle and total polygon counts. |
| `0x7004` | Emit a quad and increment quad and total polygon counts. |
| `0x7010` | Mask the color index to eight bits and update color or lighting state. |

Other opcodes consume one stream element. Signed nonpositive copy counts still
advance the copy cursor; nonpositive load counts still emit their encoded command.
The first triangle index also selects the SDK triangle rotation, as in retail.
Special lit colors 1 and 186 select a 16-byte light record. Other lit colors emit
two full RGBA words and two words containing halved RGB. Repeated lit colors use
the cached index. Integer wrapping, index truncation and signed shifts are retained.

Acceptance checks cover every live instruction and all 17 table entries under
the pinned IDO 5.3 game profile. Eight text alignment bytes and twelve table
alignment bytes are checked as zero before trimming; they receive no recovery
credit. Independent splat and spimdisasm output is reassembled and linked at the
retail addresses, then compared with the ROM. asm-differ and objdiff inspect the
fresh C object, and m2c uses the current public header context.

`make check-mesh-commands` executes 1,080 bounded fixtures against retail and
freshly compiled C, with both real vertex-copy functions (924 bytes) and no ABI
stubs. It checks packets, vertex bytes, globals, return values, call arguments,
memory bounds, stack and saved registers. Seven mutations cover the switch bound,
copy cursor, triangle rotation, RGB halving, returned cursor, table target and a
real vertex store. These fixtures do not establish arbitrary stream validity or
actual RSP rendering.

Ghidra's original 156-byte function body ended at the computed jump. Retail
instructions, table targets and memory ranges justified extending it to the full
1,336 bytes. The complete switch and the 24-byte mesh prefix are reconciled with
the public headers; the two copy callees use their verified integer arguments
and normal pointer. The evidence ledger records current comparisons and checks.

References used: the local libreultra `include/2.0I/PR/gbi.h` vertex-load and
triangle command macros, Ghidra with standalone Ghidra MCP, splat, spimdisasm,
m2c, asm-differ, objdiff, decomp-permuter with stack checks, MIPS binutils,
Unicorn, Capstone and pyelftools. The Robotron 64 ROM determines game behavior.
