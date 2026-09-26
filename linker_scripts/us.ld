OUTPUT_ARCH(mips)
OUTPUT_FORMAT("elf32-tradbigmips")
ENTRY(_start)

SECTIONS
{
    .header 0 : AT(0) { build/us/fallback.o(.rom_header) }
    .ipl3 0x40 : AT(0x40) { build/us/fallback.o(.rom_ipl3) }
    .entry 0x80000400 : AT(0x1000) {
        _start = .;
        build/us/fallback.o(.rom_entry)
    }
    .square 0x80000450 : AT(0x1050) { build/us/math.o(.text) }
    /* Unmapped fallback uses a synthetic VMA, not a claim about RAM layout. */
    .remainder 0x90000000 : AT(0x1060) { build/us/fallback.o(.rom_remainder) }
    /DISCARD/ : {
        *(.reginfo .MIPS.abiflags .mdebug .mdebug.* .pdr .comment .note.GNU-stack)
    }
    .unexpected 0 : { *(.text .data .rodata .bss .sdata .sbss COMMON) }
}

ASSERT(SIZEOF(.header) == 0x40, "header size changed")
ASSERT(SIZEOF(.ipl3) == 0xfc0, "IPL3 size changed")
ASSERT(SIZEOF(.entry) == 0x50, "entry size changed")
ASSERT(SIZEOF(.square) == 0x10, "square function size changed")
ASSERT(SIZEOF(.remainder) == 0x7fefa0, "fallback size changed")
ASSERT(SIZEOF(.unexpected) == 0, "unmapped input data")
