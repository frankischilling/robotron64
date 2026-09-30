.set noreorder
.section .text, "ax", @progbits

.globl osGetCount
.type osGetCount, @function
osGetCount:
    mfc0    $v0, $9
    jr      $ra
     nop
.size osGetCount, . - osGetCount

/* Alignment before the following SDK object. */
.space 4, 0
