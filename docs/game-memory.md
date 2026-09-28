# Memory and string helpers

`src/game/game_memory.c` reconstructs seven functions in the contiguous range
`0x8003B4C0..0x8003B734`, corresponding to ROM `0x3C0C0..0x3C334`.
Their 628 instruction bytes match IDO 5.3 with the project's normal flags.

| Function | Bytes | Behavior |
| --- | ---: | --- |
| `func_8003B4C0` | 60 | Find the first matching nonzero byte in a terminated string. |
| `func_8003B4FC` | 36 | Count bytes before the terminator. |
| `func_8003B520` | 116 | Copy bytes forward and return the end of the destination range. |
| `func_8003B594` | 256 | Copy in the direction required for overlap and return the original destination. |
| `func_8003B694` | 80 | Fill bytes and return the end of the destination range. |
| `func_8003B6E4` | 32 | Copy a terminated string and return its original destination. |
| `func_8003B704` | 48 | Copy until termination or the supplied character limit, then terminate the result. |

The three memory loops use signed counts. Zero or negative counts perform no
stores. The overlap-aware copy compares the pointers as unsigned 32-bit
addresses, copies backward when the source address is below the destination,
and returns immediately when both pointers are equal. The C retains those
conditions and IDO's generated loop unrolling.

The forward-copy and fill functions return their advanced destination pointer.
The text subsystem relies on these helpers, so their declarations are shared
through `include/game_memory.h`. They are not interchangeable with standard
`memcpy` and `memset`, which return the original destination.

The search function narrows its second argument to one byte. It stops when it
reads the string terminator before testing equality, so searching for zero
returns null. Its source keeps the target's argument home store and byte mask.

The bounded string copy first stores a character, then checks for a terminator,
then decrements the limit. When a positive limit reaches zero, it writes an
additional terminating byte. A zero initial limit therefore does not suppress
the first store and does not act as a zero-length copy. This behavior is
preserved, including the original lack of destination bounds checks.

`python3 tools/compare_runtime.py` independently compiles the matching block.
The main build also checks function boundaries, section placement, source and
header hashes, and complete ROM equality. The case-insensitive comparison at
`0x8003B768..0x8003B7FC` now matches all 148 bytes in
`src/game/game_string_case_compare.c`. It folds both characters using the
recovered character helper, returns their difference on a mismatch, and
advances until the original left string terminates. The duplicate case fold
on the mismatch path is preserved. The other four routines remain excluded
candidates in `src/game/game_string_comparisons.c`.

## Number formatting

`src/game/game_number_format.c` reconstructs the two following number-formatting
functions at `0x8003B928..0x8003BBAC`. `func_8003B928` is 360 bytes and
`func_8003BA90` is 284 bytes. Both compile to the exact retail instructions.

The integer formatter uses unsigned nibble shifts for radix 16. Other radices
use signed division and remainder, with the existing absolute-value helper for
negative inputs. Digits come from `D_8007BB1C`; the local reverse-digit buffer
holds ten bytes. The function emits a minus sign for a negative non-hexadecimal
value, reverses the collected digits, and writes the terminator. Zero has its
own complete write-and-return path.

The float formatter first multiplies its input by `1000.0f` and converts the
result to a signed integer with truncation. It then formats that scaled value
using the supplied radix. It does not insert a decimal point. The ten-digit
limit, negative-value handling, and early zero return are preserved.

The source keeps the digit buffer before its scalar locals. This produces the
observed buffer positions at `sp + 0x34` and `sp + 0x14` without padding objects.
These functions retain the target's lack of radix and destination-size checks.

## Character classification and case conversion

`src/game/game_character.c` covers seven functions at
`0x8003BBAC..0x8003BD4C`, totaling 416 matching instruction bytes. The first
three test ASCII printable, alphabetic, and decimal-digit ranges. Their input
is an unsigned byte and their result is an integer boolean.

`func_8003BC5C` and `func_8003BC90` return an unsigned byte after converting
lowercase to uppercase or uppercase to lowercase. Bytes outside the respective
letter range pass through unchanged. The byte return type reproduces both
52-byte functions; declaring these returns as `int` changes the compiled
instruction sequence. The shared header also supplies this type to the string
comparison callers.

`func_8003BCC4` and `func_8003BD08` perform the corresponding conversions in
place, stop at the zero terminator, and return the original string pointer.
Both 68-byte loops match independently. No locale tables or other character
sets are introduced.

## Decimal integer parsing

The parser at `0x8003BD4C..0x8003BDE8` matches all 156 bytes in
`src/game/game_integer_parse.c`. It accepts an initial minus sign, consumes
decimal digits, and stops at the first other character. It does not skip
whitespace or accept a leading plus sign. The floating parser beginning at
`0x8003BDE8` remains an excluded candidate.
