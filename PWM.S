.data

# Memory mapped PWM regions (ording in .data matters! Do not change)
PWM0:			.word 0x10015FFF
PWM1:			.word 0x10025FFF
PWM2:			.word 0x10035FFF

# Offsets for PWM region
PWM_CFG:		.word 0x00
PWM_COUNT:		.word 0x08
PWMS:			.word 0x10
PWM_CMP0:		.word 0x20
PWM_CMP1:		.word 0x24
PWM_CMP2:		.word 0x28
PWM_CMP3:		.word 0x2C

