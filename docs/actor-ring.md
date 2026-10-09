# Actor ring callback research

`func_80006240` is installed by the matching early effect creator for kind 5.
The complete retail function occupies `80006240..80006654`, ROM
`6E40..7254`: 261 instructions / 1,044 bytes and a 224-byte frame. Ghidra's
raw bytes and disassembly agree with the supplied USA ROM. Unmodified splat
and SPIM output independently reassemble the complete extent. Their twelve
alignment bytes are outside the function and receive no instruction credit.

The readable candidate in `src/game/actor_effects/ring.c` remains excluded.
Pinned IDO produces a 1,020-byte natural function and four zero alignment
bytes, giving 1,024 compiled bytes with a 192-byte frame. The full comparison
has 204 differing words, including the missing tail. It owns no instructions,
initialized data or BSS. The build still supplies this function from fallback.
[#127](https://github.com/frankischilling/robotron64/issues/127) tracks recovery.

## Confirmed CPU behavior

The callback selects graphics mode 1, stores the real vertex allocator's result
in `D_80123AE4`, and returns 1 when that result is -1. Failure precedes actor
and palette access. On success, it reads the actor's full-width state at 0x4C
and palette entry 1, then captures the object selected by the signed halfword
at 0x0C. Object positions at 0x54, 0x58 and 0x5C are subtracted from the camera
position with low-word wrap and an arithmetic right shift by one. The matching
transform writes object offsets 0x60 through 0x68; the matrix submitter clamps
them to -32000..32000 and emits the packed matrix command.

Alpha is the low byte of `max(10, 208 - state * 10)` under retail low-word
arithmetic. Radius is the wrapped value of `state * 150 + 150`. Sixteen angles
from 0 through 3840, spaced by 256, produce two vertices apiece. The first trig
call is cosine and its product is shifted before the sine call. Both use the
matching short-trig helpers and the source-owned sine table. Heights are 100
and 300; RGB and alpha are duplicated for both rings. The remaining vertex
flag and texture bytes retain their previous contents.

The vertex-load word is `040081FF`. Each quad connects indices
`(2i+2)&31`, `(2i+3)&31`, `(2i+1)&31` and `2i`, and emits two paired-triangle
packets with opposite winding. F3DEX byte fields contain twice each vertex
index. The callback submits 32 vertices and returns 0. The global first-vertex
cursor retains the original allocation result while the allocator advances.

## Matching evidence and remaining differences

The [ledger](actor-ring-provenance.json) records complete ranges, hashes,
tools and the bounded execution result. `config/analysis/actor_ring.yaml`
extends the public splat layout for the exact retail function; extracted
output remains in `.local/actor-ring-references/`. Verified headers supply
the 124-byte actor, 120-byte object, 16-byte vertex, four-byte palette entry,
60-byte draw view and 36-byte fixed matrix. Ghidra uses the canonical actor
prototype and now also uses `PaletteColor *` and `RendererDrawState *` in
the actual palette-copy and matrix-submit callees.

The camera globals initially had labels outside Ghidra's mapped memory. The
analysis now has uninitialized, non-executable blocks for the already owned
120-byte camera-state section and 36-byte matrix section. `FrameView` covers
only its established 40-byte record at `800C8BD8`; `FixedMatrix` covers the
36 bytes at `800CD250`. Type application preserves existing data and adds no
ROM bytes or source ownership.

m2c supplied the initial control-flow candidate using verified context.
asm-differ and objdiff compared complete independently verified reference
objects with pinned IDO output. The retail body uses separate color-offset
and position-index counters, spills blue to its frame, and builds the radius
through a multiplication-by-50 sequence followed by multiplication by 3.
These are confirmed instruction observations; they do not establish the
original declaration order or source expression.

The recorded 149 source comparisons cover blue/RGB lifetimes, direct and
captured object pointers, trig product scheduling, SDK-style byte packing,
shared/copied/derived vertex indices, consumed radius expressions, loop forms,
index signedness and declaration order. No form matches. Changing only the
radius algebra often produces identical compiled instructions. No unused
storage, extra ABI arguments, injected instructions or manual padding is used
to make the candidate resemble retail.

## Reproduce the bounded execution check

Use the normal pinned toolchain and a Python environment containing Unicorn
and Capstone:

```sh
make check-actor-ring PYTHON=/root/robotron64-tools/.venv/bin/python
robotron-tools splat split config/analysis/actor_ring.yaml
```

The checker freshly compiles, independently links and matches ten complete
support units / 4,164 instruction bytes plus their owned initialized sections.
Their real mode, palette, allocation, trig, transform and matrix instructions
execute without external ABI stubs. The table is also checked against a
separate mathematical quarter-wave formula.

All 1,800 retail/candidate pairs / 3,600 principal executions pass. Fixtures
combine ten states, five allocator results, two old modes, two valid object
indices, three matrices/position sets and three RGB triples. The independent
model checks all guarded objects, camera/matrix storage, vertices, untouched
vertex fields, commands, globals, returns and call arguments. Every guest
instruction, read and write is bounded. Stack canaries, SP/GP, nine saved
integer registers and twelve distinct F20..F31 words are checked; floating
point values are initialized and observed through actual guest instructions.

Five compiled semantic source changes, twelve saved-FPU corruptions, nine
saved-integer corruptions, GP corruption, two invalid accesses, two null-actor
success probes and one escaped-code probe are rejected: 32 faults total.
Four additional positive executions confirm that allocation failure returns
without reading an invalid actor. Five commercial-input-free model tests
cover command winding/wrap, signed arithmetic, vertex gaps and failure order.

The check uses old modes 1 and 18, frame vertex base zero, matrix cursor 7 and
buffer 1. It covers finite synthetic CPU cases, not arbitrary aliasing or all
caller states. Stack interiors are bounded and ABI-checked rather than compared
byte for byte. RSP/RDP execution, fatal formatting and full gameplay remain
unverified. Passing this check does not establish an instruction match.

The latest full pinned-IDO build matches all 8,388,608 retail bytes with the
recorded target SHA-256. That equality includes fallback. The 176-test suite
passes on Linux and Windows; Windows skips nine Linux-only checks. Matching
source totals remain 1,430 C functions / 314,348 bytes, twenty-nine assembly
functions / 4,372 bytes, 37,843 initialized bytes and 879,157 BSS bytes.

References and tools are credited in [CREDITS.md](../CREDITS.md). The local
GoldenEye 007 SDK graphics definitions guided the index encoding; Robotron's
binary establishes its own behavior. The source, matrices, vertices and
display-list code are reconstructed from that evidence. Commercial ROM data,
generated assembly and binary comparison artifacts remain outside Git.
