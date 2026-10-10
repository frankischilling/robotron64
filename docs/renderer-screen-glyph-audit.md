# Screen glyph state and execution audit

The screen glyph at `80049E3C..8004A2B4` reads and writes the four-byte
clock at `800CD2B0`. After vertex allocation succeeds, it adds ten and
passes the result to the short-angle sine routine. Allocation rejection
preserves the clock. The source declaration owns exactly four BSS bytes,
ending at the existing color-wave state at `800CD2B4`. It adds no ROM data
or matching instructions.

Run `make check-renderer-screen-glyph` with the dependencies in
`requirements-analysis.txt`. The checker independently executes the full
retail function and current C candidate through 816 paired cases. It covers
all 256 character bytes, promoted argument truncation, three allocation
states, both matrix buffers, two matrix cursors, scale and position bounds,
32-bit color values, and clock wrap.

Eight freshly matched support units execute as MIPS code: glyph mapping,
fixed math, matrix transformation, short sine, short cosine, fixed trig,
graphics allocation, and the debug leaf. There are no callee stubs. Separate
oracles check command words, packed matrices, vertex coordinates, colors,
texture coordinates, font selection, call order and global state. Memory
access guards, canaries and ABI checks constrain each execution. Source
mutations and invalid guest storage must be detected before the audit passes.

The complete glyph candidate remains nonmatching and outside instruction
ownership. These finite CPU fixtures exclude fatal matrix exhaustion and
vertex-commit exhaustion; they do not establish RSP/RDP output or gameplay.
The public draw-state type is retained. Private smaller transform views
receive no ownership from this work. The full source-recovery goal and
[issue #61](https://github.com/frankischilling/robotron64/issues/61) remain open.

Robotron's original instructions and mapped neighbors establish the clock
address, access width and behavior. The [acceptance ledger](renderer-screen-glyph-provenance.json) records independent
full-range references, pinned IDO comparisons, execution controls, BSS layout,
clean-ROM verification and test results. Tool and workflow references are
listed in [CREDITS.md](../CREDITS.md).
