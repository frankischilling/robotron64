# Early game interface and table correction

`EarlyGamePosition` uses the same proven representation as the movie integer
position type: a 0xC-byte wrapper around a real three-element `int` array. This
lets allocator and object-service calls receive the array directly while the
actor-state copy remains an ordinary aggregate assignment.

`func_80005560` consumes its actor through argument `a0` in the target code.
The early-game header therefore declares it as `void func_80005560(EarlyGameActor
*actor)`, and the recovered actor creation helpers assign it directly to the
matching callback field without casts.

`D_80075994` is a fourteen-entry pointer table. At normalized ROM offset
`0x76594`, the target stores thirteen pointers from `0x80091A20` through
`0x80091AA4` followed by a null entry. Those addresses resolve to the input and
action names used by `func_8001BBAC`. Both that lookup and `func_8001BC38` now
use one shared pointer-table declaration, and `func_8001BC38` returns the table
entry with its pointer type.

The canonical correction comparison recompiles every matching source that
transitively includes `early_game_state.h`: eleven blocks totaling 2,044 bytes.
All eleven match with zero differing words. The three-function medium batch
from `c225faf` is also compared independently and remains exact at 352/352
bytes with zero differing words.

Detailed source, header and report hashes are recorded in
`early-game-interface-correction-provenance.json`.
