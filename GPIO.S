.global setPinMode
.global getPinMode
.global setPinValue
.global setHWIOF
.global togglePinValue
.global pinToGPIO
.global GPIOEnableInterrupt

.data

PIN_INPUT_VALUE:					.word 0x10012000
PIN_INPUT_ENABLE:					.word 0x10012004
PIN_OUTPUT_ENABLE:					.word 0x10012008
PIN_OUTPUT_VALUE:					.word 0x1001200C
PIN_PULLUP_ENABLE:					.word 0x10012010
PIN_DRIVE_STRENGTH:					.word 0x10012014
POSITIVE_EDGE_INTERRUPT_ENABLE:		.word 0x10012018
POSITIVE_EDGE_INTERRUPT_PENDING:	.word 0x1001201C
NEGATIVE_EDGE_INTERRUPT_ENABLE:		.word 0x10012020
NEGATIVE_EDGE_INTERRUPT_PENDING:	.word 0x10012024
HIGH_INTERRUPT_ENABLE:				.word 0x10012028
HIGH_INTERRUPT_PENDING:				.word 0x1001202C
LOW_INTERRUPT_ENABLE:				.word 0x10012030
LOW_INTERRUPT_PENDING:				.word 0x10012034
HW_IO_FUNCTION_ENABLE:				.word 0x10012038
HW_IO_FUNCTION_SELECT:				.word 0x1001203C
PIN_INVERT_OUTPUT:					.word 0x10012040

.text
#------------------------------------------------------------------------------
# setPinMode
# Args:
#   a0 - The GPIO pin to set
#   a1 - The mode to set; 0 for output; 1 for input, -1 to disable the pin
#
# Sets whether a pin is configured to output mode, input mode, or disabled
#------------------------------------------------------------------------------
setPinMode:
	addi	t0, zero, 1
	sll		t0, t0, a0		# t0 <- pinMask
	not		t1, t0			# t1 <- ~pinMask
	la		t2, PIN_INPUT_ENABLE
	la		t3, PIN_OUTPUT_ENABLE
	lw		t2, 0(t2)		# t2 <- &pinInputEnable
	lw		t3, 0(t3)		# t3 <- &pinOutputEnable
	lw		t4, 0(t2)		# t4 <- pinInputEnable
	lw		t5, 0(t3)		# t5 <- pinOutputEnable

	# Select wich mode to set
	beq		a1, zero, setPinModeOut		# if(a1 == 0) Output
	bge		a1, zero, setPinModeIn		# elif(a1 > 0) Input
	j		setPinModeDisable			# else Disable

	setPinModeOut:
	and		t6, t4, t1		# t6 = pinInputEnable & ~pinMask
	sw		t6, 0(t2)		# &pinInputEnable &= ~pinMask
	or		t6, t5, t0		# t6 = pinOutputEnable | pinMask
	sw		t6, 0(t3)		# &pinOutputEnable |= pinMask
	j		setPinModeEnd

	setPinModeIn:
	and		t6, t5, t1		# t6 = pinOutputEnable & ~pinMask
	sw		t6, 0(t3)		# &pinOutputEnable &= ~pinMask
	or		t6, t4, t0		# t6 = pinInputEnable | pinMask
	sw		t6, 0(t2)		# &pinInputEnable |= pinMask
	j		setPinModeEnd

	setPinModeDisable:
	or		t6, t4, t1		# t6 = pinInputEnable & ~pinMask
	sw		t6, 0(t2)		# &pinInputEnable &= ~pinMask
	or		t6, t5, t1		# t6 = pinOutputEnable & ~pinMask
	sw		t6, 0(t3)		# &pinOutputEnable &= ~pinMask
	j		setPinModeEnd

	setPinModeEnd:
	ret


#------------------------------------------------------------------------------
# getPinMode
# Args:
#   a0 - The GPIO pin
# Returns:
#   a0 - The mode; 0 if output, 1 if input, -1 if disabled
#
# Returns what mode the given pin is in
#------------------------------------------------------------------------------
getPinMode:
	addi	t0, zero, 1
	sll		t0, t0, a0		# t0 <- pinMask
	la		t1, PIN_INPUT_ENABLE
	la		t2, PIN_OUTPUT_ENABLE
	lw		t1, 0(t1)		# t1 <- &pinInputEnable
	lw		t2, 0(t2)		# t2 <- &pinOutputEnable
	lw		t1, 0(t1)		# t1 <- pinInputEnable
	lw		t2, 0(t2)		# t2 <- pinOutputEnable

	and		t3, t1, t0		# t3 = pinInputEnable & pinMask
	and		t4, t2, t0		# t4 = pinOutputEnable & pinMask
	bne		t3, zero, getPinModeIn	# if(pinInputEnable & pinMask != 0) In
	bne		t4, zero, getPinModeOut # elif(pinOutputEnable & pinMask != 0) Out
	j		getPinModeDisabled		# else Disabled

	getPinModeIn:
	addi	a0, zero, 1		# Mode = 1
	j		getPinModeEnd

	getPinModeOut:
	addi	a0, zero, 0		# Mode = 0
	j		getPinModeEnd

	getPinModeDisabled:
	addi	a0, zero, -1	# Mode = -1
	j		getPinModeEnd

	getPinModeEnd:
	ret

#------------------------------------------------------------------------------
# setGPIO
# Args:
#   a0 - The GPIO Pin to set
#   a1 - The value to set
#
# Sets one of the GPIO pins to either LOW (zero) or HIGH (any non-zero value)
#------------------------------------------------------------------------------
setPinValue:
	addi	t0, zero, 1
	sll		t0, t0, a0		# t0 <- pinMask
	not		t1, t0			# t1 <- ~pinMask
	la		t2, PIN_OUTPUT_VALUE
	lw		t2, 0(t2)		# t2 <- &pinOutputValue
	lw		t3, 0(t2)		# t3 <- pinOutputValue

	# Set either high or low
	beq		a0, zero, setPinValueLow
	j		setPinValueHigh

	setPinValueLow:
	and		t4, t3, t1		# t4 <- pinOutputValue & ~pinMask
	sw		t4, 0(t2)		# &pinOutputValue &= ~pinMask
	j		setPinValueEnd

	setPinValueHigh:
	or		t4, t3, t0		# t4 <- pinOutputValue | pinMask
	sw		t4, 0(t2)		# &pinOutputValue |= pinMask
	j		setPinValueEnd

	setPinValueEnd:
	ret


#------------------------------------------------------------------------------
# setHWIOF
# Args:
#   a0 - The GPIO pin selected
#   a1 - 1 to enable IO functions or 0 to disable
#   a2 - Which IO function to select; 0 for IOF0, 1 for IOF1, and -1 to disable
#        IO functions
#
# Sets one of the IO functions accosiated with a GPIO pin or disables IO
# functions on that pin
#------------------------------------------------------------------------------
setHWIOF:
	la		t0, HW_IO_FUNCTION_ENABLE
	la		t1, HW_IO_FUNCTION_SELECT
	lw		t0, 0(t0)		# t0 <- &HWIOF_en
	lw		t1, 0(t1)		# t1 <- &HWIOF_sel
	addi	t2, zero, 1		# t2 = 1
	sll	t2, t2, a0		# t2 <- pinMask = 1 << pinNumber
	lw		t3, 0(t0)		# t3 <- HWIOF_en

	blt		a1, zero, setHWIOFDisable
	j		setHWIOFEnable

	setHWIOFDisable:
	# Disable HW_IOF for the pin
	not		t2, t2			# t2 <- ~pinMask
	and		t3, t3, t2
	sw		t3, 0(t0)		# HWIOF_en ^= ~pinMask
	j		setHWIOFEnd

	setHWIOFEnable:
	# Enable HW_IOF for the pin
	or		t3, t3, t2
	sw		t3, 0(t0)		# HWIOF_en |= pinMask

	lw		t3, 0(t1)		# t3 <- HWIOF_sel
	beq		a1, zero, setHWIOF0
	j		setHWIOF1


	setHWIOF0:
	# Select IOF0 for the pin
	not		t2, t2			# t2 <- ~pinMask
	and		t3, t3, t2
	sw		t3, 0(t1)		# HWIOF_sel ^= ~pinMask
	j		setHWIOFEnd

	setHWIOF1:
	# Select IOF1 for the pin
	or		t3, t3, t2
	sw		t3, 0(t1)		# HWIOF_sel |= pinMask
	j		setHWIOFEnd


	setHWIOFEnd:
	ret


#------------------------------------------------------------------------------
# togglePinValue
# Args:
#   a0 - Pin to toggle
#
# Toggles the output value of a given pin
#------------------------------------------------------------------------------
togglePinValue:
la t0, PIN_OUTPUT_VALUE
lw t0, 0(t0)				#t0 <- &PinValue
lw t1, 0(t0)				#t1 <- PinValue

addi t2, zero, 1			#t2 = 1
sll t3, t2, a0				#t3 <- pinMask = 1 << pinNum
xor t4, t3, t1				#t4 <- newPinVal = pinMask ^ pinVal

sw t4, 0(t0)				#store newPinVal
ret							#return

#------------------------------------------------------------------------------
# pinToGPIO
# Args:
#   a0 - pinNum
# Returns:
#   a0 - GPIONum
#
# Converts a given pin number to its corresponding GPIO number
#------------------------------------------------------------------------------
pinToGPIO:
blt	a0, zero, pinToGPIOInvalid		#if(pinNum < 0) return -1

add t0, zero, a0
addi t1, zero, 8
beq a0, t1, pinToGPIOInvalid			#if(pinNum == 8) return -1
blt a0, t1, pinToGPIOGroup0			#if(0 <= pinNum < 8) pinToGPIOGroup0

addi t2, zero, 14
beq a0, t2,pinToGPIOInvalid	#if (pinNum == 14) return -1
blt a0, t2, pinToGPIOGroup1			#if (8 < pinNum < 14) pinToGPIOGroup1

addi t1, zero, 20
blt	a0, t1, pinToGPIOGroup2			#if (14 < pinNum < 20) pinToGPIOGroup2

j pinToGPIOInvalid					#if (pinNum >= 20) return -1

pinToGPIOGroup0:
# a0 = 16 + a0
addi a0, a0, 16
j pinToGPIOEnd

pinToGPIOGroup1:
# a0 = a0 -8
addi a0, a0, -8
j pinToGPIOEnd

pinToGPIOGroup2:
# a0 = a0 -6
addi a0, a0, -6
j pinToGPIOEnd

pinToGPIOInvalid:
#a0 = -1
addi a0, zero, -1
j pinToGPIOEnd

pinToGPIOEnd:
ret


#------------------------------------------------------------------------------
# GPIOinterrupt
# Args:
#   a0 - pinNum
#	a1 - interruptMode
#
# Converts a given pin number to its corresponding GPIO number
#------------------------------------------------------------------------------
GPIOEnableInterrupt:
addi sp, sp, -8									#stacking the variables
sw s0, 0(sp)
sw ra, 4(sp)

beq a1, zero, GPIOEnableInterruptRising			#if interruptMode == zero, rising
addi a1, a1, -1

beq a1, zero, GPIOEnableInterruptFalling		#if interruptMode == 1, falling
addi a1, a1, -1

beq a1, zero, GPIOEnableInterruptHigh		    #if interruptMode == 2, high
addi a1, a1, -1

beq a1, zero, GPIOEnableInterruptLow			#if interruptMode == 3, low
addi a1, a1, -1

GPIOEnableInterruptRising:
la t0, POSITIVE_EDGE_INTERRUPT_ENABLE			#loading interrupt mask
lw s0, 0(t0)
j GPIOEnableInterruptSet

GPIOEnableInterruptFalling:
la t0, NEGATIVE_EDGE_INTERRUPT_ENABLE			#loading interrupt mask
lw s0, 0(t0)
j GPIOEnableInterruptSet

GPIOEnableInterruptHigh:
la t0, HIGH_INTERRUPT_ENABLE					#loading interrupt mask
lw s0, 0(t0)
j GPIOEnableInterruptSet

GPIOEnableInterruptLow:
la t0, LOW_INTERRUPT_ENABLE						#loading interrupt mask
lw s0, 0(t0)
j GPIOEnableInterruptSet

GPIOEnableInterruptSet:
jal pinToGPIO
addi t1, zero, 1
sll t1, t1, a0

#enabling interrupt bit
lw t2, 0(s0)
or t2, t1, t2
sw t2, 0(s0)

lw s0, 0(sp)
lw ra, 4(sp)

addi sp, sp, 8
ret
