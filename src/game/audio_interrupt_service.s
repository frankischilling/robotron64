.set noreorder
.set noat
.section .text, "ax", @progbits

.globl func_8005D9E0
.type func_8005D9E0, @function
func_8005D9E0:
    mfc0    $t0, $12
    addiu   $at, $zero, -2
    and     $t1, $t0, $at
    mtc0    $t1, $12
    andi    $v0, $t0, 1
    nop
    jr      $ra
     nop
.size func_8005D9E0, . - func_8005D9E0

.globl func_8005DA00
.type func_8005DA00, @function
func_8005DA00:
    mfc0    $t0, $12
    nop
    or      $t0, $t0, $a0
    mtc0    $t0, $12
    nop
    nop
    jr      $ra
     nop
.size func_8005DA00, . - func_8005DA00
