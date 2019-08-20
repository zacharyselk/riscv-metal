.global PWMWave
.data

# Memory mapped PWM regions (ording in .data matters! Do not change)
PWM0:			.word 0x10015000
PWM1:			.word 0x10025000
PWM2:			.word 0x10035000

# Offsets for PWM region
PWM_CFG:		.word 0x00
PWM_COUNT:		.word 0x08
PWMS:			.word 0x10
PWM_CMP0:		.word 0x20
PWM_CMP1:		.word 0x24
PWM_CMP2:		.word 0x28
PWM_CMP3:		.word 0x2C

.text

#------------------------------------------------------------------------------
# PWMWave
# Args:
#   a0 - pin
#   a1 - dutyCycle
#
# Produces a PWM wave on the given pin with the desired duty cycle
#------------------------------------------------------------------------------
PWMWave:
addi sp, sp, -8		#adding variables to the stack
sw ra, 0(sp)
sw s0, 4(sp)

add	s0, a1, zero	#storing dutyCycle
jal pinToPWM

lw t0, 0(a0)		#loading PWMconfig from pin PWM instance
addi t1, zero, 1
slli t1, t1, 12
or t0, t0, t1		#enable pwmenalways

addi t1, zero, 17
slli t1, t1, 9
not t1, t1
and t0, t1, t0		#disable pwmoneshot and pwmzerocmp

slli t0, t0, 8		#disable pwmcmpXgang and pwmcompXip
srli t0, t0, 8

sw t0, 0(a0)


addi t0, zero, 1
slli t0, t0, 16
addi t1, zero, 100
div t0, t0, t1
mul t0, t0, s0		#nomalize [0..100] to the range [0..2^16]
sw t0, 0(a1)

lw ra, 0(sp)		#unstacking variables
lw s0, 4(sp)
addi sp, sp, 8
ret


#------------------------------------------------------------------------------
# pinToPWM
# Args:
#   a0 - pin
#
# returns the pwm instance and comparator related to the pinNum
#
# returns:
#	a0 - address of pwminstance
#	a1 - address of pwmcmp
#------------------------------------------------------------------------------
pinToPWM:
addi t0, zero, 4				#if pin < 4, then instance 0
blt a0, t0, pinToPWMGroup0

addi t0, zero, 10				#if 4 <= pin < 10, then invalid
blt a0, t0, pinToPWMInvalid

addi t0, zero, 14				#if 10<= pin < 14, then instance 2
blt a0, t0, pinToPWMGroup2

addi t0, zero, 19				#if 14 <= pin < 19, then invalid
blt a0, t0, pinToPWMInvalid

addi t0, zero, 23				#if 19<= pin < 23, then instance 1
blt a0, t0, pinToPWMGroup1

j pinToPWMInvalid				#else, invalid

pinToPWMGroup0:
add a1, zero, a0				#pwmcmp == pinNum
la t0, PWM0
lw a0, 0(t0)
j pinToPWMAddOffset

pinToPWMGroup1:
addi a1, a0, -10				#pwmcmp == pinNum - 10
la t0, PWM1
lw a0, 0(t0)
j pinToPWMAddOffset

pinToPWMGroup2:
addi a1, a0, -19				#pwmcmp == pinNum - 19
la a0, PWM1
lw a0, 0(a0)
add t0, zero, 1
bge t0, a1, pinToPWMAddOffset

sub a1, t0, a1

j pinToPWMAddOffset

pinToPWMInvalid:
addi a0, zero, -1
j pinToPWMEnd

pinToPWMAddOffset:
slli a1, a1, 2					#add offset to pwmcmp
addi a1, a1, 0x20
add a1, a1, a0
j pinToPWMEnd

pinToPWMEnd:
ret 							#return
