
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega128
;Program type             : Application
;Clock frequency          : 14.745600 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : float, width, precision
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 1024 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : No
;global 'const' stored in FLASH: Yes
;Enhanced core instructions    : On
;Smart register allocation     : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega128
	#pragma AVRPART MEMORY PROG_FLASH 131072
	#pragma AVRPART MEMORY EEPROM 4096
	#pragma AVRPART MEMORY INT_SRAM SIZE 4351
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU RAMPZ=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x6D
	.EQU XMCRB=0x6C

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x10FF
	.EQU __DSTACK_SIZE=0x0400
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _i=R4
	.DEF _j=R6
	.DEF _cnt=R8
	.DEF _p_count=R10
	.DEF _i_count=R12

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _ext_int5_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _tim0_overflow
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart1_receive
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_0x3:
	.DB  0x48,0xE1,0x7A,0x3F
_0x4F:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_0x5A:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_0x0:
	.DB  0x25,0x2E,0x33,0x66,0x20,0x25,0x2E,0x33
	.DB  0x66,0x20,0x25,0x2E,0x33,0x66,0x20,0x25
	.DB  0x2E,0x33,0x66,0x20,0xA,0x0
_0x2000060:
	.DB  0x1
_0x2000000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0
_0x2020000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0

__GLOBAL_INI_TBL:
	.DW  0x04
	.DW  _alpha
	.DW  _0x3*2

	.DW  0x0A
	.DW  0x04
	.DW  _0x5A*2

	.DW  0x01
	.DW  __seed_G100
	.DW  _0x2000060*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30
	STS  XMCRB,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

	OUT  RAMPZ,R24

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x500

	.CSEG
;#include <mega128.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <delay.h>
;#include <stdlib.h>
;#include <stdio.h>
;#include <math.h>
;
;#define TWI_START 0x08
;#define MT_REPEATED_START 0x10
;#define MT_SLAW_ACK 0x18
;#define MT_DATA_ACK 0x28
;#define MT_SLAR_ACK 0x40
;#define MT_DATA_NACK 0x58
;
;#define SR_SLA_ACK 0x60
;#define SR_STOP 0xA0
;#define SR_DATA_ACK 0x80
;
;#define Over_Time 0.0001389
;
;// 동작범위
;// 모터구동 1.1ms(OCR 16220) 이상부터 구동됨.
;// 송신기 송신 주기 = 14.8ms, 최저 값 = 1.0865ms(OCR = 16020), 최대 값 = 1.915ms (OCR =  28237)
;#define MAX_OCR 28237   // 1.915ms
;#define MIN_OCR 16020   // 1.0865ms
;
;
;
;
;
;// 변수
;unsigned int i = 0;
;unsigned int j = 0;
;unsigned int cnt = 0;
;unsigned int p_count = 0;
;unsigned int i_count = 0;
;unsigned int d_count = 0;
;unsigned int time_count = 0;
;
;volatile float alpha = 0.98;

	.DSEG
;volatile float roll,pitch,yaw = 0;
;volatile float las_angle_gx, las_angle_gy, las_angle_gz = 0;
;volatile float dt = 0.000;
;volatile float baseAcX = 0;
;volatile float baseAcY = 0;
;volatile float baseAcZ = 0;
;volatile float baseGyX = 0;
;volatile float baseGyY = 0;
;volatile float baseGyZ = 0;
;
;float error;
;float moterOCR1C;
;float moterOCR3B;
;
;// LPF변수
;float f_roll, f_pitch, pre_roll, pre_pitch;
;
;// 메모리 변수 선언 (인터럽트에서 쓰이는 변수들)
;volatile long int cnt_rising= 0;
;volatile long int cnt_falling= 0;
;volatile long int throttle= 0;
;
;
;// 플래그
;//unsigned char start_flag = 0;   // 모터 시동 후 모터동작 플래그
;//unsigned char power_flag = 1;   // 시작하자마자 인터럽트 동작플래그
;unsigned char stop_flag = 0;    // 모터 정지 플래그
;unsigned char timeflag_2ms = 0; // 2ms 플래그
;
;
;// 배열
;unsigned char msg[40] = {0,};
;unsigned char msg1[40] = {0,};
;
;
;// PID variable
;float roll_desire_angle = 0;
;float roll_prev_angle = 0;
;float roll_kp = 0;
;float roll_ki = 0;
;float roll_kd = 0;
;float roll_I_control = 0;
;float roll_output = 0;
;
;
;float pitch_desire_angle = 0;
;float pitch_prev_angle = 0;
;float pitch_kp = 0;
;float pitch_ki = 0;
;float pitch_kd = 0;
;float pitch_I_control = 0;
;float pitch_output = 0;
;
;
;//float yaw_desire_angle = 0;
;//float yaw_prev_angle = 0;
;//float yaw_kp = 0;
;//float yaw_ki = 0;
;//float yaw_kd = 0;
;//float yaw_I_control;
;//float yaw_output;
;
;
;void Init_USART1_IntCon(void)
; 0000 0068 {

	.CSEG
_Init_USART1_IntCon:
; 0000 0069 
; 0000 006A     // ② RXCIE1=1(수신 인터럽트 허가), RXEN0=1(수신 허가), TXEN0 = 1(송신 허가)
; 0000 006B     UCSR1B = (1<<RXCIE1)| (1<<RXEN1)|(1 <<TXEN1);
	LDI  R30,LOW(152)
	STS  154,R30
; 0000 006C     UBRR1H = 0x00;        // ③ 115200bps 보오 레이트 설정
	LDI  R30,LOW(0)
	STS  152,R30
; 0000 006D     UBRR1L = 0x07;        // ③ 115200bps 보오 레이트 설정
	LDI  R30,LOW(7)
	STS  153,R30
; 0000 006E     SREG  |= 0x80;        // ① 전체 인터럽트 허가
	BSET 7
; 0000 006F }
	RET
;
;void putch_USART1(char data)            // USART1용 1문자 송신 함수
; 0000 0072 {
_putch_USART1:
; 0000 0073     while(!(UCSR1A & (1<<UDRE1)));
;	data -> Y+0
_0x4:
	LDS  R30,155
	ANDI R30,LOW(0x20)
	BREQ _0x4
; 0000 0074     UDR1 = data;
	LD   R30,Y
	STS  156,R30
; 0000 0075 }
	ADIW R28,1
	RET
;
;void puts_USART1(char *str)        // USART1용 문자열 송신 함수
; 0000 0078 {
_puts_USART1:
; 0000 0079     while(*str != 0){
;	*str -> Y+0
_0x7:
	LD   R26,Y
	LDD  R27,Y+1
	LD   R30,X
	CPI  R30,0
	BREQ _0x9
; 0000 007A         putch_USART1(*str);
	ST   -Y,R30
	RCALL _putch_USART1
; 0000 007B         str++;
	LD   R30,Y
	LDD  R31,Y+1
	ADIW R30,1
	ST   Y,R30
	STD  Y+1,R31
; 0000 007C     }
	RJMP _0x7
_0x9:
; 0000 007D }
	RJMP _0x20A0009
;
;// 인터럽트 루틴에서의 데이터 수신
;// PID게인값조정 USART로 하기 위한 인터럽트
;interrupt [USART1_RXC] void usart1_receive(void)    // USART1 RX Complete Handler
; 0000 0082 {
_usart1_receive:
	CALL SUBOPT_0x0
; 0000 0083     unsigned char buff;
; 0000 0084     buff = UDR1;                                    // UDR1을 buff 버퍼에 저장한다.
	ST   -Y,R17
;	buff -> R17
	LDS  R17,156
; 0000 0085 
; 0000 0086     if(buff == 'p')
	CPI  R17,112
	BRNE _0xA
; 0000 0087     {
; 0000 0088         p_count++;
	MOVW R30,R10
	ADIW R30,1
	MOVW R10,R30
; 0000 0089         buff = 0;
	LDI  R17,LOW(0)
; 0000 008A     }
; 0000 008B     else if(buff == 'd')
	RJMP _0xB
_0xA:
	CPI  R17,100
	BRNE _0xC
; 0000 008C     {
; 0000 008D         p_count--;
	MOVW R30,R10
	SBIW R30,1
	MOVW R10,R30
; 0000 008E         buff = 0;
	LDI  R17,LOW(0)
; 0000 008F     }
; 0000 0090     else if(buff == 'i')
	RJMP _0xD
_0xC:
	CPI  R17,105
	BRNE _0xE
; 0000 0091     {
; 0000 0092         i_count++;
	MOVW R30,R12
	ADIW R30,1
	MOVW R12,R30
; 0000 0093         buff = 0;
	LDI  R17,LOW(0)
; 0000 0094     }
; 0000 0095     else if(buff == 'w')
	RJMP _0xF
_0xE:
	CPI  R17,119
	BRNE _0x10
; 0000 0096     {
; 0000 0097         i_count--;
	MOVW R30,R12
	SBIW R30,1
	MOVW R12,R30
; 0000 0098         buff = 0;
	LDI  R17,LOW(0)
; 0000 0099     }
; 0000 009A     else if(buff == 'z')
	RJMP _0x11
_0x10:
	CPI  R17,122
	BRNE _0x12
; 0000 009B     {
; 0000 009C         d_count++;
	LDI  R26,LOW(_d_count)
	LDI  R27,HIGH(_d_count)
	CALL SUBOPT_0x1
; 0000 009D         buff = 0;
	LDI  R17,LOW(0)
; 0000 009E     }
; 0000 009F     else if(buff == 'x')
	RJMP _0x13
_0x12:
	CPI  R17,120
	BRNE _0x14
; 0000 00A0     {
; 0000 00A1         d_count--;
	LDI  R26,LOW(_d_count)
	LDI  R27,HIGH(_d_count)
	LD   R30,X+
	LD   R31,X+
	SBIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 00A2         buff = 0;
	LDI  R17,LOW(0)
; 0000 00A3     }
; 0000 00A4     else if(buff == 's')
	RJMP _0x15
_0x14:
	CPI  R17,115
	BRNE _0x16
; 0000 00A5     {
; 0000 00A6         stop_flag = 1;
	LDI  R30,LOW(1)
	STS  _stop_flag,R30
; 0000 00A7     }
; 0000 00A8 
; 0000 00A9 
; 0000 00AA }
_0x16:
_0x15:
_0x13:
_0x11:
_0xF:
_0xD:
_0xB:
	LD   R17,Y+
	RJMP _0x59
;
;//MPU9250 내부레지스터 주소
;enum MPU9250_REG_ADDRESS
;{
;    DEVICE_ID = 0xD0,
;    CONFIG = 0x1A,
;    GYRO_CONFIG = 0x1B,
;    ACCEL_CONFIG = 0x1C,
;    ACCEL_CONFIG_2 = 0x1D,
;    A_XOUT_H = 0x3b,
;    A_XOUT_L = 0x3c,
;    A_YOUT_H = 0x3d,
;    A_YOUT_L = 0x3e,
;    A_ZOUT_H = 0x3f,
;    A_ZOUT_L = 0x40,
;    G_XOUT_H = 0x43,
;    G_XOUT_L = 0x44,
;    G_YOUT_H = 0x45,
;    G_YOUT_L = 0x46,
;    G_ZOUT_H = 0x47,
;    G_ZOUT_L = 0x48,
;    SIGNAL_PATH_RESET = 0x68,
;    USER_CTRL = 0x6A,
;
;    PWR_MGMT_1 = 0x6B,
;    PWR_MGMT_2 = 0x6C
;};
;
;void Init_TWI()
; 0000 00C8 {
_Init_TWI:
; 0000 00C9     TWBR = 10;        //SCL = 100kHz, 14.7456MHz
	LDI  R30,LOW(10)
	STS  112,R30
; 0000 00CA     TWCR = (1<<TWEN);   //TWI Enable
	LDI  R30,LOW(4)
	STS  116,R30
; 0000 00CB     TWSR = 0x00;        //100kHz
	LDI  R30,LOW(0)
	STS  113,R30
; 0000 00CC }
	RET
;
;
;// TWI통신의 데이터를 읽는  함수.
;unsigned char TWI_Read(unsigned char regAddr)
; 0000 00D1 {
_TWI_Read:
; 0000 00D2     unsigned char Data;
; 0000 00D3     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));  //Start조건 전송
	ST   -Y,R17
;	regAddr -> Y+1
;	Data -> R17
	LDI  R30,LOW(164)
	STS  116,R30
; 0000 00D4     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));
_0x17:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x1A
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x8)
	BREQ _0x19
_0x1A:
	RJMP _0x17
_0x19:
; 0000 00D5 
; 0000 00D6     TWDR = DEVICE_ID&(~0x01);                       //쓰기 위한 주소 전송
	CALL SUBOPT_0x2
; 0000 00D7     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 00D8     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));
_0x1C:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x1F
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x18)
	BREQ _0x1E
_0x1F:
	RJMP _0x1C
_0x1E:
; 0000 00D9 
; 0000 00DA     TWDR = regAddr;                            //Register 주소 전송
	CALL SUBOPT_0x3
; 0000 00DB     TWCR = ((1<<TWINT)|(1<<TWEN));
; 0000 00DC     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
_0x21:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x24
	CALL SUBOPT_0x4
	BREQ _0x23
_0x24:
	RJMP _0x21
_0x23:
; 0000 00DD 
; 0000 00DE     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));  //Restart 전송
	LDI  R30,LOW(164)
	STS  116,R30
; 0000 00DF     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_REPEATED_START));
_0x26:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x29
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x10)
	BREQ _0x28
_0x29:
	RJMP _0x26
_0x28:
; 0000 00E0 
; 0000 00E1     TWDR = DEVICE_ID|0x01;                          //읽기 위한 주소 전송
	LDI  R30,LOW(209)
	STS  115,R30
; 0000 00E2     TWCR = ((1<<TWINT)|(1<<TWEN));
	LDI  R30,LOW(132)
	STS  116,R30
; 0000 00E3     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAR_ACK));
_0x2B:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x2E
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x40)
	BREQ _0x2D
_0x2E:
	RJMP _0x2B
_0x2D:
; 0000 00E4 
; 0000 00E5 
; 0000 00E6     TWCR = ((1<<TWINT)|(1<<TWEN));
	LDI  R30,LOW(132)
	STS  116,R30
; 0000 00E7     while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_NACK));
_0x30:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x33
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x58)
	BREQ _0x32
_0x33:
	RJMP _0x30
_0x32:
; 0000 00E8     Data = TWDR;                        //Data읽기
	LDS  R17,115
; 0000 00E9 
; 0000 00EA     TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO));
	LDI  R30,LOW(148)
	STS  116,R30
; 0000 00EB 
; 0000 00EC     return Data;
	MOV  R30,R17
	LDD  R17,Y+0
	RJMP _0x20A0009
; 0000 00ED }
;
;
;// TWI통신의 데이터를 보내는 함수.
;void TWI_Write(unsigned char addr, unsigned char data)
; 0000 00F2 {
_TWI_Write:
; 0000 00F3 
; 0000 00F4      TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));      //Start조건 전송
;	addr -> Y+1
;	data -> Y+0
	LDI  R30,LOW(164)
	STS  116,R30
; 0000 00F5      while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));
_0x35:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x38
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x8)
	BREQ _0x37
_0x38:
	RJMP _0x35
_0x37:
; 0000 00F6 
; 0000 00F7      TWDR = DEVICE_ID&(~0x01);
	CALL SUBOPT_0x2
; 0000 00F8      TWCR = ((1<<TWINT)|(1<<TWEN));                 //쓰기 위한 주소 전송
; 0000 00F9      while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));
_0x3A:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x3D
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x18)
	BREQ _0x3C
_0x3D:
	RJMP _0x3A
_0x3C:
; 0000 00FA 
; 0000 00FB      TWDR = addr;
	CALL SUBOPT_0x3
; 0000 00FC      TWCR = ((1<<TWINT)|(1<<TWEN));                 //Register 주소 전송
; 0000 00FD      while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
_0x3F:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x42
	CALL SUBOPT_0x4
	BREQ _0x41
_0x42:
	RJMP _0x3F
_0x41:
; 0000 00FE 
; 0000 00FF      TWDR = data;
	LD   R30,Y
	STS  115,R30
; 0000 0100      TWCR = ((1<<TWINT)|(1<<TWEN));                 //Data쓰기
	LDI  R30,LOW(132)
	STS  116,R30
; 0000 0101      while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
_0x44:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x47
	CALL SUBOPT_0x4
	BREQ _0x46
_0x47:
	RJMP _0x44
_0x46:
; 0000 0102 
; 0000 0103      TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO));
	LDI  R30,LOW(148)
	STS  116,R30
; 0000 0104 }
_0x20A0009:
	ADIW R28,2
	RET
;
;
;void MPU9250_Init(void)
; 0000 0108 {
_MPU9250_Init:
; 0000 0109     TWI_Write(PWR_MGMT_1, 0x80); // H_RESET[7] : 레지스터 초기화, 디폴트값 회복
	LDI  R30,LOW(107)
	ST   -Y,R30
	LDI  R30,LOW(128)
	ST   -Y,R30
	RCALL _TWI_Write
; 0000 010A     delay_ms(1);                 // MPU9250 RESET delay 1ms 이상 필수
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 010B 
; 0000 010C     TWI_Write(SIGNAL_PATH_RESET, 0x06); // Reset gyro,accel digital signal path
	LDI  R30,LOW(104)
	ST   -Y,R30
	LDI  R30,LOW(6)
	ST   -Y,R30
	RCALL _TWI_Write
; 0000 010D     TWI_Write(USER_CTRL, 0x01);  // Reset all the sensor registers
	LDI  R30,LOW(106)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	RCALL _TWI_Write
; 0000 010E     //TWI_Write(CONFIG, 0x06);
; 0000 010F     TWI_Write(GYRO_CONFIG, 0x18); // +250dps, DLPF-3600Hz-0.11ms    0b0001 1000  A 10 B 11 C 12 D 13 E 14 F 15
	LDI  R30,LOW(27)
	ST   -Y,R30
	LDI  R30,LOW(24)
	ST   -Y,R30
	RCALL _TWI_Write
; 0000 0110     TWI_Write(ACCEL_CONFIG, 0x18);  // 2g   0b0001 1000
	LDI  R30,LOW(28)
	ST   -Y,R30
	LDI  R30,LOW(24)
	ST   -Y,R30
	RCALL _TWI_Write
; 0000 0111     TWI_Write(PWR_MGMT_2, 0x00);  // On gyro, accel sensor
	LDI  R30,LOW(108)
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	RCALL _TWI_Write
; 0000 0112 
; 0000 0113     // DLPF 사용 X => 0x18(16g, 2000dps)
; 0000 0114     // DLPF 사용 O => 0
; 0000 0115 }
	RET
;
;// 가속도센서 출력값 읽기 함수
;void Get_Accel_Data(int *acc_x, int *acc_y, int *acc_z)
; 0000 0119 {
_Get_Accel_Data:
; 0000 011A     unsigned char dat[6];
; 0000 011B     dat[0] = TWI_Read(A_XOUT_H);
	SBIW R28,6
;	*acc_x -> Y+10
;	*acc_y -> Y+8
;	*acc_z -> Y+6
;	dat -> Y+0
	LDI  R30,LOW(59)
	ST   -Y,R30
	RCALL _TWI_Read
	ST   Y,R30
; 0000 011C     dat[1] = TWI_Read(A_XOUT_L);
	LDI  R30,LOW(60)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+1,R30
; 0000 011D     dat[2] = TWI_Read(A_YOUT_H);
	LDI  R30,LOW(61)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+2,R30
; 0000 011E     dat[3] = TWI_Read(A_YOUT_L);
	LDI  R30,LOW(62)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+3,R30
; 0000 011F     dat[4] = TWI_Read(A_ZOUT_H);
	LDI  R30,LOW(63)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+4,R30
; 0000 0120     dat[5] = TWI_Read(A_ZOUT_L);
	LDI  R30,LOW(64)
	CALL SUBOPT_0x5
; 0000 0121 
; 0000 0122 
; 0000 0123     *acc_x = dat[0] << 8 | dat[1];
; 0000 0124     *acc_y = dat[2] << 8 | dat[3];
; 0000 0125     *acc_z = dat[4] << 8 | dat[5];
; 0000 0126 }
	RJMP _0x20A0008
;
;
;// 자이로센서 출력값 읽기 함수
;void Get_Gyro_Data(int *gyro_x, int *gyro_y, int *gyro_z)
; 0000 012B {
_Get_Gyro_Data:
; 0000 012C     unsigned char dat[6];
; 0000 012D     dat[0] = TWI_Read(G_XOUT_H);
	SBIW R28,6
;	*gyro_x -> Y+10
;	*gyro_y -> Y+8
;	*gyro_z -> Y+6
;	dat -> Y+0
	LDI  R30,LOW(67)
	ST   -Y,R30
	RCALL _TWI_Read
	ST   Y,R30
; 0000 012E     dat[1] = TWI_Read(G_XOUT_L);
	LDI  R30,LOW(68)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+1,R30
; 0000 012F     dat[2] = TWI_Read(G_YOUT_H);
	LDI  R30,LOW(69)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+2,R30
; 0000 0130     dat[3] = TWI_Read(G_YOUT_L);
	LDI  R30,LOW(70)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+3,R30
; 0000 0131     dat[4] = TWI_Read(G_ZOUT_H);
	LDI  R30,LOW(71)
	ST   -Y,R30
	RCALL _TWI_Read
	STD  Y+4,R30
; 0000 0132     dat[5] = TWI_Read(G_ZOUT_L);
	LDI  R30,LOW(72)
	CALL SUBOPT_0x5
; 0000 0133 
; 0000 0134     *gyro_x = dat[0] << 8 | dat[1];
; 0000 0135     *gyro_y = dat[2] << 8 | dat[3];
; 0000 0136     *gyro_z = dat[4] << 8 | dat[5];
; 0000 0137 }
	RJMP _0x20A0008
;
;// IMU초기값 설정을 위한 캘리브레이션 함수
;void Calibrate_IMU(int *acc_x, int *acc_y, int *acc_z, int *gyro_x, int *gyro_y, int *gyro_z)
; 0000 013B {
; 0000 013C     int i = 0;
; 0000 013D     int sumAcX = 0, sumAcY = 0, sumAcZ = 0;
; 0000 013E     int sumGyX = 0, sumGyY = 0, sumGyZ = 0;
; 0000 013F 
; 0000 0140     for(i = 0; i<20; i++)
;	*acc_x -> Y+24
;	*acc_y -> Y+22
;	*acc_z -> Y+20
;	*gyro_x -> Y+18
;	*gyro_y -> Y+16
;	*gyro_z -> Y+14
;	i -> R16,R17
;	sumAcX -> R18,R19
;	sumAcY -> R20,R21
;	sumAcZ -> Y+12
;	sumGyX -> Y+10
;	sumGyY -> Y+8
;	sumGyZ -> Y+6
; 0000 0141     {
; 0000 0142         Get_Accel_Data(acc_x, acc_y, acc_z);
; 0000 0143         Get_Gyro_Data(gyro_x, gyro_y, gyro_z);
; 0000 0144         sumAcX += acc_x; sumAcY += acc_y; sumAcZ += acc_z;
; 0000 0145         sumGyX += gyro_x; sumGyY += gyro_y; sumGyZ += gyro_z;
; 0000 0146         delay_ms(1);
; 0000 0147     }
; 0000 0148 
; 0000 0149     baseAcX = sumAcX / 20;
; 0000 014A     baseAcY = sumAcY / 20;
; 0000 014B     baseAcZ = sumAcZ / 20;
; 0000 014C     baseGyX = sumGyX / 20;
; 0000 014D     baseGyY = sumGyY / 20;
; 0000 014E     baseGyZ = sumGyZ / 20;
; 0000 014F }
;
;
;/**
;  *@brief MPU9250 측정값 -> 가속도 변환 함수
;  *@param a_x : x축 가속도 값을 g단위로 저장하여 저장할 변수의 참조 값
;  *@param a_y : y축 가속도 값을 g단위로 저장하여 저장할 변수의 참조 값
;  *@param a_z : z축 가속도 값을 g단위로 저장하여 저장할 변수의 참조 값
;  *@param acc_x : 관성센서로 측정된 x축 가속도의 측정값
;  *@param acc_y : 관성센서로 측정된 y축 가속도의 측정값
;  *@param acc_z : 관성센서로 측정된 z축 가속도의 측정값
;  */
;void Conv_Value_Acc(float *a_x, float *a_y, float *a_z, int acc_x, int acc_y, int acc_z)
; 0000 015C {
_Conv_Value_Acc:
; 0000 015D 
; 0000 015E     *a_x = (float)acc_x/2048; //가속도 g단위 변환
;	*a_x -> Y+10
;	*a_y -> Y+8
;	*a_z -> Y+6
;	acc_x -> Y+4
;	acc_y -> Y+2
;	acc_z -> Y+0
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	CALL SUBOPT_0x6
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __PUTDP1
; 0000 015F     *a_y = (float)acc_y/2048;  // 16g => 2048
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	CALL SUBOPT_0x6
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __PUTDP1
; 0000 0160     *a_z = (float)acc_z/2048;
	LD   R30,Y
	LDD  R31,Y+1
	CALL SUBOPT_0x7
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x45000000
	RJMP _0x20A0007
; 0000 0161 }
;
;
;/**
;  *@brief MPU9250 측정값 -> 가각속도 변환 함수
;  *@param g_x : x축 각속도 값을 DPG단위로 저장하여 저장할 변수의 참조 값
;  *@param g_y : y축 각속도 값을 DPG단위로 저장하여 저장할 변수의 참조 값
;  *@param g_z : z축 각속도 값을 DPG단위로 저장하여 저장할 변수의 참조 값
;  *@param gyro_x : 관성센서로 측정된 x축 각속도의 측정값
;  *@param gyro_y : 관성센서로 측정된 y축 각속도의 측정값
;  *@param gyro_z : 관성센서로 측정된 z축 각속도의 측정값
;  */
;void Conv_Value_Gyro(float *g_x, float *g_y, float *g_z, int gyro_x, int gyro_y, int gyro_z)
; 0000 016E {
_Conv_Value_Gyro:
; 0000 016F     *g_x = (float)(gyro_x - baseGyX) / 16.384; //각속도 변환 131
;	*g_x -> Y+10
;	*g_y -> Y+8
;	*g_z -> Y+6
;	gyro_x -> Y+4
;	gyro_y -> Y+2
;	gyro_z -> Y+0
	LDS  R30,_baseGyX
	LDS  R31,_baseGyX+1
	LDS  R22,_baseGyX+2
	LDS  R23,_baseGyX+3
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	CALL SUBOPT_0x8
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CALL __PUTDP1
; 0000 0170     *g_y = (float)(gyro_y - baseGyY) / 16.384;
	LDS  R30,_baseGyY
	LDS  R31,_baseGyY+1
	LDS  R22,_baseGyY+2
	LDS  R23,_baseGyY+3
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL SUBOPT_0x8
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __PUTDP1
; 0000 0171     *g_z = (float)(gyro_z - baseGyZ) / 16.384;
	LDS  R30,_baseGyZ
	LDS  R31,_baseGyZ+1
	LDS  R22,_baseGyZ+2
	LDS  R23,_baseGyZ+3
	LD   R26,Y
	LDD  R27,Y+1
	CALL __CWD2
	CALL __CDF2
	CALL SUBOPT_0x9
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x4183126F
_0x20A0007:
	CALL __DIVF21
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __PUTDP1
; 0000 0172 }
_0x20A0008:
	ADIW R28,12
	RET
;
;
;// IMU dt값 구하기 위한 타이머초기화
;void Timer_Init_IMU(void)
; 0000 0177 {
_Timer_Init_IMU:
; 0000 0178     TCCR0 = (1<<CS01);     // Normal 모드, 14.7456MHz 8분주, 0.542us
	LDI  R30,LOW(2)
	OUT  0x33,R30
; 0000 0179     TCNT0 = 0;
	LDI  R30,LOW(0)
	OUT  0x32,R30
; 0000 017A     TIMSK |= (1<<TOIE0);
	IN   R30,0x37
	ORI  R30,1
	OUT  0x37,R30
; 0000 017B }
	RET
;
;// 드론 모터 타이머
;void Init_Timer1_BLDC(void)
; 0000 017F {
_Init_Timer1_BLDC:
; 0000 0180   // COM1A1 : OC1A핀 출력(PB5) , WGM12~WGM10 : Fast PWM(TOP = ICR1)
; 0000 0181   // COM1B1 : OC1B핀 출력(PB6)
; 0000 0182   // COM1C1 : OC1C핀 출력(PB7)
; 0000 0183   TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11) | (1<<COM1C1);
	IN   R30,0x2F
	ORI  R30,LOW(0xAA)
	OUT  0x2F,R30
; 0000 0184   TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS10);  // 1분주 14.7456MHz
	IN   R30,0x2E
	ORI  R30,LOW(0x19)
	OUT  0x2E,R30
; 0000 0185   //TIMSK =  (1<<TOIE1); // compare match interrupt set, overflow interrupt (1<< OCIE1A) | (1<< OCIE1B)
; 0000 0186 
; 0000 0187 
; 0000 0188   TCNT1 = 0x00;
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	OUT  0x2C+1,R31
	OUT  0x2C,R30
; 0000 0189   ICR1 = 36864;  // TOP값  2500us = 2.5ms
	LDI  R30,LOW(36864)
	LDI  R31,HIGH(36864)
	OUT  0x26+1,R31
	OUT  0x26,R30
; 0000 018A 
; 0000 018B }
	RET
;
;// 드론 모터 타이머
;void Init_Timer3_BLDC(void)
; 0000 018F {
_Init_Timer3_BLDC:
; 0000 0190     // COM3B1 : OC3B핀 출력(PE4) , WGM33~WGM30 : Fast PWM(TOP = ICR1)
; 0000 0191 
; 0000 0192     TCCR3A |= (1<< COM3B1)| (1<<WGM31);
	LDS  R30,139
	ORI  R30,LOW(0x22)
	STS  139,R30
; 0000 0193     TCCR3B |= (1<< WGM33)| (1<< WGM32)|(1<<CS30);   // 1분주 14.7456MHz
	LDS  R30,138
	ORI  R30,LOW(0x19)
	STS  138,R30
; 0000 0194     //ETIMSK =  (1<< TOIE3); // | (1<< OCIE3B); (1<< OCIE3A)
; 0000 0195 
; 0000 0196     TCNT3H = 0x00;
	LDI  R30,LOW(0)
	STS  137,R30
; 0000 0197     TCNT3L = 0x00;
	STS  136,R30
; 0000 0198 
; 0000 0199     ICR3H = 36864 >> 8;
	LDI  R30,LOW(144)
	STS  129,R30
; 0000 019A     ICR3L = 36864 & 0xFF; // TOP값  2500us = 2.5ms
	LDI  R30,LOW(0)
	STS  128,R30
; 0000 019B 
; 0000 019C }
	RET
;
;// dt값 계산을 위한 카운터값 증가
;interrupt [TIM0_OVF] void tim0_overflow(void)
; 0000 01A0 {
_tim0_overflow:
	CALL SUBOPT_0x0
; 0000 01A1     cnt++;                   // IMU dt값 구하기 위한 카운터값
	MOVW R30,R8
	ADIW R30,1
	MOVW R8,R30
; 0000 01A2     time_count++;            // sprintf값을 위한 카운터값
	LDI  R26,LOW(_time_count)
	LDI  R27,HIGH(_time_count)
	CALL SUBOPT_0x1
; 0000 01A3     if(time_count >= 14)
	LDS  R26,_time_count
	LDS  R27,_time_count+1
	SBIW R26,14
	BRLO _0x4C
; 0000 01A4     {
; 0000 01A5         timeflag_2ms = 1;
	LDI  R30,LOW(1)
	STS  _timeflag_2ms,R30
; 0000 01A6     }
; 0000 01A7 }
_0x4C:
_0x59:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;
;// 송신기 THROTTLE 주기값 받기 인터럽트
;interrupt [EXT_INT5] void ext_int5_isr(void)
; 0000 01AB {
_ext_int5_isr:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 01AC       if(PINE.5 == 1)                         // 상승엣지
	SBIS 0x1,5
	RJMP _0x4D
; 0000 01AD       {
; 0000 01AE              cnt_rising = TCNT1;              // TCNT1 카운터값 read
	IN   R30,0x2C
	IN   R31,0x2C+1
	CLR  R22
	CLR  R23
	STS  _cnt_rising,R30
	STS  _cnt_rising+1,R31
	STS  _cnt_rising+2,R22
	STS  _cnt_rising+3,R23
; 0000 01AF       }
; 0000 01B0       else
	RJMP _0x4E
_0x4D:
; 0000 01B1       {
; 0000 01B2              cnt_falling = TCNT1;             // TCNT1 카운터값 read
	IN   R30,0x2C
	IN   R31,0x2C+1
	CLR  R22
	CLR  R23
	STS  _cnt_falling,R30
	STS  _cnt_falling+1,R31
	STS  _cnt_falling+2,R22
	STS  _cnt_falling+3,R23
; 0000 01B3 
; 0000 01B4              throttle = (36865- cnt_rising + cnt_falling) % 36865;
	LDS  R26,_cnt_rising
	LDS  R27,_cnt_rising+1
	LDS  R24,_cnt_rising+2
	LDS  R25,_cnt_rising+3
	__GETD1N 0x9001
	CALL __SUBD12
	LDS  R26,_cnt_falling
	LDS  R27,_cnt_falling+1
	LDS  R24,_cnt_falling+2
	LDS  R25,_cnt_falling+3
	CALL __ADDD21
	__GETD1N 0x9001
	CALL __MODD21
	STS  _throttle,R30
	STS  _throttle+1,R31
	STS  _throttle+2,R22
	STS  _throttle+3,R23
; 0000 01B5       }
_0x4E:
; 0000 01B6 
; 0000 01B7 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;
;
;#define ts 2.5         // 샘플링 시간
;#define tau 0.5         // 시정수
;void Lowpass_filter(float *range, float *pre_range, float *now_range)
; 0000 01BD {
; 0000 01BE     *range = (tau * (*pre_range) + ((float)ts/1000) * (*now_range)) / (tau +((float)ts/1000)) ;
;	*range -> Y+4
;	*pre_range -> Y+2
;	*now_range -> Y+0
; 0000 01BF }
;
;
;// PID함수
;void StdPID(float *desire, float *current_angle, float *prev_angle, float *I_control, float *Kp, float *Ki, float *Kd, float *PID_control)
; 0000 01C4 {
_StdPID:
; 0000 01C5 
; 0000 01C6     float dInput;
; 0000 01C7     float P_control;
; 0000 01C8     float D_control;
; 0000 01C9 
; 0000 01CA 
; 0000 01CB     error = *desire - *current_angle;        // 에러값
	SBIW R28,12
;	*desire -> Y+26
;	*current_angle -> Y+24
;	*prev_angle -> Y+22
;	*I_control -> Y+20
;	*Kp -> Y+18
;	*Ki -> Y+16
;	*Kd -> Y+14
;	*PID_control -> Y+12
;	dInput -> Y+8
;	P_control -> Y+4
;	D_control -> Y+0
	LDD  R26,Y+26
	LDD  R27,Y+26+1
	CALL __GETD1P
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0xA
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL SUBOPT_0x9
	STS  _error,R30
	STS  _error+1,R31
	STS  _error+2,R22
	STS  _error+3,R23
; 0000 01CC     dInput = *current_angle - *prev_angle;
	CALL SUBOPT_0xA
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __GETD1P
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL SUBOPT_0x9
	__PUTD1S 8
; 0000 01CD     *prev_angle = *current_angle;
	CALL SUBOPT_0xA
	LDD  R26,Y+22
	LDD  R27,Y+22+1
	CALL __PUTDP1
; 0000 01CE 
; 0000 01CF     P_control = (*Kp) * error;
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	CALL __GETD1P
	CALL SUBOPT_0xB
	CALL SUBOPT_0xC
; 0000 01D0     *I_control += (*Ki) * (error * dt);
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	PUSH R27
	PUSH R26
	CALL __GETD1P
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	CALL __GETD1P
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0xD
	CALL SUBOPT_0xB
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDF12
	POP  R26
	POP  R27
	CALL __PUTDP1
; 0000 01D1     D_control = -(*Kd) * (dInput/ dt);
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	CALL __GETD1P
	CALL __ANEGF1
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0xD
	__GETD2S 8
	CALL __DIVF21
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL SUBOPT_0xE
; 0000 01D2 
; 0000 01D3 
; 0000 01D4     *PID_control = P_control + *I_control + D_control;  // PID 출력
	LDD  R26,Y+20
	LDD  R27,Y+20+1
	CALL __GETD1P
	CALL SUBOPT_0xF
	CALL SUBOPT_0x10
	CALL __ADDF12
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __PUTDP1
; 0000 01D5 //    sprintf(msg1,"error %.3f Pitch_kp %.3f \n", error, pitch_kp);
; 0000 01D6 //    puts_USART1(msg1);   //문자열 msg1출력
; 0000 01D7 }
	ADIW R28,28
	RET
;
;void CalcMotorPID()
; 0000 01DA {
_CalcMotorPID:
; 0000 01DB 
; 0000 01DC     //roll_kp = (p_count * 0.002);
; 0000 01DD     pitch_kp = 20 + (p_count * 1);
	MOVW R30,R10
	ADIW R30,20
	LDI  R26,LOW(_pitch_kp)
	LDI  R27,HIGH(_pitch_kp)
	CALL SUBOPT_0x11
; 0000 01DE     //roll_ki = (i_count * 0.01);
; 0000 01DF     pitch_ki = (i_count * 1);
	MOVW R30,R12
	LDI  R26,LOW(_pitch_ki)
	LDI  R27,HIGH(_pitch_ki)
	CALL SUBOPT_0x11
; 0000 01E0     //roll_kd = (d_count * 0.01);
; 0000 01E1     pitch_kd = (d_count * 1);
	LDS  R26,_d_count
	LDS  R27,_d_count+1
	LDI  R30,LOW(1)
	CALL __MULB1W2U
	LDI  R26,LOW(_pitch_kd)
	LDI  R27,HIGH(_pitch_kd)
	CALL SUBOPT_0x11
; 0000 01E2 
; 0000 01E3 
; 0000 01E4     StdPID(&roll_desire_angle, &roll, &roll_prev_angle, &roll_I_control, &roll_kp, &roll_ki, &roll_kd, &roll_output);
	LDI  R30,LOW(_roll_desire_angle)
	LDI  R31,HIGH(_roll_desire_angle)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll)
	LDI  R31,HIGH(_roll)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll_prev_angle)
	LDI  R31,HIGH(_roll_prev_angle)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll_I_control)
	LDI  R31,HIGH(_roll_I_control)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll_kp)
	LDI  R31,HIGH(_roll_kp)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll_ki)
	LDI  R31,HIGH(_roll_ki)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll_kd)
	LDI  R31,HIGH(_roll_kd)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_roll_output)
	LDI  R31,HIGH(_roll_output)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _StdPID
; 0000 01E5     StdPID(&pitch_desire_angle, &pitch, &pitch_prev_angle, &pitch_I_control, &pitch_kp, &pitch_ki, &pitch_kd, &pitch_output);
	LDI  R30,LOW(_pitch_desire_angle)
	LDI  R31,HIGH(_pitch_desire_angle)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch)
	LDI  R31,HIGH(_pitch)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch_prev_angle)
	LDI  R31,HIGH(_pitch_prev_angle)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch_I_control)
	LDI  R31,HIGH(_pitch_I_control)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch_kp)
	LDI  R31,HIGH(_pitch_kp)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch_ki)
	LDI  R31,HIGH(_pitch_ki)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch_kd)
	LDI  R31,HIGH(_pitch_kd)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_pitch_output)
	LDI  R31,HIGH(_pitch_output)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _StdPID
; 0000 01E6 //    StdPID(&roll_desire_angle, &roll, &roll_prev_angle, &roll_I_control, &roll_kp, &roll_ki, &roll_kd, &roll_output);
; 0000 01E7 //    StdPID(&pitch_desire_angle, &pitch, &pitch_prev_angle, &pitch_I_control, &pitch_kp, &pitch_ki, &pitch_kd, &pitch_output);
; 0000 01E8 
; 0000 01E9 }
	RET
;
;
;void MotorSpeed()
; 0000 01ED {
_MotorSpeed:
; 0000 01EE //    int OCR1CW;
; 0000 01EF //    int OCR3BW;
; 0000 01F0 
; 0000 01F1 //    if(throttle > 25000 && throttle < 26000)
; 0000 01F2 //    {
; 0000 01F3 //        throttle = 26500;
; 0000 01F4 //    }
; 0000 01F5 
; 0000 01F6     OCR1A = throttle - roll_output + pitch_output;
	CALL SUBOPT_0x12
	CALL SUBOPT_0x9
	CALL SUBOPT_0x13
	CALL __CFD1U
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 01F7     moterOCR3B = (throttle + roll_output + pitch_output);
	CALL SUBOPT_0x12
	CALL __ADDF12
	CALL SUBOPT_0x13
	STS  _moterOCR3B,R30
	STS  _moterOCR3B+1,R31
	STS  _moterOCR3B+2,R22
	STS  _moterOCR3B+3,R23
; 0000 01F8 
; 0000 01F9     OCR1B = throttle - roll_output - pitch_output;
	CALL SUBOPT_0x12
	CALL SUBOPT_0x9
	CALL SUBOPT_0x14
	CALL __CFD1U
	OUT  0x28+1,R31
	OUT  0x28,R30
; 0000 01FA     moterOCR1C = (throttle + roll_output - pitch_output);
	CALL SUBOPT_0x12
	CALL __ADDF12
	CALL SUBOPT_0x14
	STS  _moterOCR1C,R30
	STS  _moterOCR1C+1,R31
	STS  _moterOCR1C+2,R22
	STS  _moterOCR1C+3,R23
; 0000 01FB 
; 0000 01FC     OCR1CH = (int)(moterOCR1C) >> 8;
	CALL SUBOPT_0x15
	CALL __ASRW8
	STS  121,R30
; 0000 01FD     OCR1CL = (int)(moterOCR1C) & 0xff;
	CALL SUBOPT_0x15
	STS  120,R30
; 0000 01FE 
; 0000 01FF     OCR3BH = (int)moterOCR3B >> 8;
	CALL SUBOPT_0x16
	CALL __ASRW8
	STS  133,R30
; 0000 0200     OCR3BL = (int)moterOCR3B & 0xff;
	CALL SUBOPT_0x16
	RJMP _0x20A0006
; 0000 0201 
; 0000 0202 
; 0000 0203 
; 0000 0204 //    OCR1CW = (OCR1CH << 8)|(OCR1CL);
; 0000 0205 //    OCR3BW = (OCR3BH << 8)|(OCR3BL);
; 0000 0206 
; 0000 0207 
; 0000 0208 //    if(OCR1A > MAX_OCR) OCR1A = MAX_OCR;
; 0000 0209 //    if(OCR1A < MIN_OCR) OCR1A = MIN_OCR;
; 0000 020A //
; 0000 020B //    if(OCR1B > MAX_OCR) OCR1B = MAX_OCR;
; 0000 020C //    if(OCR1B < MIN_OCR) OCR1B = MIN_OCR;
; 0000 020D //
; 0000 020E //    if(OCR1CW > MAX_OCR)
; 0000 020F //    {
; 0000 0210 //        OCR1CH = MAX_OCR >> 8;
; 0000 0211 //        OCR1CL = MAX_OCR & 0xff;
; 0000 0212 //    }
; 0000 0213 //
; 0000 0214 //    if(OCR1CW < MIN_OCR)
; 0000 0215 //    {
; 0000 0216 //        OCR1CH = MIN_OCR >> 8;
; 0000 0217 //        OCR1CL = MIN_OCR & 0xff;
; 0000 0218 //    }
; 0000 0219 //
; 0000 021A //    if(OCR3BW > MAX_OCR)
; 0000 021B //    {
; 0000 021C //        OCR3BH = MAX_OCR >> 8;
; 0000 021D //        OCR3BL = MAX_OCR & 0xff;
; 0000 021E //    }
; 0000 021F //
; 0000 0220 //    if(OCR3BW < MIN_OCR)
; 0000 0221 //    {
; 0000 0222 //        OCR3BH = MIN_OCR >> 8;
; 0000 0223 //        OCR3BL = MIN_OCR & 0xff;
; 0000 0224 //    }
; 0000 0225 
; 0000 0226 
; 0000 0227 }
;
;void MotorStop()
; 0000 022A {
_MotorStop:
; 0000 022B 
; 0000 022C     OCR1A = MIN_OCR;
	CALL SUBOPT_0x17
; 0000 022D     OCR1B = MIN_OCR;
; 0000 022E 
; 0000 022F     OCR1CH = MIN_OCR >> 8;
; 0000 0230     OCR1CL = MIN_OCR & 0xff;
; 0000 0231 
; 0000 0232     OCR3BH = MIN_OCR >> 8;
; 0000 0233     OCR3BL = MIN_OCR & 0xff;
_0x20A0006:
	STS  132,R30
; 0000 0234 
; 0000 0235 }
	RET
;
;void Interrupt_Init(void)
; 0000 0238 {
_Interrupt_Init:
; 0000 0239     EIMSK = 0b00100000;   // INT 5번 사용허용
	LDI  R30,LOW(32)
	OUT  0x39,R30
; 0000 023A     EICRB = 0b00000100;   // INT 5번 logic변경시 인터럽트 발생
	LDI  R30,LOW(4)
	OUT  0x3A,R30
; 0000 023B }
	RET
;
;
;void Port_Init(void)
; 0000 023F {
_Port_Init:
; 0000 0240     DDRB = 0xFF;
	LDI  R30,LOW(255)
	OUT  0x17,R30
; 0000 0241     DDRE = 0xDF;   // 0b1101 1111
	LDI  R30,LOW(223)
	OUT  0x2,R30
; 0000 0242     PORTE = 0x00;  // 0b0000 0000
	LDI  R30,LOW(0)
	OUT  0x3,R30
; 0000 0243     PORTB = 0xFF;
	LDI  R30,LOW(255)
	OUT  0x18,R30
; 0000 0244 }
	RET
;
;void main(void)
; 0000 0247 {
_main:
; 0000 0248     // 가속도, 자이로센서 x,y,z 출력값
; 0000 0249     int acc_x = 0, acc_y = 0, acc_z = 0;
; 0000 024A     int gyro_x = 0, gyro_y = 0, gyro_z = 0;
; 0000 024B 
; 0000 024C     // 가속도센서 = 중력가속도(16384)를 기준 1로 잡음
; 0000 024D     // 자이로센서 = gyro_config(+-250rad/sec = +-16384)로 설정되어 있을 때,
; 0000 024E     // 1rad/sec = (16384 * 2) / 250 = 각속도 / 131
; 0000 024F     float a_x = 0, a_y = 0, a_z = 0;
; 0000 0250     float g_x = 0, g_y = 0, g_z = 0;
; 0000 0251 
; 0000 0252     float angle_ax = 0, angle_ay = 0;
; 0000 0253     float angle_gx = 0, angle_gy = 0, angle_gz = 0;
; 0000 0254 
; 0000 0255     Init_USART1_IntCon();
	SBIW R28,50
	LDI  R24,50
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x4F*2)
	LDI  R31,HIGH(_0x4F*2)
	CALL __INITLOCB
;	acc_x -> R16,R17
;	acc_y -> R18,R19
;	acc_z -> R20,R21
;	gyro_x -> Y+48
;	gyro_y -> Y+46
;	gyro_z -> Y+44
;	a_x -> Y+40
;	a_y -> Y+36
;	a_z -> Y+32
;	g_x -> Y+28
;	g_y -> Y+24
;	g_z -> Y+20
;	angle_ax -> Y+16
;	angle_ay -> Y+12
;	angle_gx -> Y+8
;	angle_gy -> Y+4
;	angle_gz -> Y+0
	__GETWRN 16,17,0
	__GETWRN 18,19,0
	__GETWRN 20,21,0
	RCALL _Init_USART1_IntCon
; 0000 0256     Init_TWI();
	RCALL _Init_TWI
; 0000 0257     MPU9250_Init();
	RCALL _MPU9250_Init
; 0000 0258     Timer_Init_IMU();
	RCALL _Timer_Init_IMU
; 0000 0259     //Calibrate_IMU(&acc_x, &acc_y, &acc_z, &gyro_x, &gyro_y, &gyro_z);
; 0000 025A 
; 0000 025B     Port_Init();
	RCALL _Port_Init
; 0000 025C     Init_Timer3_BLDC();
	RCALL _Init_Timer3_BLDC
; 0000 025D     Init_Timer1_BLDC();
	RCALL _Init_Timer1_BLDC
; 0000 025E     Interrupt_Init();
	RCALL _Interrupt_Init
; 0000 025F 
; 0000 0260     throttle = 0;     // main문 진입시 초기화할 때, 인터럽트가 발생되는 것을 초기화(왜 되는지는 모름..)
	LDI  R30,LOW(0)
	STS  _throttle,R30
	STS  _throttle+1,R30
	STS  _throttle+2,R30
	STS  _throttle+3,R30
; 0000 0261 
; 0000 0262     while(throttle < 17000){} // 송신기로 조금 움직이면(1.1ms 이상) 그 때부터 ESC 동작활성화
_0x50:
	LDS  R26,_throttle
	LDS  R27,_throttle+1
	LDS  R24,_throttle+2
	LDS  R25,_throttle+3
	__CPD2N 0x4268
	BRLT _0x50
; 0000 0263     OCR1A = 16020;
	CALL SUBOPT_0x17
; 0000 0264     OCR1B = 16020;
; 0000 0265 
; 0000 0266     OCR1CH = 16020 >> 8;
; 0000 0267     OCR1CL = 16020 & 0xff;
; 0000 0268 
; 0000 0269     OCR3BH = 16020 >> 8;
; 0000 026A     OCR3BL = 16020 & 0xff;
	STS  132,R30
; 0000 026B     delay_ms(3000);
	LDI  R30,LOW(3000)
	LDI  R31,HIGH(3000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
; 0000 026C 
; 0000 026D     while(1)
_0x53:
; 0000 026E     {
; 0000 026F         //이전 자이로 각도 - 상보필터를 걸쳐서 나온 값
; 0000 0270         las_angle_gx = roll;
	LDS  R30,_roll
	LDS  R31,_roll+1
	LDS  R22,_roll+2
	LDS  R23,_roll+3
	STS  _las_angle_gx,R30
	STS  _las_angle_gx+1,R31
	STS  _las_angle_gx+2,R22
	STS  _las_angle_gx+3,R23
; 0000 0271         las_angle_gy = pitch;
	CALL SUBOPT_0x18
	STS  _las_angle_gy,R30
	STS  _las_angle_gy+1,R31
	STS  _las_angle_gy+2,R22
	STS  _las_angle_gy+3,R23
; 0000 0272         las_angle_gz = yaw;
	LDS  R30,_yaw
	LDS  R31,_yaw+1
	LDS  R22,_yaw+2
	LDS  R23,_yaw+3
	STS  _las_angle_gz,R30
	STS  _las_angle_gz+1,R31
	STS  _las_angle_gz+2,R22
	STS  _las_angle_gz+3,R23
; 0000 0273 
; 0000 0274         Get_Accel_Data(&acc_x,&acc_y,&acc_z);
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R17
	PUSH R16
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R19
	PUSH R18
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R21
	PUSH R20
	RCALL _Get_Accel_Data
	POP  R20
	POP  R21
	POP  R18
	POP  R19
	POP  R16
	POP  R17
; 0000 0275         Get_Gyro_Data(&gyro_x, &gyro_y, &gyro_z);
	CALL SUBOPT_0x19
	CALL SUBOPT_0x19
	CALL SUBOPT_0x19
	RCALL _Get_Gyro_Data
; 0000 0276 
; 0000 0277         dt = Over_Time * cnt;
	MOVW R30,R8
	CLR  R22
	CLR  R23
	CALL __CDF1
	__GETD2N 0x3911A5AF
	CALL __MULF12
	STS  _dt,R30
	STS  _dt+1,R31
	STS  _dt+2,R22
	STS  _dt+3,R23
; 0000 0278         cnt = 0;
	CLR  R8
	CLR  R9
; 0000 0279 
; 0000 027A         Conv_Value_Acc(&a_x, &a_y, &a_z, acc_x, acc_y, acc_z);
	MOVW R30,R28
	ADIW R30,40
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,38
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,36
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	ST   -Y,R19
	ST   -Y,R18
	ST   -Y,R21
	ST   -Y,R20
	RCALL _Conv_Value_Acc
; 0000 027B         Conv_Value_Gyro(&g_x, &g_y, &g_z, gyro_x, gyro_y, gyro_z);
	MOVW R30,R28
	ADIW R30,28
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,26
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,24
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1A
	ST   -Y,R31
	ST   -Y,R30
	RCALL _Conv_Value_Gyro
; 0000 027C 
; 0000 027D         angle_ax = atan(a_y/a_z)*180/PI;      // x축 각도 값
	__GETD1S 32
	__GETD2S 36
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x1C
; 0000 027E         angle_ay = atan(a_x/a_z)*180/PI;      // y축 각도 값
	__GETD1S 32
	__GETD2S 40
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x1D
; 0000 027F 
; 0000 0280 
; 0000 0281         angle_gx = g_x * dt + las_angle_gx;   // 자이로센서 출력값 적분
	CALL SUBOPT_0xD
	__GETD2S 28
	CALL __MULF12
	LDS  R26,_las_angle_gx
	LDS  R27,_las_angle_gx+1
	LDS  R24,_las_angle_gx+2
	LDS  R25,_las_angle_gx+3
	CALL __ADDF12
	__PUTD1S 8
; 0000 0282         angle_gy = g_y * dt + las_angle_gy;
	CALL SUBOPT_0xD
	__GETD2S 24
	CALL __MULF12
	LDS  R26,_las_angle_gy
	LDS  R27,_las_angle_gy+1
	LDS  R24,_las_angle_gy+2
	LDS  R25,_las_angle_gy+3
	CALL __ADDF12
	CALL SUBOPT_0xC
; 0000 0283         angle_gz = g_z * dt + las_angle_gz;
	CALL SUBOPT_0xD
	__GETD2S 20
	CALL __MULF12
	LDS  R26,_las_angle_gz
	LDS  R27,_las_angle_gz+1
	LDS  R24,_las_angle_gz+2
	LDS  R25,_las_angle_gz+3
	CALL __ADDF12
	CALL __PUTD1S0
; 0000 0284 
; 0000 0285         // 상보필터 적용
; 0000 0286         roll = alpha* angle_gx + (1.000 - alpha)*angle_ax;
	__GETD1S 8
	CALL SUBOPT_0x1E
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x1F
	CALL SUBOPT_0x20
	CALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDF12
	STS  _roll,R30
	STS  _roll+1,R31
	STS  _roll+2,R22
	STS  _roll+3,R23
; 0000 0287         pitch = alpha* angle_gy + (1.000 - alpha)*angle_ay;
	CALL SUBOPT_0x21
	CALL SUBOPT_0x1E
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x1F
	CALL SUBOPT_0x22
	CALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __ADDF12
	STS  _pitch,R30
	STS  _pitch+1,R31
	STS  _pitch+2,R22
	STS  _pitch+3,R23
; 0000 0288         yaw = angle_gz;
	CALL SUBOPT_0x23
	STS  _yaw,R30
	STS  _yaw+1,R31
	STS  _yaw+2,R22
	STS  _yaw+3,R23
; 0000 0289 
; 0000 028A //        // LPF필터적용
; 0000 028B //        Lowpass_filter(&f_roll,&pre_roll,&roll);
; 0000 028C //        pre_roll = f_roll;
; 0000 028D //
; 0000 028E //        Lowpass_filter(&f_pitch,&pre_pitch,&pitch);
; 0000 028F //        pre_pitch = f_pitch;
; 0000 0290 
; 0000 0291         // PID 적용 모터 구동
; 0000 0292         CalcMotorPID();
	RCALL _CalcMotorPID
; 0000 0293         MotorSpeed();
	RCALL _MotorSpeed
; 0000 0294 
; 0000 0295         if(stop_flag)
	LDS  R30,_stop_flag
	CPI  R30,0
	BREQ _0x56
; 0000 0296         {
; 0000 0297             MotorStop();
	RCALL _MotorStop
; 0000 0298 
; 0000 0299         }
; 0000 029A 
; 0000 029B         if(timeflag_2ms)
_0x56:
	LDS  R30,_timeflag_2ms
	CPI  R30,0
	BREQ _0x57
; 0000 029C         {
; 0000 029D             //sprintf(msg,"%.3f %.3f %d %d %.3f %.3f\n", pitch_kp,f_pitch, OCR1A,OCR1B,moterOCR1C,moterOCR3B);
; 0000 029E             //sprintf(msg,"%.3f %.3f %.3f %.3f %.3f %.3f %.3f %d\n", a_x, a_y, a_z, g_x, g_y, g_z, f_pitch, OCR1A);
; 0000 029F             //sprintf(msg,"%.3f %.3f %d\n", pitch, f_pitch, OCR1A);
; 0000 02A0             //sprintf(msg,"%.3f \n", pitch);
; 0000 02A1             sprintf(msg,"%.3f %.3f %.3f %.3f \n", pitch_kp, pitch_ki, pitch_kd, pitch);
	LDI  R30,LOW(_msg)
	LDI  R31,HIGH(_msg)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_pitch_kp
	LDS  R31,_pitch_kp+1
	LDS  R22,_pitch_kp+2
	LDS  R23,_pitch_kp+3
	CALL __PUTPARD1
	LDS  R30,_pitch_ki
	LDS  R31,_pitch_ki+1
	LDS  R22,_pitch_ki+2
	LDS  R23,_pitch_ki+3
	CALL __PUTPARD1
	LDS  R30,_pitch_kd
	LDS  R31,_pitch_kd+1
	LDS  R22,_pitch_kd+2
	LDS  R23,_pitch_kd+3
	CALL __PUTPARD1
	CALL SUBOPT_0x18
	CALL __PUTPARD1
	LDI  R24,16
	CALL _sprintf
	ADIW R28,20
; 0000 02A2             puts_USART1(msg);   //문자열 msg1출력
	LDI  R30,LOW(_msg)
	LDI  R31,HIGH(_msg)
	ST   -Y,R31
	ST   -Y,R30
	RCALL _puts_USART1
; 0000 02A3             timeflag_2ms = 0;
	LDI  R30,LOW(0)
	STS  _timeflag_2ms,R30
; 0000 02A4             time_count = 0;
	STS  _time_count,R30
	STS  _time_count+1,R30
; 0000 02A5         }
; 0000 02A6 
; 0000 02A7         dt = 0.000;                           // dt 초기화
_0x57:
	LDI  R30,LOW(0)
	STS  _dt,R30
	STS  _dt+1,R30
	STS  _dt+2,R30
	STS  _dt+3,R30
; 0000 02A8 
; 0000 02A9 
; 0000 02AA     }
	RJMP _0x53
; 0000 02AB }
_0x58:
	RJMP _0x58

	.CSEG
_ftoa:
	SBIW R28,4
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	STD  Y+2,R30
	LDI  R30,LOW(63)
	STD  Y+3,R30
	ST   -Y,R17
	ST   -Y,R16
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	BRNE _0x200000D
	CALL SUBOPT_0x24
	__POINTW1FN _0x2000000,0
	CALL SUBOPT_0x25
	RJMP _0x20A0005
_0x200000D:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x200000C
	CALL SUBOPT_0x24
	__POINTW1FN _0x2000000,1
	CALL SUBOPT_0x25
	RJMP _0x20A0005
_0x200000C:
	LDD  R26,Y+12
	TST  R26
	BRPL _0x200000F
	__GETD1S 9
	CALL __ANEGF1
	CALL SUBOPT_0x26
	CALL SUBOPT_0x27
	LDI  R30,LOW(45)
	ST   X,R30
_0x200000F:
	LDD  R26,Y+8
	CPI  R26,LOW(0x7)
	BRLO _0x2000010
	LDI  R30,LOW(6)
	STD  Y+8,R30
_0x2000010:
	LDD  R17,Y+8
_0x2000011:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x2000013
	CALL SUBOPT_0x28
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2A
	RJMP _0x2000011
_0x2000013:
	CALL SUBOPT_0x2B
	CALL __ADDF12
	CALL SUBOPT_0x26
	LDI  R17,LOW(0)
	__GETD1N 0x3F800000
	CALL SUBOPT_0x2A
_0x2000014:
	CALL SUBOPT_0x2B
	CALL __CMPF12
	BRLO _0x2000016
	CALL SUBOPT_0x28
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x2A
	SUBI R17,-LOW(1)
	CPI  R17,39
	BRLO _0x2000017
	CALL SUBOPT_0x24
	__POINTW1FN _0x2000000,5
	CALL SUBOPT_0x25
	RJMP _0x20A0005
_0x2000017:
	RJMP _0x2000014
_0x2000016:
	CPI  R17,0
	BRNE _0x2000018
	CALL SUBOPT_0x27
	LDI  R30,LOW(48)
	ST   X,R30
	RJMP _0x2000019
_0x2000018:
_0x200001A:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x200001C
	CALL SUBOPT_0x28
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2D
	CALL __PUTPARD1
	CALL _floor
	CALL SUBOPT_0x2A
	CALL SUBOPT_0x2B
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	CALL SUBOPT_0x27
	CALL SUBOPT_0x2E
	CALL SUBOPT_0x28
	CALL SUBOPT_0x7
	CALL __MULF12
	CALL SUBOPT_0x2F
	CALL SUBOPT_0x9
	CALL SUBOPT_0x26
	RJMP _0x200001A
_0x200001C:
_0x2000019:
	LDD  R30,Y+8
	CPI  R30,0
	BREQ _0x20A0004
	CALL SUBOPT_0x27
	LDI  R30,LOW(46)
	ST   X,R30
_0x200001E:
	LDD  R30,Y+8
	SUBI R30,LOW(1)
	STD  Y+8,R30
	SUBI R30,-LOW(1)
	BREQ _0x2000020
	CALL SUBOPT_0x2F
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x26
	__GETD1S 9
	CALL __CFD1U
	MOV  R16,R30
	CALL SUBOPT_0x27
	CALL SUBOPT_0x2E
	CALL SUBOPT_0x2F
	CALL SUBOPT_0x7
	CALL SUBOPT_0x9
	CALL SUBOPT_0x26
	RJMP _0x200001E
_0x2000020:
_0x20A0004:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
_0x20A0005:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,13
	RET

	.DSEG

	.CSEG
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_put_buff_G101:
	ST   -Y,R17
	ST   -Y,R16
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x2020010
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,4
	CALL __GETW1P
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2020012
	__CPWRN 16,17,2
	BRLO _0x2020013
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1SNS 2,4
_0x2020012:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL SUBOPT_0x1
	SBIW R30,1
	LDD  R26,Y+4
	STD  Z+0,R26
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	TST  R31
	BRMI _0x2020014
	CALL SUBOPT_0x1
_0x2020014:
_0x2020013:
	RJMP _0x2020015
_0x2020010:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x2020015:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,5
	RET
__ftoe_G101:
	SBIW R28,4
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	LDI  R30,LOW(128)
	STD  Y+2,R30
	LDI  R30,LOW(63)
	STD  Y+3,R30
	CALL __SAVELOCR4
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	CPI  R30,LOW(0xFFFF)
	LDI  R26,HIGH(0xFFFF)
	CPC  R31,R26
	BRNE _0x2020019
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x2020000,0
	CALL SUBOPT_0x25
	RJMP _0x20A0003
_0x2020019:
	CPI  R30,LOW(0x7FFF)
	LDI  R26,HIGH(0x7FFF)
	CPC  R31,R26
	BRNE _0x2020018
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x2020000,1
	CALL SUBOPT_0x25
	RJMP _0x20A0003
_0x2020018:
	LDD  R26,Y+11
	CPI  R26,LOW(0x7)
	BRLO _0x202001B
	LDI  R30,LOW(6)
	STD  Y+11,R30
_0x202001B:
	LDD  R17,Y+11
_0x202001C:
	MOV  R30,R17
	SUBI R17,1
	CPI  R30,0
	BREQ _0x202001E
	CALL SUBOPT_0x30
	CALL SUBOPT_0xC
	RJMP _0x202001C
_0x202001E:
	__GETD1S 12
	CALL __CPD10
	BRNE _0x202001F
	LDI  R19,LOW(0)
	CALL SUBOPT_0x30
	CALL SUBOPT_0xC
	RJMP _0x2020020
_0x202001F:
	LDD  R19,Y+11
	CALL SUBOPT_0x31
	BREQ PC+2
	BRCC PC+3
	JMP  _0x2020021
	CALL SUBOPT_0x30
	CALL SUBOPT_0xC
_0x2020022:
	CALL SUBOPT_0x31
	BRLO _0x2020024
	CALL SUBOPT_0x22
	CALL SUBOPT_0x29
	CALL SUBOPT_0x1D
	SUBI R19,-LOW(1)
	RJMP _0x2020022
_0x2020024:
	RJMP _0x2020025
_0x2020021:
_0x2020026:
	CALL SUBOPT_0x31
	BRSH _0x2020028
	CALL SUBOPT_0x22
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x1D
	SUBI R19,LOW(1)
	RJMP _0x2020026
_0x2020028:
	CALL SUBOPT_0x30
	CALL SUBOPT_0xC
_0x2020025:
	__GETD1S 12
	CALL SUBOPT_0x2D
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x31
	BRLO _0x2020029
	CALL SUBOPT_0x22
	CALL SUBOPT_0x29
	CALL SUBOPT_0x1D
	SUBI R19,-LOW(1)
_0x2020029:
_0x2020020:
	LDI  R17,LOW(0)
_0x202002A:
	LDD  R30,Y+11
	CP   R30,R17
	BRLO _0x202002C
	CALL SUBOPT_0xF
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2D
	CALL __PUTPARD1
	CALL _floor
	CALL SUBOPT_0xC
	CALL SUBOPT_0x21
	CALL SUBOPT_0x22
	CALL __DIVF21
	CALL __CFD1U
	MOV  R16,R30
	CALL SUBOPT_0x32
	MOV  R30,R16
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __CDF1
	CALL SUBOPT_0xF
	CALL __MULF12
	CALL SUBOPT_0x22
	CALL SUBOPT_0x9
	CALL SUBOPT_0x1D
	MOV  R30,R17
	SUBI R17,-1
	CPI  R30,0
	BRNE _0x202002A
	CALL SUBOPT_0x32
	LDI  R30,LOW(46)
	ST   X,R30
	RJMP _0x202002A
_0x202002C:
	CALL SUBOPT_0x33
	SBIW R30,1
	LDD  R26,Y+10
	STD  Z+0,R26
	CPI  R19,0
	BRGE _0x202002E
	NEG  R19
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(45)
	RJMP _0x202010E
_0x202002E:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(43)
_0x202010E:
	ST   X,R30
	CALL SUBOPT_0x33
	CALL SUBOPT_0x33
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __DIVB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	CALL SUBOPT_0x33
	SBIW R30,1
	MOVW R22,R30
	MOV  R26,R19
	LDI  R30,LOW(10)
	CALL __MODB21
	SUBI R30,-LOW(48)
	MOVW R26,R22
	ST   X,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(0)
	ST   X,R30
_0x20A0003:
	CALL __LOADLOCR4
	ADIW R28,16
	RET
__print_G101:
	SBIW R28,63
	SBIW R28,17
	CALL __SAVELOCR6
	LDI  R17,0
	__GETW1SX 88
	STD  Y+8,R30
	STD  Y+8+1,R31
	__GETW1SX 86
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2020030:
	MOVW R26,R28
	SUBI R26,LOW(-(92))
	SBCI R27,HIGH(-(92))
	CALL SUBOPT_0x1
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x2020032
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x2020036
	CPI  R18,37
	BRNE _0x2020037
	LDI  R17,LOW(1)
	RJMP _0x2020038
_0x2020037:
	CALL SUBOPT_0x34
_0x2020038:
	RJMP _0x2020035
_0x2020036:
	CPI  R30,LOW(0x1)
	BRNE _0x2020039
	CPI  R18,37
	BRNE _0x202003A
	CALL SUBOPT_0x34
	RJMP _0x202010F
_0x202003A:
	LDI  R17,LOW(2)
	LDI  R30,LOW(0)
	STD  Y+21,R30
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x202003B
	LDI  R16,LOW(1)
	RJMP _0x2020035
_0x202003B:
	CPI  R18,43
	BRNE _0x202003C
	LDI  R30,LOW(43)
	STD  Y+21,R30
	RJMP _0x2020035
_0x202003C:
	CPI  R18,32
	BRNE _0x202003D
	LDI  R30,LOW(32)
	STD  Y+21,R30
	RJMP _0x2020035
_0x202003D:
	RJMP _0x202003E
_0x2020039:
	CPI  R30,LOW(0x2)
	BRNE _0x202003F
_0x202003E:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2020040
	ORI  R16,LOW(128)
	RJMP _0x2020035
_0x2020040:
	RJMP _0x2020041
_0x202003F:
	CPI  R30,LOW(0x3)
	BRNE _0x2020042
_0x2020041:
	CPI  R18,48
	BRLO _0x2020044
	CPI  R18,58
	BRLO _0x2020045
_0x2020044:
	RJMP _0x2020043
_0x2020045:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x2020035
_0x2020043:
	LDI  R20,LOW(0)
	CPI  R18,46
	BRNE _0x2020046
	LDI  R17,LOW(4)
	RJMP _0x2020035
_0x2020046:
	RJMP _0x2020047
_0x2020042:
	CPI  R30,LOW(0x4)
	BRNE _0x2020049
	CPI  R18,48
	BRLO _0x202004B
	CPI  R18,58
	BRLO _0x202004C
_0x202004B:
	RJMP _0x202004A
_0x202004C:
	ORI  R16,LOW(32)
	LDI  R26,LOW(10)
	MUL  R20,R26
	MOV  R20,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R20,R30
	RJMP _0x2020035
_0x202004A:
_0x2020047:
	CPI  R18,108
	BRNE _0x202004D
	ORI  R16,LOW(2)
	LDI  R17,LOW(5)
	RJMP _0x2020035
_0x202004D:
	RJMP _0x202004E
_0x2020049:
	CPI  R30,LOW(0x5)
	BREQ PC+3
	JMP _0x2020035
_0x202004E:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x2020053
	CALL SUBOPT_0x35
	CALL SUBOPT_0x36
	CALL SUBOPT_0x35
	LDD  R26,Z+4
	ST   -Y,R26
	CALL SUBOPT_0x37
	RJMP _0x2020054
_0x2020053:
	CPI  R30,LOW(0x45)
	BREQ _0x2020057
	CPI  R30,LOW(0x65)
	BRNE _0x2020058
_0x2020057:
	RJMP _0x2020059
_0x2020058:
	CPI  R30,LOW(0x66)
	BREQ PC+3
	JMP _0x202005A
_0x2020059:
	MOVW R30,R28
	ADIW R30,22
	STD  Y+14,R30
	STD  Y+14+1,R31
	CALL SUBOPT_0x38
	CALL __GETD1P
	CALL SUBOPT_0x39
	CALL SUBOPT_0x3A
	LDD  R26,Y+13
	TST  R26
	BRMI _0x202005B
	LDD  R26,Y+21
	CPI  R26,LOW(0x2B)
	BREQ _0x202005D
	RJMP _0x202005E
_0x202005B:
	CALL SUBOPT_0x3B
	CALL __ANEGF1
	CALL SUBOPT_0x39
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x202005D:
	SBRS R16,7
	RJMP _0x202005F
	LDD  R30,Y+21
	ST   -Y,R30
	CALL SUBOPT_0x37
	RJMP _0x2020060
_0x202005F:
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ADIW R30,1
	STD  Y+14,R30
	STD  Y+14+1,R31
	SBIW R30,1
	LDD  R26,Y+21
	STD  Z+0,R26
_0x2020060:
_0x202005E:
	SBRS R16,5
	LDI  R20,LOW(6)
	CPI  R18,102
	BRNE _0x2020062
	CALL SUBOPT_0x3B
	CALL __PUTPARD1
	ST   -Y,R20
	LDD  R30,Y+19
	LDD  R31,Y+19+1
	ST   -Y,R31
	ST   -Y,R30
	CALL _ftoa
	RJMP _0x2020063
_0x2020062:
	CALL SUBOPT_0x3B
	CALL __PUTPARD1
	ST   -Y,R20
	ST   -Y,R18
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ST   -Y,R31
	ST   -Y,R30
	RCALL __ftoe_G101
_0x2020063:
	MOVW R30,R28
	ADIW R30,22
	CALL SUBOPT_0x3C
	RJMP _0x2020064
_0x202005A:
	CPI  R30,LOW(0x73)
	BRNE _0x2020066
	CALL SUBOPT_0x3A
	CALL SUBOPT_0x3D
	CALL SUBOPT_0x3C
	RJMP _0x2020067
_0x2020066:
	CPI  R30,LOW(0x70)
	BRNE _0x2020069
	CALL SUBOPT_0x3A
	CALL SUBOPT_0x3D
	STD  Y+14,R30
	STD  Y+14+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2020067:
	ANDI R16,LOW(127)
	CPI  R20,0
	BREQ _0x202006B
	CP   R20,R17
	BRLO _0x202006C
_0x202006B:
	RJMP _0x202006A
_0x202006C:
	MOV  R17,R20
_0x202006A:
_0x2020064:
	LDI  R20,LOW(0)
	LDI  R30,LOW(0)
	STD  Y+20,R30
	LDI  R19,LOW(0)
	RJMP _0x202006D
_0x2020069:
	CPI  R30,LOW(0x64)
	BREQ _0x2020070
	CPI  R30,LOW(0x69)
	BRNE _0x2020071
_0x2020070:
	ORI  R16,LOW(4)
	RJMP _0x2020072
_0x2020071:
	CPI  R30,LOW(0x75)
	BRNE _0x2020073
_0x2020072:
	LDI  R30,LOW(10)
	STD  Y+20,R30
	SBRS R16,1
	RJMP _0x2020074
	__GETD1N 0x3B9ACA00
	CALL SUBOPT_0x1C
	LDI  R17,LOW(10)
	RJMP _0x2020075
_0x2020074:
	__GETD1N 0x2710
	CALL SUBOPT_0x1C
	LDI  R17,LOW(5)
	RJMP _0x2020075
_0x2020073:
	CPI  R30,LOW(0x58)
	BRNE _0x2020077
	ORI  R16,LOW(8)
	RJMP _0x2020078
_0x2020077:
	CPI  R30,LOW(0x78)
	BREQ PC+3
	JMP _0x20200B6
_0x2020078:
	LDI  R30,LOW(16)
	STD  Y+20,R30
	SBRS R16,1
	RJMP _0x202007A
	__GETD1N 0x10000000
	CALL SUBOPT_0x1C
	LDI  R17,LOW(8)
	RJMP _0x2020075
_0x202007A:
	__GETD1N 0x1000
	CALL SUBOPT_0x1C
	LDI  R17,LOW(4)
_0x2020075:
	CPI  R20,0
	BREQ _0x202007B
	ANDI R16,LOW(127)
	RJMP _0x202007C
_0x202007B:
	LDI  R20,LOW(1)
_0x202007C:
	SBRS R16,1
	RJMP _0x202007D
	CALL SUBOPT_0x3A
	CALL SUBOPT_0x38
	ADIW R26,4
	CALL __GETD1P
	RJMP _0x2020110
_0x202007D:
	SBRS R16,2
	RJMP _0x202007F
	CALL SUBOPT_0x3A
	CALL SUBOPT_0x3D
	CALL __CWD1
	RJMP _0x2020110
_0x202007F:
	CALL SUBOPT_0x3A
	CALL SUBOPT_0x3D
	CLR  R22
	CLR  R23
_0x2020110:
	__PUTD1S 10
	SBRS R16,2
	RJMP _0x2020081
	LDD  R26,Y+13
	TST  R26
	BRPL _0x2020082
	CALL SUBOPT_0x3B
	CALL __ANEGD1
	CALL SUBOPT_0x39
	LDI  R30,LOW(45)
	STD  Y+21,R30
_0x2020082:
	LDD  R30,Y+21
	CPI  R30,0
	BREQ _0x2020083
	SUBI R17,-LOW(1)
	SUBI R20,-LOW(1)
	RJMP _0x2020084
_0x2020083:
	ANDI R16,LOW(251)
_0x2020084:
_0x2020081:
	MOV  R19,R20
_0x202006D:
	SBRC R16,0
	RJMP _0x2020085
_0x2020086:
	CP   R17,R21
	BRSH _0x2020089
	CP   R19,R21
	BRLO _0x202008A
_0x2020089:
	RJMP _0x2020088
_0x202008A:
	SBRS R16,7
	RJMP _0x202008B
	SBRS R16,2
	RJMP _0x202008C
	ANDI R16,LOW(251)
	LDD  R18,Y+21
	SUBI R17,LOW(1)
	RJMP _0x202008D
_0x202008C:
	LDI  R18,LOW(48)
_0x202008D:
	RJMP _0x202008E
_0x202008B:
	LDI  R18,LOW(32)
_0x202008E:
	CALL SUBOPT_0x34
	SUBI R21,LOW(1)
	RJMP _0x2020086
_0x2020088:
_0x2020085:
_0x202008F:
	CP   R17,R20
	BRSH _0x2020091
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x2020092
	CALL SUBOPT_0x3E
	BREQ _0x2020093
	SUBI R21,LOW(1)
_0x2020093:
	SUBI R17,LOW(1)
	SUBI R20,LOW(1)
_0x2020092:
	LDI  R30,LOW(48)
	ST   -Y,R30
	CALL SUBOPT_0x37
	CPI  R21,0
	BREQ _0x2020094
	SUBI R21,LOW(1)
_0x2020094:
	SUBI R20,LOW(1)
	RJMP _0x202008F
_0x2020091:
	MOV  R19,R17
	LDD  R30,Y+20
	CPI  R30,0
	BRNE _0x2020095
_0x2020096:
	CPI  R19,0
	BREQ _0x2020098
	SBRS R16,3
	RJMP _0x2020099
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	LPM  R18,Z+
	STD  Y+14,R30
	STD  Y+14+1,R31
	RJMP _0x202009A
_0x2020099:
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	LD   R18,X+
	STD  Y+14,R26
	STD  Y+14+1,R27
_0x202009A:
	CALL SUBOPT_0x34
	CPI  R21,0
	BREQ _0x202009B
	SUBI R21,LOW(1)
_0x202009B:
	SUBI R19,LOW(1)
	RJMP _0x2020096
_0x2020098:
	RJMP _0x202009C
_0x2020095:
_0x202009E:
	CALL SUBOPT_0x3F
	CALL __DIVD21U
	MOV  R18,R30
	CPI  R18,10
	BRLO _0x20200A0
	SBRS R16,3
	RJMP _0x20200A1
	SUBI R18,-LOW(55)
	RJMP _0x20200A2
_0x20200A1:
	SUBI R18,-LOW(87)
_0x20200A2:
	RJMP _0x20200A3
_0x20200A0:
	SUBI R18,-LOW(48)
_0x20200A3:
	SBRC R16,4
	RJMP _0x20200A5
	CPI  R18,49
	BRSH _0x20200A7
	CALL SUBOPT_0x20
	__CPD2N 0x1
	BRNE _0x20200A6
_0x20200A7:
	RJMP _0x20200A9
_0x20200A6:
	CP   R20,R19
	BRSH _0x2020111
	CP   R21,R19
	BRLO _0x20200AC
	SBRS R16,0
	RJMP _0x20200AD
_0x20200AC:
	RJMP _0x20200AB
_0x20200AD:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x20200AE
_0x2020111:
	LDI  R18,LOW(48)
_0x20200A9:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x20200AF
	CALL SUBOPT_0x3E
	BREQ _0x20200B0
	SUBI R21,LOW(1)
_0x20200B0:
_0x20200AF:
_0x20200AE:
_0x20200A5:
	CALL SUBOPT_0x34
	CPI  R21,0
	BREQ _0x20200B1
	SUBI R21,LOW(1)
_0x20200B1:
_0x20200AB:
	SUBI R19,LOW(1)
	CALL SUBOPT_0x3F
	CALL __MODD21U
	CALL SUBOPT_0x39
	LDD  R30,Y+20
	CALL SUBOPT_0x20
	CLR  R31
	CLR  R22
	CLR  R23
	CALL __DIVD21U
	CALL SUBOPT_0x1C
	__GETD1S 16
	CALL __CPD10
	BREQ _0x202009F
	RJMP _0x202009E
_0x202009F:
_0x202009C:
	SBRS R16,0
	RJMP _0x20200B2
_0x20200B3:
	CPI  R21,0
	BREQ _0x20200B5
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	CALL SUBOPT_0x37
	RJMP _0x20200B3
_0x20200B5:
_0x20200B2:
_0x20200B6:
_0x2020054:
_0x202010F:
	LDI  R17,LOW(0)
_0x2020035:
	RJMP _0x2020030
_0x2020032:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,63
	ADIW R28,31
	RET
_sprintf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	CALL __SAVELOCR4
	CALL SUBOPT_0x40
	SBIW R30,0
	BRNE _0x20200B7
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x20200B7:
	MOVW R26,R28
	ADIW R26,6
	CALL __ADDW2R15
	MOVW R16,R26
	CALL SUBOPT_0x40
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL __ADDW2R15
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_buff_G101)
	LDI  R31,HIGH(_put_buff_G101)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,10
	ST   -Y,R31
	ST   -Y,R30
	RCALL __print_G101
	MOVW R18,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x20A0002:
	CALL __LOADLOCR4
	ADIW R28,10
	POP  R15
	RET

	.CSEG
_ftrunc:
   ldd  r23,y+3
   ldd  r22,y+2
   ldd  r31,y+1
   ld   r30,y
   bst  r23,7
   lsl  r23
   sbrc r22,7
   sbr  r23,1
   mov  r25,r23
   subi r25,0x7e
   breq __ftrunc0
   brcs __ftrunc0
   cpi  r25,24
   brsh __ftrunc1
   clr  r26
   clr  r27
   clr  r24
__ftrunc2:
   sec
   ror  r24
   ror  r27
   ror  r26
   dec  r25
   brne __ftrunc2
   and  r30,r26
   and  r31,r27
   and  r22,r24
   rjmp __ftrunc1
__ftrunc0:
   clt
   clr  r23
   clr  r30
   clr  r31
   clr  r22
__ftrunc1:
   cbr  r22,0x80
   lsr  r23
   brcc __ftrunc3
   sbr  r22,0x80
__ftrunc3:
   bld  r23,7
   ld   r26,y+
   ld   r27,y+
   ld   r24,y+
   ld   r25,y+
   cp   r30,r26
   cpc  r31,r27
   cpc  r22,r24
   cpc  r23,r25
   bst  r25,7
   ret
_floor:
	CALL SUBOPT_0x41
	CALL _ftrunc
	CALL __PUTD1S0
    brne __floor1
__floor0:
	CALL SUBOPT_0x23
	RJMP _0x20A0001
__floor1:
    brtc __floor0
	CALL SUBOPT_0x42
	CALL __SUBF12
	RJMP _0x20A0001
_xatan:
	SBIW R28,4
	CALL SUBOPT_0x21
	CALL SUBOPT_0xF
	CALL SUBOPT_0xE
	CALL SUBOPT_0x23
	__GETD2N 0x40CBD065
	CALL SUBOPT_0x43
	CALL SUBOPT_0xF
	CALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x23
	__GETD2N 0x41296D00
	CALL SUBOPT_0x10
	CALL SUBOPT_0x43
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL __DIVF21
	ADIW R28,8
	RET
_yatan:
	CALL __GETD2S0
	__GETD1N 0x3ED413CD
	CALL __CMPF12
	BRSH _0x2040020
	CALL SUBOPT_0x41
	RCALL _xatan
	RJMP _0x20A0001
_0x2040020:
	CALL __GETD2S0
	__GETD1N 0x401A827A
	CALL __CMPF12
	BREQ PC+2
	BRCC PC+3
	JMP  _0x2040021
	CALL SUBOPT_0x42
	CALL SUBOPT_0x44
	__GETD2N 0x3FC90FDB
	CALL SUBOPT_0x9
	RJMP _0x20A0001
_0x2040021:
	CALL SUBOPT_0x42
	CALL __SUBF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x42
	CALL __ADDF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	CALL SUBOPT_0x44
	__GETD2N 0x3F490FDB
	CALL __ADDF12
	RJMP _0x20A0001
_atan:
	LDD  R26,Y+3
	TST  R26
	BRMI _0x204002C
	CALL SUBOPT_0x41
	RCALL _yatan
	RJMP _0x20A0001
_0x204002C:
	CALL SUBOPT_0x23
	CALL __ANEGF1
	CALL __PUTPARD1
	RCALL _yatan
	CALL __ANEGF1
_0x20A0001:
	ADIW R28,4
	RET

	.CSEG

	.CSEG
_strcpyf:
    ld   r30,y+
    ld   r31,y+
    ld   r26,y+
    ld   r27,y+
    movw r24,r26
strcpyf0:
	lpm  r0,z+
    st   x+,r0
    tst  r0
    brne strcpyf0
    movw r30,r24
    ret
_strlen:
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
_strlenf:
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret

	.DSEG
_d_count:
	.BYTE 0x2
_time_count:
	.BYTE 0x2
_alpha:
	.BYTE 0x4
_roll:
	.BYTE 0x4
_pitch:
	.BYTE 0x4
_yaw:
	.BYTE 0x4
_las_angle_gx:
	.BYTE 0x4
_las_angle_gy:
	.BYTE 0x4
_las_angle_gz:
	.BYTE 0x4
_dt:
	.BYTE 0x4
_baseAcX:
	.BYTE 0x4
_baseAcY:
	.BYTE 0x4
_baseAcZ:
	.BYTE 0x4
_baseGyX:
	.BYTE 0x4
_baseGyY:
	.BYTE 0x4
_baseGyZ:
	.BYTE 0x4
_error:
	.BYTE 0x4
_moterOCR1C:
	.BYTE 0x4
_moterOCR3B:
	.BYTE 0x4
_cnt_rising:
	.BYTE 0x4
_cnt_falling:
	.BYTE 0x4
_throttle:
	.BYTE 0x4
_stop_flag:
	.BYTE 0x1
_timeflag_2ms:
	.BYTE 0x1
_msg:
	.BYTE 0x28
_roll_desire_angle:
	.BYTE 0x4
_roll_prev_angle:
	.BYTE 0x4
_roll_kp:
	.BYTE 0x4
_roll_ki:
	.BYTE 0x4
_roll_kd:
	.BYTE 0x4
_roll_I_control:
	.BYTE 0x4
_roll_output:
	.BYTE 0x4
_pitch_desire_angle:
	.BYTE 0x4
_pitch_prev_angle:
	.BYTE 0x4
_pitch_kp:
	.BYTE 0x4
_pitch_ki:
	.BYTE 0x4
_pitch_kd:
	.BYTE 0x4
_pitch_I_control:
	.BYTE 0x4
_pitch_output:
	.BYTE 0x4
__seed_G100:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2:
	LDI  R30,LOW(208)
	STS  115,R30
	LDI  R30,LOW(132)
	STS  116,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3:
	LDD  R30,Y+1
	STS  115,R30
	LDI  R30,LOW(132)
	STS  116,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x4:
	LDS  R30,113
	ANDI R30,LOW(0xF8)
	CPI  R30,LOW(0x28)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:38 WORDS
SUBOPT_0x5:
	ST   -Y,R30
	CALL _TWI_Read
	STD  Y+5,R30
	LDI  R30,0
	LDD  R31,Y+0
	MOVW R26,R30
	LDD  R30,Y+1
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	ST   X+,R30
	ST   X,R31
	LDI  R30,0
	LDD  R31,Y+2
	MOVW R26,R30
	LDD  R30,Y+3
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ST   X+,R30
	ST   X,R31
	LDI  R30,0
	LDD  R31,Y+4
	MOVW R26,R30
	LDD  R30,Y+5
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ST   X+,R30
	ST   X,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x6:
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x45000000
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7:
	CALL __CWD1
	CALL __CDF1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x8:
	CALL __CWD2
	CALL __CDF2
	CALL __SWAPD12
	CALL __SUBF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x4183126F
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 9 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x9:
	CALL __SWAPD12
	CALL __SUBF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xA:
	LDD  R26,Y+24
	LDD  R27,Y+24+1
	CALL __GETD1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xB:
	LDS  R26,_error
	LDS  R27,_error+1
	LDS  R24,_error+2
	LDS  R25,_error+3
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0xC:
	__PUTD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0xD:
	LDS  R30,_dt
	LDS  R31,_dt+1
	LDS  R22,_dt+2
	LDS  R23,_dt+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xE:
	CALL __MULF12
	CALL __PUTD1S0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 9 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0xF:
	__GETD2S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x10:
	CALL __ADDF12
	CALL __GETD2S0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x11:
	CLR  R22
	CLR  R23
	CALL __CDF1
	CALL __PUTDP1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:45 WORDS
SUBOPT_0x12:
	LDS  R30,_roll_output
	LDS  R31,_roll_output+1
	LDS  R22,_roll_output+2
	LDS  R23,_roll_output+3
	LDS  R26,_throttle
	LDS  R27,_throttle+1
	LDS  R24,_throttle+2
	LDS  R25,_throttle+3
	CALL __CDF2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x13:
	LDS  R26,_pitch_output
	LDS  R27,_pitch_output+1
	LDS  R24,_pitch_output+2
	LDS  R25,_pitch_output+3
	CALL __ADDF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x14:
	LDS  R26,_pitch_output
	LDS  R27,_pitch_output+1
	LDS  R24,_pitch_output+2
	LDS  R25,_pitch_output+3
	CALL __SUBF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x15:
	LDS  R30,_moterOCR1C
	LDS  R31,_moterOCR1C+1
	LDS  R22,_moterOCR1C+2
	LDS  R23,_moterOCR1C+3
	CALL __CFD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x16:
	LDS  R30,_moterOCR3B
	LDS  R31,_moterOCR3B+1
	LDS  R22,_moterOCR3B+2
	LDS  R23,_moterOCR3B+3
	CALL __CFD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x17:
	LDI  R30,LOW(16020)
	LDI  R31,HIGH(16020)
	OUT  0x2A+1,R31
	OUT  0x2A,R30
	OUT  0x28+1,R31
	OUT  0x28,R30
	LDI  R30,LOW(62)
	STS  121,R30
	LDI  R30,LOW(148)
	STS  120,R30
	LDI  R30,LOW(62)
	STS  133,R30
	LDI  R30,LOW(148)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x18:
	LDS  R30,_pitch
	LDS  R31,_pitch+1
	LDS  R22,_pitch+2
	LDS  R23,_pitch+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x19:
	MOVW R30,R28
	ADIW R30,48
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1A:
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+54
	LDD  R31,Y+54+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x1B:
	CALL __DIVF21
	CALL __PUTPARD1
	CALL _atan
	__GETD2N 0x43340000
	CALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40490FDB
	CALL __DIVF21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x1C:
	__PUTD1S 16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x1D:
	__PUTD1S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x1E:
	LDS  R26,_alpha
	LDS  R27,_alpha+1
	LDS  R24,_alpha+2
	LDS  R25,_alpha+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1F:
	RCALL SUBOPT_0x1E
	__GETD1N 0x3F800000
	CALL __SUBF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x20:
	__GETD2S 16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x21:
	__GETD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x22:
	__GETD2S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 12 TIMES, CODE SIZE REDUCTION:19 WORDS
SUBOPT_0x23:
	CALL __GETD1S0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x24:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x25:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _strcpyf

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x26:
	__PUTD1S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x27:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADIW R26,1
	STD  Y+6,R26
	STD  Y+6+1,R27
	SBIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x28:
	__GETD2S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x29:
	__GETD1N 0x3DCCCCCD
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x2A:
	__PUTD1S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x2B:
	__GETD1S 2
	__GETD2S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x2C:
	__GETD1N 0x41200000
	CALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2D:
	__GETD2N 0x3F000000
	CALL __ADDF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x2E:
	MOV  R30,R16
	SUBI R30,-LOW(48)
	ST   X,R30
	MOV  R30,R16
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2F:
	__GETD2S 9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x30:
	RCALL SUBOPT_0xF
	RJMP SUBOPT_0x2C

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x31:
	RCALL SUBOPT_0x21
	RCALL SUBOPT_0x22
	CALL __CMPF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x32:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	ADIW R26,1
	STD  Y+8,R26
	STD  Y+8+1,R27
	SBIW R26,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x33:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x34:
	ST   -Y,R18
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x35:
	__GETW1SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x36:
	SBIW R30,4
	__PUTW1SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x37:
	LDD  R30,Y+7
	LDD  R31,Y+7+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+11
	LDD  R31,Y+11+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x38:
	__GETW2SX 90
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x39:
	__PUTD1S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x3A:
	RCALL SUBOPT_0x35
	RJMP SUBOPT_0x36

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3B:
	__GETD1S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x3C:
	STD  Y+14,R30
	STD  Y+14+1,R31
	ST   -Y,R31
	ST   -Y,R30
	CALL _strlen
	MOV  R17,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x3D:
	RCALL SUBOPT_0x38
	ADIW R26,4
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x3E:
	ANDI R16,LOW(251)
	LDD  R30,Y+21
	ST   -Y,R30
	__GETW1SX 87
	ST   -Y,R31
	ST   -Y,R30
	__GETW1SX 91
	ICALL
	CPI  R21,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3F:
	__GETD1S 16
	__GETD2S 10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x40:
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x41:
	RCALL SUBOPT_0x23
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x42:
	RCALL SUBOPT_0x23
	__GETD2N 0x3F800000
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x43:
	CALL __MULF12
	__GETD2N 0x414A8F4E
	CALL __ADDF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x44:
	CALL __DIVF21
	CALL __PUTPARD1
	JMP  _xatan


	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xE66
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

__ANEGF1:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __ANEGF10
	SUBI R23,0x80
__ANEGF10:
	RET

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__SWAPACC:
	PUSH R20
	MOVW R20,R30
	MOVW R30,R26
	MOVW R26,R20
	MOVW R20,R22
	MOVW R22,R24
	MOVW R24,R20
	MOV  R20,R0
	MOV  R0,R1
	MOV  R1,R20
	POP  R20
	RET

__UADD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	RET

__NEGMAN1:
	COM  R30
	COM  R31
	COM  R22
	SUBI R30,-1
	SBCI R31,-1
	SBCI R22,-1
	RET

__SUBF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129
	LDI  R21,0x80
	EOR  R1,R21

	RJMP __ADDF120

__ADDF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129

__ADDF120:
	CPI  R23,0x80
	BREQ __ADDF128
__ADDF121:
	MOV  R21,R23
	SUB  R21,R25
	BRVS __ADDF1211
	BRPL __ADDF122
	RCALL __SWAPACC
	RJMP __ADDF121
__ADDF122:
	CPI  R21,24
	BRLO __ADDF123
	CLR  R26
	CLR  R27
	CLR  R24
__ADDF123:
	CPI  R21,8
	BRLO __ADDF124
	MOV  R26,R27
	MOV  R27,R24
	CLR  R24
	SUBI R21,8
	RJMP __ADDF123
__ADDF124:
	TST  R21
	BREQ __ADDF126
__ADDF125:
	LSR  R24
	ROR  R27
	ROR  R26
	DEC  R21
	BRNE __ADDF125
__ADDF126:
	MOV  R21,R0
	EOR  R21,R1
	BRMI __ADDF127
	RCALL __UADD12
	BRCC __ADDF129
	ROR  R22
	ROR  R31
	ROR  R30
	INC  R23
	BRVC __ADDF129
	RJMP __MAXRES
__ADDF128:
	RCALL __SWAPACC
__ADDF129:
	RCALL __REPACK
	POP  R21
	RET
__ADDF1211:
	BRCC __ADDF128
	RJMP __ADDF129
__ADDF127:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	BREQ __ZERORES
	BRCC __ADDF1210
	COM  R0
	RCALL __NEGMAN1
__ADDF1210:
	TST  R22
	BRMI __ADDF129
	LSL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVC __ADDF1210

__ZERORES:
	CLR  R30
	CLR  R31
	CLR  R22
	CLR  R23
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	CLR  R20
	CLR  R21
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__CMPF12:
	TST  R25
	BRMI __CMPF120
	TST  R23
	BRMI __CMPF121
	CP   R25,R23
	BRLO __CMPF122
	BRNE __CMPF121
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	BRLO __CMPF122
	BREQ __CMPF123
__CMPF121:
	CLZ
	CLC
	RET
__CMPF122:
	CLZ
	SEC
	RET
__CMPF123:
	SEZ
	CLC
	RET
__CMPF120:
	TST  R23
	BRPL __CMPF122
	CP   R25,R23
	BRLO __CMPF121
	BRNE __CMPF122
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	BRLO __CMPF122
	BREQ __CMPF123
	RJMP __CMPF121

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ADDD21:
	ADD  R26,R30
	ADC  R27,R31
	ADC  R24,R22
	ADC  R25,R23
	RET

__SUBD12:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	SBC  R23,R25
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__ASRW8:
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	RET

__CBD1:
	MOV  R31,R30
	ADD  R31,R31
	SBC  R31,R31
	MOV  R22,R31
	MOV  R23,R31
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__CWD2:
	MOV  R24,R27
	ADD  R24,R24
	SBC  R24,R24
	MOV  R25,R24
	RET

__MULB1W2U:
	MOV  R22,R30
	MUL  R22,R26
	MOVW R30,R0
	MUL  R22,R27
	ADD  R31,R0
	RET

__DIVB21U:
	CLR  R0
	LDI  R25,8
__DIVB21U1:
	LSL  R26
	ROL  R0
	SUB  R0,R30
	BRCC __DIVB21U2
	ADD  R0,R30
	RJMP __DIVB21U3
__DIVB21U2:
	SBR  R26,1
__DIVB21U3:
	DEC  R25
	BRNE __DIVB21U1
	MOV  R30,R26
	MOV  R26,R0
	RET

__DIVB21:
	RCALL __CHKSIGNB
	RCALL __DIVB21U
	BRTC __DIVB211
	NEG  R30
__DIVB211:
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	CLR  R20
	CLR  R21
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__MODB21:
	CLT
	SBRS R26,7
	RJMP __MODB211
	NEG  R26
	SET
__MODB211:
	SBRC R30,7
	NEG  R30
	RCALL __DIVB21U
	MOV  R30,R26
	BRTC __MODB212
	NEG  R30
__MODB212:
	RET

__MODD21U:
	RCALL __DIVD21U
	MOVW R30,R26
	MOVW R22,R24
	RET

__MODD21:
	CLT
	SBRS R25,7
	RJMP __MODD211
	COM  R26
	COM  R27
	COM  R24
	COM  R25
	SUBI R26,-1
	SBCI R27,-1
	SBCI R24,-1
	SBCI R25,-1
	SET
__MODD211:
	SBRC R23,7
	RCALL __ANEGD1
	RCALL __DIVD21U
	MOVW R30,R26
	MOVW R22,R24
	BRTC __MODD212
	RCALL __ANEGD1
__MODD212:
	RET

__CHKSIGNB:
	CLT
	SBRS R30,7
	RJMP __CHKSB1
	NEG  R30
	SET
__CHKSB1:
	SBRS R26,7
	RJMP __CHKSB2
	NEG  R26
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSB2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETD1P:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X
	SBIW R26,3
	RET

__PUTDP1:
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	RET

__GETD1S0:
	LD   R30,Y
	LDD  R31,Y+1
	LDD  R22,Y+2
	LDD  R23,Y+3
	RET

__GETD2S0:
	LD   R26,Y
	LDD  R27,Y+1
	LDD  R24,Y+2
	LDD  R25,Y+3
	RET

__PUTD1S0:
	ST   Y,R30
	STD  Y+1,R31
	STD  Y+2,R22
	STD  Y+3,R23
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__CDF2U:
	SET
	RJMP __CDF2U0
__CDF2:
	CLT
__CDF2U0:
	RCALL __SWAPD12
	RCALL __CDF1U0

__SWAPD12:
	MOV  R1,R24
	MOV  R24,R22
	MOV  R22,R1
	MOV  R1,R25
	MOV  R25,R23
	MOV  R23,R1

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__CPD10:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
