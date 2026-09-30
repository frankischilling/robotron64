# Game collision and selection services

Five complete C procedures match all 688 instruction bytes. Their two
five-entry switch tables and the complete lookup diagnostic add 78
source-owned initialized bytes. The pinned IDO 5.3 game profile is used
throughout. [The provenance ledger](game-collision-and-selection-provenance.json)
records complete linked code, initialized sections, comparison inputs and
ROM hashes.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_8000CE34` | `0x8000CE34` | 132 | Clamp a render selection and return its handler |
| `func_80016618` | `0x80016618` | 132 | Dispatch collision behavior for resource kinds 7 and 8 |
| `func_8001B7D0` | `0x8001B7D0` | 160 | Search a primary and optional secondary name table |
| `func_80022B78` | `0x80022B78` | 132 | Advance the session mode, wrap and skip mode 7 |
| `func_800338F0` | `0x800338F0` | 132 | Apply a resource operation for selections 8–10 and clear the selection |

## Render and collision dispatch

Render selection is clamped to 0–4. The returned handlers, in order, are
`func_8000B99C`, `func_8000B964`, `func_8000BEC0`, `func_8000BE80` and
`func_8000BEA0`. The existing handler interface accepts one state pointer.
The complete generated switch table occupies twenty bytes at `0x8008F974`.

Collision dispatch uses the second actor's resource kind. Kinds 4–6
return zero, while kinds 7 and 8 call `func_8001A410` and return `0x20`
unless the first actor's resource kind is 11. All other kinds return zero.
The twenty-byte table at `0x8008FF08` resolves to three default entries
and two entries for the active branch. Both complete relocated tables are
verified along with the code; a matching instruction stream alone would
not establish their case mapping.

## Name lookup and state changes

Name lookup uses the existing case-sensitive string comparison. It searches
a null-terminated primary table and, after reaching its end, the optional
secondary table. Each table starts its index at zero. A null primary table
skips the secondary table too, preserving the shipped behavior. Failure
reports the name and returns -1. The complete 38-byte diagnostic at
`0x80090370`, including its newline and terminator, is owned by this unit.

Session advance clears `D_8009E57C`, increments `D_800AD280`, wraps 9 to 1,
and clears `D_800AD28C`. Mode 6 calls `func_80022528(0, 0, 0)` before the
mode is read again. Mode 7 is then advanced once. Out-of-range initial
values receive no added normalization.

Resource selection 8 passes a local value 12 to `func_8001B8D8`, selection
9 passes 13, and selection 10 passes zero. Other selections skip the call.
The input selection is always cleared afterward. The local values and
their addresses are retained rather than replaced with direct arguments.

## Storage and validation

The two switch tables are reconstructed from the C control flow. Their raw
objects have twelve zero alignment bytes beyond each complete twenty-byte
table; those bytes are excluded from the ownership claim. The diagnostic
is an initialized character array in the compiler's `.data` section. Its
complete 38-byte extent is kept separately from alignment padding.

The local [IDO materials](https://github.com/n64decomp/ido) and
[Super Mario 64 matching build](https://github.com/n64decomp/sm64) supply
compiler and build references. Robotron's instructions and complete table
contents establish these game-specific behaviors. The thirteen requested
references remain credited in [CREDITS.md](../CREDITS.md).

Current progress requires all independent comparisons and full ROM
equality. Nonmatching collision-animation, position-follow and chain-reset
probes remain excluded; larger game routines still use fallback.
