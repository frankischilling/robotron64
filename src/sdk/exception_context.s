.set noreorder
.set noat
.set mips3
.set gp=64
.section .text, "ax", @progbits

/* Hardware registers are fixed addresses, independent of source storage. */
.equ D_A4040010, 0xA4040010 /* SP status */
.equ D_A4300000, 0xA4300000 /* MI mode */
.equ D_A4300008, 0xA4300008 /* MI interrupt status */
.equ D_A430000C, 0xA430000C /* MI interrupt mask */
.equ D_A4400010, 0xA4400010 /* VI current line */
.equ D_A450000C, 0xA450000C /* Audio-interface status */
.equ D_A4600010, 0xA4600010 /* PI status */
.equ D_A4800018, 0xA4800018 /* SI status */

/* Copied into all four exception vectors by osInitialize. */

.globl func_80066A50
.type func_80066A50, @function
func_80066A50:
    lui         $k0, %hi(func_80066A60)
    addiu       $k0, $k0, %lo(func_80066A60)
    jr          $k0
    nop
.size func_80066A50, . - func_80066A50

.globl func_80066A60
.type func_80066A60, @function
func_80066A60:
    /* Preserve scratch registers before loading the running thread. */
    lui         $k0, %hi(D_80196490)
    addiu       $k0, $k0, %lo(D_80196490)
    sd          $at, 0x20($k0)
    mfc0        $k1, $12
    sw          $k1, 0x118($k0)
    addiu       $at, $zero, -0x4
    and         $k1, $k1, $at
    mtc0        $k1, $12
    sd          $t0, 0x58($k0)
    sd          $t1, 0x60($k0)
    sd          $t2, 0x68($k0)
    sw          $zero, 0x18($k0)
    mfc0        $t0, $13
    move        $t0, $k0
    lui         $k0, %hi(D_8008F1B0)
    lw          $k0, %lo(D_8008F1B0)($k0)
    ld          $t1, 0x20($t0)
    sd          $t1, 0x20($k0)
    ld          $t1, 0x118($t0)
    sd          $t1, 0x118($k0)
    ld          $t1, 0x58($t0)
    sd          $t1, 0x58($k0)
    ld          $t1, 0x60($t0)
    sd          $t1, 0x60($k0)
    ld          $t1, 0x68($t0)
    sd          $t1, 0x68($k0)
    lw          $k1, 0x118($k0)
    mflo        $t0
    sd          $t0, 0x108($k0)
    mfhi        $t0
    andi        $t1, $k1, 0xFF00
    sd          $v0, 0x28($k0)
    sd          $v1, 0x30($k0)
    sd          $a0, 0x38($k0)
    sd          $a1, 0x40($k0)
    sd          $a2, 0x48($k0)
    sd          $a3, 0x50($k0)
    sd          $t3, 0x70($k0)
    sd          $t4, 0x78($k0)
    sd          $t5, 0x80($k0)
    sd          $t6, 0x88($k0)
    sd          $t7, 0x90($k0)
    sd          $s0, 0x98($k0)
    sd          $s1, 0xA0($k0)
    sd          $s2, 0xA8($k0)
    sd          $s3, 0xB0($k0)
    sd          $s4, 0xB8($k0)
    sd          $s5, 0xC0($k0)
    sd          $s6, 0xC8($k0)
    sd          $s7, 0xD0($k0)
    sd          $t8, 0xD8($k0)
    sd          $t9, 0xE0($k0)
    sd          $gp, 0xE8($k0)
    sd          $sp, 0xF0($k0)
    sd          $fp, 0xF8($k0)
    sd          $ra, 0x100($k0)
    beqz        $t1, .L80066B88
    sd         $t0, 0x110($k0)
    lui         $t0, %hi(D_8008E3C0)
    addiu       $t0, $t0, %lo(D_8008E3C0)
    lw          $t0, 0x0($t0)
    addiu       $at, $zero, -0x1
    xor         $t2, $t0, $at
    lui         $at, (0xFFFF00FF >> 16)
    andi        $t2, $t2, 0xFF00
    ori         $at, $at, (0xFFFF00FF & 0xFFFF)
    or          $t4, $t1, $t2
    and         $t3, $k1, $at
    andi        $t0, $t0, 0xFF00
    or          $t3, $t3, $t4
    and         $t1, $t1, $t0
    and         $k1, $k1, $at
    sw          $t3, 0x118($k0)
    or          $k1, $k1, $t1
.L80066B88:
    lui         $t1, %hi(D_A430000C)
    lw          $t1, %lo(D_A430000C)($t1)
    beqz        $t1, .L80066BC0
    nop
    lui         $t0, %hi(D_8008E3C0)
    addiu       $t0, $t0, %lo(D_8008E3C0)
    lw          $t0, 0x0($t0)
    lw          $t4, 0x128($k0)
    addiu       $at, $zero, -0x1
    srl         $t0, $t0, 16
    xor         $t0, $t0, $at
    andi        $t0, $t0, 0x3F
    and         $t0, $t0, $t4
    or          $t1, $t1, $t0
.L80066BC0:
    /* Save EPC and the floating point context only when the thread uses it. */
    sw          $t1, 0x128($k0)
    mfc0        $t0, $14
    sw          $t0, 0x11C($k0)
    lw          $t0, 0x18($k0)
    beqz        $t0, .L80066C24
    nop
    cfc1        $t0, $31
    nop
    sw          $t0, 0x12C($k0)
    sdc1        $f0, 0x130($k0)
    sdc1        $f2, 0x138($k0)
    sdc1        $f4, 0x140($k0)
    sdc1        $f6, 0x148($k0)
    sdc1        $f8, 0x150($k0)
    sdc1        $f10, 0x158($k0)
    sdc1        $f12, 0x160($k0)
    sdc1        $f14, 0x168($k0)
    sdc1        $f16, 0x170($k0)
    sdc1        $f18, 0x178($k0)
    sdc1        $f20, 0x180($k0)
    sdc1        $f22, 0x188($k0)
    sdc1        $f24, 0x190($k0)
    sdc1        $f26, 0x198($k0)
    sdc1        $f28, 0x1A0($k0)
    sdc1        $f30, 0x1A8($k0)
.L80066C24:
    /* Classify break, coprocessor-unusable, other faults and interrupts. */
    mfc0        $t0, $13
    sw          $t0, 0x120($k0)
    addiu       $t1, $zero, 0x2
    sh          $t1, 0x10($k0)
    andi        $t1, $t0, 0x7C
    addiu       $t2, $zero, 0x24
    beq         $t1, $t2, .L80066F00
    nop
    addiu       $t2, $zero, 0x2C
    beq         $t1, $t2, .L80067048
    nop
    addiu       $t2, $zero, 0x0
    bne         $t1, $t2, .L80066F64
    nop
    and         $s0, $k1, $t0
.L80066C60:
    /* Dispatch the highest pending CPU interrupt through the offset tables. */
    andi        $t1, $s0, 0xFF00
    srl         $t2, $t1, 12
    bnez        $t2, .L80066C78
    nop
    srl         $t2, $t1, 8
    addi        $t2, $t2, 0x10
.L80066C78:
    lui         $at, %hi(D_80095E60)
    addu        $at, $at, $t2
    lbu         $t2, %lo(D_80095E60)($at)
    lui         $at, %hi(D_80095E80)
    addu        $at, $at, $t2
    lw          $t2, %lo(D_80095E80)($at)
    jr          $t2
    nop
    .globl D_80066C98
D_80066C98:
    addiu       $at, $zero, -0x2001
    b           .L80066C60
    and        $s0, $s0, $at
    .globl D_80066CA4
D_80066CA4:
    addiu       $at, $zero, -0x4001
    b           .L80066C60
    and        $s0, $s0, $at
    .globl D_80066CB0
D_80066CB0:
    mfc0        $t1, $11
    mtc0        $t1, $11
    jal         func_80066F94
    addiu      $a0, $zero, 0x18
    lui         $at, (0xFFFF7FFF >> 16)
    ori         $at, $at, (0xFFFF7FFF & 0xFFFF)
    b           .L80066C60
    and        $s0, $s0, $at
    .globl D_80066CD0
D_80066CD0:
    addiu       $at, $zero, -0x801
    and         $s0, $s0, $at
    addiu       $t2, $zero, 0x4
    lui         $at, %hi(D_8008F180)
    addu        $at, $at, $t2
    lw          $t2, %lo(D_8008F180)($at)
    lui         $sp, %hi(D_80196640)
    addiu       $sp, $sp, %lo(D_80196640)
    addiu       $a0, $zero, 0x10
    beqz        $t2, .L80066D14
    addiu      $sp, $sp, 0xFF0
    jalr        $t2
    nop
    beqz        $v0, .L80066D14
    addiu      $a0, $zero, 0x10
    b           .L80066F18
    nop
.L80066D14:
    jal         func_80066F94
    nop
    b           .L80066C60
    nop
    /* RCP interrupts: signal processor, video, audio, serial, PI and display. */
    .globl D_80066D24
D_80066D24:
    lui         $t0, %hi(D_8008E3C0)
    addiu       $t0, $t0, %lo(D_8008E3C0)
    lw          $t0, 0x0($t0)
    lui         $s1, %hi(D_A4300008)
    lw          $s1, %lo(D_A4300008)($s1)
    srl         $t0, $t0, 16
    and         $s1, $s1, $t0
    andi        $t1, $s1, 0x1
    beqz        $t1, .L80066D94
    nop
    lui         $t4, %hi(D_A4040010)
    lw          $t4, %lo(D_A4040010)($t4)
    addiu       $t1, $zero, 0x8
    lui         $at, %hi(D_A4040010)
    andi        $t4, $t4, 0x300
    andi        $s1, $s1, 0x3E
    beqz        $t4, .L80066D84
    sw         $t1, %lo(D_A4040010)($at)
    jal         func_80066F94
    addiu      $a0, $zero, 0x20
    beqz        $s1, .L80066E58
    nop
    b           .L80066D94
    nop
.L80066D84:
    jal         func_80066F94
    addiu      $a0, $zero, 0x58
    beqz        $s1, .L80066E58
    nop
.L80066D94:
    andi        $t1, $s1, 0x8
    beqz        $t1, .L80066DB8
    lui        $at, %hi(D_A4400010)
    andi        $s1, $s1, 0x37
    sw          $zero, %lo(D_A4400010)($at)
    jal         func_80066F94
    addiu      $a0, $zero, 0x38
    beqz        $s1, .L80066E58
    nop
.L80066DB8:
    andi        $t1, $s1, 0x4
    beqz        $t1, .L80066DE4
    nop
    addiu       $t1, $zero, 0x1
    lui         $at, %hi(D_A450000C)
    andi        $s1, $s1, 0x3B
    sw          $t1, %lo(D_A450000C)($at)
    jal         func_80066F94
    addiu      $a0, $zero, 0x30
    beqz        $s1, .L80066E58
    nop
.L80066DE4:
    andi        $t1, $s1, 0x2
    beqz        $t1, .L80066E08
    lui        $at, %hi(D_A4800018)
    andi        $s1, $s1, 0x3D
    sw          $zero, %lo(D_A4800018)($at)
    jal         func_80066F94
    addiu      $a0, $zero, 0x28
    beqz        $s1, .L80066E58
    nop
.L80066E08:
    andi        $t1, $s1, 0x10
    beqz        $t1, .L80066E34
    nop
    addiu       $t1, $zero, 0x2
    lui         $at, %hi(D_A4600010)
    andi        $s1, $s1, 0x2F
    sw          $t1, %lo(D_A4600010)($at)
    jal         func_80066F94
    addiu      $a0, $zero, 0x40
    beqz        $s1, .L80066E58
    nop
.L80066E34:
    andi        $t1, $s1, 0x20
    beqz        $t1, .L80066E58
    nop
    addiu       $t1, $zero, 0x800
    lui         $at, %hi(D_A4300000)
    andi        $s1, $s1, 0x1F
    sw          $t1, %lo(D_A4300000)($at)
    jal         func_80066F94
    addiu      $a0, $zero, 0x48
.L80066E58:
    addiu       $at, $zero, -0x401
    b           .L80066C60
    and        $s0, $s0, $at
    .globl D_80066E64
D_80066E64:
    lw          $k1, 0x118($k0)
    addiu       $at, $zero, -0x1001
    lui         $t1, %hi(D_8008E3BC)
    and         $k1, $k1, $at
    sw          $k1, 0x118($k0)
    addiu       $t1, $t1, %lo(D_8008E3BC)
    lw          $t2, 0x0($t1)
    beqz        $t2, .L80066E90
    addiu      $at, $zero, -0x1001
    b           .L80066F18
    and        $s0, $s0, $at
.L80066E90:
    addiu       $t2, $zero, 0x1
    sw          $t2, 0x0($t1)
    jal         func_80066F94
    addiu      $a0, $zero, 0x70
    lui         $t2, %hi(D_8008F1A8)
    lw          $t2, %lo(D_8008F1A8)($t2)
    addiu       $at, $zero, -0x1001
    and         $s0, $s0, $at
    lw          $k1, 0x118($t2)
    and         $k1, $k1, $at
    b           .L80066F18
    sw         $k1, 0x118($t2)
    .globl D_80066EC0
D_80066EC0:
    addiu       $at, $zero, -0x201
    and         $t0, $t0, $at
    mtc0        $t0, $13
    jal         func_80066F94
    addiu      $a0, $zero, 0x8
    addiu       $at, $zero, -0x201
    b           .L80066C60
    and        $s0, $s0, $at
    .globl D_80066EE0
D_80066EE0:
    addiu       $at, $zero, -0x101
    and         $t0, $t0, $at
    mtc0        $t0, $13
    jal         func_80066F94
    addiu      $a0, $zero, 0x0
    addiu       $at, $zero, -0x101
    b           .L80066C60
    and        $s0, $s0, $at
.L80066F00:
    addiu       $t1, $zero, 0x1
    sh          $t1, 0x12($k0)
    jal         func_80066F94
    addiu      $a0, $zero, 0x50
    b           .L80066F18
    nop
.L80066F18:
    .globl D_80066F18
D_80066F18:
    /* Resume the current thread or enqueue it behind a higher-priority peer. */
    lui         $t2, %hi(D_8008F1A8)
    lw          $t2, %lo(D_8008F1A8)($t2)
    lw          $t1, 0x4($k0)
    lw          $t3, 0x4($t2)
    slt         $at, $t1, $t3
    beqz        $at, .L80066F4C
    nop
    lui         $a0, %hi(D_8008F1A8)
    move        $a1, $k0
    jal         func_8006717C
    addiu      $a0, $a0, %lo(D_8008F1A8)
    j           func_800671D4
    nop
.L80066F4C:
    lui         $t1, %hi(D_8008F1A8)
    addiu       $t1, $t1, %lo(D_8008F1A8)
    lw          $t2, 0x0($t1)
    sw          $t2, 0x0($k0)
    j           func_800671D4
    sw         $k0, 0x0($t1)
.L80066F64:
    /* Record a stopped, faulted thread and notify its event queue. */
    lui         $at, %hi(D_8008F1B4)
    sw          $k0, %lo(D_8008F1B4)($at)
    addiu       $t1, $zero, 0x1
    sh          $t1, 0x10($k0)
    addiu       $t1, $zero, 0x2
    sh          $t1, 0x12($k0)
    mfc0        $t2, $8
    sw          $t2, 0x124($k0)
    jal         func_80066F94
    addiu      $a0, $zero, 0x60
    j           func_800671D4
    nop
.size func_80066A60, . - func_80066A60

.globl func_80066F94
.type func_80066F94, @function
func_80066F94:
    /* Nonblocking event delivery; wake a waiting thread when one exists. */
    lui         $t2, %hi(D_80195030)
    addiu       $t2, $t2, %lo(D_80195030)
    addu        $t2, $t2, $a0
    lw          $t1, 0x0($t2)
    move        $s2, $ra
    beqz        $t1, .L80067040
    nop
    lw          $t3, 0x8($t1)
    lw          $t4, 0x10($t1)
    slt         $at, $t3, $t4
    beqz        $at, .L80067040
    nop
    lw          $t5, 0xC($t1)
    addu        $t5, $t5, $t3
    div         $zero, $t5, $t4
    bnez        $t4, .L80066FDC
    nop
    break       7
.L80066FDC:
    addiu       $at, $zero, -0x1
    bne         $t4, $at, .L80066FF4
    lui        $at, (0x80000000 >> 16)
    bne         $t5, $at, .L80066FF4
    nop
    break       6
.L80066FF4:
    lw          $t4, 0x14($t1)
    mfhi        $t5
    sll         $t5, $t5, 2
    addu        $t4, $t4, $t5
    lw          $t5, 0x4($t2)
    addiu       $t2, $t3, 0x1
    sw          $t5, 0x0($t4)
    sw          $t2, 0x8($t1)
    lw          $t2, 0x0($t1)
    lw          $t3, 0x0($t2)
    beqz        $t3, .L80067040
    nop
    jal         func_800671C4
    move       $a0, $t1
    move        $t2, $v0
    lui         $a0, %hi(D_8008F1A8)
    move        $a1, $t2
    jal         func_8006717C
    addiu      $a0, $a0, %lo(D_8008F1A8)
.L80067040:
    jr          $s2
    nop
.L80067048:
.size func_80066F94, . - func_80066F94

.globl func_80067048
.type func_80067048, @function
func_80067048:
    /* Enable CP1 lazily; other unusable coprocessors take the fault path. */
    lui         $at, (0x30000000 >> 16)
    and         $t1, $t0, $at
    srl         $t1, $t1, 28
    addiu       $t2, $zero, 0x1
    bne         $t1, $t2, .L80066F64
    nop
    lw          $k1, 0x118($k0)
    lui         $at, (0x20000000 >> 16)
    addiu       $t1, $zero, 0x1
    or          $k1, $k1, $at
    sw          $t1, 0x18($k0)
    b           .L80066F4C
    sw         $k1, 0x118($k0)
.size func_80067048, . - func_80067048

.set noreorder
.set noat
.set mips3
.set gp=64
.section .text, "ax", @progbits

/* Save the running thread's preserved registers and resume through dispatch. */
.globl func_8006707C
.type func_8006707C, @function
func_8006707C:
    lui     $a1, %hi(D_8008F1B0)
    lw      $a1, %lo(D_8008F1B0)($a1)
    mfc0    $t0, $12
    lw      $k1, 0x18($a1)
    ori     $t0, $t0, 2
    sw      $t0, 0x118($a1)
    sd      $s0, 0x98($a1)
    sd      $s1, 0xA0($a1)
    sd      $s2, 0xA8($a1)
    sd      $s3, 0xB0($a1)
    sd      $s4, 0xB8($a1)
    sd      $s5, 0xC0($a1)
    sd      $s6, 0xC8($a1)
    sd      $s7, 0xD0($a1)
    sd      $gp, 0xE8($a1)
    sd      $sp, 0xF0($a1)
    sd      $fp, 0xF8($a1)
    sd      $ra, 0x100($a1)
    beqz    $k1, .Lthread_enqueue_and_yield_yield_cpu_mask
     sw     $ra, 0x11C($a1)
    cfc1    $k1, $31
    sdc1    $f20, 0x180($a1)
    sdc1    $f22, 0x188($a1)
    sdc1    $f24, 0x190($a1)
    sdc1    $f26, 0x198($a1)
    sdc1    $f28, 0x1A0($a1)
    sdc1    $f30, 0x1A8($a1)
    sw      $k1, 0x12C($a1)
.Lthread_enqueue_and_yield_yield_cpu_mask:
    lw      $k1, 0x118($a1)
    andi    $t1, $k1, 0xFF00
    beqz    $t1, .Lthread_enqueue_and_yield_yield_rcp_mask
     nop
    lui     $t0, %hi(D_8008E3C0)
    addiu   $t0, $t0, %lo(D_8008E3C0)
    lw      $t0, 0($t0)
    addiu   $at, $zero, -1
    xor     $t0, $t0, $at
    lui     $at, 0xFFFF
    andi    $t0, $t0, 0xFF00
    ori     $at, $at, 0x00FF
    or      $t1, $t1, $t0
    and     $k1, $k1, $at
    or      $k1, $k1, $t1
    sw      $k1, 0x118($a1)
.Lthread_enqueue_and_yield_yield_rcp_mask:
    lui     $k1, 0xA430
    lw      $k1, 12($k1)
    beqz    $k1, .Lthread_enqueue_and_yield_yield_enqueue
     nop
    lui     $k0, %hi(D_8008E3C0)
    addiu   $k0, $k0, %lo(D_8008E3C0)
    lw      $k0, 0($k0)
    lw      $t0, 0x128($a1)
    addiu   $at, $zero, -1
    srl     $k0, $k0, 16
    xor     $k0, $k0, $at
    andi    $k0, $k0, 0x3F
    and     $k0, $k0, $t0
    or      $k1, $k1, $k0
.Lthread_enqueue_and_yield_yield_enqueue:
    beqz    $a0, .Lthread_enqueue_and_yield_yield_dispatch
     sw     $k1, 0x128($a1)
    jal     func_8006717C
     nop
.Lthread_enqueue_and_yield_yield_dispatch:
    j       func_800671D4
     nop
.size func_8006707C, . - func_8006707C

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
    bnez    $at, .Lthread_dispatch_queue_insert
     nop
.Lthread_dispatch_queue_search:
    move    $t9, $t8
    lw      $t8, 0($t8)
    lw      $t6, 4($t8)
    slt     $at, $t6, $t7
    beqz    $at, .Lthread_dispatch_queue_search
     nop
.Lthread_dispatch_queue_insert:
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
    beqz    $k1, .Lthread_dispatch_restore_rcp
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
.Lthread_dispatch_restore_rcp:
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
