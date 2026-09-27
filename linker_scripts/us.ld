OUTPUT_ARCH(mips)
OUTPUT_FORMAT("elf32-tradbigmips")
ENTRY(_start)
INCLUDE config/startup_symbols.ld
D_80072B40 = 0x80072B40;
D_80072BA8 = 0x80072BA8;
D_800B6FF8 = 0x800B6FF8;
func_8003B694 = 0x8003B694;
__bss_start = 0x80097290;
__bss_size = 0x1003B0;
__bss_end = __bss_start + __bss_size;
__initial_stack_top = 0x8013A280;

D_800B1BE8 = 0x800B1BE8;
D_8008F620 = 0x8008F620;
func_8001C0D0 = 0x8001C0D0;
func_8003921C = 0x8003921C;
func_8003947C = 0x8003947C;
func_80039DCC = 0x80039DCC;
func_80039E0C = 0x80039E0C;
func_80039E1C = 0x80039E1C;
func_80039E5C = 0x80039E5C;
func_80039E80 = 0x80039E80;

func_8003B4FC = 0x8003B4FC;
func_8003B704 = 0x8003B704;
D_8008F64C = 0x8008F64C;

func_800392F4 = 0x800392F4;

D_8009EFA4 = 0x8009EFA4;

func_80000F48 = 0x80000F48;
func_8003B7FC = 0x8003B7FC;

func_8003B520 = 0x8003B520;
func_8003B6E4 = 0x8003B6E4;

D_800BF918 = 0x800BF918;
D_FLT_80094C20 = 0x80094C20;
D_FLT_80094C24 = 0x80094C24;
D_FLT_80094C28 = 0x80094C28;

D_DBL_80094C30 = 0x80094C30;
D_DBL_80094C38 = 0x80094C38;
D_DBL_80094C40 = 0x80094C40;

SECTIONS
{
    .header 0 : AT(0) { build/us/fallback.o(.rom_header) }
    .ipl3 0x40 : AT(0x40) { build/us/fallback.o(.rom_ipl3) }
    .entry 0x80000400 : AT(0x1000) {
        build/us/entry.o(.text)
    }
    .text_start 0x80000450 : AT(0x1050) { build/us/text.o(.text) }
    .text_replacement 0x80000F48 : AT(0x1B48) { build/us/fallback.o(.rom_text_replacement) }
    .text_wrapper 0x800011AC : AT(0x1DAC) SUBALIGN(4) { build/us/text_wrapper.o(.text) }
    .text_edit 0x80001270 : AT(0x1E70) { build/us/text_edit.o(.text) }
    .text_properties 0x800013D0 : AT(0x1FD0) { build/us/text_properties.o(.text) }
    .text_conversion 0x800016D8 : AT(0x22D8) SUBALIGN(4) { build/us/text_conversion.o(.text) }
    .cpu_fallback 0x8000177C : AT(0x237C) { build/us/fallback.o(.rom_cpu_fallback) }
    .object_transforms 0x800394C0 : AT(0x3A0C0) { build/us/object_transforms.o(.text) }
    .cpu_after_objects 0x80039C78 : AT(0x3A878) { build/us/fallback.o(.rom_cpu_after_objects) }
    .startup 0x80048170 : AT(0x48D70) SUBALIGN(16) { build/us/startup.o(.text) }
    .cpu_after_startup 0x80048510 : AT(0x49110) { build/us/fallback.o(.rom_cpu_after_startup) }
    .scheduler 0x80050440 : AT(0x51040) { build/us/scheduler.o(.text) }
    .cpu_after_scheduler 0x80050630 : AT(0x51230) { build/us/fallback.o(.rom_cpu_after_scheduler) }
    /* CPU-visible storage address. The RSP executes this at 0x04001000. */
    .rsp_boot 0x8006F440 : AT(0x70040) { build/us/fallback.o(.rom_rsp_boot) }
    /* Unmapped fallback uses a synthetic VMA, not a claim about RAM layout. */
    .data_before_text_table 0x90000000 : AT(0x70110) { build/us/fallback.o(.rom_data_before_text_table) }
    .text_table 0x8008F678 : AT(0x90278) SUBALIGN(4) { build/us/text.o(.rodata) }
    .remainder 0x91000000 : AT(0x903A0) { build/us/fallback.o(.rom_remainder) }
    /DISCARD/ : {
        *(.reginfo .MIPS.abiflags .mdebug .mdebug.* .pdr .comment .note.GNU-stack)
    }
    .unexpected 0 : { *(.text .data .rodata .bss .sdata .sbss COMMON) }
}

ASSERT(SIZEOF(.header) == 0x40, "header size changed")
ASSERT(SIZEOF(.ipl3) == 0xfc0, "IPL3 size changed")
ASSERT(SIZEOF(.entry) == 0x50, "entry size changed")
ASSERT(SIZEOF(.text_start) == 0xaf8, "initial text functions size changed")
ASSERT(SIZEOF(.cpu_fallback) == 0x37d44, "CPU fallback size changed")
ASSERT(SIZEOF(.rsp_boot) == 0xd0, "RSP boot size changed")
ASSERT(SIZEOF(.remainder) == 0x76fc60, "fallback size changed")
ASSERT(SIZEOF(.unexpected) == 0, "unmapped input data")

ASSERT(SIZEOF(.text_table) == 0x128, "text jump tables size changed")
ASSERT(SIZEOF(.data_before_text_table) == 0x20168, "data fallback size changed")

ASSERT(SIZEOF(.text_replacement) == 0x264, "replacement fallback size changed")
ASSERT(SIZEOF(.text_wrapper) == 0xc4, "text wrapper size changed")

ASSERT(SIZEOF(.text_edit) == 0x160, "text edit functions size changed")

ASSERT(SIZEOF(.text_properties) == 0x308, "text property functions size changed")

ASSERT(SIZEOF(.text_conversion) == 0xa4, "text conversion function size changed")

ASSERT(SIZEOF(.object_transforms) == 0x7b8, "object transforms size changed")
ASSERT(SIZEOF(.cpu_after_objects) == 0xe4f8, "CPU fallback after transforms size changed")
ASSERT(SIZEOF(.startup) == 0x3a0, "startup functions size changed")
ASSERT(SIZEOF(.cpu_after_startup) == 0x7f30, "CPU fallback after startup size changed")
ASSERT(SIZEOF(.scheduler) == 0x1f0, "scheduler functions size changed")
ASSERT(SIZEOF(.cpu_after_scheduler) == 0x1ee10, "CPU fallback after scheduler size changed")
