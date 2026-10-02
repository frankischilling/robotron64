# Tweak insertion, storage, and Ghidra analysis

The tweak system uses 150 eight-byte variable records, twenty six-byte page
records, and sixty six-byte difficulty records. Their C definitions now own
1,680 BSS bytes. Five halfword counters and the display-state word own another
fourteen BSS bytes. Seven diagnostic strings and their compiler alignment own
232 initialized bytes at `80094350..80094438`.

The matching reset, page-definition, variable-definition, binding, difficulty
application, and scene-application routines establish the array strides,
field widths, counts, and references. `TweakVariable` contains the initial
halfword value, halfword name identifier, and target pointer. `TweakPage`
contains the title identifier, first variable, and count. `TweakDifficulty`
contains the variable index and easy/hard halfword values. The counters are
at `8009F024..8009F02E`; the two bytes before the variable table are outside
this ownership claim. Source definitions retain the shared checked types in
`include/tweak_internal.h`.

| Definition | Address | Bytes | Storage |
| --- | --- | ---: | --- |
| Counters | `8009F024` | 10 | BSS |
| Variables | `8009F030` | 1,200 | BSS |
| Pages | `8009F4E0` | 120 | BSS |
| Display state | `8009F558` | 4 | BSS |
| Difficulty records | `8009FAE0` | 360 | BSS |
| Diagnostics | `80094350` | 232 | Initialized |

## Insertion routines

The complete matching C procedures at `8003762C..80037700` and
`800378CC..8003799C` recover difficulty and scene override insertion. Both
read the command name and values before scanning all 150 variable slots.
Failure to find the name calls the existing diagnostic formatter and then
continues with index 150. The message uses `%s` despite the signed halfword
identifier comparison. The source preserves that argument and behavior.

Difficulty insertion saves three halfwords in the six-byte record and
increments the signed halfword count. Its limit warning occurs after the
write when the updated count exceeds sixty. Scene insertion writes the
two halfwords in the existing `SceneDefinition.tweaks` array and increments
the word counter. Its warning occurs after the write when the count exceeds
twenty-five, passing the scene's `valueCD0` and `unknownCCC` words. Neither
procedure adds bounds checks or changes diagnostic behavior.

Both procedures match every instruction with the pinned IDO 5.3 game profile,
adding 420 bytes of matching C. Their complete independent comparisons are
registered with `tools/compare_runtime.py`. Keeping the cached lookup name
separate from the diagnostic's command-field read reproduces the original
register allocation. The scene routine's meaningful locals retain their
target stack-home order. Direct indexing into the difficulty array lets IDO
reproduce the counter and halfword-store scheduling. No dummy local, binary
patch, or inline assembly is used.

The retail dispatch table contains the difficulty handler at `80077ED8` with
argument count three and the scene handler at `80077F30` with argument count
two. These entries use the existing eight-byte `CommandScriptEntry` layout.
They explain the indirect dispatch that the initial Ghidra cross-reference
list did not show.

## Ghidra session

The local Ghidra MCP connection opened an empty `Robotron64` project. The
verified `build/us/robotron64.elf` was imported as `MIPS:BE:32:default`, retaining
the recovered ELF symbols. The MCP memory reader independently compared all
454,720 loaded bytes at `80000400..8006F440` against normalized retail ROM
offsets `1000..70040`. Every byte agreed. The comparison establishes the input
for this CPU-range analysis, not a complete CPU-function inventory.

The existing actor and tweak headers were preprocessed with `gcc -E -P -x c`
and imported through the MCP data-type parser. Typed prototypes were applied
to the tweak insertion routines and actor damage/value-transition routines.
The three recovered table extents were added as uninitialized memory and
typed as `TweakVariable[150]`, `TweakPage[20]`, and `TweakDifficulty[60]`.
The five counters and display state use their verified `short` and `int` types.
Ghidra decompilation and disassembly were checked against the retail MIPS
instructions. The saved project is local; it contains commercial binary data
and is excluded from publication.

The actor damage investigation confirmed calls from `80015B5C` and `800162AC`,
the value update at actor offset `10`, the owner link at `3C`, and the death
or timestamp paths. Its candidate remains unresolved. Ghidra's initial output
for the larger death routine at `800354C8` omitted switch destinations and
reported an indirect-call warning. That output is incomplete and was not used
as proof of a reconstructed function. Cross-reference lists likewise do not
prove the absence of calls through an as-yet untyped dispatch table.

The server disables inline Java scripts. The analysis used its normal import,
type, function, cross-reference, memory, and save endpoints. No server restart
or change to that setting was required.

## Verification and references

Independent IDO compilation checks each complete initialized section and all
BSS symbol offsets and extents. The full build checks placement, source
provenance, and all 8,388,608 rebuilt ROM bytes. The
[provenance ledger](tweak-storage-and-ghidra-provenance.json) records the
accepted inputs and results. BSS ownership adds no ROM bytes.

The local Super Mario 64 Makefile provides the matching-build and per-object
compiler reference; the pinned IDO tools remain the compiler used for these
sources. Ghidra and Ghidra MCP provide interactive analysis. Robotron's ROM
and existing matching consumers establish the game-specific behavior and
storage. Reference projects and pinned revisions are credited in
[CREDITS.md](../CREDITS.md); no reference game implementation was copied.
