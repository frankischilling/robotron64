# Movie string position submission

`func_80002D70` covers `0x80002D70..0x80002EE0`, or 368 instruction bytes.
It fetches a movie track's floating position and integer rotation through
`func_80004098`, converts the position, and forwards the result to
`func_8000177C`. The movie update caller supplies the string handle, track
index, frame, scale, three zero arguments, and the final string value.
The three zero arguments remain unused, as in the target.

The routine multiplies each position coordinate by `60000.0f`, divides by
`1400.0f`, and truncates to integer. It forwards X, Z, and negated Y in
that order. The first rotation receives a `0x800` offset. Scale is
multiplied by the double literal `0.7` before integer conversion. The final
arguments include three zeros, one, `D_800B6FEC`, `32767`, and the supplied
value. These expressions preserve the target's separate single and double
precision operations and floating control-register handling.

The local position structure contains three contiguous floats. A size
check verifies its 12-byte layout, and the cast used at the existing
array-based track interface exposes those three coordinates. The three
converted coordinate locals precede the rotation and position declarations.
IDO places the position at stack offset `0x4C` and the rotation words at
`0x60`, `0x5C`, and `0x58`, within the target's 112-byte frame.

## Complete instruction and storage comparison

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces every instruction
word. The compiler emits a 16-byte read-only block at `0x8008F828`: the
`60000.0f` literal, its alignment gap, and the `0.7` double. The entire
block matches the retail bytes. The source owns that complete block; it
adds no BSS or other initialized storage.

Acceptance checks the complete linked function type, size and placement,
current source/header/compiler inputs, all instruction words, the object
and linked constant block, and whole-ROM equality. This recovery adds one
matching C procedure, 368 instruction bytes, and 16 initialized bytes.
Complete hashes and build inputs are recorded in
[the provenance ledger](movie-string-position-submit-provenance.json).

Robotron's target instructions and its movie update caller establish the
arguments and preserved arithmetic. The pinned IDO and established N64
matching workflows are credited for local and online use in
[CREDITS.md](../CREDITS.md). Further scene/menu recovery is tracked in
[issue #45](https://github.com/frankischilling/robotron64/issues/45).
