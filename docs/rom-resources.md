# Named ROM resources

The USA ROM contains a named resource directory beginning at ROM offset
`0x97E90`. Its first word is a little-endian count. The validated target
contains 1,161 entries, each 32 bytes long, immediately after that word.
The first payload begins at offset `0xA0FB4`, which is also the end of the
directory: `0x97E90 + 4 + 1161 * 32`.

| Entry offset | Size | Meaning |
| --- | ---: | --- |
| `0x00` | 1 | Unknown metadata byte. |
| `0x01` | 23 | Zero-terminated resource name. |
| `0x18` | 4 | Little-endian payload offset relative to `0x97E90`. |
| `0x1C` | 4 | Little-endian payload size. |

## Directory initialization

`src/game/rom_directory.c` covers `0x8004EB80..0x8004ED14` and contributes
404 matching instruction bytes. It contains two endian-conversion helpers,
the directory initializer and one retail empty function. The helpers are
64 and 36 bytes; they reverse a word or halfword in place and return the
converted value. The halfword helper preserves the signed input load and
the target's integer return value.

The 296-byte initializer reads the directory count through the PI word-read
wrapper, reverses its byte order, allocates the entry table and copies the
directory into RAM. It reverses each entry's offset and size fields, then
adds the ROM directory base to each relative offset. The resulting table
pointer and count are stored in `D_80141200` and `D_80141204`. A separate
initialized flag makes subsequent calls return without reloading the table.

The recovered `RomFileEntry` is exactly 32 bytes. Runtime file lookups use
the filename beginning at byte one, which independently confirms the name
offset. The ROM directory itself confirms the little-endian field encoding
and the base-relative offsets. These resource bytes remain user-provided
ROM data; only the layout and reconstruction code belong in the repository.

## Error path

The separate 100-byte function `func_8004ED14` prints an error message and
performs a floating-point division of ten by zero before converting the
result to an integer. Its C source preserves this observed error path. The
numerator and denominator are local doubles: using a single constant
expression makes the compiler fold the division and fails to reproduce the
retail instructions. The local values produce the original divide and
floating-point control-register sequence without assembly or artificial
side effects.

## Lookup and loading

`src/game/rom_files.c` reconstructs the following 560 bytes with exact
function boundaries and instruction words:

| Function | Bytes | Behavior |
| --- | ---: | --- |
| `func_8004ED78` | 184 | Find a resource by case-insensitive filename. |
| `func_8004EE30` | 108 | Read a byte count from ROM using rounded-up PI words. |
| `func_8004EE9C` | 208 | Load a resource and apply its existing format fixup when selected. |
| `func_8004EF6C` | 60 | Return the size of a named resource. |

The lookup walks the directory in order and uses the existing byte-folding
string comparison. A failed lookup prints the original diagnostic and
returns index zero; the reconstruction preserves that fallback. The loader
initializes the directory before looking up the name, copies the recorded
size, and retains the original prefix and extension tests before calling
the resource fixup routine. The format of that fixup's data is a separate
recovery task.

The low-level reader rounds `(count + 3)` down to a word count by shifting
right by two, then reads that many four-byte words. It therefore copies up
to three bytes beyond an unaligned requested byte count, just as the retail
loop does. Resource payload extraction records the directory's exact byte
lengths; inter-resource padding is preserved separately during rebuilding.

## Resource tooling

Run `make resources` to generate a directory inventory from the validated
baserom. The report contains each name, byte interval and SHA-256, together
with counts by directory and extension. It is generated under `build/` and
is not committed.

The following command extracts every named payload and verifies a lossless
rebuild while retaining the original directory, inter-resource padding and
unmapped ROM bytes:

```sh
python3 tools/resources.py --extract build/analysis/resources \
    --rebuild-from build/analysis/resources \
    --output build/analysis/resources-roundtrip.z64
```

The target contains 6,074,151 named payload bytes between `0xA0FB4` and
`0x66BEE0`. The intervals do not overlap. All 1,161 metadata bytes are zero,
all names are terminated, and no normalized names collide. Payloads include
420 files under `MODELS`, 145 under `PATHS`, 292 under `KINS`, six under
`TEXTURES`, and 298 at the resource root. These are directory categories,
not claims that each contained file format is fully decoded.

The extractor checks table bounds, payload bounds, overlap, name encoding
and extraction paths. Existing files with different bytes are preserved.
The rebuild operation requires every resource to retain its recorded size;
it changes only the payload intervals. Synthetic tests cover these checks,
unaligned payload lengths and preservation of all non-resource bytes.
