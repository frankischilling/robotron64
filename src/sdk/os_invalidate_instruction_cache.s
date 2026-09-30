.set noreorder
.set noat
.section .text, "ax", @progbits

/* Invalidate addressed 32-byte instruction lines, or the full 16 KiB cache. */
.globl func_800673E0
.type func_800673E0, @function
func_800673E0:
    blez    $a1, .Linvalidate_done
     nop
    addiu   $t3, $zero, 0x4000
    sltu    $at, $a1, $t3
    beqz    $at, .Linvalidate_all
     nop
    move    $t0, $a0
    addu    $t1, $a0, $a1
    sltu    $at, $t0, $t1
    beqz    $at, .Linvalidate_done
     nop
    andi    $t2, $t0, 31
    addiu   $t1, $t1, -32
    subu    $t0, $t0, $t2
.Linvalidate_line:
    cache   0x10, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Linvalidate_line
     addiu  $t0, $t0, 32
.Linvalidate_done:
    jr      $ra
     nop
.Linvalidate_all:
    lui     $t0, 0x8000
    addu    $t1, $t0, $t3
    addiu   $t1, $t1, -32
.Linvalidate_index:
    cache   0, 0($t0)
    sltu    $at, $t0, $t1
    bnez    $at, .Linvalidate_index
     addiu  $t0, $t0, 32
    jr      $ra
     nop
.size func_800673E0, . - func_800673E0
.space 12, 0
