.set noreorder
.section .text, "ax", @progbits

/* Slot 31 maps the debug interface's even page; preserve the current ASID. */
.globl func_80067460
.type func_80067460, @function
func_80067460:
    mfc0    $t0, $10
    addiu   $t1, $zero, 31
    mtc0    $t1, $0
    mtc0    $zero, $5
    addiu   $t2, $zero, 0x17
    lui     $t1, 0xC000
    mtc0    $t1, $10
    lui     $t1, 0x8000
    srl     $t3, $t1, 6
    or      $t3, $t3, $t2
    mtc0    $t3, $2
    addiu   $t1, $zero, 1
    mtc0    $t1, $3
    nop
    tlbwi
    nop
    nop
    nop
    nop
    mtc0    $t0, $10
    jr      $ra
     nop
.size func_80067460, . - func_80067460
.space 8, 0
