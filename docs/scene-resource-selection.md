# Scene resource selection

`func_80021C3C` has a complete C candidate in
`src/game/scene_arrivals/select.c`. Retail and compiled functions are both
1,032 bytes, but 40 instruction words still differ. The generated six-entry
switch table matches all 24 retail bytes. The function and table remain
excluded from the ROM link and source-ownership manifests.

Retail instructions occupy `0x80021C3C..0x80022044` (ROM
`0x2283C..0x22C44`). Twelve zero alignment bytes precede the next function at
`0x80022050`; they are recorded separately from the natural function size.
The dispatch table occupies `0x80091A08..0x80091A20` (ROM
`0x92608..0x92620`). Independent splat and spimdisasm assemblies reproduce
both complete ranges, including the verified instruction alignment. The
six table entries target the trigger-zero, default, trigger-two, default,
default and default blocks, respectively.

## Types and behavior

Selection reads the complete first word of `D_800B8F78` and tests bit 31.
`SceneResourceWord00` provides both that word and the previously established
byte/short fields without changing the 416-byte `SceneResourceState` layout.
A signed-byte load alone would produce the same sign test on big-endian MIPS,
but would not reproduce the observed four-byte memory access.

The 104-byte `ActorResource68Internal` record now names the animation pointer
at offset `0x28`. Selection follows it to the signed short at animation
offset `0xA`, then calls the matching model-capacity accessor. Only this
pointer is established here; the surrounding opaque fields retain their
verified extents. Existing fields at offsets `0x60` and `0x64` remain intact.
The canonical CParser types were imported into the existing Ghidra
`robotron64.elf` program. Readback and 102 compiled size, offset, field-width
and alignment probes agree. Some resource globals are outside that older
program's mapped segments; this audit did not create memory blocks for them.

The function zeros a 360-word local table with ten rows of 36 words. It reads
active arrivals in categories 0, 1 and 3. Trigger zero takes the larger of the
old value and signed count plus delay; trigger two takes the larger of the old
value and signed delay. Every other trigger adds the signed count. Resource
indices are unsigned bytes and can address later rows through the original
row calculation; the candidate preserves that observed aliasing.

Bit 31 of the scene-status word triples row-three entries zero through three
into entries four through seven. The two captured global multipliers add
scaled row-zero entries 17..20 into 21..24 and entries 9..12 into 13..16.
Nonzero entries then select from the 36 records at `D_800AF1F0`, eight at
`D_800ACE58`, and sixteen at `D_8009F560`, in that order. A resource qualifies
when its signed model capacity, divided by two toward zero, is no greater
than its accumulated count.

The destination indirection is unusual: the local selection pointer contains
the address of the first argument's stack spill. The matching helper writes
the resource's second byte into that spill when enabled is nonzero. It leaves
the caller's 400-byte output buffer unchanged. The caller at `0x80021B08`,
the helper's complete instructions and guarded execution confirm this
behavior; the candidate retains it.

## Reproducible audit

Run `make audit-scene-resource-selection` with the local retail ROM, pinned
IDO toolchain and analysis dependencies. `tools/check_scene_resource_selection.py`
freshly compiles the complete candidate, generated dispatch, three matching
support units and source-owned scene storage. It compares natural ELF
function sizes and rejects live allocated content beyond the declared
candidate sections. Linked references use the verified symbol-layout
snapshot; source, header, configuration and artifact hashes are rechecked
before the report is written.

The audit passes 1,683 paired retail/C executions: 683 systematic cases and
1,000 deterministic mixed cases. Independent byte oracles check all 360
accumulation words before and after transforms, ordered helper calls, signed
model indices and capacities, full-word status access, captured multiplier
reads, argument spills, all resource pools, output and scene buffers,
canaries, and preserved integer and floating-point registers. All callees
execute freshly matched C. Seventeen source or instruction mutations are
rejected, including a forced repeated multiplier read and ABI corruption.

Cases cover all 256 triggers, signed arithmetic boundaries, negative and
zero arrival counts, scene counts through 273, enabled values, the final
resource in each pool, and resource indices that alias later rows. Accumulation
addresses stay inside the complete 360-word table and arrival reads stay
inside the 3,348-byte scene record. Out-of-bounds inputs, gameplay and display
hardware are outside this audit.

`python3 tools/compare_runtime.py --candidates` includes the complete compound
code/table comparison and exits nonzero while this or another excluded
candidate differs. Neither behavioral agreement nor the matching dispatch
table adds recovered code or data credit. Whole-ROM equality still includes
fallback and does not establish full source completion.

The [verification ledger](scene-resource-selection-provenance.json) records
independent references, type evidence, guarded execution and fresh repository
validation. Research used the installed [splat](https://github.com/ethteck/splat),
[spimdisasm](https://github.com/Decompollaborate/spimdisasm),
[m2c](https://github.com/matt-kempster/m2c),
[asm-differ](https://github.com/simonlindholm/asm-differ),
[objdiff](https://github.com/encounter/objdiff) and
[decomp-permuter](https://github.com/simonlindholm/decomp-permuter).
The original USA NRXE revision-zero ROM remains the behavioral and byte
reference. Tool scores are research evidence only.
