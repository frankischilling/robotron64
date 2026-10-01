# Remaining CPU ranges

Run `make remaining` to generate `build/us/remaining.json` from the current
function manifest, owned data sections, extraction regions, and candidate CPU
mapping. No commercial input or analysis dependency is needed. The command
prints the largest twenty fallback spans; `python3 tools/remaining.py --limit 0`
prints just the totals and measurement limits.

This inventory answers which declared ROM spans still use extraction. It does
not prove that the source matches, establish every function boundary, or count
every byte in a fallback as an instruction. Use `make progress` after a matching
build for verified source totals.

The current candidate mapping is ROM `0x1000..0x70040`, loaded at
`0x80000400`. It covers 454,720 bytes. Its internal boundaries remain under
review, so the report keeps the whole-game code denominator and percentage
unset. Data outside this mapping and BSS are excluded from this inventory.

The tool clips intervals to the candidate mapping, sorts them by ROM address,
rejects any overlapping declarations, and reports every uncovered span.
The category totals must add up to the candidate range. Gaps remain
unclassified even when their size and position suggest compiler alignment.
Each fallback record carries its extraction name, ROM bounds, runtime bounds,
and byte length. The full list is sorted by size, with address order breaking
ties, so a later recovery can select a range without a stale handwritten list.

For a selected span, confirm procedure boundaries and callers against the
target, recover plausible types and behavior, then compare complete compiled
units. Once a unit matches, replace its fallback placement, add the function
manifest and independent comparison record, and rerun the inventory. Removing
an extraction span before adding its source leaves an explicit gap; leaving
both declarations is an error.

Public CI exercises interval clipping, runtime mapping, overlap detection,
category accounting, BSS exclusion, unknown denominators, and ordering using
synthetic layouts. It also checks the current repository layout through
`make test`. The approach uses the explicit extraction and linker ownership
already established here; the N64 workflow references and their revisions are
recorded in [credits](../CREDITS.md) and [reference study](reference-study.md).
