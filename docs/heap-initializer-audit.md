# Heap initializer candidate and execution audit

`src/game/heap/initialize.c` remains an excluded candidate for
`func_8004DE8C`, whose complete retail body is `8004DE8C..8004DED8`.
The current void candidate publishes the aligned first-block address before
computing the header. It compiles to 76 natural function bytes and differs from
retail in thirteen instruction words. Its raw text section contains four more
zero alignment bytes, which receive no instruction credit. The preceding
candidate had a 68-byte natural body, eight alignment bytes in the 76-byte
comparison, and eighteen differing words.

Both versions align the arena start upward and end downward to four bytes,
publish the first-block pointer through `D_8013EBF0`, write the free-block header,
and place `-2` at aligned end minus four. The initializer preserves unsigned
wrapping arithmetic and performs no arena-validity check. The accepted allocator
supplies `80225800..803CDFFC` and ignores a return value. The original source's
return declaration remains unresolved; the existing two-pointer void interface
is retained.

Run `make check-heap-initializer` after installing the optional analysis
dependencies and setting up the user-supplied baserom. The checker freshly
compiles the public candidate and runs retail and C directly over 449 argument
and saved-register fixtures, comprising 417 distinct argument pairs. It compares
the three ordered writes and independently reconstructed memory windows, guards
memory accesses and executed code, checks the return PC, and verifies saved
integer registers, F20 through F31, SP, GP, RA and stack canaries. These are 449
paired comparisons and 898 principal fixture executions.

Ten controls are rejected: extra writes, wrong terminator placement, saved
integer and floating-register clobbers, unexpected reads and code execution,
missing return, and C mutations of the free bit, sentinel and post-header head
reload. The head reload is tested where the header aliases the global pointer.
Retail V0 equals the terminator in all fixtures; the void candidate agrees in
20. V0 is observed and excluded from void-interface equivalence.

The private research adds 98 complete source comparisons covering consumed head
access, return liveness, repeated alignment expressions and capacity stages.
None improves the thirteen-word void result. Original-optimizer diagnostics
reproduce every allocated section from pinned IDO and expose candidate register
assignments. They do not recover the retail compiler's missing intermediate code.

Fresh [Splat](https://github.com/ethteck/splat) and
[SPIM](https://github.com/Decompollaborate/spimdisasm) references independently
reassemble all 76 retail bytes. Candidate bytes, sizes, compiler identity,
controls and scope are recorded in [the provenance ledger](heap-initializer-provenance.json).
The reproducible checker writes `build/heap-initializer-execution/proof.json`.

Collision, undersized-bound and uncached-pointer fixtures are diagnostics; they
do not establish valid game allocations. Finite emulation does not prove
hardware behavior or complete gameplay. This change adds zero matching CPU,
initialized-data or BSS bytes. The initializer remains outside the ROM build,
and [issue #36](https://github.com/frankischilling/robotron64/issues/36) remains open.
