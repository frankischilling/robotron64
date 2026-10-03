# Scene actions

The complete action handler at `8001B8D8..8001BBAC` contains 724 bytes and
181 instructions. The pinned IDO 5.3 game profile reproduces the full range
and its 32-byte stack frame from `src/game/scene_actions/dispatch.c`.
The compiler emits the fourteen-entry switch table at `800903E8..80090420`,
56 initialized bytes. No table entries or instruction words are patched.

Selection -1 returns immediately. Other selections are cleared to -1 after
their action, including negative values other than -1, values above 13, and
the empty cases 12 and 13. Action zero sets the two existing flags and copies
the current timestamp. Actions one through four require shell state five;
they start a level, reset the initial lives value, return to the menu, or
alternate the existing configuration value between one and two.
The configuration change retains its separate masking and increment stores.

Selections five through eleven enter the shared pickup block. They require
state nine, mode three, and a cleared pause value. Once those gates pass,
the pickup counter increments even when its old value is five or greater.
Only old values below five play the sound and apply the pickup. The ordinary
pickups store their action code and clear the player timer; action seven
increments the player's lives field. Action six reuses an existing attached
actor or calls the allocator with kind six, the existing resource, and the
player actor's position. Successful attachment writes the parent link and
adds the scaled value to the player's actor field at offset `10`, narrowing
to a signed halfword. Failed allocation leaves the attachment null and skips
those writes. The selection still clears after a rejected or failed pickup.

The source uses the existing 3,508-byte player and 124-byte actor views.
Unknown fields retain offset names. Ghidra MCP imports and verifies the player
layout, applies the two-argument handler prototype and switch-table type,
and records the counter as four uninitialized bytes at `800BAE8C..800BAE90`.
This BSS definition claims no ROM data. The other state globals and resource
storage retain their existing ownership or fallback status.

The retail menu caller at `800338F0` supplies only the selection argument for
actions zero, twelve and thirteen. Those paths never inspect the player.
Its unprototyped C declaration preserves the observed one-argument call
sequence; the shared header records the full handler interface for callers
that supply a player. This historical argument-count mismatch remains a C
language limitation. The pinned compiler's generated calls and their MIPS
behavior are verified, including execution with an unmapped player argument.
The existing signature-gated caller now uses the shared two-argument header;
its complete 148-byte body continues to match.

The compiler retains an unreachable `li at,6` at `8001BAF4`. Ghidra's flow
body originally omitted that word; the bounded full-range listing and ROM
comparison include it. It is not padding. The raw object contains twelve
trailing zero alignment bytes after the 724-byte function and eight after
the 56-byte table. Only those verified alignment bytes are trimmed.

The optional MIPS checker passes 3,516 cases: 3,420 direct calls and 96 through
the existing menu caller. These include 252 cases where the selection points
inside the player record, 756 that pass the state gates and increment the
counter, and 504 that apply a pickup. It checks independent byte expectations
for complete player and actor records, global state, surrounding guards,
unchanged table and resources, and the order and arguments of every call.
Cases cover failed and reused allocation, counter boundaries, each rejected
state gate, signed halfword narrowing, selection clearing, and aliasing.
Every call restores the stack and saved registers and returns to the sentinel.

Level setup, input reset, sound, menu activation and allocation use ABI stubs.
They clobber caller-saved integer and floating-point registers; the float
clobber executes real `mtc1` instructions because Unicorn's MIPS register API
does not implement FPU writes. The signature-gated caller is independently
compiled and matched but is not executed by this checker. Actual allocation,
rendering, sound playback, menu activation, invalid required pointers and
full-game behavior are outside this proof.

Run the checker with Unicorn installed:

```sh
python3 tools/check_scene_actions.py
```

The integrated ROM matches all 8,388,608 target bytes. Independent comparisons
pass for 856 runtime units, two startup units, eighteen assembly units and
95 data-only units; all 152 tooling tests pass.
[The provenance ledger](scene-actions-provenance.json) records current inputs,
compiler identity, ELF ownership, execution results and Ghidra evidence.
The provisional CPU inventory retains 186,596 fallback bytes in 213 ranges;
function and executable-byte denominators remain unknown.

The compiler and comparison workflow follow the local SM64 and IDO references
listed in [reference study](reference-study.md). Robotron's retail instructions
establish the behavior and data layout. No reference game implementation was
copied. The execution checker uses [Unicorn](https://www.unicorn-engine.org/).
