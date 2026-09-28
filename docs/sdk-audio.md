# SDK audio-adjacent helpers

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

The retail block at `0x800655DC..0x80065784` contains four libultra task/video
helpers followed by two libaudio heap helpers. Their behavior, callers and
instruction shapes identify the routines as the SDK functions normally known
as `osSpTaskStartGo`, `osViSwapBuffer`, `osViGetCurrentFramebuffer`,
`osViGetNextFramebuffer`, `alHeapInit` and `alHeapDBAlloc`.

The recovered source remains address-named so it can fit the current symbol
map without claiming broader SDK symbol coverage.

| Function | Retail range | Bytes | Recovered behavior |
| --- | --- | ---: | --- |
| `func_800655DC` | `0x800655DC..0x8006561C` | 64 | Wait for the SP device to become idle, then write status `0x125`. The task argument is homed by IDO but otherwise unused. |
| `func_80065620` | `0x80065620..0x80065670` | 80 | Disable interrupts, set the next VI framebuffer, set state bit `0x10`, then restore interrupts. |
| `func_80065670` | `0x80065670..0x800656B0` | 64 | Return the current VI framebuffer while interrupts are disabled. |
| `func_800656B0` | `0x800656B0..0x800656F0` | 64 | Return the next VI framebuffer while interrupts are disabled. |
| `func_800656F0` | `0x800656F0..0x80065724` | 52 | Initialize a 16-byte-aligned `AudioHeap`. |
| `func_80065730` | `0x80065730..0x80065784` | 84 | Allocate `count * size` bytes rounded up to 16 bytes, returning null when the heap would overflow. |

The word at `0x8006561C` is alignment between the SP helper and the VI object,
not part of `func_800655DC`. Heap init is followed by three zero words at
`0x80065724..0x80065730`; its standalone object emits those 12 alignment bytes
naturally. The allocation object likewise emits three zero words after the
function at `0x80065784..0x80065790`. No C declarations are used to manufacture
these gaps.

## Compiler profiles

The block is not built with one uniform profile.

- `func_800655DC` is insensitive across the tested set: IDO 5.3 and 7.1 match
  with O1, O2 and O3 under both MIPS I and MIPS II. Both the game profile
  (`-O2 -G 0 -non_shared -mips1 -32`) and O1/MIPS II are exact.
- The three VI helpers in `src/libultra/audio_vi.c` match all 208 retail bytes
  with IDO 5.3 and 7.1 at `-O1 -G 0 -non_shared -mips2 -32`. O2/O3 and the
  tested MIPS I builds do not match.
- `func_800656F0` plus its 12 alignment bytes matches all 64 bytes with O2 and
  O3 in both compiler versions and both ISA modes. O1 does not match. The heap
  alignment expression requires a signed 32-bit cast of the base address to
  reproduce the retail register allocation.
- `func_80065730` plus its following 12 alignment bytes matches all 96 bytes
  with IDO 5.3 at O2/MIPS II (and also O3/MIPS II). IDO 5.3 O2/MIPS I differs
  by two words, while IDO 7.1 O2/O3 MIPS II differs by eight. O1 does not
  match. Of the tested ordinary build profiles, this routine therefore gives
  the strongest evidence for IDO 5.3 O2/MIPS II.

The existing `AudioHeap` declaration in `include/audio_runtime.h` is supported
directly by the retail field accesses: base at `+0x00`, current at `+0x04`,
length at `+0x08`, and count at `+0x0C`. The allocator's first two parameters
are the unused file/line positions of the SDK debug-allocation interface. Both
signed and unsigned declarations for the final two integer parameters produce
the same matching 5.3 O2/MIPS II code, so the retail function does not by
itself require changing the project's current unsigned declaration.

Comparison reports are stored under `build/sdk-options/`. The key exact reports
are `audio_sp-5.3-O1-mips2`, `audio_vi-5.3-O1-mips2`,
`audio_heap_init-5.3-O2-mips2`, and `audio_heap_alloc-5.3-O2-mips2`.
