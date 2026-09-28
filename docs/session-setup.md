# Object definitions and shell menus

The command handlers around `0x8002E670` build the resource records consumed by
the [actor-resource loader](actor-resources.md). The callbacks beginning at
`0x8002F4D0` manage shell menus, preview actors, player selection, and game-start
transitions. Their names in `src/game/session_setup_*.c` and
`src/game/session_menu_*.c` describe these roles; address names remain available
for target comparisons.

## Definition records and commands

`SessionSetupCommand` contains a command word followed by five integer
arguments. The resource begins with a category, definition index, and variant.
Its common prefix is `0x58` bytes. Some categories extend it to `0x5C`, `0x60`,
or `0x68` bytes. `SessionSetupRecord` describes the largest view, including the
overlapping fields at `0x58` used by the category-specific command handlers.

The word at `0x04` contains three signed one-bit flags and thirteen state bits
in its lower half. The high bit of that half means loaded, followed by the
definition flag and the command-controlled flag at bit 13. Signed bitfield
access reproduces the target's byte and halfword loads. The definition commands
test the loaded field before changing names or animation records.

Model, texture-map, and bitmap names occupy `0x1E`, `0x22`, and `0x26`; their
handles occupy the preceding halfwords. Ten animation pointers start at
`0x28`. An animation record is `0x10` bytes. Its last eight bytes contain the
kinemation name, loop index, duration, sound identifier, and sound mode.

The recovered handlers include field setters, playback-speed calculation,
animation allocation and state selection, resource-name setters, and definition
validation. Allocation uses a one-based cursor into a 550-entry animation
table. Validation checks the model and texture-map names, then requires an
animation and kinemation name in slot zero. These checks preserve the target's
diagnostics and order.

The initializer's callback at resource offset `0x54` is copied to actor offset
`0x5C`. Calls in `func_80029FD8` pass an actor and an integer state. The small
callback bodies at `0x8002B31C`, `0x8002B570`, and `0x8002B7B0` independently
confirm that two-argument calling convention.

## Shell-menu behavior

The preview table at `0x80077AE0` has two `0x1C`-byte entries. Each holds a
position, two resource indices, and two actor pointers. Creation uses actor
category 9, sets the two display dimensions to 600 and 800, and saves both
players' selections. Update advances or retreats the first actor's frame
toward the selected endpoint. Release marks both actors for removal and clears
their pointers.

The remaining callbacks preserve or restore player selections, change menu
pages, invoke a transition callback, start the observed game modes, or reset
shell state. `func_800278AC` takes a function pointer as its third argument;
the target stores it for later use. Retail platform stubs retain callers that
pass an unused handle, so their declarations permit the historical call shape
without adding a parameter spill to the empty function bodies.

The option defaults restore both sound settings, update the six-word option
record at `0x800AD2F8`, clear the two player choices, optionally refresh the
selection, and invoke the existing option-save service. The option capture and
restore routines were rechecked after replacing the opaque byte-array
declaration with that typed record.

## Matching and remaining candidates

Accepted units use IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32`. Their complete function extents are recorded
in `config/functions.json` and independently linked by
`tools/compare_runtime.py`. These command and menu units own no initialized
data or BSS; they refer to the original tables through named symbols.

Three reconstructed commands remain outside the matching manifest:

| Function | Complete extent | Remaining difference |
| --- | --- | --- |
| Resource initializer | `0x8002E670..0x8002ECC4`, 1,620 bytes | Temporary-register allocation; the complete 224-byte jump-table section matches |
| Kinemation definition | `0x8002F29C..0x8002F334`, 152 bytes | Ten instruction words, principally local stack offsets |
| Extra kinemation definition | `0x8002F334..0x8002F414`, 224 bytes | Ten instruction words, principally local stack offsets |

The initializer selects ten resource categories and generates three jump
tables at `0x80093EAC`, `0x80093ED4`, and `0x80093EFC`. It also retains the
target's uninitialized variant value on the singleton category path. That
behavior has not been silently replaced with a default. Neither matching
tables alone nor an otherwise equivalent initializer count as a matched
function.

Private evidence is under `.local/recovery38-session`: target bodies and caller
excerpts, before-edit snapshots, compiler input hashes, complete comparison
reports, and archived probes. `ready-checkpoint/record.json` records the
accepted inputs and boundaries. The normal full build checks each integrated
function and the entire rebuilt ROM.

## References

Robotron's selected retail target supplies the layouts, constants, control
flow, and calling conventions described here. IDO and N64 decompilation
references listed in [the project credits](../CREDITS.md) support the compiler
and matching workflow. Private m2c output helped inspect switch structure;
the committed C is reconstructed and checked against the complete target.
