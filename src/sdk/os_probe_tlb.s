.set noreorder
.set noat
.section .text, "ax", @progbits

.globl __osProbeTLB
.type __osProbeTLB, @function
__osProbeTLB:
    mfc0    $t0, $10
    andi    $t1, $t0, 0xff
    addiu   $at, $zero, -0x2000
    and     $t2, $a0, $at
    or      $t1, $t1, $t2
    mtc0    $t1, $10
    nop
    nop
    nop
    tlbp
    nop
    nop
    mfc0    $t3, $0
    lui     $at, 0x8000
    and     $t3, $t3, $at
    bnez    $t3, .Lprobe_failed
     nop
    tlbr
    nop
    nop
    nop
    mfc0    $t3, $5
    addi    $t3, $t3, 0x2000
    srl     $t3, $t3, 1
    and     $t4, $t3, $a0
    bnez    $t4, .Lodd_page
     addi   $t3, $t3, -1
    mfc0    $v0, $2
    b       .Lcheck_valid
     nop
.Lodd_page:
    mfc0    $v0, $3
.Lcheck_valid:
    andi    $t5, $v0, 2
    beqz    $t5, .Lprobe_failed
     nop
    lui     $at, 0x3fff
    ori     $at, $at, 0xffc0
    and     $v0, $v0, $at
    sll     $v0, $v0, 6
    and     $t5, $a0, $t3
    add     $v0, $v0, $t5
    b       .Lprobe_done
     nop
.Lprobe_failed:
    addiu   $v0, $zero, -1
.Lprobe_done:
    mtc0    $t0, $10
    jr      $ra
     nop
.size __osProbeTLB, . - __osProbeTLB

/* Alignment before the following SDK object. */
.space 8, 0
