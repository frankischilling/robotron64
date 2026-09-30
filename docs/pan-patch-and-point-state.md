# Pan, patch and point state

Three complete procedures match all 1,088 instruction bytes with the pinned
IDO 5.3 game profile. Two private BSS allocations own 36 bytes.
The [provenance ledger](pan-patch-and-point-state-provenance.json) records
complete procedure extents, source inputs and storage comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_8005C1D8` | 340 | Apply a changed pan command to an owner's active hardware voices |
| `func_8005CA34` | 384 | Trigger each matching key region in a selected patch |
| `func_8000D090` | 364 | Append a rescaled point and calculate its preceding distance |

## Audio command state

The pan handler captures command byte one. It returns when that value equals
the owner's cached byte at `0x0C`. Otherwise it updates that byte, scans the
status records and calls the existing SDK pan setter for each active record
whose owner index matches. It stops after the owner's hardware voice count
has been processed. The original signed word post-decrement loop remains.

Its private work area occupies sixteen bytes at `0x80192B28`: two count
words, a status pointer and one byte value, followed by the allocation's
alignment bytes. The next owned pointer begins at `0x80192B38`.

Patch triggering captures the command's key and velocity bytes, selects the
four-byte patch using the owner's signed patch index, and visits each of its
twenty-byte regions. It selects the corresponding 24-byte wavetable before
checking the region's inclusive key range. A key in range invokes the
existing five-argument note trigger. No new bounds checks are added.

The private twenty-byte work area at `0x80192B5C` contains its region index,
three separate byte values and three pointers. The bytes occupy offsets
four, five and six; the pointers occupy offsets eight, twelve and sixteen.
The next owned note-release work area begins at `0x80192B70`. Compiler
private-symbol metadata and complete relocated accesses verify every offset.
Neither audio routine claims ownership of the runtime patch or status arrays.

## Dynamic point distances

The appender captures both incoming coordinates before the diagnostic call.
Separate local coordinates receive the existing rescale helper's results
and are stored in the current pair group. Counts at least fifty produce the
original diagnostic and still continue through the append.

For a nonfirst point, it calculates both signed coordinate differences,
forms the low 32-bit sum of their squared products and calls the existing
integer square-root helper. The distance is stored at index `count - 1`
in the group's tail. Complete accesses confirm that the tail consists of
fifty signed words at offset `0x194`. The shared group remains 604 bytes
and the full dynamic pool remains 9,096 bytes.

The subsequent diagnostic retains the original comparison of the group's
32-bit address plus `count * 604` with integer 200. The source preserves
that address calculation and literal comparison. It then increments the
count. This recovery claims no new initialized or BSS heap storage.

## References and validation

The pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/audio/synsetpan.c` corroborates the SDK pan interface and update kind.
Robotron's complete instructions establish the game commands, group layout
and private storage. The pinned IDO and Super Mario 64 matching-build
references remain credited in [the credits](../CREDITS.md). No reference
implementation is copied into these procedures.

Validation covers tooling tests, fresh extraction and build, every runtime,
startup, native assembly and data comparison unit, linked function extents,
private data metadata and the exact USA ROM. A clean committed archive and
publication audit independently check the public sources. Existing users
of the updated group header retain their complete target instructions.
