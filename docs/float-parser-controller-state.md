# Decimal float parsing and controller input storage

`src/game/game_float_parse.c` recovers the complete 372-byte procedure at
`0x8003BDE8..0x8003BF5C`. It uses the established IDO 5.3 game profile with
`-Wab,-r4300_mul`. The multiply workaround preserves the target's return-path
stalls; without it, the generated procedure is shorter.

The parser accepts an optional initial minus sign, accumulates decimal digits
as a signed integer, and optionally consumes a fractional part after a dot.
It stops at the first unrecognized byte. It does not skip whitespace or
recognize a leading plus sign or exponent. The fractional divisor starts at
one and is multiplied by ten before each digit. Each fractional digit is
converted through an unsigned word, subtracts `48.0f`, and is divided by the
signed integer divisor converted to float. The target's otherwise redundant
unsigned-conversion branch remains in the compiled code.

The sign and initial pointer advance use a sequenced comma expression:
`sign = -1.0f, character = *++cursor`. This represents the same two operations
without adding a branch or a dummy value. With this compiler, separate
statements reorder two instructions in the minus-sign path. Every word of
the selected source matches, including both integer and fractional return
paths. The byte match does not establish a unique original source spelling.
Integer overflow and long fractional divisors retain the retail arithmetic;
this is not a replacement with a host conversion library.

## Controller state layout

The two game polling paths use the same pad and input arrays. The SDK pad
record has a six-byte stride, unsigned button halfword, and signed stick
bytes. Polling stores the coordinates into signed word arrays, current and
previous buttons into word arrays, and newly pressed bits into a fifth word
array. The older polling path also stores a button halfword at `0x8013DC08`.
The complete loops and their indexed load/store widths establish these
extents. The original storage checkpoint did not count either poll as
matching; [both complete procedures now match](controller-polling-and-storage.md).

`controller_pad_state.c` now owns these 104 BSS bytes:

| Address | Size | Definition |
| --- | ---: | --- |
| `0x8013DBA0` | 24 | Four SDK pad records |
| `0x8013DBB8` | 16 | Stick X words |
| `0x8013DBC8` | 16 | Stick Y words |
| `0x8013DBD8` | 16 | Current button words |
| `0x8013DBE8` | 16 | Previous button words |
| `0x8013DBF8` | 16 | Newly pressed button words |

The compiler emits all six array symbols at these offsets. Eight trailing
alignment bytes are trimmed; their ownership is not inferred. The existing
two-byte legacy last-button word at `0x8013DC08` now belongs to the matching
poll's function-local static, preserving its address and total BSS ownership.
BSS consumes no ROM
payload. Independent data checks verify the trimmed extent, symbol offsets,
linked placement, and absence of executable code. The existing input mapper,
button readers, and edge consumers retain complete instruction comparisons.

[The provenance ledger](float-parser-controller-state-provenance.json)
records the earlier storage checkpoint's source, header, compiler, instruction,
and data-proof hashes. The current ownership split and poll comparisons are in
the [polling ledger](controller-polling-and-storage-provenance.json).
The runtime comparison and linked ROM build must pass again after any input
changes; the ledger records this checkpoint rather than replacing those checks.

## Candidate inventory correction

The old floating-parser candidate was registered at `0x8003BD4C`, which is
the already matched integer parser's entry. Its comparisons therefore used
the wrong starting address and included 156 unrelated target bytes. The
float parser is now registered under its own name and exact extent.

The combined string-comparison candidate is also retired. All its functions
already have complete matching sources, and it omitted the intervening
case-insensitive comparison. Historical source remains available in
[the earlier checkpoint](https://github.com/frankischilling/robotron64/tree/cee16dd16823a79e3862a3d294ebc4cd821d7e69/src/game).
Candidate validation now rejects spans overlapping recovered functions so
these stale registrations cannot silently produce misleading differences.

The local libreultra `include/2.0I/PR/os.h` supplies the pad-field and button
conventions. The pinned IDO and SM64 build references supply compiler context.
Robotron's own instructions establish the parser behavior, arithmetic,
controller stores, and extents; no reference implementation was copied.
All requested references remain in [CREDITS.md](../CREDITS.md).
