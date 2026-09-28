# Object and game helpers

This recovery covers object state, camera state, object-pool bookkeeping, and
the small draw dispatch helpers immediately after the object transform block.
The matching sources are intentionally split at assembly-backed gaps so each C
object maps to one contiguous ROM range.

## Matching ranges

| Source | VRAM range | Bytes | Functions | Purpose |
| --- | --- | ---: | ---: | --- |
| `src/game/object_helpers.c` | `0x80039C78..0x80039CD0` | 88 | 2 | Object setup wrapper and constant-success helper |
| `src/game/object_helpers_index_limit.c` | `0x80039CD0..0x80039D4C` | 124 | 1 | Resolve the limit associated with the object's byte property |
| `src/game/object_helpers_index_set.c` | `0x80039D4C..0x80039DAC` | 96 | 1 | Check that limit before writing the object's index |
| `src/game/object_helpers_properties.c` | `0x80039DAC..0x80039EA0` | 244 | 8 | Object index and byte-property accessors |
| `src/game/object_helpers_camera_state.c` | `0x80039EA0..0x80039F10` | 112 | 4 | Camera flags and integer state |
| `src/game/object_helpers_camera_position.c` | `0x80039F10..0x80039FCC` | 188 | 1 | Mirrored camera position with inverted fixed-point Y |
| `src/game/object_helpers_camera_position_alt.c` | `0x8003A070..0x8003A128` | 184 | 1 | Mirrored camera position with normal fixed-point Y |
| `src/game/object_helpers_camera_accessors.c` | `0x8003A1C8..0x8003A2F8` | 304 | 12 | Camera scalar/vector getters and setters |
| `src/game/object_helpers_pool_alloc.c` | `0x8003A2F8..0x8003A3F8` | 256 | 1 | Object slot selection and initialization bookkeeping |
| `src/game/object_helpers_pool_status.c` | `0x8003A3F8..0x8003A460` | 104 | 1 | Object slot release/status accounting |
| `src/game/object_reset.c` | `0x8003A460..0x8003A4EC` | 140 | 1 | Clear and initialize a 120-byte object record |
| `src/game/object_helpers_draw_noop.c` | `0x8003A4EC..0x8003A4F4` | 8 | 1 | Empty draw callback |
| `src/game/object_helpers_draw.c` | `0x8003A4F4..0x8003A778` | 644 | 8 | Draw backend dispatch wrappers |
| `src/game/object_helpers_draw_mode.c` | `0x8003A778..0x8003A8B0` | 312 | 2 | Palette selection, draw mode selection, and trailing no-op |

The matching total in this group is 44 functions and 2,804 bytes.

`include/object_helpers.h` records the observed `D_800C8B88` camera layout and
the shared `D_800C86C0[]` declaration. Camera fixed-point state uses the
existing `FrameView D_800C8BD8` declaration from `include/frame.h`.
The camera's angle vectors are at offsets `0x04` and `0x24`; its position
vectors are at `0x10` and `0x30`. The position setters also update the
integer coordinates in `FrameView`, including the first setter's inverted Y.

The draw callbacks receive an `ObjectRecord *` from the main object loop.
`ObjectRecord.draw38` is the 32-bit field at offset `0x38`; the wrappers pass
its address as the start of the backend draw subobject. `drawValue70` is the
32-bit field at offset `0x70` used by three dispatch wrappers. The shared
record keeps all previously recovered transform fields at their original
offsets.
The allocation helper writes `ObjectRecord.value16` at offset `0x16`.
The draw loop reads that field as an unsigned halfword. The record remains
120 bytes, checked by its shared header. Its embedded transform occupies
`0x1C..0x38`, and its resource and model pointers occupy `0x6C` and `0x74`.

The draw callbacks return the selected backend's integer result. The main
object loop consumes that result before accumulating the object's value at
`0x16`. Their shared declarations in `include/object_draw.h` preserve the
return register through each wrapper; all 956 bytes in the draw-wrapper
and mode-selection blocks remain exact after this type correction.

The reset routine clears the full record through `func_8003B694`, then
assigns the original defaults and points `transform` to the embedded
`localTransform`. Assigning the indexed global fields explicitly lets IDO
place the return-address load and stack release before the final stores,
as in the target. The last property-byte store occupies the return delay slot.

## Local comparison

Run the versioned comparison from the repository root:

```sh
python3 tools/compare_runtime.py
```

The comparison recompiles each complete block with IDO 5.3, assigns target
addresses only to undefined references, and checks every instruction against
the validated USA ROM. The regular build and progress check also verify source,
header, and object hashes, function sizes, linked addresses, and section placement.
Generated objects, ELFs, assembly, and reports stay under ignored local paths.

The nearby angle-conversion candidates, `func_80039FCC` and `func_8003A128`,
remain excluded. Their current arithmetic expressions let IDO reassociate
floating-point division and produce different instructions.
The large object loop beginning at `0x8003A8B0` also remains extracted code.
