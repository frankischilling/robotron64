# Actor contact gate

`func_8001669C` occupies `0x8001669C..0x80016914`, or 632 instruction bytes.
The complete source matches all 632 bytes under the pinned IDO 5.3 game
profile and now replaces the entire fallback procedure in the retail build.
It contributes one verified C procedure and 632 matching instruction bytes.

The routine copies both three-word contact positions before testing the
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

The earlier candidate differed only in branch operand order at
`0x80016714`, `0x80016724`, and `0x800167E8`. A reusable short comparison value
and a single-pass group for the two flag updates now preserve all three
words. The group contains the actual flag operations and adds no instructions.
Its exact original source form remains unknown. The redundant nested 33/34
check, 88-byte frame, aggregate offsets, calls, arithmetic, stores and branch
destinations all match. Signed division toward zero and multiplication by
minus one preserve the original absolute-value calculations.

The routine now belongs to `python3 tools/compare_runtime.py` and linked
progress validation. [Batch evidence](input-contact-sound.md) records the
complete comparison and input provenance. The target ROM supplies the
behavior and comparison bytes; all thirteen N64 reference projects and local
search tools are credited in [CREDITS.md](../CREDITS.md).
