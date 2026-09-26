# Initial ROM map

Offsets refer to the normalized big-endian ROM. The supplied file is byte-swapped; normalization leaves it untouched.

| ROM range | Evidence | Interpretation |
| --- | --- | --- |
| `0x000000–0x000040` | Parsed N64 header | Header, confirmed |
| `0x000040–0x001000` | Standard boot region location | Boot code; CIC identification pending |
| `0x001000–0x001038` | Disassembled entry instructions | Startup code at `0x80000400`, confirmed |
| `0x001050–0x001060` | Multiply, return, delay slot | Integer-square function at `0x80000450`, confirmed |
| `0x001060` onward | Instructions and control flow | More executable code; full boundaries pending |

Startup clears `0x1003B0` bytes starting at `0x80097290`, ending at `0x80197640` exclusive. This is strongly supported as the BSS range. It sets the stack pointer to `0x8013A280` and transfers control to `0x80048170`. These addresses come directly from the entry instructions.

The initial executable mapping is `VRAM = ROM + 0x7FFFF400`. Its extent still needs analysis. No claim is made yet about overlays, compression, asset formats, or the boundary between code and initialized data.

The four instructions at `0x80000450` multiply the argument by itself with `multu`, return the low 32 bits through `v0`, and return to the caller. Signedness of the source parameter is not established by this alone.
