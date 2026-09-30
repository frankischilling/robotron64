# Controller Pak notice drawing

`func_8004B340` occupies `0x8004B340..0x8004B45C`, or 284 instruction bytes.
Its complete C object matches with the pinned IDO 5.3 game profile. The
compiler-emitted string block at `0x800954B0..0x800954C4` also matches all
20 bytes, including its terminator and one alignment byte.

The routine draws `new controller pak` when state `D_80075FB8` is three
and the unsigned difference `D_8009EFA4 - D_800BAE88` is below 5,000.
The unsigned subtraction and comparison preserve wraparound behavior. The
clock unit is not assigned a name here. States zero, one, and two have empty
cases; other states also skip the notice.

The active path emits a pipe synchronization command and calls the existing
draw setup helpers. It starts X at 50 and submits twice that value, with Y
`-78` and Z `200`. Every character advances X by `-6`, including spaces.
Spaces skip glyph submission. The loop calls the string-length helper before
each iteration, as the target does. All paths finish with `func_80049DB0`.

Holding the literal through a local pointer and keeping the doubled coordinate
expression reproduce the target's induction variables and register allocation.
The literal has its own source-owned readonly section; its bytes are not taken
from an executable fallback range.

The [comparison ledger](renderer-controller-pak-notice-provenance.json) records
the complete procedure and readonly block, compiler profile, and input hashes.
A clean archive of commit `2ee8dd2` passed all 137 tooling tests, fresh extraction,
build, ROM verification, and independent comparisons of 776 runtime units,
two startup units, 18 assembly units, and six data units. The resulting progress
report contains 1,288 matching C functions and 210,996 instruction bytes.

The supplied Robotron 64 USA ROM determines the notice, control flow, command,
and coordinates. The N64 projects and compiler sources consulted for the build
and matching workflow are credited in [CREDITS.md](../CREDITS.md). Completion
requires the full object and string comparisons, actual linked procedure
metadata, current input hashes, and a byte-for-byte ROM build. Other renderer
and Controller Pak routines remain unfinished.
