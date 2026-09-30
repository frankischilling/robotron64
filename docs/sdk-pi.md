# PI access routines and compiler profile

> Local reference study: the SDK implementation described below is retained
> in the private research worktree. This public checkpoint uses ROM extraction
> for these SDK ranges and does not count them as distributed matching source.
> References to integration in this report describe the local research build.

Four SDK routines now compile to their complete retail instruction bytes:

| Source | Function | Bytes | Behavior |
| --- | --- | ---: | --- |
| `pi_read.c` | `func_80063560` | 64 | Acquire PI access, read one word, release access, return the read status. |
| `pi_access.c` | `func_800677D0` | 80 | Initialize the one-message PI access queue and seed its token. |
| `pi_access.c` | `func_80067820` | 68 | Initialize lazily, then receive the access token with blocking enabled. |
| `pi_access.c` | `func_80067864` | 44 | Return the access token without blocking. |

`include/pi.h` supplies the shared interfaces. The access routines use the
same `OSMesg` and `OSMesgQueue` types as the scheduler. The token's value is
null; presence in the queue provides exclusion. The word-read wrapper saves
the raw read's result across the release call and returns it unchanged.

## Verified compiler options

The word-read wrapper distinguishes the tested compiler profiles. Both IDO
5.3 and 7.1 reproduce all 64 bytes with `-O1 -G 0 -non_shared -mips2 -32`.
With `-O1 -mips1`, the same C produces 68 live bytes: the second argument
load cannot occupy the call delay slot and an extra instruction remains.
With `-O2 -mips1`, register allocation and the stack frame also differ.
The tested `-O2 -mips2` and `-O3 -mips2` outputs do not match the wrapper.

All three access-queue routines match with both tested compilers at either
`-O1 -mips2` or `-O2 -mips2`. This supports the MIPS II scheduling profile
but does not independently distinguish their optimization level. The build
uses IDO 5.3 at `-O1 -mips2` for these four verified functions. This is a
reproducible matching configuration; these results do not identify the
original IDO version or libultra release.

`tools/compiler.py` selects options by an explicit source-file mapping.
Game sources retain `-O2 -mips1`. Unlisted SDK candidates also retain the
default until their own comparisons establish another profile. The normal
build and independent comparisons use this same selector, and each C
object's provenance records the selected compiler profile. A changed profile
requires a rebuild before progress can be measured.
