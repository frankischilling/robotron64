# Sound bridge and game formatter

The uncovered runtime range from `0x80036064` through `0x80036668` contains
small sound-service helpers, the game sound-definition writer, immediate and
deferred sound dispatch, and a destination-string formatter. Recovery uses
IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`. Complete comparisons include
the current source, transitive local headers, compiler identity, symbol-layout
snapshot, function bounds, and every declared source-owned section.

| Source | Target range | Bytes | Status |
| --- | --- | ---: | --- |
| `sound_bridge_core.c` | `0x80036064..0x800360E8` | 132 | exact |
| `sound_bridge_definitions.c` | `0x800360F0..0x8003614C` | 92 | exact |
| `sound_request_dispatch.c` | `0x8003614C..0x800361FC` | 176 | exact, including 32-byte string |
| `sound_bridge_future_reset.c` | `0x800361FC..0x80036288` | 140 | exact |
| `sound_bridge_future_queue.c` | `0x80036288..0x80036318` | 144 | exact, including 32-byte string |
| `sound_bridge_future_update.c` | `0x80036318..0x800363D0` | 184 | exact |
| `game_format_message.c` | `0x800363D0..0x80036668` | 664 | exact size, 98 code words differ; generated table pending |

The eight-byte gaps at `0x800360E8..0x800360F0` and
`0x80036668..0x80036670` are alignment between the recovered code ranges.

## Small bridge helpers

`func_80036064` takes a `GameActor *` and a fallback integer. When
`D_8007394C` is nonzero it reads the signed halfword at actor offset `0x08`,
adds `D_800BEF6C` and `0x400`, and masks the result to twelve bits. Otherwise
it returns the caller's fallback unchanged. The current actor layout exposes
that halfword through `unknown00[4]`; its higher-level meaning is not yet
established.

`func_800360A0` and `func_800360B0` are empty. `func_800360A8` returns its
integer argument unchanged. `func_800360B8` homes its string-pointer argument
and returns `-1`. Existing callers use it as a label-based sound/platform
hook, but the N64 body does not inspect the label. `func_800360C4` calls
`func_800360B0` only when its integer argument is nonzero.

The complete `0x80036064..0x800360E8` unit is instruction-exact. The target
therefore establishes that `func_800360B8` returns an integer; shared
declarations that currently describe it as `void` need refinement before
integration.

## Sound definitions

`D_800AE568` is indexed in twenty-byte records. The recovered layout is:

| Offset | Field |
| ---: | --- |
| `0x00` | `value00` |
| `0x04` | `value04` |
| `0x08` | `value08` |
| `0x0C` | `platformFlag` |
| `0x10` | `value10` |

`func_800360F0` receives a seven-word command record: opcode, sound index,
then five values. It captures all five input values before writing the target
definition, preserving the target's snapshot behavior if the command storage
ever aliases other writable state. The fourth stored definition word comes
from command offset `0x18`, while the fifth comes from command offset `0x14`;
the typed command field names retain that observed mapping.

`func_80036138` ignores its argument and sets `D_8009EFB4` to one. Together
these functions form an exact 92-byte unit.

## Immediate sound dispatch

`func_8003614C` treats its first argument as a signed 32-bit sound handle.
It explicitly rejects negative values and values at least 117, printing
`%d is a wrong sound handle!\n` and returning zero. This signed callee
contract is distinct from actor animation storage: `ActorAnimation.sound` is
an unsigned byte, and the actor caller checks `0xFF` as its no-sound sentinel
before zero-extending the byte into this function.

For a valid handle, the function indexes the twenty-byte definition table and
tests `platformFlag` at offset `0x0C`. A nonzero flag calls
`func_8003BF9C(sound)`. It then examines the second integer parameter. Zero
calls `func_800515B0(sound, value)` using the third parameter; nonzero calls
`func_8003BF94(sound)`. The fourth integer parameter is homed by the target
prologue but is not read by the N64 body.

The actor-animation caller uses `(sound, 0, 1, 0)` after its byte sentinel
check. Movie playback also uses `(sound, 0, 1, 0)`. Deferred-sound records
preserve all four values and pass them back in the same order. These callers,
plus the callee's signed range check and full-width register use, support the
internal signature `int func_8003614C(int sound, int mode, int value,
int extra)`.

The complete routine is now matching in `sound_request_dispatch.c`. Passing
the observed mode and value arguments to `func_8003BF94` preserves their
register lifetimes and the optional-call spills. Every instruction word and
the complete 32-byte warning span match. The older 28-word candidate report
is superseded by the [current batch evidence](input-contact-sound.md).

## Deferred sound queue

The deferred pool spans `D_800BEF70..D_800BF114`, exactly `0x1A4` bytes, so
it contains fifteen `0x1C`-byte records. Each record contains:

| Offset | Field |
| ---: | --- |
| `0x00` | flags; bit 31 is the active flag |
| `0x04` | sound |
| `0x08` | mode |
| `0x0C` | value |
| `0x10` | extra |
| `0x14` | enqueue time |
| `0x18` | unsigned delay |

`func_800361FC` clears the active bit in all fifteen records and returns one.
The ordinary indexed loop compiles to the target's peeled/unrolled stores and
is exact over all 140 bytes.

`func_80036288` scans for the first inactive record. It sets the active bit,
captures `D_8009EFA0` and the incoming delay, stores sound/value/extra/mode,
then writes the captured time and delay. That source order is meaningful:
it reproduces the target's two timing loads before the four payload stores.
A full pool prints `Out of future sound handles\n` and returns zero; success
returns one. The 144-byte function and its complete 32-byte string at
`0x800942E0..0x80094300` both match exactly.

`func_80036318` checks all fifteen active records. Expiration uses unsigned
`delay < currentTime - startTime` arithmetic. Each expired record is passed
to `func_8003614C(sound, mode, value, extra)`, then its active bit is cleared.
The function returns whether any sound fired. Its complete 184-byte body is
exact.

## Destination formatter candidate

The complete formatter and generated table now match in
`src/game/formatting/destination.c`. The candidate measurements below record
the earlier private checkpoint. See [cache and formatter recovery](resource-cache-and-formatting.md)
for current source ownership and verification.

`func_800363D0` takes a destination pointer, a format pointer, and variable
arguments, and returns the original destination. Its supported conversions
match the earlier game diagnostic formatter family: `%C`/`%c`, `%s`,
`%d`, `%x`, and the decimal padding forms `%2d` through `%5d`. Decimal
padding inserts leading spaces until the rendered decimal length is greater
than the selector.

The N64 IDO wrapper used by this project does not expose `<stdarg.h>` on its
compiler include path. A local reference copy of IDO's header was inspected
only to confirm the o32 mechanics. The public candidate uses an independently
written, limited argument cursor for the types this function actually
consumes: align the cursor to four bytes, consume one 32-bit word for
integers/pointers, and read byte offset three for `%C`/`%c` so the low byte
of the promoted word is selected on big-endian MIPS. It does not include the
reference header's floating-point or structure vararg machinery.

The current ordinary source compiles to the exact 664-byte function length.
It also emits an 80-byte `.rodata` section at `0x80094300..0x80094350`:
the compiler-generated eighteen-entry switch table for characters
`0x32..0x43` plus eight alignment bytes. Code register/lifetime differences
leave 98 instruction words different, so the table's branch-target words do
not yet match the target and the whole formatter remains excluded.

## Verification

The combined current comparison is
`.local/recovery48-sound/checkpoint-current.json`. Each source also has an
independent report and input snapshot under
`.local/recovery48-sound/probes/<source>-5.3-O2-mips1/`. Source-owned data
declarations are recorded in `.local/recovery48-sound/owned.json`.

Exact units are eligible for prime integration only after a fresh independent
verification from the frozen source snapshot. The destination formatter remains outside the matching manifest until its
complete code and generated table bytes match. Immediate sound dispatch is
now part of the matching runtime report.
