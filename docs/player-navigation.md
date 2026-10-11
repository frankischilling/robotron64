# Player navigation

`func_800330F8`, at `800330F8..800338CC`, contains 2,004 instruction bytes.
Its five O32 arguments are a `GamePlayerState` view, the actor, two output
coordinates and speed. The complete source in `src/game/player/navigation.c`
matches the retail function with pinned IDO 5.3, the existing O2/MIPS I profile
and the original 120-byte frame. No generated table or separate data allocation
belongs to this helper.

The function searches actor kinds 0, 5, 1, 7 and 3 in that order. The first
three searches produce avoidance headings after a signed coordinate-distance
filter. Kind 7 is eligible only when the player's saved field at `+0x6C` is
minus one. Kind 3 uses animation zero; the other searches use `0xDEAD`.
The nearest-search helper retains all five arguments, including that animation
filter.

Avoidance prefers kind 0, then 1, then 5. With both attraction targets, the
destination weights kind 3 by three and kind 7 by two, then divides by five.
The attraction offset is clamped to `-0x300..0x300` around the avoidance
heading. Without avoidance, kind 7 takes priority over kind 3. Further branches
steer around a phase-driven circle or back toward the origin. Output velocity
is written only when a heading was selected. The return value is the original
nearest kind-0 actor, even if the distance filter discarded it.

Retail contains a contradictory resource-kind condition: less than five and
at least nine. The source retains this branch, its signed divisions and its
original threshold. Removing it changes the full function. The source also
keeps the original ordering of search and trigonometric calls.

Independent splat and spimdisasm references reassemble every retail byte.
Live Ghidra memory and the complete boundary agree with those references.
The matching comparison covers the entire function, relocations and natural
size; it removes only zero assembler alignment after the verified body.
The linker replaces the complete `33CF8..344CC` fallback region.

Run `make check-player-navigation` with the supplied baserom to repeat the
full source comparison and 512 paired execution fixtures. All ten actual
callees execute and are freshly compared across their complete 1,208 instruction
bytes. The complete 2,048-byte source sine table also matches retail; the angle
lookup table is supplied from retail memory. The checker compares returns,
callee arguments and order, output writes, bounded reads and integer O32 ABI
preservation. Eight deliberate source mutations must fail with a passing
baseline before and after each failure. This finite corpus does not establish
complete gameplay or ownership of the angle lookup table.

The caller's `PlayerBehaviorState` view is explicitly cast to the existing
`GamePlayerState` view at this call. Both describe the same 0xDB4-byte storage;
the argument registers and callee contract are unchanged. The excluded caller
still differs from retail and remains tracked by [issue #144](https://github.com/frankischilling/robotron64/issues/144).

Tools used: [Ghidra MCP](https://github.com/bethington/ghidra-mcp),
[splat](https://github.com/ethteck/splat),
[spimdisasm](https://github.com/Decompollaborate/spimdisasm),
[m2c](https://github.com/matt-kempster/m2c),
[asm-differ](https://github.com/simonlindholm/asm-differ),
[objdiff](https://github.com/encounter/objdiff),
[decomp-permuter](https://github.com/simonlindholm/decomp-permuter),
MIPS binutils and Unicorn. Tool-derived assembly and commercial ROM data remain
in ignored local evidence directories.
