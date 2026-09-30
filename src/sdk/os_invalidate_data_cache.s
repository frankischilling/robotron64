.set noreorder
.set noat
.section .text, "ax", @progbits

/* Write back partially covered edge lines, invalidate whole interior lines. */
.globl func_80065790
.type func_80065790, @function
func_80065790:
    blez    $a1, .Ldata_done
     nop
    addiu   $t3, $zero, 0x2000
    sltu    $at, $a1, $t3
    beqz    $at, .Ldata_all
     nop
    move    $t0, $a0
    addu    $t1, $a0, $a1
    sltu    $at, $t0, $t1
    beqz    $at, .Ldata_done
     nop
    andi    $t2, $t0, 15
    beqz    $t2, .Ldata_end
     addiu  $t1, $t1, -16
    subu    $t0, $t0, $t2
    cache   0x15, 0($t0)
    sltu    $at, $t0, $t1
    beqz    $at, .Ldata_done
     nop
    addiu   $t0, $t0, 16
.Ldata_end:
    andi    $t2, $t1, 15
    beqz    $t2, .Ldata_line
     nop
    subu    $t1, $t1, $t2
    cache   0x15, 16($t1)
    sltu    $at, $t1, $t0
    bnez    $at, .Ldata_done
     nop
.Ldata_line:
    cache   0x11, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Ldata_line
     addiu  $t0, $t0, 16
.Ldata_done:
    jr      $ra
     nop
.Ldata_all:
    lui     $t0, 0x8000
    addu    $t1, $t0, $t3
    addiu   $t1, $t1, -16
.Ldata_index:
    cache   1, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Ldata_index
     addiu  $t0, $t0, 16
    jr      $ra
     nop
.size func_80065790, . - func_80065790
.space 4, 0
