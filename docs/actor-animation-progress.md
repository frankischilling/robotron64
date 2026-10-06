# Actor animation progress research

The handler at `80032A00..80032CF4` contains 756 instruction bytes. Twelve zero
bytes separate it from the next function at `80032D00`. Its switch table at
`800941D0..800941FC` contains eleven entries, or 44 bytes. Complete spimdisasm
and splat references reassemble to the original bytes for both ranges.

The handler confirms two fields in the existing 88-byte
`EarlyGameActorResource` layout: `kind02` is an unsigned byte and `duration10`
is a signed halfword. The known scale at `0C` and callback at `54` keep their
offsets. The C header now agrees with the verified Ghidra layout.

Initialization installs `func_80005560` for kinds below eleven. Other kinds
select an object property through the byte lookup based at `80075F25` and set
the resource duration to 3,000. The lookup's complete storage extent remains
unknown. All kinds restart animation nine, scale the object by the wrapped
32-bit product of the resource scale and 36,864, converted to float and
divided by 40,960, and set actor mode one.

The update path subtracts the actor timestamp from the current clock with
32-bit elapsed-time wrapping. Animation zero expires only when elapsed time
is strictly greater than the signed duration converted to an unsigned word.
Expiry restarts animation one, clears flag `40` before calling the previous
completion callback, reloads its changed flags, and installs `func_8001B324`
with timer 999. Before expiry, kind eight halves elapsed time before byte
truncation; kinds zero, one, two, five, nine and ten use a triangular phase.
Other kinds retain the elapsed low byte. Rotation uses signed division.

Animation three uses unsigned division. Before elapsed time reaches 500, its
visibility period decreases from 300 and clamps to one. The angle mask is
applied before division by three. At 500 or later, the actor state becomes
two. Other animations produce no update effects.

The matching visibility setter `func_80039E5C` stores a byte at object offset
`13` and masks the input with `FF` into the return register in the return
delay slot. Its shared declaration and two local declarations now use `int`.
This corrects the interface without changing the stored byte or its callers'
behavior.

A pinned IDO layout probe verifies the resource's 88-byte size, every field
offset, and the one- and two-byte widths of the recovered fields. The type
and execution evidence is recorded in
[actor-animation-progress-provenance.json](actor-animation-progress-provenance.json).

The private animation candidate has the complete 756-byte function size and
reproduces all 44 table bytes, but 76 instruction words still differ. It is
excluded from source ownership. The table is also excluded because its
generated label relocations depend on the unfinished function.

A bounded permuter search lowered its score, but the ordinary recompiled
result changed the function size and failed the complete code and table
comparisons. The final candidate uses the shared resource layout; its fresh
comparison still differs in 76 instruction words.

A guarded execution audit compares 1,208 cases with retail and independent
state and call oracles. It executes the freshly matched animation, object
model, property and transform callees. The completion callback uses an ABI
stub that clobbers caller-saved integer and floating-point registers and can
change flags. The audit checks complete guarded buffers, call order, memory
and code bounds, stack preservation, saved integer registers, and division
traps. Three deliberately changed instructions are detected.

The records and lookup bytes in those cases are synthetic. Sound-enabled
tracks, the lookup's real extent, invalid required pointers and complete
gameplay are outside the audit. The HUD submission routine at `800371FC`
also remains private: its 248-byte frame and unspecified one-player argument
still need source recovery. No padding array is accepted to force its frame.

These declaration corrections add zero instruction, initialized-data or BSS
bytes. Full-ROM equality continues to include fallback code and assets.
The game remains incompletely decompiled.

Research uses the pinned IDO toolchain, Ghidra MCP, spimdisasm, splat, m2c,
asm-differ, objdiff, decomp-permuter and Unicorn. The local SM64 tooling
provides a reference for handling generated jump-table relocations; Robotron
instructions and complete byte comparisons determine the actual layout.
