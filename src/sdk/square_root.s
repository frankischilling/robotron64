.set noreorder
.section .text, "ax", @progbits

.globl func_80063220
.type func_80063220, @function
func_80063220:
    jr      $ra
     sqrt.s $f0, $f12
.size func_80063220, . - func_80063220
.space 8, 0
