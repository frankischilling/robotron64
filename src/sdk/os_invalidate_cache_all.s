.set noreorder
.set noat
.section .text, "ax", @progbits

/* Invalidate the 8 KiB primary data cache by its 16-byte line indices. */
.globl func_80060720
.type func_80060720, @function
func_80060720:
    lui     $t0, 0x8000
    addiu   $t2, $zero, 0x2000
    addu    $t1, $t0, $t2
    addiu   $t1, $t1, -16
.Lcache_line:
    cache   1, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Lcache_line
     addiu  $t0, $t0, 16
    jr      $ra
     nop
.size func_80060720, . - func_80060720
.space 8, 0
