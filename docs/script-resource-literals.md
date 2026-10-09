# Script and resource literals

Seventeen complete unsigned byte arrays replace 272 initialized fallback
bytes. Script commands own 56 bytes at `80090690..800906C8`; animation paths
and their diagnostic own 52 at `800906D0..80090704`; model/texture loading
literals own 164 at `80090704..800907A8`. Their ROM ranges are `91290..912C8`,
`912D0..91304` and `91304..913A8`. The eight bytes between command and
animation arrays remain unexplained fallback.

Every array retains its terminator, newline and zero padding. Pinned IDO
emits 64, 64 and 176 data bytes; only the natural 56, 52 and 164 bytes are
owned. The excluded 8, 12 and 12 trailing zeros are compiler alignment.
These units emit no code, BSS or relocations. Independent splat and SPIM
reassemblies, complete array offsets, Ghidra references/types and linked
placement establish each range. All callers keep their matching instructions.

Run `make audit-script-resource-literals` for bounded paired execution.
Actual matching command, animation, resource-loader and string helper bodies
construct filenames and update complete guarded objects. Separate oracles
check first-dot extension handling, signed halfword results, capacity
termination and `STRINGS.STR` submission. The resource loader preserves its
retail behavior of clearing a successful texture handle back to -1.

Fatal command-capacity and resource errors stop at the checked fatal call.
Their unsafe or nonreturning continuation receives no execution claim.
The separate animation error fixture lets its diagnostic boundary return
synthetically so the resolver's normal epilogue can be checked.
Returning file-loader, reservation, string-table and script-parser services
use argument-checked ABI boundaries. Resource fixtures contain ten null
animation pointers; the animation resolver runs separately. Bounded indices
and filenames below 100 bytes are exercised. File I/O, script interpretation,
arbitrary aliasing and gameplay remain unverified.

The target USA NRXE ROM supplies all byte and caller evidence. The reproducible
split is [script_resource_literals.yaml](../config/analysis/script_resource_literals.yaml).
Tools and N64 reference projects are credited in [CREDITS.md](../CREDITS.md).

The [acceptance ledger](script-resource-literals-provenance.json) records all
29 stages, 546 paired cases, seventeen data controls and the actual guest
read-bounds control. Complete objects, immutable arrays, stack guards, saved
integer registers and twelve distinct saved FPU words are checked. Whole-ROM
equality still includes extracted fallback.
