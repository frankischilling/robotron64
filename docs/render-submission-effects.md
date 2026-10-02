# Fan, prism, and image setup recovery

Five complete C candidates reconstruct two seven-sided fans, a twelve-vertex
prism, and the setup wrappers for indexed and RGBA image squares. They remain
excluded from the matching build. Their 4,164 retail instruction bytes still
come from extracted fallback.

| Procedure | Retail range | Retail bytes | Compiled bytes | Differing words |
| --- | --- | ---: | ---: | ---: |
| `func_8000BEC0` | `0x8000BEC0..0x8000C2F4` | 1,076 | 1,008 | 241 |
| `func_8000C2F4` | `0x8000C2F4..0x8000C75C` | 1,128 | 1,056 | 261 |
| `func_8000C75C` | `0x8000C75C..0x8000CD50` | 1,524 | 1,472 | 326 |
| `func_8004ACA4` | `0x8004ACA4..0x8004AD64` | 192 | 192 | 4 |
| `func_8004AFA4` | `0x8004AFA4..0x8004B098` | 244 | 244 | 4 |

The source owns 24 additional initialized bytes and twelve additional BSS
bytes. These sections pass complete byte, symbol-offset, size, and placement
checks. They contribute no new matching instructions.

## Seven-sided fans

Both fans prepare an identity matrix, select renderer mode one, and request
vertices. Failure returns one before actor, object, or vertex changes. On
success, the actor's signed halfword at `0x0C` selects a 120-byte object record.
The object position is made relative to the camera and shifted right by one;
the camera matrix transforms it into the three words at object offset `0x60`.
The draw submission receives the object prefix at `0x38` and the identity
matrix.

Radius starts at 120. A random multiplier from 100 through 114 is applied
before division by 100. Brightness is drawn from 200 through 254. These upper
bounds follow the already matching random helper's exclusive maximum. Seven
uniformly spaced perimeter vertices use angles `i * 4096 / 7`, the existing
integer cosine and sine helpers, and an arithmetic shift by twelve.

The first fan forces brightness to 255 when actor field `0x4C` is nonzero.
Its center is yellow with alpha 255. Perimeter vertices receive brightness in
red and zero in the other three color bytes. The second fan writes three to
actor field `0x4C` after successful allocation. Its center has four zero color
bytes; its perimeter uses half brightness for red and green, full brightness
for blue, and alpha 255. Signed division by two is retained.

Each procedure loads eight vertices with `0x0400207F`, emits seven triangles,
wraps the final edge to perimeter vertex one, advances the cursor by eight,
and returns zero. The handler typedef, color presets, and dispatch wrappers
now carry the integer result consistently. Both presets, both dispatch
wrappers, and the selector retain their complete 308-byte instruction match.
The return type alone does not establish how every indirect caller uses the
result.

## Twelve-vertex prism

The prism also returns one on allocation failure and zero after successful
submission. Its actor-coordinate conversion uses single-precision arithmetic:
multiply by 1,400, divide by 60,000, then convert to signed integers. Input axes
are read in the order zero, two, one. The first and third values are multiplied
by twelve. Camera subtraction and shifts follow; the middle coordinate is
replaced with 700 before camera subtraction. The source retains the earlier
conversion even though its stored middle result is replaced.

Three rings at depths -950, zero, and 950 contain four vertices each. Angles
descend through 3,072, 2,048, 1,024, and zero. The outer rings use radius 60 and
RGB `(50, 50, 100)`. Each middle-ring vertex draws a radius from 60 through 89.
A shared random value from zero through 54 gives middle RGB
`(100 + value, 100 + value, 200 + value)`. All vertices use alpha 128.

Depth is scaled by `(255 - actor->field4C) >> 8`. Bit ten of the actor's signed
angle halfword selects whether this depth occupies Z or X; cosine occupies
the other axis and sine occupies Y. The source preserves both branches and
their coordinate store order. A twelve-vertex load (`0x040030BF`) precedes
eight quad packets connecting successive rings. No end-cap packets are
emitted. Successful submission advances the vertex cursor by twelve.

The complete four-byte 60,000 float at `0x8008F970..0x8008F974` is source-owned
initialized data. IDO emits this named, const-qualified definition in `.data`.
Its value is independently checked against the retail bytes; the selected
section does not establish its original translation-unit boundary.

## Image square setup and placement state

The indexed wrapper selects mode fifteen, restores texture defaults, and
sets the texture-perspective field to zero. It fills three scale words from
`D_8008CB34`, clears the angles, and copies the current three projected-position
words into a local draw prefix. It submits that prefix through `func_80047570`,
loads the existing palette, sets alpha to 255, and calls the already matching
indexed-square procedure with extent twenty.

The RGBA wrapper submits the same scale, angle, and projected-position fields
before selecting mode fifteen and restoring texture defaults. It emits the
additional zero texture-filter field and `0xB900031D / 0x00553078` render-mode
packet, sets alpha to 128, and calls the matching RGBA square with extent forty.

Both wrappers reproduce every instruction except the stack allocation,
incoming-argument store, later argument reload, and stack restoration. The
indexed retail frame is 120 bytes versus 96 compiled bytes. The RGBA retail
frame is 128 versus 104. All local field offsets, calls, commands, and their
order match. This suggests that the full original local draw type or other
local storage is larger than the currently established 60-byte draw prefix.
It does not prove a larger structure layout. No unused local storage or type
padding has been added to force these four words to match.

The five initialized placement words at `0x8008CB24..0x8008CB38` are integers
zero, zero, 255, float 0.25, and integer four. The three projected-position
integers at `0x8013D9A0..0x8013D9AC` occupy BSS. Their 32-bit loads and stores
also occur in the already matching placement and scale setters. The new shared
header gives those setters and candidates the same declarations; all four
setter/helper procedures retain their complete 140-byte instruction match.

## Verification and remaining work

The candidates use the current IDO 5.3 game profile,
`-O2 -G 0 -non_shared -mips1 -32`. Tests with IDO 7.1, MIPS II, other optimization
levels, debug options, and different array/matrix declarations did not produce
a complete match. Stack allocation, loop induction, constant propagation,
register assignment, and scheduling remain unresolved in the three effects.
Equal lengths in the image wrappers do not establish a match.

The [provenance ledger](render-submission-effects-provenance.json) records
complete data ownership, current input identities, compiled candidate hashes,
and regression comparisons. Candidate differences are recorded as counts;
retail instruction dumps and binary assets are not published. Existing tube
and star evidence is refreshed against the same inputs.

All Robotron-specific behavior comes from the user-supplied target ROM.
The local libreultra and Super Mario 64 GBI headers supply the previously
established command-field definitions. No implementation was copied from a
reference game. Their revisions and attribution appear in
[CREDITS.md](../CREDITS.md). Issues #56 and #41 track the remaining effect and
renderer matching work; graphics microcode identification remains open in #6.
