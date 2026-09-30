# Controller input and Controller Pak storage

Eighteen complete SDK source units reconstruct controller initialization and
polling, Controller Pak identification and filesystem operations, motor
commands, and the controller address/data CRC routines. The 44 procedures
account for 19,744 live C bytes, four initialized bytes and 784 BSS bytes.
They use the existing checked controller, timer, PFS and inode declarations.

| Source in `src/sdk/` | Complete runtime range | Procedures | Live code |
| --- | --- | ---: | ---: |
| `pfs_is_plug.c` | `0x80061A00..0x80061D6C` | 3 | 876 |
| `pfs_init_pak.c` | `0x80061D70..0x80061FD4` | 1 | 612 |
| `controller_read.c` | `0x80061FE0..0x80062238` | 3 | 600 |
| `pfs_search_file.c` | `0x80062380..0x80062534` | 1 | 436 |
| `pfs_allocate_file.c` | `0x80062540..0x80062CE8` | 3 | 1,960 |
| `pfs_read_write_file.c` | `0x80062CF0..0x800631EC` | 2 | 1,276 |
| `pfs_motor.c` | `0x800636F0..0x80063D04` | 4 | 1,556 |
| `controller_init.c` | `0x80063D10..0x800640CC` | 3 | 956 |
| `pfs_free_blocks.c` | `0x80064140..0x8006428C` | 1 | 332 |
| `pfs_num_files.c` | `0x80064290..0x800643D4` | 1 | 324 |
| `pfs_delete_file.c` | `0x800643E0..0x800649E8` | 3 | 1,544 |
| `pfs_file_state.c` | `0x800649F0..0x80064CE0` | 1 | 752 |
| `pfs_contpfs.c` | `0x800688D0..0x80069628` | 8 | 3,416 |
| `pfs_cont_ram_read.c` | `0x80069630..0x800699B4` | 2 | 900 |
| `pfs_get_status.c` | `0x80069B30..0x80069C3C` | 1 | 268 |
| `pfs_checker.c` | `0x80069C40..0x8006A6A0` | 3 | 2,656 |
| `pfs_cont_ram_write.c` | `0x8006A6A0..0x8006AA20` | 2 | 896 |
| `controller_crc.c` | `0x8006AA20..0x8006ABA0` | 2 | 384 |

## Controller packets and shared SI ownership

Initialization runs once, waits for the target's minimum startup interval,
initializes the four-channel request, and exchanges a complete PIF RAM packet
through the existing serial-interface DMA functions. It decodes controller
types, status and per-channel errors, creates the SI access queue and
initializes EEPROM timer storage.

The read path rebuilds its request when the previous controller command
differs, starts the DMA read and later decodes buttons and signed stick
coordinates. Packet fields and strides are checked by the existing eight-byte
request types. Every PIF buffer includes the final control word in its
64-byte allocation; the different clearing loops in controller and motor
commands preserve their exact target extents.

The Pak read/write paths acquire the same SI access lock, construct a
channel-prefixed 40-byte request, validate the response CRC and apply the
target's retry/error behavior. The address CRC uses the five-bit polynomial
`0x15`; the data CRC uses `0x85` and shifts a final byte of zeros. The read
packet builder and write packet builder remain source-static functions
compiled with their callers.

## Pak identification, allocation and repair

The 104-byte PFS record holds the queue, channel, identity, label, directory
and inode locations, bank count and active bank. Its directory entries are
32 bytes, and its 128 two-byte inode entries form a 256-byte table. The ID
repair code probes banks, validates the primary and mirrored identity
records, computes both checksums and writes the recovered copies through the
same bounded packet interfaces.

File search checks the company/game identifiers and optional name and
extension. Allocation locates a free directory record, reserves pages across
banks, links successive inode chains and clears each allocated page. The
read/write procedure validates file number, positive size and block-aligned
offset/length before traversing the chain. Its private next-page helper
checks the bank, page and terminal markers. A successful initial write marks
the directory entry occupied.

Deletion walks and frees the chain, updates the inode copies and clears the
directory fields. Free-space and file-count queries scan the same on-Pak
records. The consistency checker tracks cross-bank references in its checked
514-byte cache, clears invalid directory records and rebuilds the inode maps
from surviving chains. File-state queries return the page-derived size and
the stored company, game, name and extension fields.

Motor initialization checks the device bank, prepares separate on/off
packets for all four channels and validates the expected CRC in each reply.
Those persistent packet arrays and their 32-byte payload buffers are owned
by `pfs_motor.c`.

## Historical behavior preserved from the target

`func_80061D70` calculates an ID checksum from its local 32-byte buffer before
that buffer has been filled. After bank selection, the target directly calls
the checksum helper with stack offset `0x3C`; it contains no intervening ID
read or initialization. This is an indeterminate automatic-object read in
the reconstructed C, and its behavior depends on the original stack state
and pinned compiler. The subsequent checksum-failure path can recover a
mirrored ID. Adding an initial read would change the shipped function, so
this source retains and documents the observed behavior.

`func_8006929C` retains three related details. When writing an inode block,
the mirror-write result replaces the primary-write result before the error
check. On a primary checksum mismatch, it reads the mirror without checking
each read result, and compares the previously computed checksum against the
mirror's checksum byte without recomputing the checksum of the newly read
data. Its later repair-write loops also return zero after completion without
propagating every intermediate status. The complete target instructions
confirm these branches and stores. These historical semantics are separate
from the intended filesystem behavior described by SDK references.

## Complete storage ownership

The initialized controller guard `D_8008F130` owns four `.data` bytes at
`0x8008F130`, ROM `0x8FD30`. Its natural trailing object alignment is checked
and trimmed before integration. No unit in this batch emits `.rodata`.

| BSS owner | Range | Bytes | Variables and section offsets |
| --- | --- | ---: | --- |
| `pfs_is_plug.c` | `0x80194D20..0x80194D60` | 64 | `D_80194D20` at 0 |
| `pfs_motor.c` | `0x80194D60..0x80194FA0` | 576 | `D_80194D60` at 0, `D_80194E60` at 256, `D_80194F60` at 512, `D_80194F80` at 544 |
| `controller_read.c` | `0x80194FA0..0x80194FE0` | 64 | `D_80194FA0` at 0 |
| `controller_init.c` | `0x80194FE0..0x80195030` | 80 | `D_80194FE0` at 0, `D_80194FE1` at 1, `D_80194FE8` at 8, `D_80195008` at 40, `D_80195020` at 64 |

These are ordinary shared definitions with existing external declarations;
all exported object symbols, offsets and sizes are checked before their
sections are placed. No artificial prefixes or padding arrays are added.
The three internal procedures retain their actual extents: 252 bytes at
`0x80062CF0`, 360 bytes at `0x8006984C`, and 380 bytes at `0x8006A8A4`.
Paired IDO ECOFF procedure records establish those extents without making the
helpers externally visible.

## Provenance and validation

The reviewed worker commit is
`59dfce3de84ecd9283d12cbf6f003ff6e6389bb9`. Its retained `src/libultra/`
payloads were checked byte for byte against the committed archive, complete
worker reports, relevant header hashes and the normalized target ROM. The
same source bytes were then freshly compiled in the integration tree and
registered under `src/sdk/`. This promotes the retained reconstruction with
complete current proofs; it does not claim that previously existing source
was first written during this integration.

The `controller-pak-prime-target-v1` reports match all 19,744 live code bytes,
all 44 complete procedure extents, the initialized guard and all four BSS
sections using IDO 5.3 `sdk-o1-mips2`. Natural trailing text alignment is
excluded from C progress. Every promoted unit also has an independent
production comparison and complete input/compiler identity records.

The integration passes all 114 tooling tests and builds the complete target.
The independent `controller-pak-canonical` run verifies all 18 production
units with zero differing words. `controller-pak-rom-final` compares all
8,388,608 bytes and records SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
Full logs, binary proofs and the import/integration ledgers remain local.

The credited sm64 CC0 and Perfect Dark MIT snapshots provide the source
reference basis. The pinned libreultra, decompals/ultralib and related
decompilation studies corroborate protocol and SDK structure; repositories
without an applicable license are not treated as a license grant. Exact
revisions and reference roles are recorded in [CREDITS.md](../CREDITS.md) and
the preserved worker review.
