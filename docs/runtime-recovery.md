# Additional runtime recovery

Nine complete routines add 2,212 bytes of matching C. The first five extend
existing actor, controller, movie, and gameplay-setting families. The last four
recover the resource bridge's model-cache, texture, bitmap, and animation entry
points.

| Source | Function | Code bytes |
| --- | --- | ---: |
| `actor_motion_facing.c` | `func_80027CE4` | 168 |
| `controller_legacy_scan.c` | `func_8004C0D4` | 244 |
| `movie_camera.c` | `func_80003ECC` | 460 |
| `movie_actor.c` | `func_80004258` | 436 |
| `tweak_scene_apply.c` | `func_800377E4` | 232 |
| `resource_bridge_model_cache.c` | `func_8003C94C` | 216 |
| `resource_bridge_texture_stub.c` | `func_8003CA24` | 16 |
| `resource_bridge_bitmap.c` | `func_8003CA34` | 220 |
| `resource_bridge_animation.c` | `func_8003CB10` | 220 |

The facing routine computes the X/Y separation between two actors, obtains
the angle through the existing angle helper, and applies each caller's
offset. The second actor receives the additional half-turn. The signed
remainder operations by `0x1000` are retained exactly.

The controller scan queries the four-port accessory mask and initializes
each present port's existing Pak state. Errors `SDK_PFS_ERR_ID_FATAL` and
`SDK_PFS_ERR_DEVICE` clear that port's bit. The later clear expression
recomputes the port bit, reproducing the target's instruction order.

The camera movie routine selects constant or sampled position and angle
channels. Movie mode eight clears Y and pitch and clears the target string
count. Position sampling and application have a separate local scope from
the final angle application; no extra locals or empty conditions are used.
The actor routine samples its movie channels, applies the observed actor-kind
height adjustments, updates position and orientation, and selects the
constant or sampled object parameter when that channel is present.

The scene-setting routine first binds the named variables. It applies each
level override except for the five observed pickup hit-count addresses,
then applies difficulty and enemy-speed adjustments. The repeated indexed
reads preserve the target's memory accesses and allocation behavior.

The model-cache lookup lazily clears the 1,000-entry identifier map, reuses an
existing handle when present, and otherwise initializes a 20-byte cache entry.
The target's `0xA8` stack frame preserves 128-byte filename and four-byte
extension workspaces even though this path does not consume them. Their names
come from the function's path input and neighboring resource helpers; no code
is added to assign them a speculative role.

The bitmap and animation resource helpers lazily clear their respective
1,000-entry handle maps. Cached identifiers reuse the stored handle. New entries
allocate from their existing counters and initialize the identifier and loaded
flag. Each helper sets the bridge guard around `func_8004BD00` and returns the
selected handle.

The texture-service entry point has no executable body beyond its argument
stores and return. The existing signature and caller contract are preserved;
no success value or inferred texture operation is added.

## Evidence and references

The earlier complete proofs are retained under
`.local/recovery49-resource-bridge` and `.local/recovery62-candidates`.
The five reviewed game routines were independently recompiled under
`.local/recovery66-geometry`. Canonical source/header snapshots and complete
procedure-boundary checks are under `.local/recovery67-integration`.
The two later resource helpers have independent complete-function proofs under
`.local/recovery69-object-runtime` and `.local/recovery73-object`, including
current transitive header hashes, exact boundaries, and zero differing words.
All use IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` and define no initialized
data or BSS.

The existing controller interface uses the state layouts and error values
checked against [libreultra](https://github.com/n64decomp/libreultra), as
recorded in [controller services](controller-services.md). The other routines
are recovered from Robotron's own instructions and callers. The N64 source
collection, compiler materials, and recovery tools are credited in
[CREDITS.md](../CREDITS.md).
