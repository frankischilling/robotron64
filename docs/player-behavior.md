# Player movement, aiming and death behavior

`func_80033974` occupies `80033974..80035190`, or 6,172 instruction
bytes. Its ten-entry animation dispatch table is at `80094254`; the
six-entry weapon table follows at `8009427C`. Together they occupy all
64 bytes through `80094294`. Splat and a separate spimdisasm reference
reassemble the complete code and both tables exactly. The original ROM
remains the authority for these boundaries and behaviors.

The C candidate is `src/game/player/behavior.c`. It has 6,092 natural
instruction bytes, a 200-byte frame and 64 generated dispatch bytes.
Retail uses a 184-byte frame. The complete comparison differs in 1,509
code words and sixteen table addresses. The source is excluded from the
matching manifest and ROM link. It adds no instruction, initialized-data
or BSS ownership. [Issue #144](https://github.com/frankischilling/robotron64/issues/144)
tracks the remaining matching work.

## Runtime views and decisions

The function sets the current actor, resets the shared aiming angle to
minus one, adds actor flag `0x2000` and sets Z to 500. Animations zero and
eight handle movement when the game mode is three. Animation one handles
death and reactivation. The other entries return after the common final
angle update.

The shared player allocation has a 3,508-byte stride. The runtime view in
`player_behavior_internal.h` preserves that size and the existing actor
and saved-player views. Input begins at player offset `0x34`. Its sampling
view is 36 bytes; the selection word at input offset `0x24` extends the
copy view to 40 bytes. Handoff copies those 40 bytes into the session.
Ghidra contains the same field offsets and sizes, independently checked
with IDO. The MCP applies its own field-name prefixes; the field mapping
is retained in the private analysis receipt.

The input source switches between the player prefix and the session.
Charge increases by four times the frame delta while the low four pressed
bits are set, otherwise it decays by one delta. A sufficiently charged
player can release a child actor, reverse its angle, assign trigonometric
velocity and decrement the attached-child count. Pressed bits `0x800`
and `0x1000` consume the two ability selections through the existing
selection-clear helper. Both calls explicitly pass the same player allocation
in `a1`, using the shared `ScenePlayerRuntime` view. The helper forwards that
word to the scene action handler; its three selected actions ignore it.
The helper's complete 132-byte body and 40-byte frame remain matching.

Movement handles primary-stick thresholds, directional buttons, secondary
aiming, signed scaling and diagonal reduction. The actor's tentative
position is checked against square bounds and the optional diamond bound.
A boundary call restores the saved position at the common exit. Aiming
uses directional input or an AI target, then selects single, opposite,
spread or offset projectile patterns from the signed weapon selection.
The projectile calls supply five O32 words. The fifth is 185 or minus one,
according to the weapon pattern. The constructor ignores this word; its
returned actor's velocity controls the second position in the offset pattern.
The shared declaration preserves the observed outgoing argument without
assigning it a gameplay meaning.

Death handling includes invulnerability timing, display blinking, animated
scale and Z updates, life decrement and selection of another live player.
Unsigned clock subtraction preserves timer wraparound. Existing apparent
quirks, including repeated frame-count calls, remain in the candidate.

## Reproducible audit and limits

Run `make audit-player-behavior` with the documented analysis Python
environment. It freshly compiles the complete candidate with pinned IDO,
checks its natural size, all sixteen table relocations and table target
bounds, and compares every code and table byte with retail. It also
freshly compiles and compares the complete signed-shift, absolute-value,
memory-copy and relative-aiming helpers before executing their real
instructions in both images.

The finite corpus contains 1,752 retail/source pairs, or 3,504 executions.
It covers all ten animation states, both players, input thresholds,
ability slots, charged release, six weapon selections, death timing,
player handoff, square and diamond boundaries, and clock wraparound.
All 26 callee entries are exercised. The checker compares call traces and
every nonstack byte written by either execution, enforces guest memory
widths and fixture allocation bounds, checks the natural stack frame and
guards, and verifies preserved integer and floating-point registers.
Fourteen source mutations and seven guest faults must fail between passing
retail/source baselines.
Two source controls deliberately pass the actor instead of the player to
each ability slot. The observer records both O32 argument words, so these
mistakes fail even though its synthetic selection-clearing effect ignores
the forwarded player. The helper and actual scene action handler are also
covered by `tools/check_scene_actions.py`, including an unmapped unused
player word for the clear helper's selected actions.

Two further source controls corrupt the primary and secondary projectile
words. All five constructor arguments are observed, including the unused
stack word. These controls check the retail call trace, not a gameplay effect.

The original 1,536 random fixtures left the separate player-count word at
session offset `0x2C` zero. They exercised the empty-search exit but did not
prove handoff to a live player. The additional 216 cases initialize counts
zero, one and two, both starting players, four choice orders, live and dead
alternatives, and elapsed times 1,000, 1,001 and 2,001. The checker independently
derives the bounded search result from those inputs, checks the selected player
and index, and compares all 40 copied input bytes. Its receipt reports the
actual handoff, exhaustion and wrap counts. Five further source controls
corrupt wrapping, choice indexing, liveness, copy length and the failure count.
Each must fail on an expired positive-count search between passing baselines.

The remaining 22 callees use explicit returning O32 observers. Their
effects and returns are synthetic fixture models. Observers clobber
caller-saved registers; constructor output, AI output and ability clearing
are bounded fixture operations. The audit compares the two implementations
under those boundaries. It has no independent model of the entire game
state and does not prove unrestricted gameplay or matching ownership.
The normal rebuilt ROM still uses retail fallback for this function.

The complete private split is reproducible from
[`config/analysis/player_behavior.yaml`](../config/analysis/player_behavior.yaml).
Keep all extracted banks and reference objects outside Git. Tool and
reference credits are in [CREDITS.md](../CREDITS.md).

## Navigation helper

The called [navigation helper](player-navigation.md), `func_800330F8`, now
matches all 2,004 retail instruction bytes and replaces its complete fallback
range. Its separate audit executes ten real callees. The larger caller remains
excluded, and its existing audit still uses the explicit AI-output observer
described above. The shared declaration uses the existing `GamePlayerState`
view; the call casts the identical player storage without changing the O32
arguments. The caller's complete 6,092-byte candidate and 64 dispatch bytes
are rechecked with the navigation, selection-clear and projectile declarations.
