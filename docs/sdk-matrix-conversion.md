# Fixed and float matrix conversion

`src/sdk/matrix_convert.c` reconstructs the complete 620-byte matrix utility
unit at `0x80068250..0x800684BC`, corresponding to ROM
`0x68E50..0x690BC`. All four procedures retain their original symbol extents.

| Procedure | Purpose | Object offset | Bytes |
| --- | --- | ---: | ---: |
| `func_80068250` | Pack a float matrix into signed 16.16 matrix words | `0x000` | 256 |
| `func_80068350` | Initialize a float identity matrix | `0x100` | 136 |
| `func_800683D8` | Initialize a fixed-point identity matrix | `0x188` | 48 |
| `func_80068408` | Unpack signed 16.16 matrix words into floats | `0x1B8` | 180 |

The 64-byte fixed matrix stores its integer halves in the first eight words
and its fractional halves in the final eight words. Each word contains two
matrix components. Packing multiplies each float by `65536.0f`, truncates to
a signed integer, and places the upper and lower halves in their respective
word arrays.

Unpacking combines the integer and fractional halves as unsigned words before
reading each word through its corresponding signed integer type. The result
is divided by `65536.0f`. This preserves negative fixed-point components and
the target's logical shifts. The intermediate unsigned words and signed views
are used directly in the conversion; no padding variables or inserted
instructions participate in the match.

The identity initializer writes one on the diagonal and zero elsewhere. Its
fixed-point wrapper constructs a local float matrix and passes it to the
packing helper. The translation helpers documented in
[SDK scheduling and audio services](sdk-scheduling-and-audio-services.md)
reuse these same interfaces and the checked `SdkMatrix` declaration.

## Verification

IDO 5.3 with the `sdk-o3-mips2-r4300-mul` profile reproduces all 620 code bytes,
with zero differing words. The independent comparison checks the actual ELF
procedure offsets and sizes, including all four exported functions. The unit
emits no initialized data or BSS. Only four trailing alignment bytes beyond
the complete target unit are removed after the existing padding verifier
checks them.

`tools/compare_runtime.py` includes `matrix_convert` as a canonical source
unit. Its original ROM range is supplied by the compiled object, and its
functions are removed from the absolute fallback-symbol bindings. The
full-ROM build verifies its calls from identity and translation users.

The target instruction stream establishes the arithmetic and placement. The
retained matrix reference study corroborates the unsigned storage, signed
views, and the division form of `FIX32TOF`; see [GU notes](sdk-gu.md) and the
libreultra and GoldenEye entries in [CREDITS.md](../CREDITS.md). The original
reference source remains outside the published reconstruction.
