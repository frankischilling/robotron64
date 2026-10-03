# Framebuffer strip rendering

`func_80040724` draws one 160-by-6-pixel strip from the opposite framebuffer.
The complete procedure occupies `80040724..80040874`, or 336 bytes at ROM
`41324..41474`. Its source is `src/game/model_framebuffer_strip.c`.

The matching caller `func_80040560` invokes it for X values 0 and 160 and Y
values 0 through 234 in steps of six. The strip converts screen coordinates
to four integer corners centered on `(160, 120)`, with X/Y scaled by 100.
All four corners use the depth at `D_800CD3B8`. Texture coordinates are set
through the existing vertex-attribute helper, and the existing opaque-quad
routine advances the vertex cursor by four and emits the triangles.

The image pointer selects `D_80138260[D_8007D914 ^ 1]`. Its byte offset is
`2 * (x - 160) + 2 * (74880 - y * 320)`. This expression preserves the
retail row/address convention, including its edge offsets. The framebuffer
array retains the existing `void *` declaration; the local image pointer
uses 16-bit pixels. No framebuffer extent or new global storage is claimed.

One integer temporary holds the scaled X coordinate, then the scaled Y
coordinate. The four three-word corner arrays are all consumed by the quad
call. No unused stack local or artificial padding is needed. The compiler
uses the ordinary pinned IDO 5.3 game profile: `-O2 -G 0 -non_shared -mips1 -32`.
The full compiled procedure, including its epilogue, matches all 336 retail
bytes. It generates no initialized data or jump table.

Analysis used the existing `robotron64.elf` Ghidra project and MCP, the
retail MIPS listing, and m2c with IDO-preprocessed context. The established
N64 references and tool attribution remain in [CREDITS](../CREDITS.md).
A separately assembled reference object from that listing was linked at the
retail address and compared over all 336 bytes. Objdiff also compared this
reference with the IDO object. Their relocation representations differ;
full linked byte equality is the acceptance check.

`python3 tools/check_framebuffer_strip.py` independently compiles the strip
and all three support source units before executing them and the retail
blocks under Unicorn. All 416 cases pass. They include all 80 caller strip
positions with two depths and both framebuffers, plus screen-edge and signed
coordinate/depth cases with different vertex cursors. The checker compares
four emitted vertices, eleven display-list commands, call arguments, pool
counters, memory guards, and preserved ABI registers. It also checks the
corner coordinates and selected framebuffer address against explicit
formulas. No graphics callee is stubbed. This is CPU-side rendering evidence;
it does not execute the RSP or RDP.

`model-framebuffer-strip-provenance.json` records the independent comparisons
and execution digest. Whole-ROM validation and current-head CI remain
integration requirements; their results are recorded with the integrating PR.
