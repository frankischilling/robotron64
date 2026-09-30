.set noreorder
.set noat
.section .text, "ax", @progbits

.globl __osDisableInt
.type __osDisableInt, @function
__osDisableInt:
    mfc0    $t0, $12
    addiu   $at, $zero, -2
    and     $t1, $t0, $at
    mtc0    $t1, $12
    andi    $v0, $t0, 1
    nop
    jr      $ra
     nop
.size __osDisableInt, . - __osDisableInt

.globl __osRestoreInt
.type __osRestoreInt, @function
__osRestoreInt:
    mfc0    $t0, $12
    or      $t0, $t0, $a0
    mtc0    $t0, $12
    nop
    nop
    jr      $ra
     nop
.size __osRestoreInt, . - __osRestoreInt

/* Alignment before the following SDK object. */
.space 4, 0
