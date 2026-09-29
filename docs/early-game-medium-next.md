# Early game medium recovery continuation

This tranche recovers three complete early-game routines with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`.

| Source | Range | Function | Bytes |
| --- | --- | --- | ---: |
| `early_actor_spawn_helper.c` | `0x8001B3DC..0x8001B448` | `func_8001B3DC` | 108 |
| `early_file_state_reset.c` | `0x8001B870..0x8001B8D8` | `func_8001B870` | 104 |
| `early_name_mask_lookup.c` | `0x8001BBAC..0x8001BC38` | `func_8001BBAC` | 140 |

`func_8001B3DC` creates one actor from resource `D_800B26E8` at the source
actor's position, invokes the resource callback when creation succeeds, clears
the new actor's Z coordinate and field at `0x54`, and installs
`func_80005560` as its callback.

`func_8001B870` loads the file named by `D_800903A0`, copies `0x320` bytes
into `D_8009E590`, releases the loaded allocation, and clears four related
runtime state words.

`func_8001BBAC` searches the fourteen-entry table beginning at `D_80075994`
for a case-insensitive name match. A match returns the corresponding one-hot
bit. A miss reports the name through `D_800903AC` and returns `-1`.

Canonical comparison details and retained hashes are recorded in
`early-game-medium-next-provenance.json`. The focused comparison covers all
352 target bytes with zero differing words. The three IDO objects contain no
source-owned allocated data or BSS. The integrated `make -j2 verify` rebuild
matches all 8,388,608 bytes of the US target with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

Two nearby recovered candidates remain fallback. `func_8001B468` has the exact
144-byte extent with seven differing tail words around callback, flag and timer
register allocation. `func_8001BD24` has its token parser and mask lookup
behavior represented, but the current structured loop compiles to 288 bytes
against the 264-byte target.
