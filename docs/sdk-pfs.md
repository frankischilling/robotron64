# SDK controller Pak recovery

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

The controller Pak code in the US ROM uses an older libultra PFS implementation. The recovered source is ordinary C compiled with IDO 5.3 using `-O1 -G0 -non_shared -mips2 -32`.

`src/libultra/pfs_search_file.c` covers `0x80062380..0x80062534` and corresponds to `osPfsFindFile`. `src/libultra/pfs_allocate_file.c` covers `0x80062540..0x80062CE8`: `osPfsAllocateFile` at `0x80062540`, `__osPfsDeclearPage` at `0x800629C4`, and the page-clearing helper at `0x80062C28`. `src/libultra/pfs_read_write_file.c` covers `0x80062CF0..0x800631EC`: the next-page helper at `0x80062CF0` and `osPfsReadWriteFile` at `0x80062DEC`.

The page allocator matches the older SDK behavior represented by the local libreultra and Mario Kart 64 references: newly allocated Pak pages are explicitly cleared through the helper at `0x80062C28`. The read/write routine is from the same family but the Robotron ROM omits the later directory company/game zero check. The target instructions and callers establish that difference independently.

The motor source unit begins at `0x800636F0`, after the padding following the message-send routine, and ends at `0x80063D04`. Its four routines are `osMotorStop` at `0x800636F0`, `osMotorStart` at `0x80063858`, the command-buffer builder at `0x800639C4`, and `osMotorInit` at `0x80063B40`. This ROM uses the older motor protocol shape also present in the local GoldenEye-era reference: fixed response CRC sentinels for stop/start and a single `0x80` device probe.

The motor translation unit owns 576 bytes of BSS at `0x80194D60..0x80194FA0`: four stop command PIF buffers at `0x80194D60`, four start command PIF buffers at `0x80194E60`, the 32-byte stop payload at `0x80194F60`, and the 32-byte start payload at `0x80194F80`. The shared 64-byte PFS PIF transfer buffer at `0x80194D20` is required as an external definition. The existing controller last-command byte at `0x80194FE0` is also shared.

Each recovered PFS text unit is validated directly against the retail ROM. Exact comparator reports and immutable source/header snapshots are retained under `.local/recovery5-pfs/`.

Reference sources used for structure and SDK-family identification were local checkouts at these exact revisions. The Robotron ROM remained the authority for function boundaries, behavior, and revision-specific differences.

- `https://github.com/n64decomp/libreultra.git` at `1aca5c13ca041cef86f8dc194b727361dad9c09b`: `src/io/pfssearchfile.c`, `src/io/pfsallocatefile.c`, `src/io/pfsreadwritefile.c`, `src/io/motor.c`, `src/io/controller.h`, and `include/2.0I/PR/os.h`.
- `https://github.com/n64decomp/mk64.git` at `58cfcb022e10f83bc3b889d7e97508cae6837098`: `src/os/osPfsSearchFile.c` and `src/os/osPfsAllocateFile.c` corroborated the older page-clearing allocator shape.
- `https://github.com/n64decomp/007.git` at `c4356466796c697dfd298010b9bed261f9ed8c6a`: `src/motor.c` identified the older fixed-CRC motor command shape.
- `https://github.com/zeldaret/oot.git` at `1bef952ff61a6dd1945c7887c1babd94efe95f72`: `src/libultra/io/pfsfindfile.c`, `pfsallocatefile.c`, `pfsfreeblocks.c`, `pfsdeletefile.c`, `pfsreadwritefile.c`, and `pfsselectbank.c` were inspected to distinguish later PFS behavior from the target revision.

Final zero-difference comparisons under IDO 5.3 `-O1 -G0 -non_shared -mips2 -32` are 436/436 bytes for search, 1960/1960 for allocation, 1276/1276 for read/write, and 1556/1556 for motor.

The next-page helper remains `static` in C. IDO's ELF symbol table omits its
name, while the compiler's `.mdebug` records identify `func_80062CF0` and its
252-byte extent. [Static-function verification](ido-static-functions.md)
explains how those records supplement the linked-section and byte checks.
