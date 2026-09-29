# SDK assembly identification

Five complete handwritten libultra service routines are now represented as
matching assembly. Robotron's target instructions establish the implementation;
the recorded SM64 libultra checkout supplies the conventional SDK names and an
independent comparison for the instruction shapes.

| Routine | ROM | Runtime | Live bytes | Target SHA-256 | Target evidence |
| --- | ---: | ---: | ---: | --- | --- |
| `__osDisableInt` | `0x68160` | `0x80067560` | 32 | `b5ec893cd5c1e37c723f982142b67fc24befcf35b6e48b596abbcca4c4d44560` | Read CP0 Status, clear IE, preserve the old IE bit, then return after the observed hazard nop |
| `__osRestoreInt` | `0x68180` | `0x80067580` | 28 | `b6f58a0412d63a52440645623c5a49320459a39befc7ea4359a374051eceb105` | Read CP0 Status, OR the caller mask, write Status, then retain both observed hazard nops |
| `__osProbeTLB` | `0x68D90` | `0x80068190` | 184 | `12b6f5b60134817aeedf2b981de4b804b3c6fa887e20414084efbbacb88b0052` | Save EntryHi, issue `tlbp`/`tlbr`, select EntryLo0/1 from PageMask and address, validate the mapping, restore EntryHi |
| `osGetCount` | `0x690C0` | `0x800684C0` | 12 | `923a8ad5844532bc55f28624d13567c9795c3f893ebf07353f29b4ea1df8bc84` | Read CP0 Count and return |
| `__osSetCompare` | `0x6F340` | `0x8006E740` | 12 | `36d5b735ab25f9bb478700d6bf34d5e54555d915b3f13a889e07eade088947cd` | Write CP0 Compare and return |

The source also owns the zero alignment immediately following the latter four
SDK objects where the target places it. `tools/compare_assembly.py` verifies the
complete source section, exact procedure extents, zero-only bytes outside the
registered procedures, linked addresses, and every target byte. The normal
full-ROM verification remains the final integration check.

The game-facing SDK headers retain their existing address-based aliases. For
example, the TLB caller declares `unsigned int func_80068190(void *address)`,
the count callers declare `unsigned int func_800684C0(void)`, and the timer
code declares `void func_8006E740(unsigned int compare)`. The canonical labels
above occupy the same target addresses without changing those callers.

The [startup investigation](startup.md) adds behavior-supported names for OS
initialization, raw PI reads, thread creation/start/priority changes, the PI
manager, and message queue initialization. The [scheduler investigation](scheduler.md)
adds VI manager creation, mode/black/feature/event setters, and event-message
registration. Those larger compiler-generated SDK routines remain separate
from the handwritten assembly accounting here.

The [SDK runtime recovery](sdk-runtime.md) now implements the complete thread
creation/start, message send/receive/queue initialization, event registration,
VI mode/black/feature/event/framebuffer services, and additional transfer and
arithmetic routines in C. Their complete procedure and generated-data checks
are recorded separately from these handwritten assembly functions.

References inspected at SM64 revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`:
[disable interrupts](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/__osDisableInt.s),
[restore interrupts](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/__osRestoreInt.s),
[probe TLB](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/__osProbeTLB.s),
[read count](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/osGetCount.s), and
[set compare](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/lib/asm/__osSetCompare.s).
The matching Robotron sources were reconstructed and assembled against the
target; no reference implementation was copied into this project. File and
target hashes are retained in `docs/libultra-assembly-provenance.json`.
