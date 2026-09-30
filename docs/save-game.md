# Save game format

The save image at `D_800AD318` is exactly 0x1000 bytes. The matching read and write routines transfer it as sixteen 0x100-byte records.

## Image layout

| Offset | Size | Field | Observed use |
| ---: | ---: | --- | --- |
| 0x000 | 0x14 | `signature` | Copied to and from `D_80075D88`. |
| 0x014 | 0x190 | `configuration` | Copied to and from `D_80075DA0`. |
| 0x1A4 | 0x04 | unknown | No meaning established by these routines. |
| 0x1A8 | 0x20 | `occupied[8]` | One 32-bit occupancy value per save slot. |
| 0x1C8 | 0xDE0 | `slots[8]` | Eight records of 0x1BC bytes each. |
| 0xFA8 | 0x28 | global options | Captured before writing and optionally restored after reading. |
| 0xFD0 | 0x04 | `checksum` | Stored additive checksum. |
| 0xFD4 | 0x2C | unknown | Not touched by the recovered save helpers. |

Each 0x1BC-byte slot contains a 0x4C-byte session prefix, two 0xA0-byte saved-player prefixes, two 32-bit player levels, and a 0x28-byte options record. The player prefixes preserve `active` at offset 0x1C and `field34` at offset 0x34. The live player record is 0xDB4 bytes and has its level at offset 0xD6C.

The 0x28-byte options record contains 0x18 bytes copied from `D_800AD2F8`, the two audio values `D_800AD310` and `D_800AD314`, and `field34` from both live player records. Restoring options reverses those copies, then calls `func_8001A2C4`, `func_80051888`, and `func_80051854`.

## Checksum

`func_800301A4` and `func_80030420` use the same additive checksum. They start at `0x12345678` and add `words[0]` through `words[1010]`, which covers bytes 0x000 through 0xFCB.

That range stops four bytes before the checksum field. The final word of the global options record, `playerField34[1]` at 0xFCC, is therefore outside the checksum. The checksum itself at 0xFD0 and the trailing 0x2C bytes are also outside the summed range. This boundary comes directly from the target loop count of 1011 words.

On a successful read, a changed checksum sets `D_80077C04`. If the previous cached checksum was not `0xFFFFFFFF`, the routine also sets `D_80075FB8` to 3 and copies `D_8009EFA4` to `D_800BAE88`. A checksum mismatch prints `"Failed checksum\n"`, returns the read-failure result, and later clears all eight occupancy values.

## Slot capture and restore

`func_8002FE68` first stores the current session level in the active live player record. For each of the two players it copies the first 0xA0 bytes of the 0xDB4-byte live record into the slot and stores the live level separately. It then copies the 0x4C-byte session record and captures the 0x28-byte options record.

`func_8002FFC8` has an asymmetric target behavior that must be preserved. For each player it copies 0xDB4 bytes into the live player record, but the source address is the corresponding 0xA0-byte saved-player prefix inside the slot. The copy therefore continues beyond that prefix into following save-image storage. After both copies, the routine restores the 0x4C-byte session record and the slot's options. The 0xDB4 copy length is present in the matching target code and is not inferred from the C structure.

`func_80030054` rebuilds all eight display labels. An occupied slot asks `func_80021B20` for the saved session level and retries with level + 1 when the first lookup returns null. Mode 2 uses `"2p"`; other modes use `"1p"`. The format string is `"level %d %s"`. Unoccupied slots use `"unused"`.

## File read and write

`func_800301A4` checks the Pak status, opens the save with mode `"rb"`, reads 0x1000 bytes, validates the checksum, copies the signature and configuration into their live buffers, optionally restores global options, and rebuilds the slot labels. Its observed negative results are:

| Result | Target path |
| ---: | --- |
| -1 | Checksum failure, or a short read when errors are reported. |
| -2 | Status check did not report a usable save device. |
| -3 | Save open failed without the fatal/device result. |
| -4 | Status or open returned the fatal/device result. |

If the final result is not 1, the routine clears all eight occupancy values. Results -2 and -3 also toggle `D_80077C08`. It always rebuilds the labels before returning.

`func_80030420` copies the live signature and configuration into the image, captures options, opens with `"wb"`, recalculates the checksum, and requests a 0x1000-byte write. A successful write caches the new checksum in `D_80077C00`. Its explicit failure results are -2 for a failed status check and -3 for a short write. Open results 0 and -1 return 0 immediately. When `clearFailedSlot` is nonzero and the final result is nonpositive, the selected occupancy entry is cleared.

## Matching evidence

Fresh IDO 5.3 `-O2 -G 0 -non_shared -mips1 -32` comparisons in `.local/recovery26-save-pak` match these complete target units:

| Function | Range | Bytes |
| --- | --- | ---: |
| `func_8002FE00` | 0x8002FE00..0x8002FE68 | 104 |
| `func_8002FE68` | 0x8002FE68..0x8002FF40 | 216 |
| `func_8002FF40` | 0x8002FF40..0x8002FFC8 | 136 |
| `func_8002FFC8` | 0x8002FFC8..0x80030054 | 140 |
| `func_80030054` | 0x80030054..0x800301A4 | 336 |
| `func_800301A4` | 0x800301A4..0x80030420 | 636 |
| `func_80030420` | 0x80030420..0x800305F8 | 472 |
| `func_800305F8` | 0x800305F8..0x80030798 | 416 |

`func_800305F8` restores an occupied slot, clears the pending shell flag, and
walks the active players in current-player order. Expressing inactive players
as the loop's early `continue` reproduces the target's saved-register assignment
without a constant condition or synthetic control-flow block. The complete
416-byte procedure matches with zero differing words.
