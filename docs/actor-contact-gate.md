# Actor contact gate candidate

`func_8001669C` occupies `0x8001669C..0x80016914`, or 632 instruction bytes.
The complete candidate compiles to the same size under the pinned IDO 5.3
game profile. Three branch words still differ, so the retail build retains
fallback for the entire procedure and the candidate contributes no matching
functions or instruction bytes.

The candidate copies both three-word contact positions before testing the
active dynamic-group value at `D_800BA74C`. A value other than minus one exits
with zero. It excludes resource kinds 17 through 20, then orders the actors
and copied positions by the resource kind byte. The target also contains a
redundant nested check for kinds 33 and 34. Its purpose and original source
form remain unresolved; the candidate preserves its observed control flow.

A kind-five actor whose animation byte is not three has flag mask `0x02` set.
The gate rejects a pair when the absolute Z difference exceeds the
absolute value of half the `GRUNT2_HOVER_HEIGHT` setting, or when both actors'
fields at `0x28` are nonzero. Otherwise it calls `func_80018E1C` with the ordered
actors, their signed resource halfwords at `0x5A`, and the copied positions.
Every path returns zero. The halfwords and the callee's arguments keep generic
names until their meanings are established.

Complete independent comparison leaves only operand-order differences in
branches at `0x80016714`, `0x80016724`, and `0x800167E8`. Each target branch
lists the constant register before the kind register; IDO emits the reverse
order for this candidate. The 88-byte stack frame, all three aggregate offsets,
calls, arithmetic, loads, stores, branch destinations, and remaining words
match. The target's absolute-value expressions retain multiplication by minus
one and signed division toward zero.

Run `python3 tools/compare_runtime.py --candidates` to include this source in
the excluded research report. That command exits nonzero while any candidate
is nonmatching. The normal matching report and linked progress remain separate.
The target ROM supplies the behavior and comparison bytes. The N64 compiler
and decompilation references are credited in [CREDITS.md](../CREDITS.md).
