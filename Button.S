.global button

.data
PIN_OUTPUT_ENABLE:		.word 0x10012008
PIN_OUTPUT_VALUE: 	    .word 0x1001200c
.text

button:

la t0, PIN_OUTPUT_ENABLE
lw t0, 0(t0)
lw t1, 0(t0)
addi t2, zero, 1
slli t2, t2, 16
or t3, t2, t1
sw t3, 0(t0)

la t4, PIN_OUTPUT_VALUE
lw t4, 0(t4)
lw t5, 0(t4)
addi t6, zero, 1
or t6, t2, t5
sw t6, 0(t4)

jalr zero, ra, 0
