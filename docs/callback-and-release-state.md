# Callback and release state

Four complete procedures match all 1,160 instruction bytes with the pinned
IDO 5.3 game profile. Three private BSS allocations own twenty bytes.
The [provenance ledger](callback-and-release-state-provenance.json) records
complete procedure extents, source inputs, storage layouts and comparisons.

| Procedure | Complete bytes | Behavior |
| --- | ---: | --- |
| `func_800544F0` | 256 | Register a callback in the first inactive slot |
| `func_800545F0` | 304 | Remove the first active callback with the supplied code |
| `func_8005C3E4` | 276 | Stop and release a hardware voice and update its owner |
| `func_80017ACC` | 324 | Resolve collision health and return the result byte |

## Callback slots

Both procedures first validate the audio context, then use the existing
lock and unlock helpers. Each eight-byte callback record contains an active
byte, a code byte, a signed value halfword and a function pointer. The shared
callback signature takes an unsigned code byte and a signed value halfword.

Registration compares the current callback count with the configured capacity.
It searches inactive slots, writes the code, clears the value, installs the
callback and increments the count. The original procedure does not set the
slot's active byte. Removal visits active slots until it finds the code or
has seen the recorded number of active callbacks. A match clears the active
byte and decrements the count. Both routines preserve the unsigned-byte
post-decrement loops, including their wrap when the counter reaches zero.

The registration work area begins at `0x801902F0`; removal begins at
`0x801902F8`. Each has two byte counters at offsets zero and one and a pointer
at offset four. Compiler private-symbol metadata and every relocated access
confirm these offsets. The adjacent command data starts at `0x80190300`.
The build retains each complete eight-byte allocation and excludes the
compiler's extra section alignment from source ownership.

## Hardware voice release

Release calls the existing SDK stop and free procedures for the selected
28-byte synthesizer voice. It selects the owning 80-byte game voice before
decrementing the context's active hardware count. It then decrements the
owner's hardware voice count. An owner with no hardware voices, its paused
bit set and its `0x40` bit clear receives the existing completion callback.
Finally, the status record's active, `0x40` and `0x20` bits are cleared through
the three original byte stores.

The selected owner pointer occupies four bytes at `0x80192B38`. Complete
instruction relocation and the neighboring owned decay work area at
`0x80192B3C` establish the boundary. The pointer remains private to the
procedure; no absolute linker assignment replaces its source definition.

## Collision result

A second actor with flag `0x100` returns `0x20`. Otherwise, a first actor
with resource kind at least four receives the existing collision damage
helper. Nonpositive health invokes its existing release helper. Positive
health creates effect 19 at the signed midpoint of the two supplied
positions, with the third coordinate cleared. Zero health in the second
actor sets result `0x20`.

The alternate branch retains the shipped conjunction that compares the
second resource kind with both one and two. Its subsequent checks and call
remain even though that conjunction cannot succeed. The source preserves
signed division by two and the unsigned-byte return from its word local.

## References and validation

The pinned local [libreultra](https://github.com/n64decomp/libreultra)
`src/audio/synstopvoice.c` and `src/audio/synfreevoice.c` corroborate the SDK
call interfaces and stop/free ordering. Robotron's complete instructions
establish the game logic and private storage. The project retains the pinned
IDO and Super Mario 64 compiler/build references described in
[the credits](../CREDITS.md). No reference implementation is copied here.

Validation covers tooling tests, fresh extraction and build, every runtime,
startup, native assembly and data comparison unit, linked function extents,
private storage metadata and publication provenance. A fresh committed
archive independently rebuilds the exact USA ROM. Existing shared-header
users retain their complete target instructions.
