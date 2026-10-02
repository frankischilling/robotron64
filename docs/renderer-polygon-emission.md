# Fixed-alpha quads and polygon command recovery

This document and its provenance ledger record the PR 64 checkpoint at
`ac2b0f3`. The mesh submitter now matches, and the command-stream candidate
has changed. See [mesh and resource recovery](renderer-mesh-resources.md)
for the current comparisons; the candidate table below is historical.

Two complete quad procedures now have matching C in
`src/game/renderer_primitives/`:

| Procedure | Complete RAM range | Instruction bytes | Alpha |
| --- | --- | ---: | ---: |
| `func_80044F60` | `80044F60..80045124` | 452 | 255 |
| `func_80045214` | `80045214..800453D8` | 452 | 160 |

Both capture the vertex cursor and check `base - frameBase + 3` against
10,000. They retain the `prims.c` diagnostics at lines `0x34E` and `0x38D`,
increment the quad and total polygon counters, and copy four signed word
positions into consecutive hardware vertices. The narrowing to signed
halfwords follows the target. Only alpha is set; existing RGB and texture
coordinates remain in place.

Each procedure emits the four-vertex load `0400103F`, followed by two
separate triangle packets with words `BF000000/00000204` and
`BF000000/00060004`. The global vertex cursor then advances by four. The
already matching camera-square caller uses the alpha-160 path.

The reconstructed alpha and command-word locals are all used. Their
declaration and use order reproduce the target's 56-byte stack frame and
complete register allocation. The original local names are unknown. No
unused local, enlarged storage type, empty conditional, inline assembly,
or instruction patch is needed.

## Diagnostic ownership

Two data-only source units define five complete diagnostic pairs, adding
200 initialized bytes and no BSS:

| Source unit | Complete RAM range | Bytes |
| --- | --- | ---: |
| Expanded quad diagnostics | `80095088..800950B0` | 40 |
| Fixed-alpha quads, line, and mesh diagnostics | `80095100..800951A0` | 160 |

Each pair consists of the surviving vertex-limit format and `prims.c`
filename. The compiler supplies the format's alignment bytes. All symbol
offsets, raw section sizes, linked addresses, and complete contents are
checked independently. The existing textured-submission messages between
these ranges retain their separate ownership. Defining messages referenced
by an excluded procedure does not give that procedure instruction credit.

## Complete excluded candidates

Four additional procedures have complete C candidates. They remain outside
the matching manifest and ROM rules:

| Candidate | Retail instruction bytes | Compiled instruction bytes | Differing words |
| --- | ---: | ---: | ---: |
| Expanded quad `func_800447D0` | 840 | 840 | 167 |
| Diagnostic line `func_800453D8` | 316 | 316 | 57 |
| Mesh submission `func_80045534` | 1,024 | 1,024 | 251 |
| Mesh commands `func_80045A08` | 1,336 | 1,376 | 332 |

The expanded quad consumes four packed texture-corner selectors, computes
the X and Z centroid with signed division by four, and conditionally
translates all four positions using `centroid * 4 * strength / 256`. Y
remains unchanged. It retains current alpha and the paired-triangle packet.
The supplied positions, corner table, and selector byte have the existing
verified layouts. Remaining differences include corner-loop scheduling,
centroid operand allocation, and command-pointer use.

The line procedure checks `base - frameBase + 1`, preserves both supplied
XY endpoints at Z ten, sets yellow with full alpha, advances the vertex
cursor by two, and emits a two-vertex load and `B5000000/00000200` line
packet. It does not increment the polygon counters. The source keeps its
command writes in separate packets. A private search output that moved a
write into the wrong packet was rejected.

Mesh submission first copies all supplied positions and emits their vertex
load. For each 36-byte polygon it captures four signed vertex indices. The
lighting path sets material state and writes four indexed normals to slots
zero through three; the other path sets texture state and uses each color
word's high byte to look up and apply its palette color at the captured
vertex index. A three-vertex polygon emits the target's rotated triangle
encoding; other counts take the quad path. The global cursor advances by
the mesh vertex count after all polygons.

The command-stream procedure reads signed halfwords until opcode `7000`
returns the load cursor. The actual seventeen-entry retail dispatch table
establishes these handlers:

| Opcode | Operation |
| --- | --- |
| `7000` | Return the load cursor |
| `7001` | Copy a vertex range with colors or normals |
| `7002` | Load vertices, splitting counts above 32 into packets |
| `7003` | Count and emit a triangle |
| `7004` | Count and emit a quad |
| `7010` | Select lighting or update color words |

The copy and load cursors advance independently. Large loads subtract 32
vertices per packet, advance the source by 512 bytes, and advance the
encoded destination by 64. Counts at most 32 retain the target's lack of a
positive-count check. Unknown opcodes consume one halfword and continue;
the source adds no stream-length or terminator validation.

With lighting enabled, color indices one and 186 select complete light
records. Other changed indices write the selected color twice, halve the
RGB words, and write that reduced color twice. A cached-index match emits
nothing. Without lighting, the handler updates RGB words only. The
candidate's generated dispatch table is not claimed as recovered data;
its instructions and table still need a complete match.

## Verification and references

The pinned IDO 5.3 game profile is `-O2 -G 0 -non_shared -mips1 -32`.
The PR 64 complete comparisons and source/header/compiler identities are
recorded in [the provenance ledger](renderer-polygon-emission-provenance.json).
Whole-ROM equality still uses extracted fallback and does not establish
source completion. Further polygon and mesh work remains tracked in
[issue #41](https://github.com/frankischilling/robotron64/issues/41).

The local libreultra `include/2.0I/PR/gbi.h` and Super Mario 64
`include/PR/gbi.h` corroborate hardware vertex fields, vertex-load packing,
triangle rotation, paired-triangle commands, and line commands. Robotron's
target establishes the alpha values, packet order, bounds, counters, opcode
table, and color behavior. Their revisions and all thirteen requested
reference projects remain recorded in [CREDITS.md](../CREDITS.md).
