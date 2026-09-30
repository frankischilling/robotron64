# Audio sequence loading

Twelve complete functions provide 1,968 bytes of matching C. They load the sequence
table, calculate storage requirements, and manage individual sequences and
contiguous or sentinel-terminated lists of sequences. Each source unit retains
its complete procedure extent.

| Source | Complete range | Code bytes |
| --- | --- | ---: |
| `audio_sequence_table_size.c` | `0x8005D220..0x8005D2E4` | 196 |
| `audio_sequence_table_load.c` | `0x8005D2E4..0x8005D4A4` | 448 |
| `audio_sequence_table_close.c` | `0x8005D4A4..0x8005D4C8` | 36 |
| `audio_sequence_size.c` | `0x8005D4C8..0x8005D584` | 188 |
| `audio_sequence_load.c` | `0x8005D584..0x8005D610` | 140 |
| `audio_sequence_release.c` | `0x8005D610..0x8005D690` | 128 |
| `audio_sequence_list_size.c` | `0x8005D690..0x8005D708` | 120 |
| `audio_sequence_list_load.c` | `0x8005D708..0x8005D7B4` | 172 |
| `audio_sequence_list_release.c` | `0x8005D7B4..0x8005D828` | 116 |
| `audio_sequence_range_size.c` | `0x8005D830..0x8005D8AC` | 124 |
| `audio_sequence_range_load.c` | `0x8005D8AC..0x8005D95C` | 176 |
| `audio_sequence_range_release.c` | `0x8005D95C..0x8005D9D8` | 124 |

## Table and sequence records

The serialized table header is 32 bytes. Its sequence count is the unsigned
halfword at `0x0E`, its storage mode is at `0x10`, and the packed and unpacked
table sizes are at `0x14` and `0x18`. The table loader installs the caller's
storage, reads the table directly for mode zero, and otherwise invokes the
existing storage callback. The data offset follows the appropriate table size.

A sequence entry is 16 bytes: unsigned track count, storage mode, data length,
file offset, and loaded-track pointer. This is the serialized interpretation
of the existing audio record-table slots. Runtime voice-count readers retain
their independently observed signed access to the first halfword. A loaded
track has three pointers occupying 12 bytes: header, labels, and commands.
The 20-byte track header's label count is signed, as established by the reader's
halfword loads; that reader remains a candidate in this batch.

The size calculation reserves the track-pointer records, rounds their end up
to an eight-byte boundary, and adds the sequence data length. It returns zero
for an invalid sequence index, a count beyond the configured track limit, or a
sequence that is already loaded. Release clears a loaded-track pointer and
reports whether it changed an entry.

## I/O and range behavior

The table loader samples its expected read length before invoking the host
read routine and compares the returned byte count with that saved value.
Explicit local variables preserve the target's sampling order. The error
callback receives code one for open failure, three for seek failure, and two
for a short table read. The recovered code preserves the target's return and
reference-count behavior on each path.

The range helpers retain a separate sequence index and remaining count.
Range loading opens the shared file before checking a zero count; that early
return does not close it in the target, and the source preserves that behavior.
Nonempty range loading accumulates the consumed bytes and closes the shared
file after the loop. Range release reports whether the requested loop ran.

The list helpers consume signed halfword indices terminated by `-1`. Size and
release first check the installed-table flag and the initial sentinel. Their
loops sample each index into an integer before invoking the single-sequence
helper. List loading opens the shared file before inspecting the sentinel and
closes it even when the list is empty. Each successful load advances the output
position by the accumulated byte count. List release reports whether the loop
ran, including when an individual release did not change a sequence entry.

All three list loops retain a separate cursor and a guarded `do` loop. This
preserves the target's initial sentinel test, index sampling, and saved-register
lifetimes. Their 408 code bytes form consecutive complete procedures; the
eight following alignment bytes remain outside their source ownership.

## Verification

All twelve candidates were independently compiled with the pinned IDO 5.3 game
profile, linked at the observed addresses, and compared over their entire
function ranges. Every comparison has zero differing words. They introduce
no initialized data or BSS definitions and leave all neighboring fallback
spans intact.

The original [input ledger](audio-sequence-loading-provenance.json) and the
[list-helper ledger](audio-sequence-lists-provenance.json) retain source,
comparison-report, and linked-code identities. `tools/compare_runtime.py`
registers all twelve complete units for current-header verification. `make test`
checks their manifest, evidence paths, and tooling; `make progress` requires
the complete ROM and linked source provenance to pass before counting them.

The original nine-function checkpoint passed all nine registered comparisons
and all 106 tooling tests; its linked build had 900 matching C functions
covering 117,056 bytes. Those historical identities remain in the original
ledger. The current aggregate counts are in the repository README.
The rebuilt 8,388,608-byte USA ROM has SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

The full track reader at `0x8005CE0C` remains an excluded candidate. Its
retained comparison still differs, so those bytes continue to come from the
extracted fallback. The listed N64 projects and WESS references are credited
in [CREDITS.md](../CREDITS.md); Robotron's own instructions and callers establish
the behavior and layouts recorded here.
