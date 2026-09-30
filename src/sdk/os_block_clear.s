.set noreorder
.set noat
.section .text, "ax", @progbits

/* Native SDK zero fill: align, clear 32-byte blocks, words, then bytes. */
.globl func_800674C0
.type func_800674C0, @function
func_800674C0:
    slti    $at, $a1, 12
    bnez    $at, .Lclear_bytes
     negu   $v1, $a0
    andi    $v1, $v1, 3
    beqz    $v1, .Lclear_blocks
     subu   $a1, $a1, $v1
    swl     $zero, 0($a0)
    addu    $a0, $a0, $v1
.Lclear_blocks:
    addiu   $at, $zero, -32
    and     $a3, $a1, $at
    beqz    $a3, .Lclear_words
     subu   $a1, $a1, $a3
    addu    $a3, $a3, $a0
.Lclear_block:
    addiu   $a0, $a0, 32
    sw      $zero, -32($a0)
    sw      $zero, -28($a0)
    sw      $zero, -24($a0)
    sw      $zero, -20($a0)
    sw      $zero, -16($a0)
    sw      $zero, -12($a0)
    sw      $zero, -8($a0)
    bne     $a0, $a3, .Lclear_block
     sw     $zero, -4($a0)
.Lclear_words:
    addiu   $at, $zero, -4
    and     $a3, $a1, $at
    beqz    $a3, .Lclear_bytes
     subu   $a1, $a1, $a3
    addu    $a3, $a3, $a0
.Lclear_word:
    addiu   $a0, $a0, 4
    bne     $a0, $a3, .Lclear_word
     sw     $zero, -4($a0)
.Lclear_bytes:
    blez    $a1, .Lclear_done
     nop
    addu    $a1, $a1, $a0
.Lclear_byte:
    addiu   $a0, $a0, 1
    bne     $a0, $a1, .Lclear_byte
     sb     $zero, -1($a0)
.Lclear_done:
    jr      $ra
     nop
.size func_800674C0, . - func_800674C0
.space 4, 0
