# Audio control and callbacks

`src/game/audio_control.c` reconstructs all sixteen functions in the contiguous range `0x80052A00..0x80052D70`. The corresponding ROM range is `0x53600..0x53970`. IDO 5.3 produces all 880 bytes exactly with `-O2 -G 0 -non_shared -mips1 -32`; no data, rodata, or additional alignment bytes belong to this block.

| Function | Bytes | Observed behavior |
| --- | ---: | --- |
| `func_80052A00` | 56 | Deliver an error number to the registered callback, when present, with its saved argument. |
| `func_80052A38` | 40 | Clear the requested number of bytes. |
| `func_80052A60` | 20 | Store the error callback and its argument. |
| `func_80052A74` | 16 | Return the current audio context pointer. |
| `func_80052A84` | 36 | Return whether state `D_8008D7B4` is nonzero. |
| `func_80052AA8` | 36 | Return whether state `D_8008D7B8` is nonzero. |
| `func_80052ACC` | 116 | Reject an out-of-range index, then test the value at offset `0xC` in a sixteen-byte slot. |
| `func_80052B40` | 36 | Set the pending state word to one only when it is zero. |
| `func_80052B64` | 32 | Call `func_80058ADC`. |
| `func_80052B84` | 32 | Call `func_80058AF4`. |
| `func_80052BA4` | 100 | Perform the state-enable call sequence once and report whether it changed the state. |
| `func_80052C08` | 124 | Perform the paired disable sequence, including subordinate cleanup and conditional release. |
| `func_80052C84` | 16 | Return the pointer at `D_8008D7C4`. |
| `func_80052C94` | 16 | Return the pointer at `D_8008D7C8`. |
| `func_80052CA4` | 80 | Release an owned allocation when present and clear its ownership state. |
| `func_80052CF4` | 124 | Stop the active subsystem, invoke both registered operation tables, release its allocation, and clear its state. |

## State and memory effects

The source preserves each conditional store and the order of calls. In particular, `func_80052C08` calls the state-query helper before rereading the state global. Its final release condition combines the argument and `D_8008D864` with bitwise OR. The cleanup routine loads the context again for the second operation-table call, allowing the first callback to change that global.

The error callback takes the saved argument first and the error number second. Calls from the following bank-loading routines supply error values one and two when their validation fails. No error handling is added when the callback is absent.

`func_80052ACC` accepts only a nonnegative index below the result of `func_8005CD0C`. The target follows a pointer at context offset `0xC`, a second pointer at table offset `0x20`, and a slot stride of `0x10`, then tests slot offset `0xC`. `include/audio_control.h` gives those observed prefixes and the slot layout explicit types. The unknown fields and complete context/table sizes remain unclassified. These declarations do not identify a particular audio SDK release.

`func_80052A38` retains the decrementing unsigned count and ascending byte stores. A zero count performs no store. The source does not add bounds checks or change the target's null-pointer behavior.

## Verification

`python3 tools/compare_runtime.py` compiles the entire block independently, resolves only undefined symbols, and compares it with the validated USA ROM. Each of its sixteen input-object symbols has the original address offset and size. The regular build places the object at `0x80052A00`, and `make progress` checks its source/header/object hashes, actual ELF placement, function symbols, and linked bytes. The following bank loader remains extracted code.
