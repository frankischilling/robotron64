.set noreorder
.section .text, "ax", @progbits

.globl __osSetCompare
.type __osSetCompare, @function
__osSetCompare:
    mtc0    $a0, $11
    jr      $ra
     nop
.size __osSetCompare, . - __osSetCompare

/* Alignment before the following SDK object. */
.space 4, 0
