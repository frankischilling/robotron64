# Session initializer diagnostics

The resource initializer at `0x8002E670` passes four diagnostic strings to the
fatal service. Reconstructed C arrays own the complete 104-byte range
`0x80093CB0..0x80093D18`, stored at ROM `0x948B0..0x94918`.

| Symbol | Bytes | Use |
| --- | ---: | --- |
| `D_80093CB0` | 16 | Prop capacity |
| `D_80093CC0` | 32 | Unknown resource category |
| `D_80093CE0` | 28 | Missing category callback |
| `D_80093CFC` | 28 | Missing enemy callback; one string argument |

The arrays preserve every terminator, newline, trailing zero and the retail
`OBEJCT` spelling. Their complete byte SHA-256 is
`66cc9d31a378f3bccbc8d1e49165e984700a4f58ff9e57f85328d2ae40fb6747`.
Fresh splat and SPIM references independently reassemble all 104 bytes.
IDO 5.3 with the unchanged game profile emits the same arrays at offsets
zero, 16, 48 and 76. The data comparison rejects extra allocated sections,
and the linker asserts the complete range and each source symbol. This unit
defines no instructions, relocations or BSS. Compiler alignment after the
104-byte range receives no ownership credit.

Initializer code and its 224-byte generated dispatch tables remain outside
matching ownership. A private readable candidate passes 944 paired execution
checks but retains 180 differing instruction words. Fatal-service internals
and gameplay are unverified. These diagnostics add data ownership only.

The selected USA NRXE retail ROM supplies the strings and caller evidence.
Tools and N64 references are listed in [the project credits](../CREDITS.md).
Private splits, original bytes, objects and execution records remain ignored.

The [acceptance ledger](session-initializer-diagnostics-provenance.json) records
the complete data range, compiler identity, independent comparisons and all
23 validation stages. Whole-ROM equality includes extracted fallback.
