;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1069 (Apr 23 2015) (MSVC)
; This file was generated Mon Mar 14 19:27:59 2022
;--------------------------------------------------------
$name LCD_4bit_AT89LP51RC2
$optc51 --model-small
	R_DSEG    segment data
	R_CSEG    segment code
	R_BSEG    segment bit
	R_XSEG    segment xdata
	R_PSEG    segment xdata
	R_ISEG    segment idata
	R_OSEG    segment data overlay
	BIT_BANK  segment data overlay
	R_HOME    segment code
	R_GSINIT  segment code
	R_IXSEG   segment xdata
	R_CONST   segment code
	R_XINIT   segment code
	R_DINIT   segment code

;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	public _main
	public _LCDprint
	public _LCD_4BIT
	public _WriteCommand
	public _WriteData
	public _LCD_byte
	public _LCD_pulse
	public _waitms
	public _wait_us
	public __c51_external_startup
	public _LCDprint_PARM_3
	public _LCDprint_PARM_2
	public _mystr
;--------------------------------------------------------
; Special Function Registers
;--------------------------------------------------------
_ACC            DATA 0xe0
_B              DATA 0xf0
_PSW            DATA 0xd0
_SP             DATA 0x81
_SPX            DATA 0xef
_DPL            DATA 0x82
_DPH            DATA 0x83
_DPLB           DATA 0xd4
_DPHB           DATA 0xd5
_PAGE           DATA 0xf6
_AX             DATA 0xe1
_BX             DATA 0xf7
_DSPR           DATA 0xe2
_FIRD           DATA 0xe3
_MACL           DATA 0xe4
_MACH           DATA 0xe5
_PCON           DATA 0x87
_AUXR           DATA 0x8e
_AUXR1          DATA 0xa2
_DPCF           DATA 0xa1
_CKRL           DATA 0x97
_CKCKON0        DATA 0x8f
_CKCKON1        DATA 0xaf
_CKSEL          DATA 0x85
_CLKREG         DATA 0xae
_OSCCON         DATA 0x85
_IE             DATA 0xa8
_IEN0           DATA 0xa8
_IEN1           DATA 0xb1
_IPH0           DATA 0xb7
_IP             DATA 0xb8
_IPL0           DATA 0xb8
_IPH1           DATA 0xb3
_IPL1           DATA 0xb2
_P0             DATA 0x80
_P1             DATA 0x90
_P2             DATA 0xa0
_P3             DATA 0xb0
_P4             DATA 0xc0
_P0M0           DATA 0xe6
_P0M1           DATA 0xe7
_P1M0           DATA 0xd6
_P1M1           DATA 0xd7
_P2M0           DATA 0xce
_P2M1           DATA 0xcf
_P3M0           DATA 0xc6
_P3M1           DATA 0xc7
_P4M0           DATA 0xbe
_P4M1           DATA 0xbf
_SCON           DATA 0x98
_SBUF           DATA 0x99
_SADEN          DATA 0xb9
_SADDR          DATA 0xa9
_BDRCON         DATA 0x9b
_BRL            DATA 0x9a
_TCON           DATA 0x88
_TMOD           DATA 0x89
_TCONB          DATA 0x91
_TL0            DATA 0x8a
_TH0            DATA 0x8c
_TL1            DATA 0x8b
_TH1            DATA 0x8d
_RL0            DATA 0xf2
_RH0            DATA 0xf4
_RL1            DATA 0xf3
_RH1            DATA 0xf5
_WDTRST         DATA 0xa6
_WDTPRG         DATA 0xa7
_T2CON          DATA 0xc8
_T2MOD          DATA 0xc9
_RCAP2H         DATA 0xcb
_RCAP2L         DATA 0xca
_TH2            DATA 0xcd
_TL2            DATA 0xcc
_SPCON          DATA 0xc3
_SPSTA          DATA 0xc4
_SPDAT          DATA 0xc5
_SSCON          DATA 0x93
_SSCS           DATA 0x94
_SSDAT          DATA 0x95
_SSADR          DATA 0x96
_KBLS           DATA 0x9c
_KBE            DATA 0x9d
_KBF            DATA 0x9e
_KBMOD          DATA 0x9f
_BMSEL          DATA 0x92
_FCON           DATA 0xd2
_EECON          DATA 0xd2
_ACSRA          DATA 0xa3
_ACSRB          DATA 0xab
_AREF           DATA 0xbd
_DADC           DATA 0xa4
_DADI           DATA 0xa5
_DADL           DATA 0xac
_DADH           DATA 0xad
_CCON           DATA 0xd8
_CMOD           DATA 0xd9
_CL             DATA 0xe9
_CH             DATA 0xf9
_CCAPM0         DATA 0xda
_CCAPM1         DATA 0xdb
_CCAPM2         DATA 0xdc
_CCAPM3         DATA 0xdd
_CCAPM4         DATA 0xde
_CCAP0H         DATA 0xfa
_CCAP1H         DATA 0xfb
_CCAP2H         DATA 0xfc
_CCAP3H         DATA 0xfd
_CCAP4H         DATA 0xfe
_CCAP0L         DATA 0xea
_CCAP1L         DATA 0xeb
_CCAP2L         DATA 0xec
_CCAP3L         DATA 0xed
_CCAP4L         DATA 0xee
;--------------------------------------------------------
; special function bits
;--------------------------------------------------------
_ACC_0          BIT 0xe0
_ACC_1          BIT 0xe1
_ACC_2          BIT 0xe2
_ACC_3          BIT 0xe3
_ACC_4          BIT 0xe4
_ACC_5          BIT 0xe5
_ACC_6          BIT 0xe6
_ACC_7          BIT 0xe7
_B_0            BIT 0xf0
_B_1            BIT 0xf1
_B_2            BIT 0xf2
_B_3            BIT 0xf3
_B_4            BIT 0xf4
_B_5            BIT 0xf5
_B_6            BIT 0xf6
_B_7            BIT 0xf7
_P              BIT 0xd0
_F1             BIT 0xd1
_OV             BIT 0xd2
_RS0            BIT 0xd3
_RS1            BIT 0xd4
_F0             BIT 0xd5
_AC             BIT 0xd6
_CY             BIT 0xd7
_EX0            BIT 0xa8
_ET0            BIT 0xa9
_EX1            BIT 0xaa
_ET1            BIT 0xab
_ES             BIT 0xac
_ET2            BIT 0xad
_EC             BIT 0xae
_EA             BIT 0xaf
_PX0            BIT 0xb8
_PT0            BIT 0xb9
_PX1            BIT 0xba
_PT1            BIT 0xbb
_PS             BIT 0xbc
_PT2            BIT 0xbd
_IP0D           BIT 0xbf
_PPCL           BIT 0xbe
_PT2L           BIT 0xbd
_PLS            BIT 0xbc
_PT1L           BIT 0xbb
_PX1L           BIT 0xba
_PT0L           BIT 0xb9
_PX0L           BIT 0xb8
_P0_0           BIT 0x80
_P0_1           BIT 0x81
_P0_2           BIT 0x82
_P0_3           BIT 0x83
_P0_4           BIT 0x84
_P0_5           BIT 0x85
_P0_6           BIT 0x86
_P0_7           BIT 0x87
_P1_0           BIT 0x90
_P1_1           BIT 0x91
_P1_2           BIT 0x92
_P1_3           BIT 0x93
_P1_4           BIT 0x94
_P1_5           BIT 0x95
_P1_6           BIT 0x96
_P1_7           BIT 0x97
_P2_0           BIT 0xa0
_P2_1           BIT 0xa1
_P2_2           BIT 0xa2
_P2_3           BIT 0xa3
_P2_4           BIT 0xa4
_P2_5           BIT 0xa5
_P2_6           BIT 0xa6
_P2_7           BIT 0xa7
_P3_0           BIT 0xb0
_P3_1           BIT 0xb1
_P3_2           BIT 0xb2
_P3_3           BIT 0xb3
_P3_4           BIT 0xb4
_P3_5           BIT 0xb5
_P3_6           BIT 0xb6
_P3_7           BIT 0xb7
_RXD            BIT 0xb0
_TXD            BIT 0xb1
_INT0           BIT 0xb2
_INT1           BIT 0xb3
_T0             BIT 0xb4
_T1             BIT 0xb5
_WR             BIT 0xb6
_RD             BIT 0xb7
_P4_0           BIT 0xc0
_P4_1           BIT 0xc1
_P4_2           BIT 0xc2
_P4_3           BIT 0xc3
_P4_4           BIT 0xc4
_P4_5           BIT 0xc5
_P4_6           BIT 0xc6
_P4_7           BIT 0xc7
_RI             BIT 0x98
_TI             BIT 0x99
_RB8            BIT 0x9a
_TB8            BIT 0x9b
_REN            BIT 0x9c
_SM2            BIT 0x9d
_SM1            BIT 0x9e
_SM0            BIT 0x9f
_IT0            BIT 0x88
_IE0            BIT 0x89
_IT1            BIT 0x8a
_IE1            BIT 0x8b
_TR0            BIT 0x8c
_TF0            BIT 0x8d
_TR1            BIT 0x8e
_TF1            BIT 0x8f
_CP_RL2         BIT 0xc8
_C_T2           BIT 0xc9
_TR2            BIT 0xca
_EXEN2          BIT 0xcb
_TCLK           BIT 0xcc
_RCLK           BIT 0xcd
_EXF2           BIT 0xce
_TF2            BIT 0xcf
_CF             BIT 0xdf
_CR             BIT 0xde
_CCF4           BIT 0xdc
_CCF3           BIT 0xdb
_CCF2           BIT 0xda
_CCF1           BIT 0xd9
_CCF0           BIT 0xd8
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	rbank0 segment data overlay
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	rseg R_DSEG
_mystr:
	ds 17
_LCDprint_PARM_2:
	ds 1
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
	rseg R_OSEG
;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	rseg R_ISEG
;--------------------------------------------------------
; absolute internal ram data
;--------------------------------------------------------
	DSEG
;--------------------------------------------------------
; bit data
;--------------------------------------------------------
	rseg R_BSEG
_LCDprint_PARM_3:
	DBIT	1
;--------------------------------------------------------
; paged external ram data
;--------------------------------------------------------
	rseg R_PSEG
;--------------------------------------------------------
; external ram data
;--------------------------------------------------------
	rseg R_XSEG
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	XSEG
;--------------------------------------------------------
; external initialized ram data
;--------------------------------------------------------
	rseg R_IXSEG
	rseg R_HOME
	rseg R_GSINIT
	rseg R_CSEG
;--------------------------------------------------------
; Reset entry point and interrupt vectors
;--------------------------------------------------------
	CSEG at 0x0000
	ljmp	_crt0
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	rseg R_HOME
	rseg R_GSINIT
	rseg R_GSINIT
;--------------------------------------------------------
; data variables initialization
;--------------------------------------------------------
	rseg R_DINIT
	; The linker places a 'ret' at the end of segment R_DINIT.
;--------------------------------------------------------
; code
;--------------------------------------------------------
	rseg R_CSEG
;------------------------------------------------------------
;Allocation info for local variables in function '_c51_external_startup'
;------------------------------------------------------------
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:27: unsigned char _c51_external_startup(void)
;	-----------------------------------------
;	 function _c51_external_startup
;	-----------------------------------------
__c51_external_startup:
	using	0
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:30: P0M0=0; P0M1=0;
	mov	_P0M0,#0x00
	mov	_P0M1,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:31: P1M0=0; P1M1=0;
	mov	_P1M0,#0x00
	mov	_P1M1,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:32: P2M0=0; P2M1=0;
	mov	_P2M0,#0x00
	mov	_P2M1,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:33: P3M0=0; P3M1=0;
	mov	_P3M0,#0x00
	mov	_P3M1,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:36: PCON|=0x80;
	orl	_PCON,#0x80
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:37: SCON = 0x52;
	mov	_SCON,#0x52
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:38: BDRCON=0;
	mov	_BDRCON,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:39: BRL=BRG_VAL;
	mov	_BRL,#0xF4
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:40: BDRCON=BRR|TBCK|RBCK|SPD;
	mov	_BDRCON,#0x1E
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:42: CLKREG=0x00; // TPS=0000B
	mov	_CLKREG,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:44: return 0;
	mov	dpl,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'wait_us'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;j                         Allocated to registers r2 r3 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:47: void wait_us (unsigned char x)
;	-----------------------------------------
;	 function wait_us
;	-----------------------------------------
_wait_us:
	mov	r2,dpl
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:51: TR0=0; // Stop timer 0
	clr	_TR0
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:52: TMOD&=0xf0; // Clear the configuration bits for timer 0
	anl	_TMOD,#0xF0
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:53: TMOD|=0x01; // Mode 1: 16-bit timer
	orl	_TMOD,#0x01
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:55: if(x>5) x-=5; // Subtract the overhead
	mov	a,r2
	add	a,#0xff - 0x05
	jnc	L003002?
	mov	a,r2
	add	a,#0xfb
	mov	r2,a
	sjmp	L003003?
L003002?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:56: else x=1;
	mov	r2,#0x01
L003003?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:58: j=-ONE_USEC*x;
	mov	__mullong_PARM_2,r2
	mov	(__mullong_PARM_2 + 1),#0x00
	mov	(__mullong_PARM_2 + 2),#0x00
	mov	(__mullong_PARM_2 + 3),#0x00
	mov	dptr,#0xFFEA
	mov	a,#0xFF
	mov	b,a
	lcall	__mullong
	mov	r2,dpl
	mov	r3,dph
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:59: TF0=0;
	clr	_TF0
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:60: TH0=j/0x100;
	mov	ar4,r3
	mov	r5,#0x00
	mov	_TH0,r4
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:61: TL0=j%0x100;
	mov	r3,#0x00
	mov	_TL0,r2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:62: TR0=1; // Start timer 0
	setb	_TR0
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:63: while(TF0==0); //Wait for overflow
L003004?:
	jnb	_TF0,L003004?
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'waitms'
;------------------------------------------------------------
;ms                        Allocated to registers r2 r3 
;j                         Allocated to registers r4 r5 
;k                         Allocated to registers r6 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:66: void waitms (unsigned int ms)
;	-----------------------------------------
;	 function waitms
;	-----------------------------------------
_waitms:
	mov	r2,dpl
	mov	r3,dph
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:70: for(j=0; j<ms; j++)
	mov	r4,#0x00
	mov	r5,#0x00
L004005?:
	clr	c
	mov	a,r4
	subb	a,r2
	mov	a,r5
	subb	a,r3
	jnc	L004009?
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:71: for (k=0; k<4; k++) wait_us(250);
	mov	r6,#0x00
L004001?:
	cjne	r6,#0x04,L004018?
L004018?:
	jnc	L004007?
	mov	dpl,#0xFA
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	lcall	_wait_us
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
	inc	r6
	sjmp	L004001?
L004007?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:70: for(j=0; j<ms; j++)
	inc	r4
	cjne	r4,#0x00,L004005?
	inc	r5
	sjmp	L004005?
L004009?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'LCD_pulse'
;------------------------------------------------------------
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:74: void LCD_pulse (void)
;	-----------------------------------------
;	 function LCD_pulse
;	-----------------------------------------
_LCD_pulse:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:76: LCD_E=1;
	setb	_P3_3
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:77: wait_us(40);
	mov	dpl,#0x28
	lcall	_wait_us
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:78: LCD_E=0;
	clr	_P3_3
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'LCD_byte'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:81: void LCD_byte (unsigned char x)
;	-----------------------------------------
;	 function LCD_byte
;	-----------------------------------------
_LCD_byte:
	mov	r2,dpl
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:84: ACC=x; //Send high nible
	mov	_ACC,r2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:85: LCD_D7=ACC_7;
	mov	c,_ACC_7
	mov	_P3_7,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:86: LCD_D6=ACC_6;
	mov	c,_ACC_6
	mov	_P3_6,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:87: LCD_D5=ACC_5;
	mov	c,_ACC_5
	mov	_P3_5,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:88: LCD_D4=ACC_4;
	mov	c,_ACC_4
	mov	_P3_4,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:89: LCD_pulse();
	push	ar2
	lcall	_LCD_pulse
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:90: wait_us(40);
	mov	dpl,#0x28
	lcall	_wait_us
	pop	ar2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:91: ACC=x; //Send low nible
	mov	_ACC,r2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:92: LCD_D7=ACC_3;
	mov	c,_ACC_3
	mov	_P3_7,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:93: LCD_D6=ACC_2;
	mov	c,_ACC_2
	mov	_P3_6,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:94: LCD_D5=ACC_1;
	mov	c,_ACC_1
	mov	_P3_5,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:95: LCD_D4=ACC_0;
	mov	c,_ACC_0
	mov	_P3_4,c
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:96: LCD_pulse();
	ljmp	_LCD_pulse
;------------------------------------------------------------
;Allocation info for local variables in function 'WriteData'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:99: void WriteData (unsigned char x)
;	-----------------------------------------
;	 function WriteData
;	-----------------------------------------
_WriteData:
	mov	r2,dpl
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:101: LCD_RS=1;
	setb	_P3_2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:102: LCD_byte(x);
	mov	dpl,r2
	lcall	_LCD_byte
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:103: waitms(2);
	mov	dptr,#0x0002
	ljmp	_waitms
;------------------------------------------------------------
;Allocation info for local variables in function 'WriteCommand'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:106: void WriteCommand (unsigned char x)
;	-----------------------------------------
;	 function WriteCommand
;	-----------------------------------------
_WriteCommand:
	mov	r2,dpl
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:108: LCD_RS=0;
	clr	_P3_2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:109: LCD_byte(x);
	mov	dpl,r2
	lcall	_LCD_byte
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:110: waitms(5);
	mov	dptr,#0x0005
	ljmp	_waitms
;------------------------------------------------------------
;Allocation info for local variables in function 'LCD_4BIT'
;------------------------------------------------------------
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:113: void LCD_4BIT (void)
;	-----------------------------------------
;	 function LCD_4BIT
;	-----------------------------------------
_LCD_4BIT:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:115: LCD_E=0; // Resting state of LCD's enable is zero
	clr	_P3_3
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:117: waitms(20);
	mov	dptr,#0x0014
	lcall	_waitms
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:119: WriteCommand(0x33);
	mov	dpl,#0x33
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:120: WriteCommand(0x33);
	mov	dpl,#0x33
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:121: WriteCommand(0x32); // Change to 4-bit mode
	mov	dpl,#0x32
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:124: WriteCommand(0x28);
	mov	dpl,#0x28
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:125: WriteCommand(0x0c);
	mov	dpl,#0x0C
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:126: WriteCommand(0x01); // Clear screen command (takes some time)
	mov	dpl,#0x01
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:127: waitms(20); // Wait for clear screen command to finsih.
	mov	dptr,#0x0014
	ljmp	_waitms
;------------------------------------------------------------
;Allocation info for local variables in function 'LCDprint'
;------------------------------------------------------------
;line                      Allocated with name '_LCDprint_PARM_2'
;string                    Allocated to registers r2 r3 r4 
;j                         Allocated to registers r5 r6 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:130: void LCDprint(char * string, unsigned char line, bit clear)
;	-----------------------------------------
;	 function LCDprint
;	-----------------------------------------
_LCDprint:
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:134: WriteCommand(line==2?0xc0:0x80);
	mov	a,#0x02
	cjne	a,_LCDprint_PARM_2,L010013?
	mov	r5,#0xC0
	sjmp	L010014?
L010013?:
	mov	r5,#0x80
L010014?:
	mov	dpl,r5
	push	ar2
	push	ar3
	push	ar4
	lcall	_WriteCommand
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:135: waitms(5);
	mov	dptr,#0x0005
	lcall	_waitms
	pop	ar4
	pop	ar3
	pop	ar2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:136: for(j=0; string[j]!=0; j++)	WriteData(string[j]);// Write the message
	mov	r5,#0x00
	mov	r6,#0x00
L010003?:
	mov	a,r5
	add	a,r2
	mov	r7,a
	mov	a,r6
	addc	a,r3
	mov	r0,a
	mov	ar1,r4
	mov	dpl,r7
	mov	dph,r0
	mov	b,r1
	lcall	__gptrget
	mov	r7,a
	jz	L010006?
	mov	dpl,r7
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	lcall	_WriteData
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
	inc	r5
	cjne	r5,#0x00,L010003?
	inc	r6
	sjmp	L010003?
L010006?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:137: if(clear) for(; j<CHARS_PER_LINE; j++) WriteData(' '); // Clear the rest of the line
	jnb	_LCDprint_PARM_3,L010011?
	mov	ar2,r5
	mov	ar3,r6
L010007?:
	clr	c
	mov	a,r2
	subb	a,#0x10
	mov	a,r3
	xrl	a,#0x80
	subb	a,#0x80
	jnc	L010011?
	mov	dpl,#0x20
	push	ar2
	push	ar3
	lcall	_WriteData
	pop	ar3
	pop	ar2
	inc	r2
	cjne	r2,#0x00,L010007?
	inc	r3
	sjmp	L010007?
L010011?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;j                         Allocated to registers r2 
;c                         Allocated to registers r4 
;------------------------------------------------------------
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:140: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:145: waitms(500); // Gives time to putty to start before sending text
	mov	dptr,#0x01F4
	lcall	_waitms
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:148: LCD_4BIT();
	lcall	_LCD_4BIT
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:151: LCDprint("LCD 4-bit test:", 1, 1);
	mov	_LCDprint_PARM_2,#0x01
	setb	_LCDprint_PARM_3
	mov	dptr,#__str_0
	mov	b,#0x80
	lcall	_LCDprint
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:152: LCDprint("Hello, World!", 2, 1);
	mov	_LCDprint_PARM_2,#0x02
	setb	_LCDprint_PARM_3
	mov	dptr,#__str_1
	mov	b,#0x80
	lcall	_LCDprint
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:155: printf("LCD test.\nType something and press <Enter>\n(it will show in the LCD, %d characters max): ", CHARS_PER_LINE);
	mov	a,#0x10
	push	acc
	clr	a
	push	acc
	mov	a,#__str_2
	push	acc
	mov	a,#(__str_2 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:157: while(1)
L011013?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:159: if(RI)
	jnb	_RI,L011013?
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:162: for(j=0; j<CHARS_PER_LINE; j++)
	mov	r2,#0x00
	mov	r3,#0x00
L011004?:
	cjne	r3,#0x10,L011024?
L011024?:
	jnc	L011007?
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:164: c=getchar();
	push	ar2
	push	ar3
	lcall	_getchar
	mov	r4,dpl
	pop	ar3
	pop	ar2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:165: if((c=='\n')||(c=='\r'))
	cjne	r4,#0x0A,L011026?
	sjmp	L011001?
L011026?:
	cjne	r4,#0x0D,L011002?
L011001?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:167: mystr[j]=0;
	mov	a,r2
	add	a,#_mystr
	mov	r0,a
	mov	@r0,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:168: LCDprint(mystr, 2, 1);
	mov	_LCDprint_PARM_2,#0x02
	setb	_LCDprint_PARM_3
	mov	dptr,#_mystr
	mov	b,#0x40
	push	ar2
	lcall	_LCDprint
	pop	ar2
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:169: break;
	sjmp	L011007?
L011002?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:171: mystr[j]=c;
	mov	a,r3
	add	a,#_mystr
	mov	r0,a
	mov	@r0,ar4
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:162: for(j=0; j<CHARS_PER_LINE; j++)
	inc	r3
	mov	ar2,r3
	sjmp	L011004?
L011007?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:173: if(j==CHARS_PER_LINE)
	cjne	r2,#0x10,L011009?
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:175: mystr[j]=0;
	mov	a,r2
	add	a,#_mystr
	mov	r0,a
	mov	@r0,#0x00
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:176: LCDprint(mystr, 2, 1);
	mov	_LCDprint_PARM_2,#0x02
	setb	_LCDprint_PARM_3
	mov	dptr,#_mystr
	mov	b,#0x40
	lcall	_LCDprint
L011009?:
;	D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c:178: printf("\nType something: ");
	mov	a,#__str_3
	push	acc
	mov	a,#(__str_3 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
	ljmp	L011013?
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
__str_0:
	db 'LCD 4-bit test:'
	db 0x00
__str_1:
	db 'Hello, World!'
	db 0x00
__str_2:
	db 'LCD test.'
	db 0x0A
	db 'Type something and press <Enter>'
	db 0x0A
	db '(it will show in '
	db 'the LCD, %d characters max): '
	db 0x00
__str_3:
	db 0x0A
	db 'Type something: '
	db 0x00

	CSEG

end
