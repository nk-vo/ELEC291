;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1069 (Apr 23 2015) (MSVC)
; This file was generated Mon Mar 14 19:01:22 2022
;--------------------------------------------------------
$name adc_two_point_cal
$optc51 --model-small
$printf_float
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
	public _Read_ADC_Channel
	public _Read_ADC_Channel2
	public _ADC_ISR
	public _waitms
	public _wait_us
	public __c51_external_startup
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
_main_V_1_36:
	ds 8
_main_ADC_1_36:
	ds 8
_main_m_1_36:
	ds 4
_main_v0_1_36:
	ds 4
_main_result_1_36:
	ds 4
_main_j_1_36:
	ds 2
_main_sloc0_1_0:
	ds 4
_main_sloc1_1_0:
	ds 4
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
	rseg	R_OSEG
	rseg	R_OSEG
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
	CSEG at 0x006b
	ljmp	_ADC_ISR
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
;	adc_two_point_cal.c:12: unsigned char _c51_external_startup(void)
;	-----------------------------------------
;	 function _c51_external_startup
;	-----------------------------------------
__c51_external_startup:
	using	0
;	adc_two_point_cal.c:14: AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
	mov	_AUXR,#0x11
;	adc_two_point_cal.c:16: P1M0=0; P1M1=0;    
	mov	_P1M0,#0x00
	mov	_P1M1,#0x00
;	adc_two_point_cal.c:17: P2M0=0; P2M1=0;    
	mov	_P2M0,#0x00
	mov	_P2M1,#0x00
;	adc_two_point_cal.c:18: P3M0=0; P3M1=0;    
	mov	_P3M0,#0x00
	mov	_P3M1,#0x00
;	adc_two_point_cal.c:19: PCON|=0x80;
	orl	_PCON,#0x80
;	adc_two_point_cal.c:20: SCON = 0x52;
	mov	_SCON,#0x52
;	adc_two_point_cal.c:21: BDRCON=0;
	mov	_BDRCON,#0x00
;	adc_two_point_cal.c:25: BRL=BRG_VAL;
	mov	_BRL,#0xF4
;	adc_two_point_cal.c:26: BDRCON=BRR|TBCK|RBCK|SPD;
	mov	_BDRCON,#0x1E
;	adc_two_point_cal.c:28: return 0;
	mov	dpl,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'wait_us'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;j                         Allocated to registers r2 r3 
;------------------------------------------------------------
;	adc_two_point_cal.c:31: void wait_us (unsigned char x)
;	-----------------------------------------
;	 function wait_us
;	-----------------------------------------
_wait_us:
	mov	r2,dpl
;	adc_two_point_cal.c:35: TR0=0; // Stop timer 0
	clr	_TR0
;	adc_two_point_cal.c:36: TMOD&=0xf0; // Clear the configuration bits for timer 0
	anl	_TMOD,#0xF0
;	adc_two_point_cal.c:37: TMOD|=0x01; // Mode 1: 16-bit timer
	orl	_TMOD,#0x01
;	adc_two_point_cal.c:39: if(x>5) x-=5; // Subtract the overhead
	mov	a,r2
	add	a,#0xff - 0x05
	jnc	L003002?
	mov	a,r2
	add	a,#0xfb
	mov	r2,a
	sjmp	L003003?
L003002?:
;	adc_two_point_cal.c:40: else x=1;
	mov	r2,#0x01
L003003?:
;	adc_two_point_cal.c:42: j=-ONE_USEC*x;
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
;	adc_two_point_cal.c:43: TF0=0;
	clr	_TF0
;	adc_two_point_cal.c:44: TH0=j/0x100;
	mov	ar4,r3
	mov	r5,#0x00
	mov	_TH0,r4
;	adc_two_point_cal.c:45: TL0=j%0x100;
	mov	r3,#0x00
	mov	_TL0,r2
;	adc_two_point_cal.c:46: TR0=1; // Start timer 0
	setb	_TR0
;	adc_two_point_cal.c:47: while(TF0==0); //Wait for overflow
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
;	adc_two_point_cal.c:50: void waitms (unsigned int ms)
;	-----------------------------------------
;	 function waitms
;	-----------------------------------------
_waitms:
	mov	r2,dpl
	mov	r3,dph
;	adc_two_point_cal.c:54: for(j=0; j<ms; j++)
	mov	r4,#0x00
	mov	r5,#0x00
L004005?:
	clr	c
	mov	a,r4
	subb	a,r2
	mov	a,r5
	subb	a,r3
	jnc	L004009?
;	adc_two_point_cal.c:55: for (k=0; k<4; k++) wait_us(250);
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
;	adc_two_point_cal.c:54: for(j=0; j<ms; j++)
	inc	r4
	cjne	r4,#0x00,L004005?
	inc	r5
	sjmp	L004005?
L004009?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'ADC_ISR'
;------------------------------------------------------------
;------------------------------------------------------------
;	adc_two_point_cal.c:58: void ADC_ISR (void) interrupt 13
;	-----------------------------------------
;	 function ADC_ISR
;	-----------------------------------------
_ADC_ISR:
;	adc_two_point_cal.c:60: }
	reti
;	eliminated unneeded push/pop psw
;	eliminated unneeded push/pop dpl
;	eliminated unneeded push/pop dph
;	eliminated unneeded push/pop b
;	eliminated unneeded push/pop acc
;------------------------------------------------------------
;Allocation info for local variables in function 'Read_ADC_Channel2'
;------------------------------------------------------------
;n                         Allocated to registers r2 
;------------------------------------------------------------
;	adc_two_point_cal.c:62: int Read_ADC_Channel2(unsigned char n)
;	-----------------------------------------
;	 function Read_ADC_Channel2
;	-----------------------------------------
_Read_ADC_Channel2:
	mov	r2,dpl
;	adc_two_point_cal.c:64: DADC&=~ADCE;
	anl	_DADC,#0xEF
;	adc_two_point_cal.c:65: DADI&=~ACON;
;	adc_two_point_cal.c:66: DADI&=0xf8;
	anl	_DADI,#(0x7F&0xF8)
;	adc_two_point_cal.c:67: DADI|=n;
	mov	a,r2
	orl	_DADI,a
;	adc_two_point_cal.c:68: DADI|=ACON; // Connect multiplexer	
	orl	_DADI,#0x80
;	adc_two_point_cal.c:69: DADC|=ADCE;
	orl	_DADC,#0x10
;	adc_two_point_cal.c:71: DADC|=GO_BSY; // Start conversion
	orl	_DADC,#0x40
;	adc_two_point_cal.c:72: while(DADC&GO_BSY); // Wait for conversion to complete
L006001?:
	mov	a,_DADC
	jb	acc.6,L006001?
;	adc_two_point_cal.c:73: return ((DADH+2)*256)+DADL;
	mov	r2,_DADH
	mov	r3,#0x00
	mov	a,#0x02
	add	a,r2
	mov	r2,a
	clr	a
	addc	a,r3
	mov	ar3,r2
	mov	r2,#0x00
	mov	r4,_DADL
	mov	r5,#0x00
	mov	a,r4
	add	a,r2
	mov	dpl,a
	mov	a,r5
	addc	a,r3
	mov	dph,a
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Read_ADC_Channel'
;------------------------------------------------------------
;n                         Allocated to registers r2 
;j                         Allocated to registers 
;------------------------------------------------------------
;	adc_two_point_cal.c:76: int Read_ADC_Channel(unsigned char n)
;	-----------------------------------------
;	 function Read_ADC_Channel
;	-----------------------------------------
_Read_ADC_Channel:
	mov	r2,dpl
;	adc_two_point_cal.c:80: TR0=0; // Stop timer 0
	clr	_TR0
;	adc_two_point_cal.c:81: TMOD&=0xf0; // Clear the configuration bits for timer 0
	anl	_TMOD,#0xF0
;	adc_two_point_cal.c:82: TMOD|=0x01; // Mode 1: 16-bit timer
	orl	_TMOD,#0x01
;	adc_two_point_cal.c:85: TF0=0;
	clr	_TF0
;	adc_two_point_cal.c:86: TH0=j/0x100;
	mov	_TH0,#0xEE
;	adc_two_point_cal.c:87: TL0=j%0x100;
	mov	_TL0,#0xD0
;	adc_two_point_cal.c:89: DADC&=~ADCE;
	anl	_DADC,#0xEF
;	adc_two_point_cal.c:90: DADI&=~ACON;
;	adc_two_point_cal.c:91: DADI&=0xf8;
	anl	_DADI,#(0x7F&0xF8)
;	adc_two_point_cal.c:92: DADI|=n;
	mov	a,r2
	orl	_DADI,a
;	adc_two_point_cal.c:93: DADI|=ACON; // Connect multiplexer
	orl	_DADI,#0x80
;	adc_two_point_cal.c:94: DADI|=TRG0; // Start conversion on timer 0 overflow	
	orl	_DADI,#0x10
;	adc_two_point_cal.c:95: DADC|=ADCE;
	orl	_DADC,#0x10
;	adc_two_point_cal.c:97: IEN1|=0x20; // Enable ADC interrupt
	orl	_IEN1,#0x20
;	adc_two_point_cal.c:98: EA=1;
	setb	_EA
;	adc_two_point_cal.c:100: TR0=1; // Start timer 0
	setb	_TR0
;	adc_two_point_cal.c:101: PCON|=0x01; // Go to idle mode
	orl	_PCON,#0x01
;	adc_two_point_cal.c:102: TR0=0;
	clr	_TR0
;	adc_two_point_cal.c:103: IEN1&=(~0x20); // Disable ADC interrupt
	anl	_IEN1,#0xDF
;	adc_two_point_cal.c:105: return ((DADH+2)*256)+DADL;
	mov	r2,_DADH
	mov	r3,#0x00
	mov	a,#0x02
	add	a,r2
	mov	r2,a
	clr	a
	addc	a,r3
	mov	ar3,r2
	mov	r2,#0x00
	mov	r4,_DADL
	mov	r5,#0x00
	mov	a,r4
	add	a,r2
	mov	dpl,a
	mov	a,r5
	addc	a,r3
	mov	dph,a
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;V                         Allocated with name '_main_V_1_36'
;ADC                       Allocated with name '_main_ADC_1_36'
;m                         Allocated with name '_main_m_1_36'
;v0                        Allocated with name '_main_v0_1_36'
;result                    Allocated with name '_main_result_1_36'
;j                         Allocated with name '_main_j_1_36'
;mask                      Allocated to registers r2 r3 
;sloc0                     Allocated with name '_main_sloc0_1_0'
;sloc1                     Allocated with name '_main_sloc1_1_0'
;------------------------------------------------------------
;	adc_two_point_cal.c:108: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	adc_two_point_cal.c:111: float V[2] = { VDD*(2.0/3.0), VDD*(1.0/3.0)};
	mov	_main_V_1_36,#0xF0
	mov	(_main_V_1_36 + 1),#0xA7
	mov	(_main_V_1_36 + 2),#0x56
	mov	(_main_V_1_36 + 3),#0x40
	mov	(_main_V_1_36 + 0x0004),#0xF0
	mov	((_main_V_1_36 + 0x0004) + 1),#0xA7
	mov	((_main_V_1_36 + 0x0004) + 2),#0xD6
	mov	((_main_V_1_36 + 0x0004) + 3),#0x3F
;	adc_two_point_cal.c:117: CLKREG=0x00; // TPS=0000B
	mov	_CLKREG,#0x00
;	adc_two_point_cal.c:121: P0M0=0x07;
	mov	_P0M0,#0x07
;	adc_two_point_cal.c:122: P0M1=0x00;
	mov	_P0M1,#0x00
;	adc_two_point_cal.c:124: printf("\n\nAT89LP51Rx2 ADC test program with self calibration:\n");
	mov	a,#__str_0
	push	acc
	mov	a,#(__str_0 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	adc_two_point_cal.c:125: printf("   1) Connect a 150 ohm resistor from P0.1 to VDD\n");
	mov	a,#__str_1
	push	acc
	mov	a,#(__str_1 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	adc_two_point_cal.c:126: printf("   2) Connect a 150 ohm resistor from P0.1 to P0.2\n");
	mov	a,#__str_2
	push	acc
	mov	a,#(__str_2 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	adc_two_point_cal.c:127: printf("   3) Connect a 150 ohm resistor from P0.2 to GND\n");
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
;	adc_two_point_cal.c:128: printf("Pick three resistors that are almost identical (less than 0.1%% difference)\n");
	mov	a,#__str_4
	push	acc
	mov	a,#(__str_4 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	adc_two_point_cal.c:130: DADI=0x00;
	mov	_DADI,#0x00
;	adc_two_point_cal.c:131: DADC=0x00;
	mov	_DADC,#0x00
;	adc_two_point_cal.c:135: DADC=ACK1; // CLK/16
	mov	_DADC,#0x02
;	adc_two_point_cal.c:136: DADC|=ADCE;
	orl	_DADC,#0x10
;	adc_two_point_cal.c:139: for(ADC[0]=0.0, j=0; j<1024; j++)
	clr	a
	mov	_main_ADC_1_36,a
	mov	(_main_ADC_1_36 + 1),a
	mov	(_main_ADC_1_36 + 2),a
	mov	(_main_ADC_1_36 + 3),a
	mov	_main_j_1_36,a
	mov	(_main_j_1_36 + 1),a
L008006?:
	mov	a,#0x100 - 0x04
	add	a,(_main_j_1_36 + 1)
	jc	L008009?
;	adc_two_point_cal.c:141: ADC[0]+=Read_ADC_Channel(1);
	mov	_main_sloc0_1_0,_main_ADC_1_36
	mov	(_main_sloc0_1_0 + 1),(_main_ADC_1_36 + 1)
	mov	(_main_sloc0_1_0 + 2),(_main_ADC_1_36 + 2)
	mov	(_main_sloc0_1_0 + 3),(_main_ADC_1_36 + 3)
	mov	dpl,#0x01
	lcall	_Read_ADC_Channel
	lcall	___sint2fs
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	dpl,_main_sloc0_1_0
	mov	dph,(_main_sloc0_1_0 + 1)
	mov	b,(_main_sloc0_1_0 + 2)
	mov	a,(_main_sloc0_1_0 + 3)
	lcall	___fsadd
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	mov	_main_ADC_1_36,r2
	mov	(_main_ADC_1_36 + 1),r3
	mov	(_main_ADC_1_36 + 2),r4
	mov	(_main_ADC_1_36 + 3),r5
;	adc_two_point_cal.c:139: for(ADC[0]=0.0, j=0; j<1024; j++)
	inc	_main_j_1_36
	clr	a
	cjne	a,_main_j_1_36,L008006?
	inc	(_main_j_1_36 + 1)
	sjmp	L008006?
L008009?:
;	adc_two_point_cal.c:143: ADC[0]/=j;
	mov	_main_sloc0_1_0,_main_ADC_1_36
	mov	(_main_sloc0_1_0 + 1),(_main_ADC_1_36 + 1)
	mov	(_main_sloc0_1_0 + 2),(_main_ADC_1_36 + 2)
	mov	(_main_sloc0_1_0 + 3),(_main_ADC_1_36 + 3)
	mov	dpl,_main_j_1_36
	mov	dph,(_main_j_1_36 + 1)
	lcall	___uint2fs
	mov	r6,dpl
	mov	r7,dph
	mov	r2,b
	mov	r3,a
	push	ar6
	push	ar7
	push	ar2
	push	ar3
	mov	dpl,_main_sloc0_1_0
	mov	dph,(_main_sloc0_1_0 + 1)
	mov	b,(_main_sloc0_1_0 + 2)
	mov	a,(_main_sloc0_1_0 + 3)
	lcall	___fsdiv
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	mov	_main_ADC_1_36,r2
	mov	(_main_ADC_1_36 + 1),r3
	mov	(_main_ADC_1_36 + 2),r4
	mov	(_main_ADC_1_36 + 3),r5
;	adc_two_point_cal.c:145: for(ADC[1]=0.0, j=0; j<1024; j++)
	clr	a
	mov	(_main_ADC_1_36 + 0x0004),a
	mov	((_main_ADC_1_36 + 0x0004) + 1),a
	mov	((_main_ADC_1_36 + 0x0004) + 2),a
	mov	((_main_ADC_1_36 + 0x0004) + 3),a
	mov	_main_j_1_36,a
	mov	(_main_j_1_36 + 1),a
L008010?:
	mov	a,#0x100 - 0x04
	add	a,(_main_j_1_36 + 1)
	jc	L008013?
;	adc_two_point_cal.c:147: ADC[1]+=Read_ADC_Channel(2);
	mov	_main_sloc0_1_0,(_main_ADC_1_36 + 0x0004)
	mov	(_main_sloc0_1_0 + 1),((_main_ADC_1_36 + 0x0004) + 1)
	mov	(_main_sloc0_1_0 + 2),((_main_ADC_1_36 + 0x0004) + 2)
	mov	(_main_sloc0_1_0 + 3),((_main_ADC_1_36 + 0x0004) + 3)
	mov	dpl,#0x02
	lcall	_Read_ADC_Channel
	lcall	___sint2fs
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	dpl,_main_sloc0_1_0
	mov	dph,(_main_sloc0_1_0 + 1)
	mov	b,(_main_sloc0_1_0 + 2)
	mov	a,(_main_sloc0_1_0 + 3)
	lcall	___fsadd
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	mov	(_main_ADC_1_36 + 0x0004),r2
	mov	((_main_ADC_1_36 + 0x0004) + 1),r3
	mov	((_main_ADC_1_36 + 0x0004) + 2),r4
	mov	((_main_ADC_1_36 + 0x0004) + 3),r5
;	adc_two_point_cal.c:145: for(ADC[1]=0.0, j=0; j<1024; j++)
	inc	_main_j_1_36
	clr	a
	cjne	a,_main_j_1_36,L008010?
	inc	(_main_j_1_36 + 1)
	sjmp	L008010?
L008013?:
;	adc_two_point_cal.c:149: ADC[1]/=j;
	mov	_main_sloc0_1_0,(_main_ADC_1_36 + 0x0004)
	mov	(_main_sloc0_1_0 + 1),((_main_ADC_1_36 + 0x0004) + 1)
	mov	(_main_sloc0_1_0 + 2),((_main_ADC_1_36 + 0x0004) + 2)
	mov	(_main_sloc0_1_0 + 3),((_main_ADC_1_36 + 0x0004) + 3)
	mov	dpl,_main_j_1_36
	mov	dph,(_main_j_1_36 + 1)
	lcall	___uint2fs
	mov	r6,dpl
	mov	r7,dph
	mov	r2,b
	mov	r3,a
	push	ar6
	push	ar7
	push	ar2
	push	ar3
	mov	dpl,_main_sloc0_1_0
	mov	dph,(_main_sloc0_1_0 + 1)
	mov	b,(_main_sloc0_1_0 + 2)
	mov	a,(_main_sloc0_1_0 + 3)
	lcall	___fsdiv
	mov	_main_sloc0_1_0,dpl
	mov	(_main_sloc0_1_0 + 1),dph
	mov	(_main_sloc0_1_0 + 2),b
	mov	(_main_sloc0_1_0 + 3),a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	mov	(_main_ADC_1_36 + 0x0004),_main_sloc0_1_0
	mov	((_main_ADC_1_36 + 0x0004) + 1),(_main_sloc0_1_0 + 1)
	mov	((_main_ADC_1_36 + 0x0004) + 2),(_main_sloc0_1_0 + 2)
	mov	((_main_ADC_1_36 + 0x0004) + 3),(_main_sloc0_1_0 + 3)
;	adc_two_point_cal.c:151: m=(V[0]-V[1])/(ADC[0]-ADC[1]);
	push	(_main_V_1_36 + 0x0004)
	push	((_main_V_1_36 + 0x0004) + 1)
	push	((_main_V_1_36 + 0x0004) + 2)
	push	((_main_V_1_36 + 0x0004) + 3)
	mov	dpl,_main_V_1_36
	mov	dph,(_main_V_1_36 + 1)
	mov	b,(_main_V_1_36 + 2)
	mov	a,(_main_V_1_36 + 3)
	lcall	___fssub
	mov	_main_sloc1_1_0,dpl
	mov	(_main_sloc1_1_0 + 1),dph
	mov	(_main_sloc1_1_0 + 2),b
	mov	(_main_sloc1_1_0 + 3),a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	(_main_sloc0_1_0 + 2)
	push	(_main_sloc0_1_0 + 3)
	mov	dpl,_main_ADC_1_36
	mov	dph,(_main_ADC_1_36 + 1)
	mov	b,(_main_ADC_1_36 + 2)
	mov	a,(_main_ADC_1_36 + 3)
	lcall	___fssub
	mov	r4,dpl
	mov	r5,dph
	mov	r2,b
	mov	r3,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	push	ar4
	push	ar5
	push	ar2
	push	ar3
	mov	dpl,_main_sloc1_1_0
	mov	dph,(_main_sloc1_1_0 + 1)
	mov	b,(_main_sloc1_1_0 + 2)
	mov	a,(_main_sloc1_1_0 + 3)
	lcall	___fsdiv
	mov	_main_m_1_36,dpl
	mov	(_main_m_1_36 + 1),dph
	mov	(_main_m_1_36 + 2),b
	mov	(_main_m_1_36 + 3),a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	adc_two_point_cal.c:152: v0=V[0]-m*ADC[0];
	mov	_main_sloc1_1_0,_main_V_1_36
	mov	(_main_sloc1_1_0 + 1),(_main_V_1_36 + 1)
	mov	(_main_sloc1_1_0 + 2),(_main_V_1_36 + 2)
	mov	(_main_sloc1_1_0 + 3),(_main_V_1_36 + 3)
	push	_main_ADC_1_36
	push	(_main_ADC_1_36 + 1)
	push	(_main_ADC_1_36 + 2)
	push	(_main_ADC_1_36 + 3)
	mov	dpl,_main_m_1_36
	mov	dph,(_main_m_1_36 + 1)
	mov	b,(_main_m_1_36 + 2)
	mov	a,(_main_m_1_36 + 3)
	lcall	___fsmul
	mov	r4,dpl
	mov	r5,dph
	mov	r2,b
	mov	r3,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	push	ar4
	push	ar5
	push	ar2
	push	ar3
	mov	dpl,_main_sloc1_1_0
	mov	dph,(_main_sloc1_1_0 + 1)
	mov	b,(_main_sloc1_1_0 + 2)
	mov	a,(_main_sloc1_1_0 + 3)
	lcall	___fssub
	mov	_main_v0_1_36,dpl
	mov	(_main_v0_1_36 + 1),dph
	mov	(_main_v0_1_36 + 2),b
	mov	(_main_v0_1_36 + 3),a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	adc_two_point_cal.c:154: printf("\nV=m*ADC+v0 where m=%e v0=%e\n\n", m, v0);
	push	_main_v0_1_36
	push	(_main_v0_1_36 + 1)
	push	(_main_v0_1_36 + 2)
	push	(_main_v0_1_36 + 3)
	push	_main_m_1_36
	push	(_main_m_1_36 + 1)
	push	(_main_m_1_36 + 2)
	push	(_main_m_1_36 + 3)
	mov	a,#__str_5
	push	acc
	mov	a,#(__str_5 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
;	adc_two_point_cal.c:156: while(1)
L008004?:
;	adc_two_point_cal.c:158: for(result=0.0, j=0; j<128; j++)
	clr	a
	mov	_main_result_1_36,a
	mov	(_main_result_1_36 + 1),a
	mov	(_main_result_1_36 + 2),a
	mov	(_main_result_1_36 + 3),a
	mov	_main_j_1_36,a
	mov	(_main_j_1_36 + 1),a
L008014?:
	clr	c
	mov	a,_main_j_1_36
	subb	a,#0x80
	mov	a,(_main_j_1_36 + 1)
	subb	a,#0x00
	jnc	L008017?
;	adc_two_point_cal.c:160: result+=Read_ADC_Channel(0);
	mov	dpl,#0x00
	lcall	_Read_ADC_Channel
	lcall	___sint2fs
	mov	r4,dpl
	mov	r5,dph
	mov	r2,b
	mov	r3,a
	push	ar4
	push	ar5
	push	ar2
	push	ar3
	mov	dpl,_main_result_1_36
	mov	dph,(_main_result_1_36 + 1)
	mov	b,(_main_result_1_36 + 2)
	mov	a,(_main_result_1_36 + 3)
	lcall	___fsadd
	mov	_main_result_1_36,dpl
	mov	(_main_result_1_36 + 1),dph
	mov	(_main_result_1_36 + 2),b
	mov	(_main_result_1_36 + 3),a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	adc_two_point_cal.c:158: for(result=0.0, j=0; j<128; j++)
	inc	_main_j_1_36
	clr	a
	cjne	a,_main_j_1_36,L008014?
	inc	(_main_j_1_36 + 1)
	sjmp	L008014?
L008017?:
;	adc_two_point_cal.c:162: result/=j;
	mov	dpl,_main_j_1_36
	mov	dph,(_main_j_1_36 + 1)
	lcall	___uint2fs
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	dpl,_main_result_1_36
	mov	dph,(_main_result_1_36 + 1)
	mov	b,(_main_result_1_36 + 2)
	mov	a,(_main_result_1_36 + 3)
	lcall	___fsdiv
	mov	_main_result_1_36,dpl
	mov	(_main_result_1_36 + 1),dph
	mov	(_main_result_1_36 + 2),b
	mov	(_main_result_1_36 + 3),a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	adc_two_point_cal.c:164: printf("ADC=");
	mov	a,#__str_6
	push	acc
	mov	a,#(__str_6 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	adc_two_point_cal.c:165: for(mask=0x200; mask!=0; mask>>=1) putchar((((int)result)&mask)?'1':'0');
	mov	r2,#0x00
	mov	r3,#0x02
L008018?:
	cjne	r2,#0x00,L008046?
	cjne	r3,#0x00,L008046?
	sjmp	L008021?
L008046?:
	mov	dpl,_main_result_1_36
	mov	dph,(_main_result_1_36 + 1)
	mov	b,(_main_result_1_36 + 2)
	mov	a,(_main_result_1_36 + 3)
	push	ar2
	push	ar3
	lcall	___fs2sint
	mov	a,dpl
	mov	b,dph
	pop	ar3
	pop	ar2
	anl	a,r2
	mov	r4,a
	mov	a,b
	anl	a,r3
	mov	r5,a
	orl	a,r4
	jz	L008024?
	mov	r4,#0x31
	sjmp	L008025?
L008024?:
	mov	r4,#0x30
L008025?:
	mov	dpl,r4
	push	ar2
	push	ar3
	lcall	_putchar
	pop	ar3
	pop	ar2
	mov	a,r3
	clr	c
	rrc	a
	xch	a,r2
	rrc	a
	xch	a,r2
	mov	r3,a
	sjmp	L008018?
L008021?:
;	adc_two_point_cal.c:166: printf(", 0x%04x, %5.3fV\r", (int)result, result*m+v0);
	push	_main_m_1_36
	push	(_main_m_1_36 + 1)
	push	(_main_m_1_36 + 2)
	push	(_main_m_1_36 + 3)
	mov	dpl,_main_result_1_36
	mov	dph,(_main_result_1_36 + 1)
	mov	b,(_main_result_1_36 + 2)
	mov	a,(_main_result_1_36 + 3)
	lcall	___fsmul
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	push	_main_v0_1_36
	push	(_main_v0_1_36 + 1)
	push	(_main_v0_1_36 + 2)
	push	(_main_v0_1_36 + 3)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,r5
	lcall	___fsadd
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	mov	dpl,_main_result_1_36
	mov	dph,(_main_result_1_36 + 1)
	mov	b,(_main_result_1_36 + 2)
	mov	a,(_main_result_1_36 + 3)
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	lcall	___fs2sint
	mov	r6,dpl
	mov	r7,dph
	push	ar6
	push	ar7
	mov	a,#__str_7
	push	acc
	mov	a,#(__str_7 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf7
	mov	sp,a
;	adc_two_point_cal.c:167: waitms(100);
	mov	dptr,#0x0064
	lcall	_waitms
;	adc_two_point_cal.c:168: if(RI)
	jb	_RI,L008048?
	ljmp	L008004?
L008048?:
;	adc_two_point_cal.c:172: _endasm;
	
	   ljmp 0
	   
	ljmp	L008004?
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
__str_0:
	db 0x0A
	db 0x0A
	db 'AT89LP51Rx2 ADC test program with self calibration:'
	db 0x0A
	db 0x00
__str_1:
	db '   1) Connect a 150 ohm resistor from P0.1 to VDD'
	db 0x0A
	db 0x00
__str_2:
	db '   2) Connect a 150 ohm resistor from P0.1 to P0.2'
	db 0x0A
	db 0x00
__str_3:
	db '   3) Connect a 150 ohm resistor from P0.2 to GND'
	db 0x0A
	db 0x00
__str_4:
	db 'Pick three resistors that are almost identical (less than 0.'
	db '1%% difference)'
	db 0x0A
	db 0x00
__str_5:
	db 0x0A
	db 'V=m*ADC+v0 where m=%e v0=%e'
	db 0x0A
	db 0x0A
	db 0x00
__str_6:
	db 'ADC='
	db 0x00
__str_7:
	db ', 0x%04x, %5.3fV'
	db 0x0D
	db 0x00

	CSEG

end
