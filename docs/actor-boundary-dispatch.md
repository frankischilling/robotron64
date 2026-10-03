# Actor boundary dispatch

`func_800190F8` traverses the active actor list and dispatches actors outside the
arena to their existing boundary-response callbacks. The complete 996-byte
procedure occupies `800190F8..800194DC`, ROM `19CF8..1A0DC`.

An actor with a nonzero word at offset `28` is skipped. Other actors are checked
against square bounds adjusted by their signed 16-bit radius at offset `06`.
When enabled, the additional diamond boundary uses the sum of absolute X and Y.
The outer actor-kind switch and two resource-kind switches select clamping,
reflection, retirement and diagnostic paths. Resource kind 23 in actor class
nine changes the actor state, decrements the current player's byte counter at
`06`, and increments the word at `1C`. These field names remain conservative;
the local player view preserves the established `DB4` stride.

Actor class four preserves the resource-kind-two age threshold, independent X
and Y movement checks, the diamond test and the flag `100` retirement behavior.
Unsigned elapsed-time subtraction, signed-radius comparisons, byte-counter wrap
and the original callback order are retained. The absolute-value sum is written
with Y on the left so pinned IDO evaluates the X call first, as retail does.

The function owns three compiler-generated jump tables, totaling 140 bytes at
`800900AC..80090138`. Their 35 relocated entries cover the outer ten-entry
switch, the twenty-entry class-zero resource switch and the five-entry class-five
resource switch. The explicit class-five resource-six case preserves the
original table. The diagnostic string owns 36 bytes at `8008FDE0..8008FE04`,
including its terminator and three zero alignment bytes.

`tools/check_boundary_dispatch.py` freshly compiles with the pinned IDO 5.3 game
profile, checks all 996 instruction bytes, independently compares both linked
data sections with retail, verifies all 35 MIPS32 table relocations, and rejects
live code or nonzero data beyond the owned ranges. The raw object has twelve
zero instruction-tail bytes, four zero table-tail bytes and twelve zero
string-section-tail bytes. No additional allocated source sections are omitted.

The checker executes retail and compiled procedures against an independent
array model in 5,889 cases. It covers every outer kind from zero through ten,
resource-switch members and defaults, both arena shapes, positive and negative
axis boundaries, signed-radius extremes, disabled actors, retirement flags,
the 200-tick threshold, both player indices, counter wrap and an empty actor
list. Guarded three-node actor lists exercise traversal past skipped nodes.
Callback arguments, caller-saved clobbers, preserved registers, stack guards and
all direct actor/player memory effects are checked.

Boundary-response, retirement, sound and diagnostic callees are recorded ABI
stubs; absolute value uses an independent integer model. This does not validate
those callees or whole-game collision behavior. Both executions use their own
independently verified table and message bytes.

Research used the existing Ghidra MCP analysis and retail MIPS listing, the
installed matching workbench and IDO preprocessing context, and Unicorn with
pyelftools. No reference-project source was copied.

```sh
python3 tools/check_boundary_dispatch.py
```

Focused hashes and execution results are recorded in
[the dispatcher provenance](actor-boundary-dispatch-provenance.json). Clean
full-ROM validation and final-head CI remain separate batch requirements.
