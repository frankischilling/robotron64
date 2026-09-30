# Audio note release

`func_8005CBB4` recovers the complete 264-byte routine at
`0x8005CBB4..0x8005CCBC`. It scans the hardware-status records selected by
`D_8019281C` and `D_80192820`, considering only active records whose second
status flag is clear. A record must match both the command's key byte and
the logical voice index. When the voice's pedal-release bit is set, the routine
calls `func_8005C5BC`; otherwise it records the pending release at byte seven
of the hardware-status record.

The shared declarations preserve the observed 20-byte hardware-status stride
and 80-byte logical voice layout. The key and voice-index comparisons use the
actual byte fields at offsets five and three. The command pointer is read
from the logical voice's `0x34` field, and its byte-one key is compared with
the selected status record.

Two function-local statics retain the scan count and record pointer at
`0x80192B70` and `0x80192B74`. Their eight live BSS bytes are owned by this
source. The raw compiler emits an additional eight bytes of zero alignment;
the owned-section tooling checks the complete raw allocation and removes only
that trailing alignment for the final placement.

The matching source uses ordinary record dereference syntax for the key
lookup. The equivalent arrow expression changes IDO's temporary-register
allocation and differs at ten instructions. A bounded source search found
the dereference form; the result was reviewed and formatted before a separate
complete code-and-storage comparison. No score alone establishes the match.

The retained complete comparison is
`.local/backend-probes/resume_note_release_matched/report.json`. It reports
264 expected bytes, 264 emitted bytes, zero differing words, and the two
private BSS symbols at their original offsets. The
[provenance ledger](audio-note-release-provenance.json) records the source,
compiler, inputs, complete target extent, and owned storage. Canonical
verification is available through `python3 tools/compare_runtime.py` and
the normal ROM build.

Robotron's supplied USA revision-zero ROM determines the instructions,
field accesses, and storage addresses. WESS terminology was checked against
the previously recorded DOOM64-RE `n64cmd.c` reference; no implementation was
copied from that checkout. The reference revision and terms remain in
[CREDITS.md](../CREDITS.md).
