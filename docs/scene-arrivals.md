# Scene storage and arrival insertion

The C definition at `800B9A78` owns the complete `0xD14`-byte scene record.
The save-slot selector and continued-game decoder copy exactly that extent.
The existing `SceneDefinition` layout describes five positions, 256 twelve-byte
arrivals, 25 tweak pairs, four effect pairs and the trailing scene fields.
Fields with unknown meanings keep their offset-based names. Neighboring
resource-state storage is separate.

Six compatibility names for individual fields are linker expressions derived
from the C object. Linker assertions check the base, full BSS extent and each
field address. No absolute assignment can override the C definition.

Two mutable diagnostic arrays own `800917F8..80091834`, or 60 initialized
bytes. Their explicit extents retain the terminating nulls and retail zero
padding. Independent data comparison checks the complete compiled section,
symbol offsets and absence of executable or unowned allocated content.

The ordinary-C insertion candidate spans `8001FCE4..80020134`, or 1,104 retail
bytes. It remains outside the matching function manifest and ROM link.
`make audit-scene-arrivals` freshly compiles it, six matching random, copy and
diagnostic helper units, and the owned scene and diagnostic data units. The
paired executions check complete scene memory, overlap-copy arguments,
resource reads, random state, signed coordinate conversion, duplicate states,
capacity handling, preserved integer/FPU registers and guarded memory.
Source and message mutations check that the audit rejects broken behavior.

Replacement at a full table can move the last entry into the three scene words
following the arrival array before the capacity warning. The candidate retains
this observed ordering. Trigger 4 draws from the real random helper even when
the requested arrival count is zero. Limits use unsigned comparisons; default
resource delays and coordinate divisions use signed arithmetic.

Diagnostic output and the fatal renderer use ABI observers that clobber
caller-saved integer and floating-point registers. The fatal renderer returns
synthetically so the following stores can be compared. Display hardware,
terminal fatal handling and gameplay are outside this audit.

The [verification ledger](scene-arrivals-provenance.json) records the source
and type evidence, full independent references, bounded execution and fresh
acceptance checks. Behavioral agreement does not count the insertion candidate
as recovered code. Whole-ROM equality retains fallback and does not establish
full source completion.
