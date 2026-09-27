# Text options and accessors

Four more text-record functions match the target ROM:

| Function | ROM range (end exclusive) | Bytes | Behavior |
| --- | --- | --- | --- |
| `func_80000B7C` | `0x177C..0x1A74` | 760 | Change options and apply associated record/object updates. |
| `func_80000E74` | `0x1A74..0x1AB4` | 64 | Read the signed options field; return -1 for a negative record index. |
| `func_80000EB4` | `0x1AB4..0x1B08` | 84 | Copy the 12-byte aggregate at record offset `0xF4`; do nothing for a negative index. |
| `func_80000F08` | `0x1B08..0x1B48` | 64 | Subtract the value at record offset `0x0C` from `D_8009EFA4`; return zero for a negative index. |

All four omit an upper-bound check on the record index. The reconstruction preserves that behavior.

## Option updates

The setter first ORs the low 18 bits of its set argument into the signed options field, then clears the bits named by its clear argument. It subsequently visits each of the 18 bits in ascending order, first for the set argument and then for the clear argument. Effects use the requested masks even when a bit's stored state was already unchanged. If both masks name a bit, the corresponding set-side effect still occurs before any clear-side effect.

| Set bit | Observed effect |
| --- | --- |
| `0x1`, `0x2` | Save `D_8009EFA4` at `0x0C`; copy scale word `0x6C` to `0x70`. |
| `0x4` | Save the global at `0x0C`; set `0x70` to twice `0x6C`. |
| `0x10` | Save the global at `0x14`. |
| `0x20` | Save the global at `0x10`. |
| `0x80`, `0x100` | Save the global at `0x18`. |
| `0x200` | Save the global at `0x1C`. |
| `0x400` | Store the arithmetic right shift `set >> 18` at `0x04`. |
| `0x1000` | Store that shifted value at `0x04`, save the global at `0x0C`, and copy `0x6C` to `0x68`. |
| `0x2000` | Store that shifted value at `0x04`, set `0x68` to twice `0x6C`, and save the global at `0x0C`. |
| `0x8000` | Store that shifted value as the selected object-array index at `0x20`. |
| `0x10000` | If the selected signed object index is nonnegative, call `func_80039E80` with property value 88. |

Other set bits have no observed per-bit effect beyond changing the packed options. Only clear bit `0x10000` has an additional effect: for a nonnegative selected object index, it calls the same property setter with the low byte of record field `0x64`.

The global's producer and units remain untraced. Saving it and later subtracting it supports a counter-like role, but does not establish that it measures time. The record's new `value0C` through `value1C` fields retain offset-based names. Likewise, the copied aggregate at `0xF4` is represented by three raw 32-bit words in `TextValue3`; its numerical types and purpose are not established by the copy instructions.

## Matching evidence

The setter generates a 32-entry switch table at ROM `0x90320..0x903A0`, immediately following the previously reconstructed character table. The build now compiles 296 bytes of table data, with no fallback covering either table. IDO's eight trailing read-only alignment bytes are removed by the existing checked padding tool. The partial text section ends at `0xAF8`, also followed by eight compiler alignment bytes.

The four functions and both tables match through the existing IDO 5.3 flags and fixed linker placement. Clean extraction/build, full-ROM verification, per-function symbol and byte checks, and tooling tests pass. All 8,388,608 bytes reproduce SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

C progress increases from ten functions / 1,836 bytes to fourteen functions / 2,808 bytes. Assembly progress remains 56 bytes. Generated tables are not counted as code, and whole-game totals remain unknown.
