# Audio queries, glyph selection and actor callback installation

Six complete game procedures account for 1,472 live C bytes. All use the
verified IDO 5.3 `game` profile and emit no initialized storage or BSS.

| Source | Procedure range | Live bytes |
| --- | --- | ---: |
| `early_actor_callback_install.c` | `0x8001B468..0x8001B4F8` | 144 |
| `renderer_glyph_map.c` | `0x800498F0..0x80049AD8` | 488 |
| `audio_instance_count.c` | `0x80056130..0x800561E8` | 184 |
| `audio_instance_enumerate.c` | `0x800561E8..0x800562D4` | 236 |
| `audio_owner_count.c` | `0x800562D4..0x8005638C` | 184 |
| `audio_owner_enumerate.c` | `0x8005638C..0x80056478` | 236 |

## Instance and owner queries

The four audio queries use the shared 24-byte `AudioInstance` declaration.
Its active bit occupies the high bit of the first word, the signed sequence
index is at offset two, and the owner tag is at offset eight. The context
supplies an active-instance count and the instance-array pointer. The complete
target instructions verify these accesses and the 24-byte iteration stride.

`func_80056130` validates its sequence index before counting matching active
instances. `func_800562D4` checks that the audio system is initialized, then
counts active instances with the requested owner tag. Both acquire the
existing audio lock before examining the context and release it before
returning their count. The scans stop when either the array capacity is
exhausted or the advertised active count has been consumed.

The two enumeration routines also check initialization and hold that lock
throughout their scan. Each searches the values already written before
appending an active instance's sequence index or owner tag. The resulting
list preserves first-occurrence order and contains each value once. Each
routine returns the number of values written. The original interfaces accept
an output pointer without a capacity argument; the reconstruction preserves
that caller-provided-storage contract.

## Renderer character mapping

`func_800498F0` accepts an unsigned byte and selects the renderer's glyph index.
Its unsigned-byte intermediate preserves the original narrowing before the
integer return. The independent conditionals and default result of zero
follow the target's complete 488-byte procedure.

| Input | Glyph result |
| --- | --- |
| `A..Z`, `a..z` | `0..25` |
| `_ ? = + / - . % ! *` | `26..35`, in that order |
| `0..9`, byte values `170..179` | `36..45` |
| Byte values `31, 11, 12, 13` | `46..49`, in that order |
| `^ ,` | `50, 51` |
| `# " : @ '` | `53..57`, in that order |
| Other inputs | `0` |

The procedure assigns no input to glyph 52. These are the target's numeric
character codes; the source does not infer a host character encoding for the
extended range or control-byte entries.

## Callback handoff

`func_8001B468` applies the global object property through `func_80039DCC`.
When the actor's callback-active bit is set, it clears the bit and invokes
the current callback before installing `func_8001B324`, setting the bit again,
and setting the timer to 999. The flags are reloaded after the call so callback
changes are retained. The final comma-expression installation matches the
same source pattern in the recovered countdown and animation behaviors.

The shared declaration of `func_80039DCC` in `text.h` now returns `int`, matching
its existing definition in `object_helpers_properties.c`. The setter writes
one object byte and returns the narrowed unsigned value. This caller ignores
that return value. Complete recompilation checks the declaration change
against all registered callers.

## Evidence

The complete target instruction streams were inspected for every range above,
including the enumeration duplicate search, lock release, callback return,
and glyph return. The retained source candidates are reproduced with the
current shared headers. `actor-callback-target-v3-interface` and
`retained-game-queries-v1` verify the complete code, public procedure sizes,
and absence of additional allocated sections. All six sources are registered
for independent production comparisons. Source, header, compiler and complete
procedure identities are retained in the
[provenance record](game-query-and-glyph-provenance.json).
