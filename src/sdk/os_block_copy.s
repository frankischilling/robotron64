.set noreorder
.set noat
.section .text, "ax", @progbits

/* Native overlap-safe copy: source, destination, byte count; return destination. */
.globl func_8006B010
.type func_8006B010, @function
func_8006B010:
    beqz    $a2, .Lcopy_return
     move   $a3, $a1
    beq     $a0, $a1, .Lcopy_return
     slt    $at, $a1, $a0
    bnel    $at, $zero, .Lforward_check
     slti   $at, $a2, 16
    add     $v0, $a0, $a2
    slt     $at, $a1, $v0
    beql    $at, $zero, .Lforward_check
     slti   $at, $a2, 16
    b       .Lbackward_check
     slti   $at, $a2, 16
    slti    $at, $a2, 16
.Lforward_check:
    bnez    $at, .Lforward_bytes
     nop
    andi    $v0, $a0, 3
    andi    $v1, $a1, 3
    beq     $v0, $v1, .Lforward_align
     nop
.Lforward_bytes:
    beqz    $a2, .Lcopy_return
     nop
    addu    $v1, $a0, $a2
.Lforward_byte:
    lb      $v0, 0($a0)
    addiu   $a0, $a0, 1
    addiu   $a1, $a1, 1
    bne     $a0, $v1, .Lforward_byte
     sb     $v0, -1($a1)
.Lcopy_return:
    jr      $ra
     move   $v0, $a3
.Lforward_align:
    beqz    $v0, .Lforward_blocks
     addiu  $at, $zero, 1
    beq     $v0, $at, .Lforward_three
     addiu  $at, $zero, 2
    beql    $v0, $at, .Lforward_two
     lh     $v0, 0($a0)
    lb      $v0, 0($a0)
    addiu   $a0, $a0, 1
    addiu   $a1, $a1, 1
    addiu   $a2, $a2, -1
    b       .Lforward_blocks
     sb     $v0, -1($a1)
    lh      $v0, 0($a0)
.Lforward_two:
    addiu   $a0, $a0, 2
    addiu   $a1, $a1, 2
    addiu   $a2, $a2, -2
    b       .Lforward_blocks
     sh     $v0, -2($a1)
.Lforward_three:
    lb      $v0, 0($a0)
    lh      $v1, 1($a0)
    addiu   $a0, $a0, 3
    addiu   $a1, $a1, 3
    addiu   $a2, $a2, -3
    sb      $v0, -3($a1)
    sh      $v1, -2($a1)
.Lforward_blocks:
    slti    $at, $a2, 32
    bnel    $at, $zero, .Lforward_half_check
     slti   $at, $a2, 16
    lw      $v0, 0($a0)
    lw      $v1, 4($a0)
    lw      $t0, 8($a0)
    lw      $t1, 12($a0)
    lw      $t2, 16($a0)
    lw      $t3, 20($a0)
    lw      $t4, 24($a0)
    lw      $t5, 28($a0)
    addiu   $a0, $a0, 32
    addiu   $a1, $a1, 32
    addiu   $a2, $a2, -32
    sw      $v0, -32($a1)
    sw      $v1, -28($a1)
    sw      $t0, -24($a1)
    sw      $t1, -20($a1)
    sw      $t2, -16($a1)
    sw      $t3, -12($a1)
    sw      $t4, -8($a1)
    b       .Lforward_blocks
     sw     $t5, -4($a1)
.Lforward_halves:
    slti    $at, $a2, 16
.Lforward_half_check:
    bnel    $at, $zero, .Lforward_word_check
     slti   $at, $a2, 4
    lw      $v0, 0($a0)
    lw      $v1, 4($a0)
    lw      $t0, 8($a0)
    lw      $t1, 12($a0)
    addiu   $a0, $a0, 16
    addiu   $a1, $a1, 16
    addiu   $a2, $a2, -16
    sw      $v0, -16($a1)
    sw      $v1, -12($a1)
    sw      $t0, -8($a1)
    b       .Lforward_halves
     sw     $t1, -4($a1)
.Lforward_words:
    slti    $at, $a2, 4
.Lforward_word_check:
    bnez    $at, .Lforward_bytes
     nop
    lw      $v0, 0($a0)
    addiu   $a0, $a0, 4
    addiu   $a1, $a1, 4
    addiu   $a2, $a2, -4
    b       .Lforward_words
     sw     $v0, -4($a1)
    slti    $at, $a2, 16
.Lbackward_check:
    add     $a0, $a0, $a2
    bnez    $at, .Lbackward_bytes
     add    $a1, $a1, $a2
    andi    $v0, $a0, 3
    andi    $v1, $a1, 3
    beq     $v0, $v1, .Lbackward_align
     nop
.Lbackward_bytes:
    beqz    $a2, .Lcopy_return
     nop
    addiu   $a0, $a0, -1
    addiu   $a1, $a1, -1
    subu    $v1, $a0, $a2
.Lbackward_byte:
    lb      $v0, 0($a0)
    addiu   $a0, $a0, -1
    addiu   $a1, $a1, -1
    bne     $a0, $v1, .Lbackward_byte
     sb     $v0, 1($a1)
    jr      $ra
     move   $v0, $a3
.Lbackward_align:
    beqz    $v0, .Lbackward_blocks
     addiu  $at, $zero, 3
    beq     $v0, $at, .Lbackward_three
     addiu  $at, $zero, 2
    beql    $v0, $at, .Lbackward_two
     lh     $v0, -2($a0)
    lb      $v0, -1($a0)
    addiu   $a0, $a0, -1
    addiu   $a1, $a1, -1
    addiu   $a2, $a2, -1
    b       .Lbackward_blocks
     sb     $v0, 0($a1)
    lh      $v0, -2($a0)
.Lbackward_two:
    addiu   $a0, $a0, -2
    addiu   $a1, $a1, -2
    addiu   $a2, $a2, -2
    b       .Lbackward_blocks
     sh     $v0, 0($a1)
.Lbackward_three:
    lb      $v0, -1($a0)
    lh      $v1, -3($a0)
    addiu   $a0, $a0, -3
    addiu   $a1, $a1, -3
    addiu   $a2, $a2, -3
    sb      $v0, 2($a1)
    sh      $v1, 0($a1)
.Lbackward_blocks:
    slti    $at, $a2, 32
    bnel    $at, $zero, .Lbackward_half_check
     slti   $at, $a2, 16
    lw      $v0, -4($a0)
    lw      $v1, -8($a0)
    lw      $t0, -12($a0)
    lw      $t1, -16($a0)
    lw      $t2, -20($a0)
    lw      $t3, -24($a0)
    lw      $t4, -28($a0)
    lw      $t5, -32($a0)
    addiu   $a0, $a0, -32
    addiu   $a1, $a1, -32
    addiu   $a2, $a2, -32
    sw      $v0, 28($a1)
    sw      $v1, 24($a1)
    sw      $t0, 20($a1)
    sw      $t1, 16($a1)
    sw      $t2, 12($a1)
    sw      $t3, 8($a1)
    sw      $t4, 4($a1)
    b       .Lbackward_blocks
     sw     $t5, 0($a1)
.Lbackward_halves:
    slti    $at, $a2, 16
.Lbackward_half_check:
    bnel    $at, $zero, .Lbackward_word_check
     slti   $at, $a2, 4
    lw      $v0, -4($a0)
    lw      $v1, -8($a0)
    lw      $t0, -12($a0)
    lw      $t1, -16($a0)
    addiu   $a0, $a0, -16
    addiu   $a1, $a1, -16
    addiu   $a2, $a2, -16
    sw      $v0, 12($a1)
    sw      $v1, 8($a1)
    sw      $t0, 4($a1)
    b       .Lbackward_halves
     sw     $t1, 0($a1)
.Lbackward_words:
    slti    $at, $a2, 4
.Lbackward_word_check:
    bnez    $at, .Lbackward_bytes
     nop
    lw      $v0, -4($a0)
    addiu   $a0, $a0, -4
    addiu   $a1, $a1, -4
    addiu   $a2, $a2, -4
    b       .Lbackward_words
     sw     $v0, 0($a1)
.size func_8006B010, . - func_8006B010
.space 12, 0
