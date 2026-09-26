OUTPUT_ARCH(mips)
OUTPUT_FORMAT("elf32-tradbigmips")
ENTRY(_start)
D_80072B40 = 0x80072B40;
D_80072BA8 = 0x80072BA8;
D_800B6FF8 = 0x800B6FF8;
func_8003B694 = 0x8003B694;
__bss_start = 0x80097290;
__bss_size = 0x1003B0;
__bss_end = __bss_start + __bss_size;
__initial_stack_top = 0x8013A280;
func_80048170 = 0x80048170;

SECTIONS
{
    .header 0 : AT(0) { build/us/fallback.o(.rom_header) }
    .ipl3 0x40 : AT(0x40) { build/us/fallback.o(.rom_ipl3) }
    .entry 0x80000400 : AT(0x1000) {
        build/us/entry.o(.text)
    }
    .text_start 0x80000450 : AT(0x1050) { build/us/text.o(.text) }
    .cpu_fallback 0x80000750 : AT(0x1350) { build/us/fallback.o(.rom_cpu_fallback) }
    /* CPU-visible storage address. The RSP executes this at 0x04001000. */
    .rsp_boot 0x8006F440 : AT(0x70040) { build/us/fallback.o(.rom_rsp_boot) }
    /* Unmapped fallback uses a synthetic VMA, not a claim about RAM layout. */
    .data_before_text_table 0x90000000 : AT(0x70110) { build/us/fallback.o(.rom_data_before_text_table) }
    .text_table 0x8008F678 : AT(0x90278) SUBALIGN(4) { build/us/text.o(.rodata) }
    .remainder 0x91000000 : AT(0x90320) { build/us/fallback.o(.rom_remainder) }
    /DISCARD/ : {
        *(.reginfo .MIPS.abiflags .mdebug .mdebug.* .pdr .comment .note.GNU-stack)
    }
    .unexpected 0 : { *(.text .data .rodata .bss .sdata .sbss COMMON) }
}

ASSERT(SIZEOF(.header) == 0x40, "header size changed")
ASSERT(SIZEOF(.ipl3) == 0xfc0, "IPL3 size changed")
ASSERT(SIZEOF(.entry) == 0x50, "entry size changed")
ASSERT(SIZEOF(.text_start) == 0x300, "initial text functions size changed")
ASSERT(SIZEOF(.cpu_fallback) == 0x6ecf0, "CPU fallback size changed")
ASSERT(SIZEOF(.rsp_boot) == 0xd0, "RSP boot size changed")
ASSERT(SIZEOF(.remainder) == 0x76fce0, "fallback size changed")
ASSERT(SIZEOF(.unexpected) == 0, "unmapped input data")

ASSERT(SIZEOF(.text_table) == 0xa8, "character jump table size changed")
ASSERT(SIZEOF(.data_before_text_table) == 0x20168, "data fallback size changed")
