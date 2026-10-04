# Boss update

`src/game/actor_groups/boss_update.c` reconstructs the complete 668-byte
routine at `800107A0..80010A3C` and its 24 initialized bytes at
`800736B8..800736D0`. Fresh complete comparison verifies every instruction
and initializer byte with the pinned IDO 5.3 game profile.

The routine always updates light entry 186. It then requires a ready,
nonnull animation actor with state zero. Animation five and session index
two select triple playback speed; other combinations use the base speed.
The resource's already verified signed halfword at offset `50` receives
the narrowed result.

Unsigned clock differences strictly greater than 100 permit the effect
and single queued spawn. A pending burst takes precedence and requires
a difference strictly greater than 700, then submits indices zero through
nine with kind four. The single spawn uses index five and kind nine.
Timestamps update before the calls, and counters reload and decrement
after them. The session actor, clock and player index are reloaded where
retail reloads them; callees may change this shared state.

The current actor's signed value at offset `10` is copied to the selected
player's saved value at offset `24`. Nonpositive actor and global values
clear the ready flag. Failed initial gates still perform the light update.
The source preserves integer wrap, signed narrowing and unchecked required
resource pointers rather than introducing new runtime checks.

Retail retains copies of `{20000, 20000, 0}` and three four-byte initializers
`00 FF 00 00`, `FF 00 00 00`, `00 00 FF 00`. The resulting stack bytes are
never read again. Measured word and byte aggregate views retain these copies
without claiming the original declarations or their intended uses. These
source-private definitions use initialized `.data`, as the compiler emits
for the accepted source form.

The 80-byte frame includes an unused eight-byte region at offsets `48..50`.
The source represents that measured region as opaque storage; its original
local type, allocation and purpose are unknown. No instruction padding,
assembly, volatile qualifier or alternate compiler profile is used.

The original ROM and independently reassembled MIPS establish this recovery.
The requested tools and reference projects remain credited in
[CREDITS.md](../CREDITS.md).

The optional checker runs 6,936 cases against independent byte and call
expectations, retail instructions and newly compiled source. It covers all
three initial gates, both lighting choices, animation/index combinations,
speed wrap and signed narrowing, both saved players, positive/zero/negative
health, exact timer thresholds, clock wrap, burst precedence, and zero,
positive and negative pending counters.

The complete matching lighting unit executes real C. Effect creation,
trigger dispatch and queued spawn use integer-register ABI stubs. Synthetic
boundary mutations change shared actor pointers, player selection, clocks,
counters and health to verify retail reload behavior; they do not establish
actual callee side effects. Full guarded records, initializer bytes, code,
stack gaps, stack restoration, saved integer registers and `gp` are checked.
Required pointer faults, complete gameplay and floating-point register
preservation remain outside this proof.

```sh
python3 tools/check_boss_update.py
```

Splat/spimdisasm assembly reassembles the complete range independently.
The raw objdiff view retains ten relocation-argument differences because
retail address aliases and IDO's static-pool/player-base expressions have
different symbol names. There are no instruction-shape differences. Fresh
matching and asm-differ verify the complete resolved retail bytes; an
independent 24-byte data object also scores 100 percent. Only four external
text-alignment bytes and eight external data-alignment bytes are removed.

Ghidra records the verified void prototype, measured initializer types,
data names, comments and references. The game-state routine calls this
update at `800248D8`; that caller retains fallback ownership.

The [provenance ledger](boss-update-provenance.json) records final inputs,
independent comparisons, guarded execution and complete build evidence.

Full independent checks pass for 879 runtime units, two startup units,
18 assembly units and 115 data-only units. All 155 tooling tests pass.
Native and fresh isolated clean builds both match all 8,388,608 ROM bytes.
Current matching C totals 1,397 functions and 284,660 instruction bytes;
initialized ownership totals 31,223 bytes and BSS ownership 505,131 bytes.
The provisional CPU inventory still contains 165,536 fallback bytes in
204 ranges and 152 unclassified bytes. Total executable bytes and function
count remain unknown; this is a verified recovery checkpoint, not complete
decompilation.
