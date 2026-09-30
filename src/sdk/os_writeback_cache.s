.set noreorder
.set noat
.section .text, "ax", @progbits

/* Write back addressed 16-byte data lines, or the full 8 KiB cache. */
.globl func_80067360
.type func_80067360, @function
func_80067360:
    blez    $a1, .Lwriteback_done
     nop
    addiu   $t3, $zero, 0x2000
    sltu    $at, $a1, $t3
    beqz    $at, .Lwriteback_all
     nop
    move    $t0, $a0
    addu    $t1, $a0, $a1
    sltu    $at, $t0, $t1
    beqz    $at, .Lwriteback_done
     nop
    andi    $t2, $t0, 15
    addiu   $t1, $t1, -16
    subu    $t0, $t0, $t2
.Lwriteback_line:
    cache   0x19, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Lwriteback_line
     addiu  $t0, $t0, 16
.Lwriteback_done:
    jr      $ra
     nop
.Lwriteback_all:
    lui     $t0, 0x8000
    addu    $t1, $t0, $t3
    addiu   $t1, $t1, -16
.Lwriteback_index:
    cache   1, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Lwriteback_index
     addiu  $t0, $t0, 16
    jr      $ra
     nop
.size func_80067360, . - func_80067360
.space 12, 0
