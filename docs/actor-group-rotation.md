# Actor-group rotation

`src/game/actor_groups/rotate.c` owns both complete planar rotation helpers:
`func_8000E720` at `[0x8000E720, 0x8000E7E0)` (192 bytes) and
`func_8000E7E0` at `[0x8000E7E0, 0x8000E894)` (180 bytes). Pinned IDO 5.3
produces all 372 retail instruction bytes, including both 56-byte frames.
Neither helper generates initialized data or BSS.

The first helper changes the angle to `1024 - angle`; both then mask it to
twelve bits. They call the existing fixed cosine and sine helpers, compute
both coordinates before writing either output, and divide signed products
by 4,096 toward zero. Input and output can overlap. Neither helper writes Z.
The matching group constructor and the excluded path callback use the second
helper to rotate endpoint pairs in place.

The sine-negation assignment is part of the first coordinate expression.
Its result is reused for the second coordinate. This preserves the compiler's
multiply operand order without forced registers, padding locals, instruction
patches or an expression with a discarded constant operand.

Ghidra MCP decompilation and disassembly establish both complete boundaries,
the three-argument interface, memory ordering and signed arithmetic. A private
spimdisasm reference is independently reassembled and checked against retail
bytes. A two-worker decomp-permuter search with stack differences enabled
identified the expression constraint; the final source was simplified and
then compared independently across both complete procedures.

`tools/check_actor_group_path.py` freshly compiles the rotation helpers,
seven arithmetic support units and two numerical tables before executing
8,512 rotation cases and 1,008 path cases. Rotation covers every masked angle,
wrapped angles, signed coordinate extremes and overlapping buffers. The
checker also validates all 1,024 short-sine samples against their mathematical
generator and checks each rotation against independent arithmetic and guarded
buffer expectations. The path routine remains an excluded candidate; its execution agreement contributes
no matching source credit. Signed overflow cases describe the pinned IDO and
retail behavior, with no claim of portable ISO C arithmetic or complete gameplay.

The [provenance ledger](actor-group-rotation-provenance.json) records the final
complete comparisons, object and input hashes, execution coverage and clean
build. [Issue #43](https://github.com/frankischilling/robotron64/issues/43) tracks
the remaining path, bonus-child and actor scheduling work. References and
software are listed in [CREDITS.md](../CREDITS.md).
