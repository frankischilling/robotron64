# 3D text records

`func_80000918` allocates a string record and creates its character objects. `func_80000ACC` releases those objects and invalidates the caller's record index. Both now compile to the original bytes with IDO 5.3 and the existing MIPS I flags.

## Pool and layout

The allocation scan visits 30 records at `0x800B6FF8` with a stride of `0x10C` (268 bytes). Their combined size is `0x1F68` (8,040 bytes), exactly the range cleared by `func_800005E0`. The initializer now expresses that length with `sizeof(D_800B6FF8)` and still matches.

| Offset | Evidence and representation |
| --- | --- |
| `0x00` | Packed word: bit 31 indicates allocation; bit 30 is set on allocation but its meaning is unknown; bit 29 is unexamined; bits 28 through 11 form an 18-bit signed options field; low 11 bits are unexamined. |
| `0x04` | Unexamined word. |
| `0x08` | Mode argument stored and passed to character creation. |
| `0x0C..0x24` | Unexamined bytes. |
| `0x24..0x64` | Text storage. Copying is limited to 60 input bytes and writes a terminator; the remaining bytes before the next field are not used by these routines. |
| `0x64` | Integer property initialized to 24; purpose unknown. |
| `0x68`, `0x6C`, `0x70` | Three integers initialized from the scale argument. Their later individual roles remain unknown. |
| `0x74` | Stored character count, capped at 60. |
| `0x78..0xF0` | 60 signed 16-bit object indices. Negative entries are skipped during release. |
| `0xF0..0x100` | Unexamined bytes. |
| `0x100`, `0x104`, `0x108` | Three words initialized to `0xDEADBEEF`; subsequent use is unknown. |

Ranges have exclusive ends. `TextRecord` keeps unknown regions explicit. The bitfield assignment and signed extraction both reproduce the original instruction sequence, including preservation of adjacent bits.

## Allocation behavior

The function chooses the first record whose allocation bit is clear. It stores the options and mode, sets bits 31 and 30, initializes the fields listed above, and copies the input text. For inputs shorter than 60 bytes, it calls the length helper twice; the reconstruction preserves both calls.

For each stored character, a zero byte or space produces object index `-1`. Other characters pass to `func_80000750`, using bit `0x200` of the signed options field as the fourth argument. Each result is narrowed into the signed 16-bit array. Failed character creation does not roll back the record or preceding objects. Exhausting the pool invokes the diagnostic at ROM `0x9024C` and returns `-1` if the diagnostic returns.

The length helper at `0x8003B4FC` scans to the first zero byte and returns a signed count. The copy helper at `0x8003B704` stops at a copied zero or after the requested count; in the latter case it appends a zero. These helpers are still extracted fallback, not counted as matching C.

## Release behavior

`func_80000ACC` takes a pointer to the caller's index. A negative index does nothing. Otherwise it clears the allocation bit, calls `func_800392F4` for each nonnegative object index up to the stored character count, then writes `-1` to the caller's index. It does not check for an index of 30 or greater and does not clear the remaining record fields. Those behaviors are preserved.

## Verification

The allocation function occupies ROM `0x1518..0x16CC` (436 bytes); release occupies `0x16CC..0x177C` (176 bytes). Extraction excludes both ranges. The partial text object's logical length is now `0x72C`, with four trailing compiler alignment bytes removed by the existing checked padding tool.

Clean extraction and build, per-function linked-byte and object-symbol checks, and full comparison reproduce all 8,388,608 ROM bytes. The SHA-256 is `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`. C progress increases from eight functions / 1,224 bytes to ten functions / 1,836 bytes. Assembly progress remains 56 bytes, and whole-game code totals remain unknown.
