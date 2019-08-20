.global main
.text

main:
addi sp, sp, -4
sw ra, 0(sp)

addi t0, zero, 1
slli t0, t0, 25
li t1, 0x0C002000
sw t0, 0(t1)

li t0, 0x0C200004
addi t1, zero, 4
lw t2, 0(t0)
sw t2, 0(t0)
lw t3, 0(t0)

addi a0, zero, 16
addi a1, zero, 0
jal setPinMode

addi a0, zero, 17
addi a1, zero, 1
jal setPinMode

la t0, Handler
csrw mtvec, t0
li t0, 0x888
csrw mie, t0
# !
li t0, 0x8
csrw mstatus, t0
# X
addi t0, zero, 1
slli t0, t0, 25
li t1, 0x0C002000
sw t0, 0(t1)
li t0, 25
slli t0, t0, 2
li	t1, 0x0C000000
add t0, t0, t1
addi t1, zero, 1
sw t1, 0(t0)
li t0, 0x0C200000
sw	zero, 0(t0)

addi a0, zero, 1
addi a1, zero, 0
jal GPIOEnableInterrupt

li t0, 0x0C001000
lw t1, 0(t0)

#addi a0, zero, 16
#addi a1, zero, 1
#jal setPinValue
nop
nop
nop
nop

li t0, 0x0C001000
lw t1, 0(t0)

main_loop:
nop
j main_loop

lw ra, 0(sp)
addi sp, sp, 4
ret

Handler:
addi sp, sp, -112
sw ra, 0(sp)
sw a0, 4(sp)
sw a1, 8(sp)
sw a2, 12(sp)
sw a3, 16(sp)
sw a4, 20(sp)
sw a5, 24(sp)
sw a6, 28(sp)
sw a7, 32(sp)
sw t0, 36(sp)
sw t1, 40(sp)
sw t2, 44(sp)
sw t3, 48(sp)
sw t4, 52(sp)
sw t5, 56(sp)
sw t6, 60(sp)
sw s0, 64(sp)
sw s1, 68(sp)
sw s2, 72(sp)
sw s3, 76(sp)
sw s4, 80(sp)
sw s5, 84(sp)
sw s6, 88(sp)
sw s7, 92(sp)
sw s8, 96(sp)
sw s9, 100(sp)
sw s10, 104(sp)
sw s11, 108(sp)

csrr t0, mcause
li t1, 0x0C001000
lw t1, 0(t1)

addi a0, zero, 18
addi a1, zero, 0
jal setPinMode

addi a0, zero, 18
addi a1, zero, 1
jal setPinValue

lw ra, 0(sp)
lw a0, 4(sp)
lw a1, 8(sp)
lw a2, 12(sp)
lw a3, 16(sp)
lw a4, 20(sp)
lw a5, 24(sp)
lw a6, 28(sp)
lw a7, 32(sp)
lw t0, 36(sp)
lw t1, 40(sp)
lw t2, 44(sp)
lw t3, 48(sp)
lw t4, 52(sp)
lw t5, 56(sp)
lw t6, 60(sp)
lw s0, 64(sp)
lw s1, 68(sp)
lw s2, 72(sp)
lw s3, 76(sp)
lw s4, 80(sp)
lw s5, 84(sp)
lw s6, 88(sp)
lw s7, 92(sp)
lw s8, 96(sp)
lw s9, 100(sp)
lw s10, 104(sp)
lw s11, 108(sp)
addi sp, sp, 112

mret
