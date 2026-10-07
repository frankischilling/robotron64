# Renderer peak metrics storage

The peak metrics array now has a complete C definition: 201 twenty-byte
records, or 4,020 BSS bytes, at `0x8013DC30..0x8013EBE4`. Its reset and writer
were already matching C; this change adds no instructions or initialized ROM
bytes. [The evidence ledger](renderer-peak-metrics-storage-provenance.json)
records current inputs, natural object sizes, independent references and the
complete checkpoint checks.

## Layout and extent

| Field | Offset | Size | Update input |
| --- | ---: | ---: | --- |
| `primitives` | 0 | 4 | `D_80123B18` |
| `vertices` | 4 | 4 | `D_80126B84 - D_80123B20` |
| `renderBufferBytes` | 8 | 4 | `D_8013D9C0 - D_8013D9C4` |
| `framesPerSecond` | 12 | 4 | `D_80138250` |
| `matrices` | 16 | 4 | `D_8007D6A8` |

All five fields use signed maximum comparisons. Equality causes no store.
The writer updates render bytes, FPS, primitives, matrices and vertices in
that order. The subtraction inputs retain the retail 32-bit `SUBU` behavior.

The complete 44-byte reset at `0x8004CCA4..0x8004CCD0` passes the exact
`0xFB4` byte count to the real memory-fill routine. The complete 228-byte
writer at `0x8004CCD0..0x8004CDB4` establishes the twenty-byte stride and all
five fields. Together these establish 201 complete cleared records. The
separate, already recovered heap pointer at `0x8013EBF0` also rules out a
202-record array at this address. This is more than a distance between names.

Pinned IDO naturally emits a 4,020-byte array symbol in a 4,032-byte raw BSS
section. Only the twelve bytes of trailing compiler alignment are trimmed
from the input object. The twelve retail addresses `0x8013EBE4..0x8013EBF0`
remain outside source ownership. No enlarged record, extra record, artificial
padding declaration or forced symbol size is used. The final linked symbol
and `NOLOAD` section both retain the complete 4,020-byte extent.

Ghidra has the exact uninitialized array block and `RendererPeakMetrics[201]`
type, plus the independent four-byte heap pointer. The canonical header and
Ghidra agree with all twelve IDO size, alignment, field-offset and field-width
probes. Both procedure prototypes, the real fill prototype and boundary
comments are saved in the existing `robotron64.elf` project.

## Retail boundary bug

The writer clamps negative indices to zero and indices above 201 to 201.
Index 201 is beyond the cleared array. Its five field addresses are:

| Field | Address | Relationship to recovered storage |
| --- | --- | --- |
| `primitives` | `0x8013EBE4` | First word after the array |
| `vertices` | `0x8013EBE8` | Following unclaimed word |
| `renderBufferBytes` | `0x8013EBEC` | Following unclaimed word |
| `framesPerSecond` | `0x8013EBF0` | Aliases `D_8013EBF0`, the heap pointer |
| `matrices` | `0x8013EBF4` | Word after the heap pointer |

The source retains the retail upper limit. It neither fixes the off-by-one
access nor treats index 201 as another array record. Its possible writes to
the heap pointer are conditional on the same signed comparison as retail.

## Verification

Splat and spimdisasm independently reassemble both complete procedures with
their natural 44- and 228-byte sizes. Fresh and cached workbench comparisons,
asm-differ and objdiff agree with retail. Source context is generated with
the pinned IDO profile and used for m2c analysis. Extracted assembly, context,
objects and ROM bytes remain in ignored research directories. Tool and
reference attribution is in [CREDITS](../CREDITS.md).

`make audit-renderer-peak-metrics-storage` compiles the entire storage object,
both consumers and the full matching memory-helper translation unit before
executing the relevant real instructions. The audit passes 1,210 paired
cases / 2,420 principal target executions. It covers all 201 valid records,
all 32 update masks at selected boundary/control indices, equality, signed
extremes and subtraction wraparound. Three reset patterns verify every byte
of the array, all neighbors and the heap pointer.

The guard checks exact ordered reads and writes, real fill-call arguments,
code/read/write bounds, complete stack contents and O32 preserved integer
registers. The real fill loop's `+1/+2/+3/+0` store order, including its delay
slot, is checked explicitly. No service is stubbed on either tested path.

The 145 index-201 cases use a separate twenty-byte boundary fixture. Both
images first fail the array-only read guard, giving 290 rejected controls;
the separate fixture then verifies every retail access and the heap alias.
Seven isolated source mutations are rejected after positive controls pass:
short/long clears, a changed lower clamp, a repaired upper clamp, unsigned
FPS comparison, an equality store and a swapped destination field.

Fresh acceptance passes all 906 runtime, two startup, eighteen assembly and
180 data-only comparison units. A clean extraction and pinned IDO build
reproduce all 8,388,608 retail ROM bytes. Linux passes all 163 tooling tests;
Windows passes 159 and skips four Linux-only checks. Current source totals
are 1,424 matching C functions / 308,796 instruction bytes, twenty-nine
assembly functions / 4,372 bytes, 36,351 initialized bytes and 874,313 BSS
bytes.

These checks establish the storage and its reset/update behavior. They do
not execute renderer commands, hardware, heap traversal after corruption or
whole gameplay. Whole-ROM equality still includes fallback code and assets;
141,388 declared fallback CPU bytes remain in 186 spans, alongside 164
unclassified bytes. Full matching-source decompilation remains unfinished.
