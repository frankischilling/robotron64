# Player and save-state storage

Three source files in `src/game/save_storage/` define complete uninitialized
objects used by the existing matching save routines. They contribute no new
functions or initialized ROM bytes.

| Object | Complete range | BSS bytes |
| --- | --- | ---: |
| Two `GamePlayerState` records | `8009B190..8009CCF8` | 7,016 |
| Configuration and two audio settings | `800AD2F8..800AD318` | 32 |
| `GameSaveImage` | `800AD318..800AE318` | 4,096 |

The player capture routine at `8002FE68` advances the live pointer by `0xDB4`
and stops at `8009CCF8`, proving two complete records. It copies only the
160-byte saved prefix and separately records the level at offset `D6C`.
The clear routine at `80032D00` uses the same stride and end pointer, clearing
only the actor pointer and active word. Uninterpreted fields retain their
existing byte-array views.

The restore routine at `8002FFC8` copies `0xDB4` bytes from each 160-byte
saved-player prefix. This reads beyond the individual saved prefix. The
source and execution checker retain the retail length and source stride;
they do not substitute a 160-byte restore. Fixtures supply the complete
readable source span and check every destination byte.

The option capture and restore routines transfer six configuration words,
followed by the separately stored audio settings. The save-file reader and
writer request sixteen 256-byte blocks and require a 4,096-byte result.
Their checksum covers the first 1,011 words; the checksum itself sits at
offset `FD0`. The named `GameSaveData` view and the 1,024-word union describe
the same complete save image.

The linker places these objects in `NOLOAD` sections and asserts their bases,
sizes and all five global symbols. The session state at `800AD138` already
has source ownership and receives no additional credit here. Other neighboring
objects remain outside these definitions.

`python3 tools/check_save_state_storage.py --mutations` passes 1,356 paired
cases, totaling 2,712 target-function executions. Three byte patterns cover
both current players and all eight capture destinations. Writer cases vary
connection results, early open failures, transfer lengths around 4,096, the
failure-clear flag and all eight selected slots. Independent byte models check
complete player, session, configuration, save, source and template buffers,
their guards, call order, the exact 1,011 checksum word reads, return values and
O32 register preservation. All six source mutations are rejected after the
unmodified controls pass.

The real matching byte-copy routine executes in these cases. File services,
audio/configuration application and menu refresh are recorded ABI stubs that
clobber caller-saved registers. Save-file reading, those service effects,
hardware and full gameplay remain outside the execution proof. The full
source span supplied to restore fixtures is essential; the checker does not
establish that every real saved-slot address has that span available.

Pinned IDO and Ghidra agree on eight types, including all 52 field offsets and
widths, their sizes and alignments. Ghidra has the complete uninitialized player
and save-image blocks, typed audio settings and canonical save prototypes.
Existing labels and code units are preserved. Both splat and spimdisasm
independently reassemble all 868 bytes of the four principal consumers.
Fresh/cached workbench checks, asm-differ and objdiff inspect those complete
retail references against compiled C.

Fresh comparisons pass 904 runtime units, two startup units, eighteen assembly
units and 164 data-only units. A clean extraction and pinned build reproduce
all 8,388,608 retail ROM bytes. All 163 tooling tests pass on Linux; Windows
passes 159 with four platform skips. Current source owns 568,591 BSS bytes.
Matching instruction and initialized-data totals do not change: this work
credits only the 11,144 complete BSS bytes.

The [provenance ledger](save-state-storage-provenance.json) records current
inputs and finite proof limits. Whole-ROM equality still includes extracted
fallback code and assets. The retail ROM remains the behavior reference;
compiler and section workflow references are credited in [CREDITS](../CREDITS.md).
