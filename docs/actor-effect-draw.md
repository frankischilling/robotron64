# Actor effect drawing and object storage

`func_80005560` is reconstructed as complete C at
`80005560..80005814`: 692 instruction bytes. A fresh pinned IDO 5.3
comparison matches every instruction, including the 136-byte stack frame,
four display-list packets, both drawing branches, and the zero return value.
The function generates no initialized data or BSS.

The callback selects the first of 31 configurations whose resource pointer
matches the actor. A missing match uses entry zero. Its frame, renderer flag,
and scale interpolate from the actor's signed field at offset `4C`; division
by 256 truncates toward zero. The scale then uses an arithmetic right shift
by four. All three object scale fields receive that value.

The position comes from the object's integer position fields, relative to
the camera, with the configured height multiplied by twelve added to Y.
Arithmetic right shifts halve the coordinates. The shared camera matrix
produces the object's projected position. A nonbillboard configuration uses
a local identity matrix and the first texture-square renderer; a billboard
uses the camera matrix and the second renderer. The texture-index lookup
uses the resource's signed bitmap handle and a 1,024-byte frame offset.

The existing 40-byte configuration, 88-byte resource, 120-byte object,
60-byte renderer-state view, and 36-byte matrix layouts provide typed access.
The callback's integer return is required by
the retail object dispatcher, as documented in the
[callback audit](palette-fade-and-callback-returns.md). The early one-argument
and dispatcher two-argument views retain the existing N64 ABI assumption;
portable ISO C compatibility of those views is not established.

## Object storage

Two complete runtime arrays now have C definitions and NOLOAD placements:

| Symbol | Runtime range | Type | BSS bytes |
| --- | --- | --- | ---: |
| `D_800BF918` | `800BF918..800C85B8` | `ObjectRecord[300]` | 36,000 |
| `D_800C86C0` | `800C86C0..800C8B70` | `int[300]` | 1,200 |

The matching allocator at `8003A2F8` rejects indices at or above 300, scans
four-byte slot values, and addresses records with a 120-byte stride. The
matching reset at `8003A460` clears exactly 120 bytes for each record. The
matching slot reset at `80039358` writes 300 integers, stopping exactly at
`800C8B70`. The retail object loop also visits 300 records. These independent
uses establish the complete capacities and boundaries. Unknown fields in
the existing partial object layout remain named as unknown fields.

The record pool ends at the separate renderer mode variable. The gap from
`800C85B8` to `800C86C0` and the following globals at `800C8B70` remain outside
this ownership. Neither array contains initialized ROM bytes. Linker size
assertions, independent data-only comparisons, and ELF symbol-section checks
verify both definitions without counting absolute aliases as source storage.

The retail ROM and Ghidra instructions are the behavior and matching
references. The build follows the pinned IDO and independent object
comparison workflow studied in the locally available
[SM64 reference](https://github.com/n64decomp/sm64), credited in
[CREDITS.md](../CREDITS.md). The local
[Majora's Mask specification](https://github.com/zeldaret/mm/blob/main/spec/spec)
provides the NOLOAD placement convention. No reference implementation was copied.

## Execution checks

After installing the optional analysis dependencies, run
`python3 tools/check_actor_effect_draw.py`. It freshly compiles the callback,
the fixed-matrix transform and identity helpers, and the complete configuration
table. Its 1,372 cases compare compiled and retail MIPS execution, with an
independent arithmetic and memory oracle. Cases cover actual retail pointers,
synthetic copies reaching all 31 configuration slots, unknown resources,
duplicate first matches, negative phases, signed bitmap handles, both camera
matrices, and nonzero billboard flags.

The checks retain guarded object/command buffers, actor and resource contents,
the table, camera, palette, matrix, and texture records. They verify all four
display-list packets, exact call order and arguments, projected positions,
three scale stores, the zero result, stack restoration, and saved registers.
The six renderer callees use recorded ABI stubs; texture contents, actual
renderer output and full-game drawing are outside this execution proof.

The complete 8,388,608-byte ROM matches SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
All 850 runtime, two startup, 18 assembly, and 91 data-only comparisons pass,
along with 152 tooling tests. This checkpoint owns 1,367 C functions totaling
260,048 bytes and 503,375 BSS bytes. The remaining fallback contains 190,148
bytes in 217 ranges.

Final build and comparison results are recorded in
[the provenance ledger](actor-effect-draw-provenance.json). Whole-ROM equality
still includes extracted fallback ranges and does not establish complete
decompilation.
