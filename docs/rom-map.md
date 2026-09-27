# Initial ROM map

Offsets refer to the normalized big-endian ROM. The supplied file is byte-swapped; normalization leaves it untouched.

| ROM range | Evidence | Interpretation |
| --- | --- | --- |
| `0x000000–0x000040` | Parsed N64 header | Header, confirmed |
| `0x000040–0x001000` | Standard boot region location | Boot code; CIC identification pending |
| `0x001000–0x001038` | Disassembled entry instructions | Startup code at `0x80000400`, confirmed |
| `0x001038–0x001050` | All zero bytes | Entry alignment padding, reconstructed |
| `0x001050–0x001060` | Multiply, return, delay slot | Integer-square function at `0x80000450`, confirmed |
| `0x001060–0x0011E0` | Linked C bytes match original | Character lookup and conversion helpers, confirmed |
| `0x0011E0..0x001350` | Linked C bytes match original | Buffer clear and character normalization, confirmed |
| `0x001350..0x001518` | Linked C bytes match original | 3D text object creation, confirmed |
| `0x001518..0x00177C` | Linked C bytes match original | Text record allocation and release, confirmed |
| `0x00177C..0x001B48` | Linked C bytes match original | Text option setter and accessors, confirmed |
| `0x001B48..0x001DAC` | Instructions and control flow | Text replacement; nonmatching C candidate, extracted fallback |
| `0x001DAC..0x001E70` | Linked C bytes match original | Text create-or-replace wrapper, confirmed |
| `0x001E70..0x001FD0` | Linked C bytes match original | Text suffix editing and active-record cleanup, confirmed |
| `0x001FD0..0x0022D8` | Linked C bytes match original | Run and whole-record property updates, confirmed |
| `0x0022D8..0x00237C` | Linked C bytes match original | Three-component integer/float round trip, confirmed |
| `0x00237C` onward | Instructions and control flow | More executable code; full boundaries pending |

SDK instruction sequences have been identified at ROM `0x68160`, `0x68180`, and `0x690C0`; see [libultra evidence](libultra.md). Graphics microcode strings occur at `0x96E80` and `0x97680`; see [graphics evidence](graphics.md). These observations do not establish segment boundaries.

The initial thread handoff occupies ROM `0x48D70..0x48EA0`, mapping to RAM `0x80048170..0x800482A0`. See [startup evidence](startup.md) for calls, object addresses, and an excluded C candidate. These function boundaries do not prove original object-file boundaries.

The CRC32 of bytes `0x40..0x1000` is `0x90BB6CB5`. CIC identification remains pending confirmation against an authoritative boot-code reference. Header CRC1 and CRC2 are recorded in `config/target.json`; they have not yet been independently recomputed using a CIC-specific algorithm.

Startup clears `0x1003B0` bytes starting at `0x80097290`, ending at `0x80197640` exclusive. This is strongly supported as the BSS range. It sets the stack pointer to `0x8013A280` and transfers control to `0x80048170`. These addresses come directly from the entry instructions.

The initial executable mapping is `VRAM = ROM + 0x7FFFF400`. Its extent still needs analysis. No claim is made yet about overlays, compression, asset formats, or the boundary between code and initialized data.

The four instructions at `0x80000450` multiply the argument by itself with `multu`, return the low 32 bits through `v0`, and return to the caller. Signedness of the source parameter is not established by this alone.
`config/analysis.json` now records a candidate CPU range ending at ROM `0x70040` and the RSP boot region `0x70040..0x70110`. See [executable inventory](executable-inventory.md) for task-pointer and RSP instruction evidence, commands, and provisional counts.

The 168-byte character-normalization jump table at ROM `0x90278..0x90320` is now generated from C. See [text evidence](text.md).

The text option switch table at ROM `0x90320..0x903A0` is also generated from C; see [option evidence](text-options.md).
