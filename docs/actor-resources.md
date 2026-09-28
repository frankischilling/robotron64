# Actor resource loading

The actor resource loader is `func_8001CF68` at `0x8001CF68..0x8001D260`. Its resource record is `0x58` bytes. A negative signed value at offset `0x06` means the resource is already resident, in which case the loader returns `2`. A successful new load sets the high bit in the byte at offset `0x06` and returns `1`.

The loader checks another packed resource flag through the word at offset `0x04` before loading. It then validates the resource kind, constructs model, bitmap, and texture-map paths, and conditionally loads the model and texture-map data according to its second argument. The model fields are the handle/name pair at offsets `0x1C/0x1E`; the texture-map pair is at `0x20/0x22`; the bitmap pair is at `0x24/0x26`.

Ten animation pointers begin at offset `0x28`. For each non-null animation the loader resolves its kinemation through `func_8001CE70`, inherits the first animation's frame index when the current frame index is `-1`, resolves the optional track at animation offset `0x02`, writes the animation slot number at offset `0x00`, and passes the model, texture-map, and bitmap handles to `func_800391F0`.

`func_8001D260` at `0x8001D260..0x8001D3F0` clears only the loaded bit across the static actor-resource tables. The exact source uses indexed loops whose counts and strides are established by the target: 244 records of `0x58`, 36 records of `0x68`, 8 records of `0x58`, 16 records of `0x58`, 11 records of `0x5C`, 16 records of `0x5C`, one standalone `0x58` resource, 4 records of `0x58`, and 5 records of `0x60`.

The next function starts at `0x8001D3F0` and ends at `0x8001DE54`. It is a 2,660-byte resource setup routine that calls `func_8001CF68` repeatedly and continues well past `0x8001D600`. Its complete body still needs reconstruction; no partial body contributes to matching progress.

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces all 400 bytes of `func_8001D260`. It is integrated and counted as one matching function, with no source-owned data or BSS. The excluded loader candidate has the exact 760-byte size, control flow, constants, call sequence, stack frame, path-buffer address (`sp+0x48`), and saved first-animation pointer slot (`sp+0xB0`); nineteen instruction words still differ in temporary-register allocation. Target disassembly, caller excerpts, compiler reports, source snapshots, and header snapshots are retained under `.local/recovery15-actor-resources/` and `.local/recovery27-movies/`.
