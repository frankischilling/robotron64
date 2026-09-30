# Pak, signature and argument state

Three complete procedures match all 452 instruction bytes with the pinned
IDO 5.3 game profile. Two signature literals own sixteen initialized bytes.
The [provenance ledger](pak-signature-and-argument-state-provenance.json)
records complete procedure extents, source inputs and storage comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_800266BC` | 144 | Select a Controller Pak file name and format its menu label |
| `func_80005DEC` | 148 | Check the saved image signatures before dispatching command three |
| `func_8000EC30` | 160 | Copy ten command arguments into an indexed resource view |

## Controller Pak selection

The name selector reads a menu pointer, subtracts the base of the name
records and divides the byte difference by thirty. This establishes the
record stride. It stores the resulting file index, asks the existing Pak
entry helper for pages and a decoded name, and formats the selected label.
The forty-byte local name buffer and separate page word reproduce the
complete stack layout. The original code ignores the entry helper's result,
clears the menu flag and invokes the menu transition with mode zero.
Neither the name records nor the pointer table receive a storage ownership
claim here; their complete bounds still require their producers.

## Saved image gate

The gate compares the image's leading signature with `laddie`, checks word
five against decimal 1234567 and compares configuration bytes starting at
offset four with `arvid`. Each failed check returns zero. Successful checks
set the existing global flag and dispatch command three with a zero second
argument. The successful path has no return expression. Startup ignores
the result, and the source preserves this historical fallthrough.

Both complete signature literals occupy sixteen read-only bytes at
`0x8008F930`, including their terminators and allocation alignment. The
second begins at offset eight. The compiler emits zero object-symbol sizes
for these constants; the complete section and both offsets are verified.
The shared string comparator accepts read-only inputs because its complete
procedure only reads them. Existing callers and its complete implementation
retain their target instructions.

## Resource argument view

The argument routine captures the command index before writing to the
shared resource workspace. It writes value five to the selected record,
copies ten signed words from command offset `0x0C` to record offset `0x3C4`
and stores the captured index in the existing selection word.
The loop's two leading copies and four-word iteration reproduce the
complete target instructions.

The target's address arithmetic establishes a 1,004-byte record stride.
Other resource operations use a 96-byte view of the same base address.
The source retains a separate typed view and the observed cast. The
relationship between these overlapping views and valid index bounds
remains unresolved. This procedure claims no workspace allocation and
adds no bounds checks.

## References and validation

The pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/io/pfsfilestate.c` corroborates the SDK file metadata and name fields
used by the existing Pak services. Robotron's complete procedures establish
the game-specific name stride, save signatures and resource copy. The
pinned IDO and Super Mario 64 matching-build references remain credited in
[the credits](../CREDITS.md). No reference implementation is copied into
these procedures.

Validation covers tooling tests, fresh extraction and build, every runtime,
startup, native assembly and data comparison unit, linked procedure extents,
both constant offsets and the exact USA ROM. A clean committed archive and
publication audit independently check the public sources.
