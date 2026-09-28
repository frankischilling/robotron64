# Continue-code encoding

`func_800312B0` at `0x800312B0..0x80031420` encodes the game's ten-character
continue code. The complete 368-byte function matches the US target with
IDO 5.3 and `-O2 -G 0 -non_shared -mips1 -32`. It emits no initialized data
or BSS.

The first packed word uses the following big-endian bit fields:

| Bits | Width | Stored value |
| --- | ---: | --- |
| 31..29 | 3 | Sum of the other five fields, reduced modulo eight |
| 28..14 | 15 | Player `saved.value18 / 1000` |
| 13..11 | 3 | Option `field08` |
| 10..7 | 4 | Option `field0C` |
| 6..0 | 7 | Player `saved.active` |

The next byte contains the session's saved level. The unused 24 bits in that
second word are cleared. Assignments to the unsigned bit fields preserve the
original truncation before the checksum reads them back; the source does not
introduce range checks or saturation. Two preceding local storage words remain
uninterpreted because the target accesses only the packed code that follows.

The function visits those five bytes in address order. For each byte it sends
the low nibble to `func_80030FEC` first, then the high nibble, and finally writes
the string terminator. The existing nibble encoder supplies the alphabet.

The reciprocal routine at `0x80031080` remains under comparison. Matching the
encoder does not establish that the decoder has been recovered.

The accepted source and first complete proof are preserved under
`.local/recovery61-menu/accepted/func_800312B0`. Independent canonical-source
comparison, complete procedure bounds, compiler identity, and current
transitive-header evidence are under `.local/recovery61-integration`.
