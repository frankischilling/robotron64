# Script and resource storage

Three source units define the complete file registry, string-offset table and
scene-file boundaries used by the existing matching services. They add no new
instructions or initialized ROM bytes.

| Object | Complete range (end exclusive) | BSS bytes |
| --- | --- | ---: |
| 100 `ScriptedFile` records | `80097650..8009A850` | 12,800 |
| 1,000 signed string offsets and count | `800A3AD8..800A42AA` | 2,002 |
| 80 `SceneFileBoundary` records and count | `800A42B0..800A4534` | 644 |

The registry reset and registration scans establish all 100 records with a
128-byte stride. Registered and loaded use the two high bits of the flag word;
the size, data pointer, 14-byte basename and 102-byte path retain the canonical
header offsets. Registration sets the registered bit while preserving the
loaded bit and other fields. It also retains the retail diagnostic for existing
registered basenames that compare unequal, including case folding.

The string reset writes all 1,000 halfwords. Lookup sign-extends each offset
before adding it to the external string pool. The halfword count immediately
follows the table. The string pool's complete allocation remains unproved and
has no new ownership here.

The scene command checks the existing count against 80 and writes an eight-byte
level/name pair. The selector uses a strict upper level boundary and submits
the preceding entry. Its counter follows the complete array. The recovered
source preserves unchecked inputs and the original diagnostic behavior.

Validation and complete-range evidence are recorded in
[script-resource-storage-provenance.json](script-resource-storage-provenance.json).
The checker executes retail and independently compiled service bodies with
guarded complete arrays, actual string helpers, recorded service boundaries and
independent state/call oracles. Platform I/O, script interpretation and complete
gameplay remain outside this bounded audit.

The audit passes 630 paired cases, or 1,260 target executions, and rejects
seven isolated source mutations after positive controls. It covers every scene
append slot, registry allocation through its last slot and exhaustion, empty and
sparse registry searches, all registered/loaded flag combinations, full resets,
and signed string offsets. Each run compares complete arrays, reserved bytes,
adjacent gaps and guards, return values, service arguments/order and saved O32
registers including GP, RA and SP. Service stubs clobber caller-saved integers.

Pinned IDO and Ghidra agree on twenty size, alignment and ordinary-field checks
across `ScriptedFile`, `ScriptedFileFlags` and `SceneFileBoundary`. Seven complete
retail ranges totaling 1,372 instruction bytes reassemble through both splat and
spimdisasm; their eleven procedure extents remain distinct. Ghidra's mapped
consumer bytes agree with retail. Six complete source units also pass fresh and
cached workbench comparisons, with independent reference objects for objdiff
and asm-differ. Ghidra preserves the existing global labels and adds three
uninitialized, writable, non-executable blocks without clearing code or data.

Run `make audit-script-resource-storage` for the execution audit, or
`python tools/check_script_resource_storage.py --mutations` to include its
negative controls. The ownership manifest and linker assertions check all five
symbols and each complete NOLOAD section. These arrays replace absolute
bindings; the new BSS consumes no ROM bytes.

The compiler, analysis and execution workflow follows the local IDO and SM64
references in [reference study](reference-study.md). No reference game code or
extracted retail strings are included in these storage definitions.
