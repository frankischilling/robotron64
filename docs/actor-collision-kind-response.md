# Collision-kind response

`func_80016950` occupies VRAM `0x80016950..0x80016C1C`, ROM
`0x17550..0x1781C`. Its complete 716-byte IDO 5.3 C output matches retail.
The generated 36-entry switch table occupies VRAM `0x8008FF1C..0x8008FFAC`,
ROM `0x90B1C..0x90BAC`; all 144 bytes match. Independent splat assembly was
reassembled with MIPS binutils and checked against both original ranges.

The handler first calls the contact predicate with actors and input positions
reversed. A rejected contact returns zero. First-actor kind 27 invokes separation;
kind 1 evaluates the absolute height against half the shared threshold. Both
threshold outcomes return zero, but the retail procedure retains the calculation.
Ghidra's simplified pseudocode omits it, so the instruction listing determines
this part of the source.

Second-actor kinds 8 and 9 invoke separation and then set first-actor flag bit 1.
Kinds 10 and 13 add unsigned tick-scaled quotients to the first actor's X and Y
positions. A zero coordinate difference becomes 1; negative differences become
unsigned divisors. The Y calculation reads its inputs after the X write.

The remaining paths dispatch on the cached first kind. Kinds 0 through 4 retire
the first actor, then reload the second actor's resource kind before deciding
whether to invoke animation response. Several groups invoke animation response,
separation, or return without further work. The explicit default-kind entries
preserve the full table, including entries 31 through 35.

The source uses the existing actor and resource layouts and canonical helper
prototypes. The collision callback matrix casts this handler to its existing
callback type; both actor views have the verified 124-byte layout. The handler
owns its code and generated table, with no additional initialized globals or BSS.

`tools/check_actor_collision_kind_response.py` independently recompiles three
complete source units and checks guarded CPU execution. The 3,871 cases cover 2,808 dispatch cases, 24 unknown-kind cases, 210 callback
mutations, 360 unsigned-division and alias cases, 49 threshold cases, and 420
cases using the real contact predicate and absolute-value helper. Memory and
instruction bounds, complete guarded actor/resource images, stack guards,
caller homes, saved integer registers, GP, and F20 through F31 are checked.
Separation, retirement and animation use caller-clobbering ABI stubs.

Fresh startup, runtime, assembly and data comparisons, the clean build, full-ROM
comparison, tooling tests and all required execution gates passed.
[The verification ledger](actor-collision-kind-response-provenance.json) records
the input hashes and results. Objdiff reports 100 percent for the relocatable
function and text; its linked viewer reports a symbol-bounds error. Direct
linked-byte comparisons independently verify the full procedure and table.
These checks do not establish complete gameplay.

Tools used: [splat](https://github.com/ethteck/splat),
[spimdisasm](https://github.com/Decompollaborate/spimdisasm),
[m2c](https://github.com/matt-kempster/m2c),
[asm-differ](https://github.com/simonlindholm/asm-differ),
[objdiff](https://github.com/encounter/objdiff),
[decomp-permuter](https://github.com/simonlindholm/decomp-permuter), Ghidra,
MIPS binutils, and Unicorn. The original ROM remains the source of truth.
