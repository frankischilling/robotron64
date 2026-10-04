# Controller Pak directory menu

`func_800267BC` spans VRAM `800267BC..80026A10` and ROM
`273BC..27610` (596 bytes). The original instructions scan 16 directory slots,
format page counts into 30-byte labels, compact pointers to occupied labels,
and construct the deletion menu. The status returns `-1` and `-2` remain
distinct; an unsuccessful free-page query returns zero.

The shared `PakMenuFileName` type is supported by the loop's 30-byte stride
and the selection callback's pointer subtraction. Its original developer name
is unknown. Six strings occupy all 144 bytes at `80093838..800938C8`, including
terminators and alignment zeros. The zero-initialized count at `80077A94` is
four bytes. The 16 labels and 16 pointers occupy 544 bytes at
`800BAF08..800BB128`.

The title is represented by the measured 104-byte span at
`800BAEA0..800BAF08`. Its use as the formatter destination is confirmed;
the original allocation size, declaration and purpose of unused bytes are
unknown. This representation preserves the following labels' addresses and
does not identify that entire span as an original character array.

Retail's `%3d` conversion pads to four characters. The name copy uses a
32-byte maximum even though each label has a 30-byte stride, and does not copy
a terminator. Preserve that overlap. Actual device names are shorter, but the
bounded execution checker also exercises 30- through 33-byte names. Synthetic
32- and 33-byte inputs write their terminators into the incoming argument area,
beyond the local buffer. These are instruction checks, not claims about
device-produced names. The cancel callback ignores its argument; its cast
preserves the existing menu callback
ABI. The file-open helper ignores its first argument, which this caller fills
with the `robo64` string address.

The complete function was independently split with splat/spimdisasm and
reassembled before comparison. The pinned IDO 5.3 source matches all 596 bytes;
objdiff reports 100% for the function, both initialized data ranges and BSS
layout. A fresh matching-workbench run and asm-differ inspection agree. No
frame padding, assembly or compiler-profile changes were needed.

`python3 tools/check_pak_menu_directory.py` freshly compiles the caller,
destination formatter and matching string/number helpers, and separately
compares both data units. Its 1,952 cases compare retail and compiled MIPS
against an independent storage oracle. They cover error returns, unsuccessful
free-page queries, empty/full/sparse directories, nonzero negative entry
responses, selected name lengths from 0 through 33 bytes, wide page counts, and both file-open
results. The checker verifies every storage byte, adjacent guards, the unused
24-byte frame gap, integer callee-saved registers, GP and SP.

Device queries, file opening and menu submission use recorded ABI stubs that
clobber caller-saved registers. The check does not emulate a Controller Pak or
run the complete menu. Decimal `INT_MIN`, arbitrary pointers and unbounded
helper output remain outside the oracle. The standard digit alphabet is
checked against retail and remains unowned.

Fresh repository comparisons passed. Final clean-build, ROM and publication
evidence is recorded in [provenance](controller-pak-menu-provenance.json).

Analysis used Ghidra and GhidraMCP, splat/spimdisasm, m2c, asm-differ, objdiff,
the pinned IDO 5.3 compiler and Unicorn. The retail ROM remains the source of
truth. Extracted references and generated binaries remain local and ignored.
