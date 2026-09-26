.set noreorder
.set noat
.section .text, "ax", @progbits
.globl _start
.type _start, @function

_start:
    lui     $t0, %hi(__bss_start)
    lui     $t1, %hi(__bss_size)
    addiu   $t0, $t0, %lo(__bss_start)
    ori     $t1, $t1, %lo(__bss_size)
.Lclear_bss:
    addi    $t1, $t1, -8
    sw      $zero, 0($t0)
    sw      $zero, 4($t0)
    bnez    $t1, .Lclear_bss
     addi   $t0, $t0, 8
    lui     $t2, %hi(func_80048170)
    lui     $sp, %hi(__initial_stack_top)
    addiu   $t2, $t2, %lo(func_80048170)
    jr      $t2
     addiu  $sp, $sp, %lo(__initial_stack_top)
.size _start, . - _start

/* Observed alignment bytes before the first C function. */
.space 0x18, 0
