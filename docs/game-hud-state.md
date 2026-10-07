# HUD state dispatch

`func_800371FC` owns the complete 524-byte retail range
`0x800371FC..0x80037408` (ROM `0x37DFC..0x38008`): 131 MIPS instructions,
including the return delay slot. Its IDO function symbol naturally has that
size. It contributes no initialized data, BSS, or generated tables.

The function gathers player statistics and calls `func_8004B590` with fifteen
integer O32 arguments. The first seven are the primary player's score, level,
lives, fields at `0x70`, `0x74`, and `0x6C`, and the unsigned byte at `0x01`.
The next seven describe the secondary player in the same order; the last is
the player count. Address-based names and generic field names remain where
the retail reads establish the layout but not a broader gameplay meaning.

Mode 2 always uses player zero as the primary player, even when the selected
player is nonzero. It copies player one's statistics and powers, and reports
two players. When the selected player is zero, the scene supplies the primary
level and the stored secondary level is clamped to at least one. Otherwise,
the stored primary level is clamped and the scene supplies the secondary
level. Other modes select the primary player by index, zero the six secondary
integer fields, and report one player. Retail leaves the secondary powers
stack word uninitialized in these modes; the source preserves this behavior.

HUD dispatch requires `D_800AD284 == 0`, scene `resourceCD4 == -1`, and
`D_800AD288` equal to 3 or 4. With `D_800AD1C8` clear, the function forwards the
computed primary level. Otherwise it reads the animation actor's signed
halfword at `0x10`. A closed gate never reads that actor. The HUD drawing
callee's 1,588-byte range remains extracted fallback code; this recovery
does not establish framebuffer or gameplay correctness for that callee.

The secondary snapshot uses the existing 160-byte `SavedPlayerState` record.
Its three newly exposed integer fields split the previously unknown region
at `0x6C`, `0x70`, and `0x74`; the record and 3,508-byte `GamePlayerState`
retain their sizes. The record explains the retail 248-byte stack frame
without padding objects or unused local variables. `value24` holds a local
display level here; this use does not establish a global meaning for that
saved field. The comma expression joining the last zero initialization and
player-count initialization preserves IDO's retail instruction scheduling.

The six address views in the linker maps are offsets into the already owned
player and session records, rather than additional storage allocations.

## Verification

Splat and spimdisasm independently produce assembly for the full range. Each
reference is reassembled with MIPS binutils and checked against all 524 retail
bytes before it is used by m2c, asm-differ, or objdiff. The source is compiled
with pinned IDO 5.3, with complete instruction, symbol-size, section, and
relocation checks. Cached tool scores are research aids, not acceptance proof.

Run the public execution guard with:

```sh
python3 tools/check_game_hud_state.py --mutations
```

The guard checks 595 paired retail/source cases covering level boundaries,
display gates, signed actor levels, single-player stack seeds, and mode-2
selection. It independently checks all fifteen arguments, exact stack writes,
whole-record canaries, memory bounds, integer ABI preservation, and preserved
floating-point registers after a caller-clobbering HUD stub. Eleven isolated
source mutations must fail. Four additional executions must reject reads
outside the two-player pool. The stub validates dispatch rather than executing
the excluded drawing callee. The provenance ledger records the accepted
public-source run, layout probes, fresh comparisons, and clean ROM build.

The repository's runtime, startup, assembly, and data comparisons and tool
tests remain required. An equal full ROM still contains extracted fallback
regions and is not evidence that the whole game has been decompiled.

Tools and references are credited in [CREDITS.md](../CREDITS.md). The retail
binary remains the authority for instruction bytes and behavior.
