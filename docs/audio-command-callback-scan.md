# Audio command callback scan

`func_80059964` delivers a voice command to an active callback record. Its
complete range is `0x80059964..0x80059A88`, with 292 instruction bytes.
It extends `src/game/audio_engine_parameters.c` to fourteen complete
procedures and 496 instruction bytes. The thirteen parameter handlers
already occupy the preceding 204 bytes.

The scanner copies the context's active callback count into its static
count byte. A zero count skips scanning and leaves its previous cursor and
index unchanged. Otherwise it starts at the callback array and scans up to
the slot-capacity byte `D_8008D857`. The unsigned index decrements before
each iteration and retains its wraparound behavior.

Inactive records consume a slot without consuming the active count. An
active record whose code matches the command receives a signed halfword
formed from command byte 2 and byte 3 in little-endian order. The function
calls that record's callback with its unsigned code and signed value, then
stops. An unmatched active record decrements the active count; reaching
zero also stops. The static cursor and index retain the selected or final
record state on each path.

## Source state and compiler evidence

The complete source-private BSS span is `0x80192764..0x80192770`, twelve
bytes. It contains the four parameter-handler mirrors, the scan index and
active count, and the callback pointer. The signed mirror at `0x80192766`
and pointer at `0x8019276C` establish their alignment; the one-byte gap at
`0x80192765` belongs to the compiler layout. The ownership record checks
all seven static definitions and their exact offsets using IDO metadata.
This state consumes no ROM bytes.

The scanner's static variables let IDO retain values in registers while
preserving the required global stores around calls and exits. The explicit
member access `(*D_8019276C).code` produces the target's comparison operand
order. This is the same C member access as `D_8019276C->code`; it changes no
game behavior. A local decomp-permuter search suggested that source form.
The entire 496-byte unit was then rebuilt and compared independently,
including every preceding handler.

The compiler is IDO 5.3 with the verified game profile
`-O2 -G 0 -non_shared -mips1 -32`. Acceptance requires complete instruction
bytes, linked function types, sizes and placement, the twelve-byte BSS
layout, current source/header/compiler identities, and full ROM equality.
Instruction patches, inline assembly, dummy expressions, and unused padding
locals are absent.

Complete procedure hashes, build inputs, and BSS ownership are recorded in
[the provenance ledger](audio-command-callback-scan-provenance.json).

A clean archive of `97540ad` passes all 137 tooling tests, fresh extraction
and build, 783 complete runtime units, both startup units, eighteen assembly
units, and eight data-only units. Linked verification reports 1,299 complete
matching C functions and 216,836 instruction bytes. Source ownership totals
9,531 initialized bytes and 30,353 BSS bytes. The rebuilt USA ROM matches
byte for byte, and the publication audit checks all 1,257 public files.

Robotron's instructions establish the command fields, signed value,
callback arguments, scan stops, and retained state. The IDO compiler
materials and established N64 decompilation workflows remain the compiler
references. The local and online
[decomp-permuter project](https://github.com/simonlindholm/decomp-permuter)
supplies the search tool; its result is accepted only after independent
complete comparisons. All references, pinned revisions and notices are in
[CREDITS.md](../CREDITS.md). Further audio recovery is tracked in issues #34
and #37.
