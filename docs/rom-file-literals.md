# ROM-file literals

Seven terminated arrays replace 101 initialized fallback bytes. The failure
format and missing-file message live beside their existing consumers; location,
resource prefixes and the stream extension live in `src/game/rom_files_data/`.
Definitions retain the original bytes and unsigned-character declarations.
Separate data units keep every inter-array and following zero outside ownership.

The first NUL fixes each credited extent. Array lengths are 16, 52, 10, 6, 6, 6,
and 5 at `80095B40`, `80095B50`, `80095B84`, `80095B90`, `80095B98`, `80095BA0`,
and `80095BA8`. Layout assertions and ownership checks require the C definitions
at those retail addresses. The existing 100-byte failure function and complete
560-byte ROM-file block must remain byte exact. No new instruction or BSS
ownership is claimed.

`make audit-rom-file-literals` compares every array and complete consumer/helper
range, verifies compiler array extents, and runs bounded file lookup, size,
copy and resource-prefix cases with independent memory/call oracles. Directory
initialization, PI reads, script relocation and fatal reporting use checked
service boundaries. Missing-file and failure fixtures stop before their unsafe
continuations; the failure routine's division by zero is outside this audit.
Arbitrary aliases, actual cartridge I/O and full gameplay remain unverified.

The audit passes 345 paired cases and detects fourteen character/terminator
mutations. Returning service boundaries clobber caller-saved integer and FPU
registers; returning consumers preserve integer O32 state and twelve distinct
saved FPU words. Complete literal oracles also cover terminators that bounded
prefix comparisons do not read.

Independent Splat and spimdisasm reassemblies reproduce all seven aligned banks.
Their eleven following zero bytes are checked against retail but receive no
ownership. Ghidra xrefs agree with the retail consumers. The extension's type
is inferred from its bytes and terminating string comparison; its original
Ghidra location was undefined.

The supplied USA ROM provides the bytes and instructions. Ghidra, Splat,
spimdisasm, pinned IDO, MIPS binutils and Unicorn are credited in
[CREDITS.md](../CREDITS.md).
