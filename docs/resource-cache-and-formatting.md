# Resource cache storage and destination formatting

The destination formatter `func_800363D0` occupies `800363D0..80036668`,
with 664 instruction bytes. Its source is `src/game/formatting/destination.c`.
The complete function and its compiler-generated table must match together.
The shared declaration in `include/destination_format.h` returns the
original destination pointer, as the retail epilogue does.

## Formatting behavior

The formatter consumes o32 integer and pointer argument homes. `%C` and
`%c` read byte three of an aligned four-byte promoted argument. The local
byte-reader macro expresses that ABI access without changing the other
game formatter's historical argument handling.

`%s` copies the terminating zero and advances by the copied string's length.
`%d` and `%x` use the existing decimal and hexadecimal conversion routine.
Selectors `2` through `5` choose a decimal padding limit and skip the next
format character without validating it. Padding moves the current string
right by one byte, including its terminator, and inserts a leading space.
It repeats until the rendered length is greater than the selector. Unknown
conversions consume no argument. The original lack of output bounds and
malformed-format checks is retained.

The requested width, current length, and loop padding limit are distinct
used locals. Recording the length before copying the limit reproduces the
target's register transfer into the padding loop. No unused local, empty
conditional, inline assembly, or instruction patch is added.

The switch produces eighteen entries for characters `0x32..0x43`, followed
by eight alignment bytes. All 80 bytes at `80094300..80094350` have source
ownership in the same translation unit. The compiler supplies every entry
and alignment byte.

## Typed cache banks

Two independently compiled data units define the complete cache banks:

| Bank | RAM range | Records | Stride | Initialized bytes |
| --- | --- | ---: | ---: | ---: |
| Model | `80078284..8007A1C4` | 400 | 20 | 8,000 |
| Animation | `8007A1C4..8007BAC4` | 400 | 16 | 6,400 |

The matching cache-reset routine clears exactly 400 loaded flags in each
bank. The loader and bridge establish their data pointers, loaded bytes,
and signed identifiers. Model flag uses in the object draw loop establish
the word at record offset eight. The model record's final eight bytes
remain unknown. The arrays use explicit zero initialization, which IDO
emits as initialized data. They replace these complete fallback bytes;
they add no BSS.

The resource base at `80078274` is sixteen bytes before the first model
record. Those preceding bytes and the bitmap region remain outside this
ownership claim. Existing address-based views keep their verified indexing;
no bitmap array length is inferred from the loader's unchecked argument.

Two further data units define the three initial identifier-map reset words
at `80078264..80078270` and the animation/bitmap counters and loader guard
at `8007BB0C..8007BB18`. They add 24 initialized bytes. All symbol offsets,
section sizes, linked addresses, and contents are compared independently.

The three identifier maps at `800C8E00..800CA570` each contain 1,000 signed
halfwords and own 6,000 BSS bytes. The bridge routines initialize every
entry to `-1` on the first use of the corresponding reset word, then map
resource identifiers to cache indices. The compiled object verifies all
three 2,000-byte arrays, their exact offsets, and the complete BSS extent.
These maps consume no ROM bytes.

## Animation count correction and loader candidate

The first signed halfword in the animation file is the point count; the
second is the frame count. The loader stores them at cache offsets four
and eight. The projection consumer multiplies the first count by the frame
index to locate a frame, while the existing animation-length helpers read
the second count. These consumers establish the roles that the earlier
mesh/resource notes named in reverse order.

The complete loader at `8004BD00..8004C088` still has an excluded C
candidate. A used byte-offset local expresses the three cache index strides
and reproduces the cache pointer's stack home. The remaining differences
concern pointer registers; matching credit requires the entire procedure.
Its current comparison is recorded in the ledger.

## Evidence

Robotron's complete instructions and matching consumers establish these
layouts and operations. The local IDO and established matching-decomp
references remain credited in [CREDITS](../CREDITS.md). The earlier
[sound-bridge notes](sound-bridge.md) documented the formatter's behavior;
this recovery reconstructs it from the target and publishes the complete
source and generated table.

The current independent comparisons and source/header/compiler identities
are recorded in `resource-cache-and-formatting-provenance.json`. Fresh
extraction, build, tooling tests, linked-byte comparison, full-ROM equality,
and publication audit verify the selected source tree. Whole-ROM equality
continues to use fallback and does not establish full source recovery.
