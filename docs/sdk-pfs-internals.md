# SDK controller Pak internals

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

The remaining controller Pak service layer in the US ROM matches an older libultra PFS family. Every source unit in this recovery compiles with IDO 5.3 using `-O1 -G0 -non_shared -mips2 -32` and compares byte-for-byte with the retail ROM. The final sources account for 12,576 text bytes across Pak detection and initialization, free-space and directory operations, ID and inode maintenance, status and checker logic, and controller RAM reads and writes.

The recovered text units are:

| Source | Target range | Role | Exact bytes |
| --- | --- | --- | ---: |
| `src/libultra/pfs_is_plug.c` | `0x80061A00..0x80061D6C` | Pak detection, request builder, response parser | 876/876 |
| `src/libultra/pfs_init_pak.c` | `0x80061D70..0x80061FD4` | Pak initialization | 612/612 |
| `src/libultra/pfs_free_blocks.c` | `0x80064140..0x8006428C` | Free-space count | 332/332 |
| `src/libultra/pfs_num_files.c` | `0x80064290..0x800643D4` | Directory occupancy count | 324/324 |
| `src/libultra/pfs_delete_file.c` | `0x800643E0..0x800649E8` | Delete, release-page walk, block checksum | 1544/1544 |
| `src/libultra/pfs_file_state.c` | `0x800649F0..0x80064CE0` | File metadata and size walk | 752/752 |
| `src/libultra/pfs_contpfs.c` | `0x800688D0..0x80069628` | ID checks, repair, inode I/O, bank select | 3416/3416 |
| `src/libultra/pfs_cont_ram_read.c` | `0x80069630..0x800699B4` | Controller Pak RAM read and packet builder | 900/900 |
| `src/libultra/pfs_get_status.c` | `0x80069B30..0x80069C3C` | Current Pak status | 268/268 |
| `src/libultra/pfs_checker.c` | `0x80069C40..0x8006A6A0` | Filesystem consistency checker | 2656/2656 |
| `src/libultra/pfs_cont_ram_write.c` | `0x8006A6A0..0x8006AA20` | Controller Pak RAM write and packet builder | 896/896 |

`pfs_is_plug.c` proves ownership of the shared PFS PIF buffer. Its only owned data is the 64-byte BSS object `D_80194D20` at `0x80194D20..0x80194D60`. The last-command and controller-count bytes `D_80194FE0` and `D_80194FE1` remain shared with the existing controller initialization unit. The RAM transfer sources also call the existing SI access/DMA routines and the address/data CRC helpers.

Several old-SDK behaviors are visible in the target and are kept as written. `pfs_init_pak.c` goes from bank selection directly to the ID checksum path; there is no controller-RAM read between those operations in the target. The matching C therefore does not add the ID-block read present in several later reference implementations. `func_8006929C` writes both primary and mirror inode blocks before checking the final return value, and its mirror-recovery read path preserves the target checksum handling rather than introducing a new checksum calculation. The free-block and file-count routines likewise keep their older return behavior instead of adding later status checks.

The delete path uses the older release-page condition at `0x800646C0`: after following a chain, a page whose encoded value remains at or above `inodeStartPage` is cleared without an additional current-bank comparison. The file-state routine converts its page count to bytes with `SDK_PFS_PAGE_SHIFT` (`8`, because a page is 256 bytes).

The checker compares encoded inode pages against the low 16 bits of `pfs->inodeStartPage`. The production source expresses that as `(unsigned short)pfs->inodeStartPage`. On the target big-endian layout, `inodeStartPage` is the 32-bit field at offset `0x60`, and IDO emits the observed `lhu 0x62(pfs)`. The local old-SDK reconstruction sources use the representation-oriented `((__OSInodeUnit *)&pfs->inode_start_page + 1)->ipage` form. Both forms were compiled as private probes and both produce the same zero-difference `0x80069C40..0x8006A6A0` text; the production source keeps the clearer numeric narrowing.

The controller RAM read/write routines use the older retry behavior. They build the complete PIF packet once, retry failed transfers after consulting Pak status, map channel errors to the no-Pak result, and preserve the target's fixed retry count. Both packet builders clear the full PIF RAM before constructing a request.

Reference source shapes were checked against these local revisions; they identify SDK structure and family but do not override the Robotron ROM when revisions differ:

- `https://github.com/n64decomp/libreultra.git` at `1aca5c13ca041cef86f8dc194b727361dad9c09b`: `src/io/pfsfreeblocks.c`, `pfsnumfiles.c`, `pfsdeletefile.c`, `pfsfilestate.c`, `contpfs.c`, `contramread.c`, `contramwrite.c`, `pfsgetstatus.c`, `pfschecker.c`, `pfsinitpak.c`, and `pfsisplug.c`.
- `https://github.com/n64decomp/mk64.git` at `58cfcb022e10f83bc3b889d7e97508cae6837098`: `src/os/osPfsDeleteFile.c`, `contramread.c`, `contramwrite.c`, and `osPfsIsPlug.c` corroborate the older page-chain and full-PIF-clear variants.
- `https://github.com/n64decomp/sm64.git` at `9921382a68bb0c865e5e45eb594d9c64db59b1af`: `lib/src/contramread.c`, `contramwrite.c`, and `pfsgetstatus.c` corroborate the RAM-transfer/status family.
- `https://github.com/n64decomp/007.git` at `c4356466796c697dfd298010b9bed261f9ed8c6a`: `src/libultrare/io/pfsinit.c` was used as an additional old-SDK initialization/status reference.
- `https://github.com/zeldaret/oot.git` at `1bef952ff61a6dd1945c7887c1babd94efe95f72` and `https://github.com/zeldaret/mm.git` at `56fa21dd0031a17cfc9e355f609542617598a265` were inspected where later PFS behavior helped distinguish target-revision differences.

Final source snapshots, comparator reports, target disassemblies, BSS ownership evidence, function boundaries, and the two checker-expression probes are retained under `.local/recovery6-pfs/`.
