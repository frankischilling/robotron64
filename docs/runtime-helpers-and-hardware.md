# Runtime helpers and hardware interfaces

The functions in this batch are complete target procedures. Each C unit is
compiled with the pinned IDO 5.3 toolchain and compared at its original address.
The SDK hardware procedures are assembled separately and counted as assembly.
No extracted instructions are included in these source objects.

## Game behavior

The early pool initializer sets the pool and allocation flags and clears two
72-byte arrays. The coordinate helper reads both input values before storing
`(value - 100) * 320`; the reads and stores retain their order when the pointers
alias. The player counter reset initializes fourteen signed short counters to
minus one and fourteen timers to zero, and sets state word six to minus one.
The selection helper publishes the selected value and marks its pair active.

The scene index helper inserts gaps after indexes 2, 5, and 10 and adds 97 to
the result. Its name describes the mapping without assuming a text encoding.
The sign helper returns minus one, zero, or one. The sine wrapper calls the
recovered SDK trigonometric routine. The frame interval setter stores the
absolute interval using the target's signed arithmetic. Frame slot allocation
clears two state words and marks the first free entry in a twenty-byte pool.
An exhausted pool leaves the cleared index at zero.

The renderer flag setter stores the integer rendering value at `0x80123AE8`.
Digit extraction writes numeric digits, least significant first, with no ASCII
conversion or terminator. It treats negative inputs as zero and always writes
at least one digit. The three audio tests wrap the existing handle count
queries. The conditional wrapper retains the retail false path, which falls
through with zero in the return register. Its original return declaration is
not established; an explicit C return changes the compiled procedure. The empty
audio command retains the target's unused argument home-slot store.

## SDK behavior

The vertical video scale setter updates the pending context's vertical factor
and marks state bit four while interrupts are disabled. The thread helper marks
the current thread waiting and passes the ready queue to the native yield
routine. Global interrupt mask updates also disable interrupts; the reset
routine preserves bits `0x401`.

Extended PI word access waits until both busy bits clear, combines the handle's
base address with the requested offset, and accesses the uncached word. The
handle declaration describes only its confirmed sixteen-byte prefix. Read and
write remain separate compiler units because their retail placement has an
alignment gap. These C units use the verified `sdk-o1-mips2` profile. The PI queue
getter returns null until the PI manager is active, then its command queue.

Native assembly recovers status and floating point control register access,
whole data-cache invalidation, the debugger's TLB mapping, and single precision
square root. Cache invalidation covers 8 KiB in sixteen-byte lines. The debugger
mapping saves and restores EntryHi and writes TLB slot 31. The procedure sizes
exclude zero alignment. These routines remain assembly in the progress report.

Thread dispatch preserves the native 64-bit register loads, interrupt mask
combination, optional floating point context restoration, MI mask table lookup,
and exception return. Its queue insertion and removal helpers keep the retail
ordering and delay slots. The 380-byte dispatch procedure ends at its `eret`.
The adjacent eight-byte cleanup trampoline is a separate procedure, referenced
by the recovered thread creator as the thread's return address. It calls thread
destruction with a null argument to destroy the running thread. The combined
source unit has 476 live bytes and four zero alignment bytes; all 480 linked
bytes match. The assembler's `mips3` and `gp=64` settings preserve native `ld`
instructions inside the 32-bit object.

## Evidence and references

`config/functions.json` records every accepted procedure's address and complete
size. `tools/compare_runtime.py` and `tools/compare_assembly.py` independently
reproduce the linked instruction comparisons. The normal build records object,
source, header, and toolchain identities; `make progress` requires those records
and a byte-for-byte matching ROM.

The [input ledger](runtime-helpers-and-hardware-provenance.json) retains the
identities for these 27 source units and 33 complete procedures. The checked
checkpoint passes all 114 tooling tests, 665 independent runtime units, both
startup units, and all twelve assembly units. The complete 8,388,608-byte ROM
matches SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The ledger is historical evidence; current progress requires reproducing the
comparisons from the current checkout.

The local [libreultra](https://github.com/n64decomp/libreultra) checkout at the
revision recorded in [CREDITS.md](../CREDITS.md) supplies hardware and native SDK
references, including `src/os/setsr.s`, `src/os/getsr.s`, and `src/gu/sqrtf.s`.
Robotron's own instructions determine the accepted register choices, delay
slots, procedure extents, and compiler profiles. The project credits all
thirteen requested reference repositories and their local revisions.
