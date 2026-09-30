.set noreorder
.section .text, "ax", @progbits

/* Return the old floating-point control/status value before installing a0. */
.globl func_800669A0
.type func_800669A0, @function
func_800669A0:
    cfc1    $v0, $31
    ctc1    $a0, $31
    jr      $ra
     nop
.size func_800669A0, . - func_800669A0
