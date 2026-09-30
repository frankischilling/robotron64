.set noreorder
.section .text, "ax", @progbits

/* CP0 Status access must retain the hardware hazard delay. */
.globl func_80066980
.type func_80066980, @function
func_80066980:
    mtc0    $a0, $12
    nop
    jr      $ra
     nop
.size func_80066980, . - func_80066980

.globl func_80066990
.type func_80066990, @function
func_80066990:
    mfc0    $v0, $12
    jr      $ra
     nop
.size func_80066990, . - func_80066990

/* Alignment before the FPU control object. */
.space 4, 0
