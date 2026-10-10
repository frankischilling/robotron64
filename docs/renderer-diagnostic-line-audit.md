# Diagnostic line candidate audit

The complete retail `func_800453D8` occupies `800453D8..80045514`: 316
instruction bytes and a 56-byte frame. Independent splat and SPIM references
reassemble every byte. The current excluded C emits 308 natural instruction
bytes and differs in 57 words. Its 320-byte raw text section has twelve zero
alignment bytes; eight occur in the 316-byte comparison window. They are not
reconstructed instructions. No source ownership is added.

Run `make check-renderer-diagnostic-line` with the optional analysis dependencies
and the target baserom. It freshly compiles the public candidate with pinned
IDO 5.3 and checks its raw symbol, natural boundary, alignment, generated-data
absence and complete mismatch before executing retail and C separately.

The independent memory oracle covers 528 pairs, including 384 normal returns
and 144 stops at the fatal formatter entry. Four command-buffer placements
exercise ordinary storage, vertex overlap, vertex-index overlap and overlap
with the display-list cursor. Six coordinate sets cover signed halfword
boundaries, 32-bit extrema and discarded high bits. Eleven allocation/frame
combinations cover the 10,000-vertex limit, the final valid pool pair, negative
usage and wrapped subtraction under the pinned MIPS profile.

Normal cases check both XYZ endpoints, yellow RGBA, the two command packets,
global cursors and every byte in the surrounding initialized windows. Ordinary
vertex flags and texture fields remain unchanged. Execution guards bound data
accesses, code and stack writes. The checker requires the explicit return PC,
SP, GP, RA, saved integer registers, F20-F31 and stack/FPU canaries.

Error cases verify the formatter address, format and filename pointers, signed
usage word, limit and source line `0x3C1`. They require no vertex or packet
writes. The checker stops at formatter entry and checks the caller's 56-byte
frame. It executes no formatter body and supplies no returning diagnostic
stub. The separate [fatal formatter audit](renderer-fatal-formatter.md) covers
that formatter's bounded CPU behavior and wait loop.

Twelve controls are rejected: a saved-integer fault, an altered F20 seed,
unexpected read/write/code, stack escape, missing return, and changed depth,
blue channel, vertex advance, line packet and limit comparison. The proof
is written to `build/renderer-diagnostic-line-execution/proof.json`.

Eighty additional source forms do not improve the candidate. In 24 paired
forms, advancing the last vertex cursor or omitting that unused advance
produces identical allocated sections. That expression does not explain the
retail increment. The two retained retail vertex pointers, increment and
complete compiler allocation still need matching source. No incoming runtime
caller is established; V0/V1 contents do not establish a return contract.

These finite checks do not prove arbitrary inputs, RSP/RDP output or gameplay.
The function stays outside the matching manifest and ROM rules. Current
fingerprints and validation are in the [provenance ledger](renderer-diagnostic-line-provenance.json).
