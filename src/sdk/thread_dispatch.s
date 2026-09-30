.set noreorder
.set noat
.set mips3
.set gp=64
.section .text, "ax", @progbits

/* Insert after equal-priority peers in the descending ready queue. */
.globl func_8006717C
.type func_8006717C, @function
func_8006717C:
    lw      $t8, 0($a0)
    lw      $t7, 4($a1)
    move    $t9, $a0
    lw      $t6, 4($t8)
    slt     $at, $t6, $t7
    bnez    $at, .Lqueue_insert
     nop
.Lqueue_search:
    move    $t9, $t8
    lw      $t8, 0($t8)
    lw      $t6, 4($t8)
    slt     $at, $t6, $t7
    beqz    $at, .Lqueue_search
     nop
.Lqueue_insert:
    lw      $t8, 0($t9)
    sw      $t8, 0($a1)
    sw      $a1, 0($t9)
    jr      $ra
     sw     $a0, 8($a1)
.size func_8006717C, . - func_8006717C

.globl func_800671C4
.type func_800671C4, @function
func_800671C4:
    lw      $v0, 0($a0)
    lw      $t9, 0($v0)
    jr      $ra
     sw     $t9, 0($a0)
.size func_800671C4, . - func_800671C4

/* Restore the selected thread's native 64-bit CPU and floating point context. */
.globl func_800671D4
.type func_800671D4, @function
func_800671D4:
    lui     $a0, %hi(D_8008F1A8)
    jal     func_800671C4
     addiu  $a0, $a0, %lo(D_8008F1A8)
    lui     $at, %hi(D_8008F1B0)
    sw      $v0, %lo(D_8008F1B0)($at)
    addiu   $t0, $zero, 4
    sh      $t0, 0x10($v0)
    move    $k0, $v0
    lui     $t0, %hi(D_8008E3C0)
    lw      $k1, 0x118($k0)
    addiu   $t0, $t0, %lo(D_8008E3C0)
    lw      $t0, 0($t0)
    lui     $at, 0xFFFF
    andi    $t1, $k1, 0xFF00
    ori     $at, $at, 0x00FF
    andi    $t0, $t0, 0xFF00
    and     $t1, $t1, $t0
    and     $k1, $k1, $at
    or      $k1, $k1, $t1
    mtc0    $k1, $12
    ld      $k1, 0x108($k0)
    ld      $at, 0x20($k0)
    ld      $v0, 0x28($k0)
    mtlo    $k1
    ld      $k1, 0x110($k0)
    ld      $v1, 0x30($k0)
    ld      $a0, 0x38($k0)
    ld      $a1, 0x40($k0)
    ld      $a2, 0x48($k0)
    ld      $a3, 0x50($k0)
    ld      $t0, 0x58($k0)
    ld      $t1, 0x60($k0)
    ld      $t2, 0x68($k0)
    ld      $t3, 0x70($k0)
    ld      $t4, 0x78($k0)
    ld      $t5, 0x80($k0)
    ld      $t6, 0x88($k0)
    ld      $t7, 0x90($k0)
    ld      $s0, 0x98($k0)
    ld      $s1, 0xA0($k0)
    ld      $s2, 0xA8($k0)
    ld      $s3, 0xB0($k0)
    ld      $s4, 0xB8($k0)
    ld      $s5, 0xC0($k0)
    ld      $s6, 0xC8($k0)
    ld      $s7, 0xD0($k0)
    ld      $t8, 0xD8($k0)
    ld      $t9, 0xE0($k0)
    ld      $gp, 0xE8($k0)
    mthi    $k1
    ld      $sp, 0xF0($k0)
    ld      $fp, 0xF8($k0)
    ld      $ra, 0x100($k0)
    lw      $k1, 0x11C($k0)
    mtc0    $k1, $14
    lw      $k1, 0x18($k0)
    beqz    $k1, .Lrestore_rcp
     nop
    lw      $k1, 0x12C($k0)
    ctc1    $k1, $31
    ldc1    $f0, 0x130($k0)
    ldc1    $f2, 0x138($k0)
    ldc1    $f4, 0x140($k0)
    ldc1    $f6, 0x148($k0)
    ldc1    $f8, 0x150($k0)
    ldc1    $f10, 0x158($k0)
    ldc1    $f12, 0x160($k0)
    ldc1    $f14, 0x168($k0)
    ldc1    $f16, 0x170($k0)
    ldc1    $f18, 0x178($k0)
    ldc1    $f20, 0x180($k0)
    ldc1    $f22, 0x188($k0)
    ldc1    $f24, 0x190($k0)
    ldc1    $f26, 0x198($k0)
    ldc1    $f28, 0x1A0($k0)
    ldc1    $f30, 0x1A8($k0)
.Lrestore_rcp:
    lw      $k1, 0x128($k0)
    lui     $k0, %hi(D_8008E3C0)
    addiu   $k0, $k0, %lo(D_8008E3C0)
    lw      $k0, 0($k0)
    srl     $k0, $k0, 16
    and     $k1, $k1, $k0
    sll     $k1, $k1, 1
    lui     $k0, %hi(D_80095DD0)
    addiu   $k0, $k0, %lo(D_80095DD0)
    addu    $k1, $k1, $k0
    lhu     $k1, 0($k1)
    lui     $k0, 0xA430
    addiu   $k0, $k0, 0xC
    sw      $k1, 0($k0)
    nop
    nop
    nop
    nop
    eret
.size func_800671D4, . - func_800671D4

/* A created thread returns here; destroying the running thread does not return. */
.globl func_80067350
.type func_80067350, @function
func_80067350:
    jal     func_8006E4A0
     move   $a0, $zero
.size func_80067350, . - func_80067350
