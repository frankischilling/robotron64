# Early game medium recovery continuation

This tranche recovers four complete early-game routines with IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`.

| Source | Range | Function | Bytes |
| --- | --- | --- | ---: |
| `early_actor_spawn_helper.c` | `0x8001B3DC..0x8001B448` | `func_8001B3DC` | 108 |
| `early_file_state_reset.c` | `0x8001B870..0x8001B8D8` | `func_8001B870` | 104 |
| `early_name_mask_lookup.c` | `0x8001BBAC..0x8001BC38` | `func_8001BBAC` | 140 |
| `early_name_mask_parse.c` | `0x8001BD24..0x8001BE2C` | `func_8001BD24` | 264 |

`func_8001B3DC` creates one actor from resource `D_800B26E8` at the source
actor's position, invokes the resource callback when creation succeeds, clears
the new actor's Z coordinate and field at `0x54`, and installs
`func_80005560` as its callback.

`func_8001B870` loads the file named by `D_800903A0`, copies `0x320` bytes
into `D_8009E590`, releases the loaded allocation, and clears four related
runtime state words.

`func_8001BBAC` searches the fourteen-entry pointer table beginning at
`D_80075994` for a case-insensitive name match. The target table contains
thirteen action-name pointers followed by null. A match returns the
corresponding one-hot bit. A miss reports the name through `D_800903AC` and
returns `-1`.

`func_8001BD24` parses underscore-inclusive identifier tokens from a
delimiter-separated input string, converts each token through `func_8001BBAC`,
and stores the resulting masks as shorts. It returns the parsed count, or `-1`
as soon as one token cannot be resolved. The input pointer advances through the
delimiter test after every completed token, matching the target control flow.

Canonical comparison details and retained hashes are recorded in
`early-game-medium-next-provenance.json`. The focused comparison covers all
616 target bytes with zero differing words. The four IDO objects contain no
source-owned allocated data or BSS. The integrated `make -j2 verify` rebuild
matches all 8,388,608 bytes of the US target with SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

One nearby recovered candidate remains fallback. `func_8001B468` has the exact
144-byte extent with seven differing tail words around callback, flag and timer
register allocation.
