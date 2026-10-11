# Random-color background grid

`func_80040BA0(int horizontal, int vertical)` occupies the complete
`80040BA0..80040F5C` range, ROM `417A0..41B5C`. Its 956 instruction bytes
compile with the pinned IDO 5.3 game profile. The raw `.text` has four further
zero alignment bytes; these are excluded from source instruction totals.
The function generates no initialized data, BSS, or jump tables.

The matching background dispatcher calls it with `(5, 5)` and `(10, 4)`.
It divides the signed global extents by these half-dimensions, sets graphics
mode two, and generates `(2*horizontal+1)*(2*vertical+1)` vertices. Each vertex
makes three discarded sine calls, advances the captured clock by 40, and
draws three random values in `[0,64)`. Their order in the vertex is third,
first, second, followed by alpha 128. Position Z is 32000. Vertex flags and
texture coordinates retain their previous bytes.

Each cell passes four byte addresses to the matching quad submitter, which
emits four vertex loads and two triangles. The address expression scales
the X offset, horizontal origin, and row offset separately. Combining them
as one array subscript changes IDO's induction variables and register use.
Two local values are reused across phases: the second corner scalar first
holds the allocation sentinel, and blue first supplies a random-call bound.
Both initial values are consumed. These names and source arrangements are
reconstructions, not surviving original developer names.

Run `make check-renderer-random-grid PYTHON=/path/to/analysis/python` for
fresh complete instruction comparisons and guarded MIPS execution. The
harness checks 384 retail/candidate pairs, including both dispatcher grid
sizes, smaller grids, negative dimensions, clock wraparound, signed extents,
two RNG seeds, allocation failure, pool index zero, the last fitting pool
allocation, and mode changes. Ten freshly compiled,
independently matching support units execute without ABI stubs. It compares
call order and arguments, complete display-list packets, vertices, counters,
RNG state, permitted reads/writes, stack canaries, SP/GP/RA, saved integer
registers, and all twelve saved floating words through guest COP1 probes.
Four separately compiled source faults change the phase, corner address,
channel, and extent divisor; each follows an unchanged positive execution.

The proof covers CPU-side packet generation. Diagnostic formatter branches,
zero-divisor traps, RSP processing, and complete visual gameplay are outside
the execution fixture. Exact instruction equality includes the retail divide
guards. No completion percentage is inferred from this recovery.

This replaces one 956-byte fallback span: source-owned C totals increase from
1,437 functions / 321,808 instruction bytes to 1,438 / 322,764. Initialized
data and BSS ownership do not change. The rest of the game remains incomplete.

Analysis used the existing Ghidra `robotron64.elf` program and MCP, the retained
spimdisasm reference independently reassembled with MIPS binutils, m2c with
current C context, objdiff, decomp-permuter with stack comparisons, and the
existing Unicorn/Capstone/pyelftools tooling. Tool revisions and attribution
are recorded in [the matching tool documentation](matching-tools-current.md).

The [provenance ledger](renderer-random-grid-provenance.json) records the complete
references, compiler identity, guarded execution, and clean integration results.
