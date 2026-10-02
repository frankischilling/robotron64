# Actor retirement and manual movement

Two complete C procedures replace 2,600 fallback instruction bytes. Their
generated switch table and movement diagnostic own 52 initialized bytes.
Both use pinned IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`.

| Function | Complete VRAM range | Instruction bytes | Source |
| --- | --- | ---: | --- |
| `func_800354C8` | `800354C8..80035CC8` | 2,048 | `src/game/actor_retirement.c` |
| `func_80035E3C` | `80035E3C..80036064` | 552 | `src/game/actor_manual_motion.c` |

## Retirement and animation

Only mode three runs retirement. The routine saves the player owner, advances
the byte at owner offset three, replaces the retiring actor's callback, and
updates its timestamp. Callback replacement clears the old flag and calls the
old callback before installing the new callback and timer.

For an other actor of kind zero, resource kinds zero through four and the
default copy the retiring actor's position and angle into the other actor and
use animation four. Resource kind five copies in the opposite direction,
replaces eight animation bytes, resets movement, and installs a delayed
callback. Resource kinds six through eight attach the retiring object's index
to the other object using models 108, 110, and 109 respectively. Kind seven
retains the angle-helper call whose result is overwritten, quarters the signed
animation duration, and creates kind-190 particles. Other actor kind one uses
its special animation bytes. The remaining path uses the generic animation.
Zero-speed sine and cosine calls remain present.

The final path either starts scene reset or selects a living player, then
applies object mode nine. Owner and player access reuse `GamePlayerState` and
`GameSessionState`, including the verified `0xDB4` player stride. The nine-entry
switch table at `80094294..800942B8` owns exactly 36 bytes. Its raw compiler
section has twelve additional zero alignment bytes, which are removed; the
following retail padding and diagnostic remain outside this ownership.

## Manual movement

The movement helper is gated by `D_8007394C`. Controller mode zero applies an
absolute deadzone of five to port-zero axes, adjusts the actor angle by
`stickX * 10 / 200`, and computes forward movement with
`stickY * 10 / 400`. Held input bits one and two rotate by minus or plus 55;
bits four and eight add or subtract the incoming movement speed. Other
controller modes use zero forward movement.

The helper stores sine and cosine velocities using signed division by 4,096
and updates object heading only when moving. `D_800BEF68` receives the actor
angle, with the port-zero X axis shifted by four added in controller mode one.
The caller selects the existing session input prefix or the player's prefix
at offset `34`; the helper reuses `EarlyPlayerInputState` and its held field at
offset `1C`. The diagnostic at `80094244..80094254` owns its 13-byte terminated
string and three zero alignment bytes.

## Compiler and representation assumptions

Pinned IDO retains the widened increment when compiling the two byte-counter
statements before modulo five. The retail sequence loads the unsigned byte,
adds one, starts division by five, stores the increment's low byte, and finally
stores the remainder. For input 255, the retail and pinned-IDO result is one;
portable C byte increment followed by modulo would produce zero. Algebraic
evaluation of the verified instruction sequence checks all 256 byte inputs;
255 is the sole difference. This is compiler behavior preserved by the exact
build, not a live emulator test or a portability guarantee.

The position copies retain the existing `TextValue3` view over coordinate
storage, and actor calls retain the project's partial `GameActor` views. These
are pinned N64 representation assumptions. Strict-aliasing-safe portable C is
not established. The no-op `func_8002E65C` retains its existing
`SessionSetupCommand *` declaration and receives an explicit object-pointer
conversion; it never dereferences that argument. The property setter uses the
already documented provisional module interfaces from
`actor-family-completion.md`, receives zero here, and has its result discarded.

## Validation and remaining work

`actor-retirement-and-manual-motion-provenance.json` records complete
instruction and generated-data comparisons, current source/header/compiler
hashes, clean extraction and full-ROM equality, all 151 tooling tests, and
Ghidra evidence. Ghidra retains the complete 512- and 138-instruction ranges,
typed interfaces, and all verified switch destinations. Its loaded CPU bytes
remain identical to retail.

The checkpoint contains 1,361 matching C functions and 255,832 instruction
bytes, plus 27,727 source-owned initialized bytes. Assembly and BSS remain
29 procedures / 4,372 bytes and 458,883 bytes. The provisional CPU interval has
194,364 fallback bytes in 222 ranges and 152 unclassified bytes. Whole-ROM
equality still includes extracted fallback ranges; the game is not fully
decompiled, and no complete function or executable-byte denominator has been
established.

The damage handler at `80035244..80035360` remains private with six differing
instruction words across its complete 284-byte extent. The actor family still
has the excluded 2,208-byte handler at `8002DDBC..8002E65C` with 27 differing
words. Neither candidate receives matching credit.
