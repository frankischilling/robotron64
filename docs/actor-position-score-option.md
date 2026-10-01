# Actor position conversion and score option adjustment

Two complete procedures recover 400 instruction bytes with the pinned IDO 5.3
game profile. The position conversion also owns its four-byte floating-point
literal. No new BSS allocation is claimed.

| Procedure | Address | Complete bytes | Behavior |
| --- | --- | ---: | --- |
| `func_800290B0` | `0x800290B0` | 164 | Convert actor coordinates and submit the object position |
| `func_80030DC0` | `0x80030DC0` | 236 | Adjust the score interval option through the retail value sequence |

## Actor coordinates

The helper copies the three signed integer coordinates before converting them.
It multiplies each coordinate by `1400.0f`, then divides by `60000.0f`, and
passes a float triple to the existing object-position setter `func_80039614`.
The output order is X, Z, Y. Combining the two arithmetic operations into a
precomputed scale would change floating-point rounding and the instructions.

The shared `ActorMotionPositionInternal` definition supplies the integer
triple. A separate float triple holds the result. The compiler places both
records in the target's 48-byte frame; there are no artificial padding locals.
The `60000.0f` literal occupies `0x800939C0..0x800939C4`, at ROM offset
`0x945C0`. The compiler emits the `1400.0f` value directly in instructions.

Already recovered callers include actor allocation, collision separation,
position following, and player setup. Their call sites establish the object
index and integer-position arguments. This function bridges those actor
coordinates to the existing float-based object transform.

## Score interval option

The menu callback changes `D_800AD2F8.field10`, the same option used as a
divisor by `func_80037144`. Its selection-pointer argument is unused in the
retail procedure.

The initial adjustment uses signed remainder by 5,000. A remainder below
2,500 selects the next 5,000 boundary; otherwise the value drops to the
lower boundary. Subsequent checks run in sequence: values below 10,000
become 10,000; 15,000 becomes 25,000; 20,000 becomes 10,000; 30,000 becomes
50,000; 45,000 becomes 25,000; 55,000 becomes 100,000; and 95,000 becomes
50,000. The final check caps values at 105,000.

For example, an input of 25,000 first becomes 30,000 and then 50,000. An
input of 24,999 first becomes 20,000 and then 10,000. These are sequential
retail updates, not ordinary nearest-boundary rounding. The source retains
the repeated remainder expressions: IDO eliminates the repeated division,
and the resulting register allocation matches all 236 bytes.

[The provenance ledger](actor-position-score-option-provenance.json) records
the complete source, compiler inputs, instruction hashes, and constant proof.
Independent comparison and a linked ROM build must pass after input changes.
The complete-ROM match still includes extracted fallback ranges and does not
mean the full game has been decompiled.

Robotron's instructions and recovered callers establish the behavior and
layouts. The pinned IDO and SM64 references supply compiler and matching
workflow context; no game implementation was copied from another project.
All thirteen requested reference projects remain credited in
[CREDITS.md](../CREDITS.md).
