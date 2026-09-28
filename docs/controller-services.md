# Controller services

The game controller layer occupies `0x8004EFB0..0x8004FE04`, with a twelve-byte
alignment gap at `0x8004F984..0x8004F990`. Its functions serialize SI access,
poll controller input, dispatch rumble commands, identify accessories, and
present Controller Pak directory entries. Recovery uses the US target ROM,
the actual call sites, and the existing matched SDK interfaces.

Candidates are compared with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`. A candidate contributes no progress until
its complete function body, source inputs, and any data it defines pass the
independent comparison and integrated build checks.

## Matching source

Seven source units contain eleven matching functions and 1,432 bytes. Each
complete unit passed an independent comparison and the full public ROM build.

| Source | Complete range | Functions | Bytes |
| --- | --- | ---: | ---: |
| `controller_access.c` | `0x8004EFB0..0x8004F06C` | 3 | 188 |
| `controller_motor_commands.c` | `0x8004F178..0x8004F1EC` | 2 | 116 |
| `controller_scan.c` | `0x8004F1EC..0x8004F330` | 1 | 324 |
| `controller_pak_info.c` | `0x8004F990..0x8004FA14` | 2 | 132 |
| `controller_pak_delete.c` | `0x8004FA14..0x8004FAC0` | 1 | 172 |
| `controller_pak_name.c` | `0x8004FAC0..0x8004FB48` | 1 | 136 |
| `controller_pak_directory.c` | `0x8004FC98..0x8004FE04` | 1 | 364 |

These units define no initialized data or BSS. The motor thread, polling,
initialization/rescan, rumble update, and individual Pak-entry routines remain
excluded candidates. Their private comparison records include code-size,
instruction-scheduling, and register-allocation differences; they contribute
no matching bytes to this checkpoint.

## Layout and behavior

`ControllerMotorCommand` contains a signed halfword operation at offset zero
and a port number at offset four. Queue messages point to this eight-byte
record. Operation one starts the motor and operation zero stops it. The
record at `D_80143418` is shared by both command producers.

The game allocates four 104-byte `SdkPfs` records at `D_8013D9D8`. The presence,
running, and pulse-accumulator arrays each contain four words, as shown by
the initialization loops. Controller pad records use the SDK's six-byte
stride; stick coordinates are signed bytes. Polling stores the current
buttons, changed-to-pressed buttons, previous buttons, and stick coordinates.

The thread object at `D_80141248` is 432 bytes. Its following stack begins at
`0x801413F8`; the initializer passes `0x801433F8` as the stack top. The
8192-byte interval is represented by 1024 doublewords. The controller status
array starts at that same top address. This extent follows the object layout
and initializer arguments; the original stack identifier is unavailable.

Rumble intensity is made nonnegative by `func_8004F960`. The update routine
uses full rumble at strengths of at least 71, stops below six, and otherwise
updates a pulse accumulator with signed integer division of the cubed
strength by 512. The target's arithmetic and command order are preserved.

The Pak name decoder maps character codes 15 through 65 using the table at
`D_8008D520`. It clears its 256-byte output buffer before decoding. The
terminating input byte is converted to a space, and the preceding clear
provides the following zero byte. Directory labels append the decoded
extension using the target format `%s.%c`; unsupported glyphs become spaces.

Deleting a file with game code `NRXE` and company code `4Z` also clears the
eight occupancy words at `D_800AD318 + 0x1A8`. The complete 4 KiB image layout
and the capture/read/write behavior are documented in [Save format](save-game.md).

## Evidence and references

Private target assembly, caller excerpts, rejected candidates, and complete
comparison reports are retained under `.local/recovery19-controller`,
`.local/recovery25-controller`, and `.local/recovery28-integration`. Canonical
proofs are under `build/sdk-options` with archived source/header inputs. The provisional target
inventory is used for discovery; each accepted function needs a complete
body comparison and a real endpoint.

The local [libreultra](https://github.com/n64decomp/libreultra) checkout at
`1aca5c13ca041cef86f8dc194b727361dad9c09b`, especially
`include/2.0I/PR/os.h`, identifies the Controller Pak state layout, accessory
error values 10 and 11, and motor API signatures. These interfaces help
interpret the game calls. The game instructions and calling sites determine
the reconstructed control flow. The broader reference collection is credited
in [CREDITS.md](../CREDITS.md).

## Legacy accessory scan

The separate `func_8004C0D4` entry point now matches in
`src/game/controller_legacy_scan.c`, adding one complete 244-byte function.
It queries the accessory mask, visits each of the four indicated ports, and
clears a port for the target's fatal-ID or device error. It uses the existing
SDK interface declarations; no SDK implementation is copied into this game
source. The complete canonical proof is under `.local/recovery67-integration`,
with behavior summarized in [Additional runtime recovery](runtime-recovery.md).
