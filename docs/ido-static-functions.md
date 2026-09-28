# Static function verification

IDO 5.3 keeps some private function names out of the ELF symbol table even
though it emits their code and retains their names in `.mdebug`. The PFS
read/write object demonstrates this: its ELF table describes `.text` and the
public function at offset `0xFC`, while its debug records identify the static
`func_80062CF0` at offset zero with a 252-byte extent.

The function manifest can mark a C function with `"linkage": "static"`.
`tools/ido_symbols.py` reads its compiler-produced ECOFF static-procedure
record and the associated end record. It validates the debug table and file
descriptor bounds, auxiliary index, matching start/end names, end-to-start
back reference, text storage class, word alignment, and text extent. An
absent, malformed, overlapping or ambiguous record fails verification.

The reader does not add ELF symbols, alter the compiler output, export the
function, or modify instructions. Object provenance still binds the source,
headers, compiler and object. Progress verification checks the compiler's
static function extent, the linked section's VMA/LMA, every claimed byte at
its section offset, and the complete ROM. Public functions retain the existing
ELF symbol address and size checks.

Synthetic tests exercise malformed metadata and valid static procedure pairs
without embedding game or toolchain binaries. The real PFS object supplies a
separate local validation of the 252-byte procedure and its full 1,276-byte
translation unit.

The binary layouts and procedure-end relationship were checked against
ZeldaRET's CC0 [IDO symbol reader](https://github.com/zeldaret/oot/blob/1bef952ff61a6dd1945c7887c1babd94efe95f72/tools/ido_block_numbers.py)
and the [decompals/ultralib ECOFF reader](https://github.com/decompals/ultralib/blob/e24c836796df4bf520ff8b11a5c9d2cea3a66cbd/tools/mdebug.py).
OOT's assembly processor also recovers private names from this metadata for
its own linking workflow. Robotron's reader only verifies the records.

## Private initialized data

The SDK random-number generator keeps its seed local to the function. IDO's
ELF table contains only a data-section symbol for it; `.mdebug` records the
static variable `seed` at data offset zero. Changing that variable to an
external definition changes the generated address/register sequence.

An owned section may record `static_symbols` separately from its exported
`symbols`. Before linking, the verifier checks the compiler's static-variable
name, allocated storage class, input section and offset. Ambiguous names,
missing records, displaced variables and unrecorded private definitions fail.
After linking, the ordinary owned-section placement, extent and complete data
comparison checks still apply. The final ROM comparison includes those bytes.
Source and object provenance tie both checks to the same compiler output.

The reader neither creates exported aliases nor changes the data. Static
variables in unrelated translation units can retain their own source names.
Synthetic fixtures check static-data metadata and linked-byte corruption
separately, without embedding game data.
