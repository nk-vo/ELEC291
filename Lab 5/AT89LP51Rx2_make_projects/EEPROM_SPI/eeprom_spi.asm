;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1069 (Apr 23 2015) (MSVC)
; This file was generated Fri Mar 11 18:37:38 2022
;--------------------------------------------------------
$name eeprom_spi
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
	public _main_pattern_1_61
	public _main
	public _Test
	public _waitms
	public _wait_us
	public __c51_external_startup
	public _SeedCnt
	public _ErrCnt
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
_ErrCnt:
	ds 2
_SeedCnt:
	ds 2
_main_i_1_61:
	ds 1
_main_j_1_61:
	ds 1
_main_k_1_61:
	ds 2
_main_m_1_61:
	ds 2
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
;	eeprom_spi.c:19: unsigned char _c51_external_startup(void)
;	-----------------------------------------
;	 function _c51_external_startup
;	-----------------------------------------
__c51_external_startup:
	using	0
;	eeprom_spi.c:21: AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
	mov	_AUXR,#0x11
;	eeprom_spi.c:23: P0M0=0x00; P0M1=0x00;    
	mov	_P0M0,#0x00
	mov	_P0M1,#0x00
;	eeprom_spi.c:24: P1M0=0x00; P1M1=0x00;    
	mov	_P1M0,#0x00
	mov	_P1M1,#0x00
;	eeprom_spi.c:25: P2M0=0x00; P2M1=0x00;//P2M1=0b_0000_1011;    
	mov	_P2M0,#0x00
	mov	_P2M1,#0x00
;	eeprom_spi.c:26: P3M0=0x00; P3M1=0x00;    
	mov	_P3M0,#0x00
	mov	_P3M1,#0x00
;	eeprom_spi.c:27: PCON|=0x80;
	orl	_PCON,#0x80
;	eeprom_spi.c:28: SCON = 0x52;
	mov	_SCON,#0x52
;	eeprom_spi.c:29: BDRCON=0;
	mov	_BDRCON,#0x00
;	eeprom_spi.c:30: BRL=BRG_VAL;
	mov	_BRL,#0xF4
;	eeprom_spi.c:31: BDRCON=BRR|TBCK|RBCK|SPD;
	mov	_BDRCON,#0x1E
;	eeprom_spi.c:33: CLKREG=0x00; // TPS=0000B
	mov	_CLKREG,#0x00
;	eeprom_spi.c:35: return 0;
	mov	dpl,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'wait_us'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;j                         Allocated to registers r2 r3 
;------------------------------------------------------------
;	eeprom_spi.c:38: void wait_us (unsigned char x)
;	-----------------------------------------
;	 function wait_us
;	-----------------------------------------
_wait_us:
	mov	r2,dpl
;	eeprom_spi.c:42: TR0=0; // Stop timer 0
	clr	_TR0
;	eeprom_spi.c:43: TMOD&=0xf0; // Clear the configuration bits for timer 0
	anl	_TMOD,#0xF0
;	eeprom_spi.c:44: TMOD|=0x01; // Mode 1: 16-bit timer
	orl	_TMOD,#0x01
;	eeprom_spi.c:46: if(x>5) x-=5; // Subtract the overhead
	mov	a,r2
	add	a,#0xff - 0x05
	jnc	L003002?
	mov	a,r2
	add	a,#0xfb
	mov	r2,a
	sjmp	L003003?
L003002?:
;	eeprom_spi.c:47: else x=1;
	mov	r2,#0x01
L003003?:
;	eeprom_spi.c:49: j=-ONE_USEC*x;
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
;	eeprom_spi.c:50: TF0=0;
	clr	_TF0
;	eeprom_spi.c:51: TH0=j/0x100;
	mov	ar4,r3
	mov	r5,#0x00
	mov	_TH0,r4
;	eeprom_spi.c:52: TL0=j%0x100;
	mov	r3,#0x00
	mov	_TL0,r2
;	eeprom_spi.c:53: TR0=1; // Start timer 0
	setb	_TR0
;	eeprom_spi.c:54: while(TF0==0); //Wait for overflow
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
;	eeprom_spi.c:57: void waitms (unsigned int ms)
;	-----------------------------------------
;	 function waitms
;	-----------------------------------------
_waitms:
	mov	r2,dpl
	mov	r3,dph
;	eeprom_spi.c:61: for(j=0; j<ms; j++)
	mov	r4,#0x00
	mov	r5,#0x00
L004005?:
	clr	c
	mov	a,r4
	subb	a,r2
	mov	a,r5
	subb	a,r3
	jnc	L004009?
;	eeprom_spi.c:62: for (k=0; k<4; k++) wait_us(250);
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
;	eeprom_spi.c:61: for(j=0; j<ms; j++)
	inc	r4
	cjne	r4,#0x00,L004005?
	inc	r5
	sjmp	L004005?
L004009?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Test'
;------------------------------------------------------------
;testval                   Allocated to registers r2 
;j                         Allocated to registers r7 
;k                         Allocated to registers r5 r6 
;cnt                       Allocated to registers r3 r4 
;------------------------------------------------------------
;	eeprom_spi.c:65: void Test (unsigned char testval)
;	-----------------------------------------
;	 function Test
;	-----------------------------------------
_Test:
;	eeprom_spi.c:71: FT93C66_Write_All(testval);
	mov  r2,dpl
	push	ar2
	lcall	_FT93C66_Write_All
	pop	ar2
;	eeprom_spi.c:73: for(k=0; k<0x200; k++)
	mov	r3,#0x00
	mov	r4,#0x00
	mov	r5,#0x00
	mov	r6,#0x00
L005008?:
	mov	a,#0x100 - 0x02
	add	a,r6
	jnc	L005021?
	ret
L005021?:
;	eeprom_spi.c:75: j=FT93C66_Read(k);
	mov	dpl,r5
	mov	dph,r6
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	lcall	_FT93C66_Read
	mov	r7,dpl
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
;	eeprom_spi.c:76: if(j!=testval)
	mov	a,r7
	cjne	a,ar2,L005022?
	ljmp	L005010?
L005022?:
;	eeprom_spi.c:78: if(cnt==0) printf("\n0x%02x failed at:", testval);
	mov	a,r3
	orl	a,r4
	jnz	L005002?
	mov	ar7,r2
	mov	r0,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	push	ar7
	push	ar0
	mov	a,#__str_0
	push	acc
	mov	a,#(__str_0 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
L005002?:
;	eeprom_spi.c:79: ErrCnt++;
	inc	_ErrCnt
	clr	a
	cjne	a,_ErrCnt,L005024?
	inc	(_ErrCnt + 1)
L005024?:
;	eeprom_spi.c:80: if( ((cnt&0x0f)==0) && (cnt>0) ) printf("\n               ");
	mov	a,r3
	anl	a,#0x0F
	jz	L005026?
	sjmp	L005004?
L005026?:
	mov	a,r3
	orl	a,r4
	jz	L005004?
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
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
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
L005004?:
;	eeprom_spi.c:81: cnt++;
	inc	r3
	cjne	r3,#0x00,L005028?
	inc	r4
L005028?:
;	eeprom_spi.c:82: printf(" %03x", k);
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	push	ar5
	push	ar6
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
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
L005010?:
;	eeprom_spi.c:73: for(k=0; k<0x200; k++)
	inc	r5
	cjne	r5,#0x00,L005029?
	inc	r6
L005029?:
	ljmp	L005008?
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;i                         Allocated with name '_main_i_1_61'
;j                         Allocated with name '_main_j_1_61'
;k                         Allocated with name '_main_k_1_61'
;m                         Allocated with name '_main_m_1_61'
;------------------------------------------------------------
;	eeprom_spi.c:88: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	eeprom_spi.c:90: volatile unsigned char i=0, j=0;
	mov	_main_i_1_61,#0x00
	mov	_main_j_1_61,#0x00
;	eeprom_spi.c:98: waitms(500);
	mov	dptr,#0x01F4
	lcall	_waitms
;	eeprom_spi.c:100: while(1)
L006038?:
;	eeprom_spi.c:102: FT93C66_Init();
	lcall	_FT93C66_Init
;	eeprom_spi.c:115: "Option: ");
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
;	eeprom_spi.c:117: while(RI==0)
L006001?:
	jb	_RI,L006003?
;	eeprom_spi.c:119: SeedCnt++;
	inc	_SeedCnt
	clr	a
	cjne	a,_SeedCnt,L006001?
	inc	(_SeedCnt + 1)
	sjmp	L006001?
L006003?:
;	eeprom_spi.c:122: switch(getchar())
	lcall	_getchar
	mov	r2,dpl
	clr	c
	mov	a,r2
	xrl	a,#0x80
	subb	a,#0xb1
	jc	L006038?
	mov	a,#(0x38 ^ 0x80)
	mov	b,r2
	xrl	b,#0x80
	subb	a,b
	jc	L006038?
	mov	a,r2
	add	a,#0xcf
	mov	r2,a
	add	a,acc
	add	a,r2
	mov	dptr,#L006073?
	jmp	@a+dptr
L006073?:
	ljmp	L006004?
	ljmp	L006008?
	ljmp	L006020?
	ljmp	L006021?
	ljmp	L006022?
	ljmp	L006030?
	ljmp	L006033?
	ljmp	L006034?
;	eeprom_spi.c:124: case '1':
L006004?:
;	eeprom_spi.c:125: FT93C66_Write_Enable();
	lcall	_FT93C66_Write_Enable
;	eeprom_spi.c:127: ErrCnt=0;		
	clr	a
	mov	_ErrCnt,a
	mov	(_ErrCnt + 1),a
;	eeprom_spi.c:128: printf("\nPattern testing all memory locations.\n");
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
;	eeprom_spi.c:130: for(i=0; i<sizeof(pattern); i++) Test(pattern[i]);
	mov	_main_i_1_61,#0x00
L006040?:
	mov	a,#0x100 - 0x18
	add	a,_main_i_1_61
	jc	L006043?
	mov	a,_main_i_1_61
	mov	dptr,#_main_pattern_1_61
	movc	a,@a+dptr
	mov	dpl,a
	lcall	_Test
	inc	_main_i_1_61
	sjmp	L006040?
L006043?:
;	eeprom_spi.c:131: if(ErrCnt>0)
	mov	a,_ErrCnt
	orl	a,(_ErrCnt + 1)
	jz	L006006?
;	eeprom_spi.c:133: printf("\nThere were %d ERROR(s).\n", ErrCnt);
	push	_ErrCnt
	push	(_ErrCnt + 1)
	mov	a,#__str_5
	push	acc
	mov	a,#(__str_5 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
	sjmp	L006007?
L006006?:
;	eeprom_spi.c:137: printf("\nNo errors.  Memory works fine!\n");
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
L006007?:
;	eeprom_spi.c:140: FT93C66_Write_Disable();
	lcall	_FT93C66_Write_Disable
;	eeprom_spi.c:141: break;
	ljmp	L006038?
;	eeprom_spi.c:143: case '2':
L006008?:
;	eeprom_spi.c:144: FT93C66_Write_Enable();
	lcall	_FT93C66_Write_Enable
;	eeprom_spi.c:145: printf("\nRandom testing all memory locations.\n");
	mov	a,#__str_7
	push	acc
	mov	a,#(__str_7 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:146: srand(SeedCnt);
	mov	dpl,_SeedCnt
	mov	dph,(_SeedCnt + 1)
	lcall	_srand
;	eeprom_spi.c:147: for(k=0; k<0x200; k++)
	clr	a
	mov	_main_k_1_61,a
	mov	(_main_k_1_61 + 1),a
L006013?:
	mov	a,#0x100 - 0x02
	add	a,(_main_k_1_61 + 1)
	jnc	L006076?
	ljmp	L006016?
L006076?:
;	eeprom_spi.c:149: i=rand()&0xff;
	lcall	_rand
	mov	a,dpl
	mov	b,dph
	mov	r2,a
	mov	_main_i_1_61,r2
;	eeprom_spi.c:150: FT93C66_Write(k, i);
	mov	_FT93C66_Write_PARM_2,_main_i_1_61
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Write
;	eeprom_spi.c:151: j=FT93C66_Read(k);
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Read
	mov	_main_j_1_61,dpl
;	eeprom_spi.c:152: if((k&0xf)==0)
	mov	a,_main_k_1_61
	anl	a,#0x0F
	jz	L006078?
	sjmp	L006010?
L006078?:
;	eeprom_spi.c:154: printf("\n%03x: ", k);
	push	_main_k_1_61
	push	(_main_k_1_61 + 1)
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
L006010?:
;	eeprom_spi.c:156: printf(" %02x", j);			
	mov	r2,_main_j_1_61
	mov	r3,#0x00
	push	ar2
	push	ar3
	mov	a,#__str_9
	push	acc
	mov	a,#(__str_9 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	eeprom_spi.c:157: if(j!=i) break;
	mov	a,_main_i_1_61
	cjne	a,_main_j_1_61,L006016?
;	eeprom_spi.c:147: for(k=0; k<0x200; k++)
	mov	a,#0x01
	add	a,_main_k_1_61
	mov	_main_k_1_61,a
	clr	a
	addc	a,(_main_k_1_61 + 1)
	mov	(_main_k_1_61 + 1),a
	ljmp	L006013?
L006016?:
;	eeprom_spi.c:159: if(j!=i)
	mov	a,_main_i_1_61
	cjne	a,_main_j_1_61,L006081?
	sjmp	L006018?
L006081?:
;	eeprom_spi.c:161: printf("\nERROR at location %03x.  Wrote %02x but read %02x\n", k, i, j);
	mov	r2,_main_j_1_61
	mov	r3,#0x00
	mov	r4,_main_i_1_61
	mov	r5,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_k_1_61
	push	(_main_k_1_61 + 1)
	mov	a,#__str_10
	push	acc
	mov	a,#(__str_10 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf7
	mov	sp,a
	sjmp	L006019?
L006018?:
;	eeprom_spi.c:165: printf("\nTest pass\n");
	mov	a,#__str_11
	push	acc
	mov	a,#(__str_11 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
L006019?:
;	eeprom_spi.c:167: FT93C66_Write_Disable();
	lcall	_FT93C66_Write_Disable
;	eeprom_spi.c:168: break;
	ljmp	L006038?
;	eeprom_spi.c:170: case '3':
L006020?:
;	eeprom_spi.c:171: printf("\nAddress: ");
	mov	a,#__str_12
	push	acc
	mov	a,#(__str_12 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:172: scanf("%x", &k);
	mov	a,#_main_k_1_61
	push	acc
	mov	a,#(_main_k_1_61 >> 8)
	push	acc
	mov	a,#0x40
	push	acc
	mov	a,#__str_13
	push	acc
	mov	a,#(__str_13 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_scanf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	eeprom_spi.c:173: waitms(10);
	mov	dptr,#0x000A
	lcall	_waitms
;	eeprom_spi.c:174: printf("\nValue: ");
	mov	a,#__str_14
	push	acc
	mov	a,#(__str_14 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:175: scanf("%x", &m);
	mov	a,#_main_m_1_61
	push	acc
	mov	a,#(_main_m_1_61 >> 8)
	push	acc
	mov	a,#0x40
	push	acc
	mov	a,#__str_13
	push	acc
	mov	a,#(__str_13 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_scanf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	eeprom_spi.c:177: FT93C66_Write_Enable();
	lcall	_FT93C66_Write_Enable
;	eeprom_spi.c:178: FT93C66_Write(k, m);
	mov	_FT93C66_Write_PARM_2,_main_m_1_61
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Write
;	eeprom_spi.c:179: j=FT93C66_Read(k);
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Read
	mov	_main_j_1_61,dpl
;	eeprom_spi.c:180: FT93C66_Write_Disable();
	lcall	_FT93C66_Write_Disable
;	eeprom_spi.c:182: printf("\n[%03x]: %02x\n", k, j);			
	mov	r2,_main_j_1_61
	mov	r3,#0x00
	push	ar2
	push	ar3
	push	_main_k_1_61
	push	(_main_k_1_61 + 1)
	mov	a,#__str_15
	push	acc
	mov	a,#(__str_15 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	eeprom_spi.c:184: break;
	ljmp	L006038?
;	eeprom_spi.c:186: case '4':
L006021?:
;	eeprom_spi.c:187: printf("\nAddress: ");
	mov	a,#__str_12
	push	acc
	mov	a,#(__str_12 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:188: scanf("%x", &k);
	mov	a,#_main_k_1_61
	push	acc
	mov	a,#(_main_k_1_61 >> 8)
	push	acc
	mov	a,#0x40
	push	acc
	mov	a,#__str_13
	push	acc
	mov	a,#(__str_13 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_scanf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	eeprom_spi.c:189: j=FT93C66_Read(k);
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Read
	mov	_main_j_1_61,dpl
;	eeprom_spi.c:190: printf("\n[%03x]: %02x\n", k, j);			
	mov	r2,_main_j_1_61
	mov	r3,#0x00
	push	ar2
	push	ar3
	push	_main_k_1_61
	push	(_main_k_1_61 + 1)
	mov	a,#__str_15
	push	acc
	mov	a,#(__str_15 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	eeprom_spi.c:191: break;
	ljmp	L006038?
;	eeprom_spi.c:193: case '5':
L006022?:
;	eeprom_spi.c:194: FT93C66_Write_Enable();
	lcall	_FT93C66_Write_Enable
;	eeprom_spi.c:195: printf("\nLocation to test: ");
	mov	a,#__str_16
	push	acc
	mov	a,#(__str_16 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:196: scanf("%x", &k);
	mov	a,#_main_k_1_61
	push	acc
	mov	a,#(_main_k_1_61 >> 8)
	push	acc
	mov	a,#0x40
	push	acc
	mov	a,#__str_13
	push	acc
	mov	a,#(__str_13 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_scanf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	eeprom_spi.c:198: i=0;
;	eeprom_spi.c:199: ErrCnt=0;
	clr	a
	mov	_main_i_1_61,a
	mov	_ErrCnt,a
	mov	(_ErrCnt + 1),a
;	eeprom_spi.c:200: do
L006027?:
;	eeprom_spi.c:202: FT93C66_Write(k, i);
	mov	_FT93C66_Write_PARM_2,_main_i_1_61
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Write
;	eeprom_spi.c:203: j=FT93C66_Read(k);
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Read
	mov	_main_j_1_61,dpl
;	eeprom_spi.c:204: if((i&0xf)==0)
	mov	a,_main_i_1_61
	anl	a,#0x0F
	jz	L006083?
	sjmp	L006024?
L006083?:
;	eeprom_spi.c:206: printf("\n%03x: ", i);
	mov	r2,_main_i_1_61
	mov	r3,#0x00
	push	ar2
	push	ar3
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
L006024?:
;	eeprom_spi.c:208: printf(" %02x", j);			
	mov	r2,_main_j_1_61
	mov	r3,#0x00
	push	ar2
	push	ar3
	mov	a,#__str_9
	push	acc
	mov	a,#(__str_9 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	eeprom_spi.c:209: if(j!=i) ErrCnt++;
	mov	a,_main_i_1_61
	cjne	a,_main_j_1_61,L006084?
	sjmp	L006026?
L006084?:
	inc	_ErrCnt
	clr	a
	cjne	a,_ErrCnt,L006085?
	inc	(_ErrCnt + 1)
L006085?:
L006026?:
;	eeprom_spi.c:210: i++;
	inc	_main_i_1_61
;	eeprom_spi.c:211: } while (i!=0);
	mov	a,_main_i_1_61
	jnz	L006027?
;	eeprom_spi.c:212: printf("\nThere were %d error(s).\n", ErrCnt);
	push	_ErrCnt
	push	(_ErrCnt + 1)
	mov	a,#__str_17
	push	acc
	mov	a,#(__str_17 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	eeprom_spi.c:214: FT93C66_Write_Disable();
	lcall	_FT93C66_Write_Disable
;	eeprom_spi.c:215: break;
	ljmp	L006038?
;	eeprom_spi.c:217: case '6':
L006030?:
;	eeprom_spi.c:218: printf("\nMemory contains:\n");
	mov	a,#__str_18
	push	acc
	mov	a,#(__str_18 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:219: for(k=0; k<0x200; k++)
	clr	a
	mov	_main_k_1_61,a
	mov	(_main_k_1_61 + 1),a
L006044?:
	mov	a,#0x100 - 0x02
	add	a,(_main_k_1_61 + 1)
	jc	L006047?
;	eeprom_spi.c:221: j=FT93C66_Read(k);
	mov	dpl,_main_k_1_61
	mov	dph,(_main_k_1_61 + 1)
	lcall	_FT93C66_Read
	mov	_main_j_1_61,dpl
;	eeprom_spi.c:222: if((k&0xf)==0)
	mov	a,_main_k_1_61
	anl	a,#0x0F
	jz	L006089?
	sjmp	L006032?
L006089?:
;	eeprom_spi.c:224: printf("\n%03x: ", k);
	push	_main_k_1_61
	push	(_main_k_1_61 + 1)
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
L006032?:
;	eeprom_spi.c:226: printf(" %02x", j);			
	mov	r2,_main_j_1_61
	mov	r3,#0x00
	push	ar2
	push	ar3
	mov	a,#__str_9
	push	acc
	mov	a,#(__str_9 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	eeprom_spi.c:219: for(k=0; k<0x200; k++)
	mov	a,#0x01
	add	a,_main_k_1_61
	mov	_main_k_1_61,a
	clr	a
	addc	a,(_main_k_1_61 + 1)
	mov	(_main_k_1_61 + 1),a
	sjmp	L006044?
L006047?:
;	eeprom_spi.c:228: printf("\n");
	mov	a,#__str_19
	push	acc
	mov	a,#(__str_19 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:229: break;
	ljmp	L006038?
;	eeprom_spi.c:231: case '7':
L006033?:
;	eeprom_spi.c:232: FT93C66_Write_Enable();
	lcall	_FT93C66_Write_Enable
;	eeprom_spi.c:233: printf("\nValue: ");
	mov	a,#__str_14
	push	acc
	mov	a,#(__str_14 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	eeprom_spi.c:234: scanf("%x", &m);
	mov	a,#_main_m_1_61
	push	acc
	mov	a,#(_main_m_1_61 >> 8)
	push	acc
	mov	a,#0x40
	push	acc
	mov	a,#__str_13
	push	acc
	mov	a,#(__str_13 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_scanf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	eeprom_spi.c:235: FT93C66_Write_All(m);
	mov	dpl,_main_m_1_61
	lcall	_FT93C66_Write_All
;	eeprom_spi.c:236: FT93C66_Write_Disable();
	lcall	_FT93C66_Write_Disable
;	eeprom_spi.c:237: break;
	ljmp	L006038?
;	eeprom_spi.c:239: case '8':
L006034?:
;	eeprom_spi.c:240: FT93C66_Write_Enable();
	lcall	_FT93C66_Write_Enable
;	eeprom_spi.c:241: FT93C66_Erase_All();
	lcall	_FT93C66_Erase_All
;	eeprom_spi.c:242: FT93C66_Write_Disable();
	lcall	_FT93C66_Write_Disable
;	eeprom_spi.c:243: break;
;	eeprom_spi.c:247: }
	ljmp	L006038?
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
__str_0:
	db 0x0A
	db '0x%02x failed at:'
	db 0x00
__str_1:
	db 0x0A
	db '               '
	db 0x00
__str_2:
	db ' %03x'
	db 0x00
_main_pattern_1_61:
	db 0x00	; 0 
	db 0xff	; 255 
	db 0x55	; 85 	U
	db 0xaa	; 170 	ª
	db 0x0f	; 15 
	db 0xf0	; 240 	ð
	db 0x5a	; 90 	Z
	db 0xa5	; 165 	¥
	db 0x01	; 1 
	db 0x02	; 2 
	db 0x04	; 4 
	db 0x08	; 8 
	db 0x10	; 16 
	db 0x20	; 32 
	db 0x40	; 64 
	db 0x80	; 128 	€
	db 0xfe	; 254 	þ
	db 0xfd	; 253 	ý
	db 0xfb	; 251 	û
	db 0xf7	; 247 
	db 0xef	; 239 
	db 0xdf	; 223 
	db 0xbf	; 191 
	db 0x7f	; 127 
__str_3:
	db 0x0A
	db 0x0A
	db 'AT89LP51Rx2 SPI EEPROM test program.'
	db 0x0A
	db 0x0A
	db 'Select option:'
	db 0x0A
	db '   1)'
	db ' Pattern test'
	db 0x0A
	db '   2) Random test'
	db 0x0A
	db '   3) Write Memory location'
	db 0x0A
	db '   4) Read Memory location'
	db 0x0A
	db '   5) Memory Location test'
	db 0x0A
	db '   6) '
	db 'Display Memory'
	db 0x0A
	db '   7) Fill Memory'
	db 0x0A
	db '   8) Erase Memory'
	db 0x0A
	db 'Option: '
	db 0x00
__str_4:
	db 0x0A
	db 'Pattern testing all memory locations.'
	db 0x0A
	db 0x00
__str_5:
	db 0x0A
	db 'There were %d ERROR(s).'
	db 0x0A
	db 0x00
__str_6:
	db 0x0A
	db 'No errors.  Memory works fine!'
	db 0x0A
	db 0x00
__str_7:
	db 0x0A
	db 'Random testing all memory locations.'
	db 0x0A
	db 0x00
__str_8:
	db 0x0A
	db '%03x: '
	db 0x00
__str_9:
	db ' %02x'
	db 0x00
__str_10:
	db 0x0A
	db 'ERROR at location %03x.  Wrote %02x but read %02x'
	db 0x0A
	db 0x00
__str_11:
	db 0x0A
	db 'Test pass'
	db 0x0A
	db 0x00
__str_12:
	db 0x0A
	db 'Address: '
	db 0x00
__str_13:
	db '%x'
	db 0x00
__str_14:
	db 0x0A
	db 'Value: '
	db 0x00
__str_15:
	db 0x0A
	db '[%03x]: %02x'
	db 0x0A
	db 0x00
__str_16:
	db 0x0A
	db 'Location to test: '
	db 0x00
__str_17:
	db 0x0A
	db 'There were %d error(s).'
	db 0x0A
	db 0x00
__str_18:
	db 0x0A
	db 'Memory contains:'
	db 0x0A
	db 0x00
__str_19:
	db 0x0A
	db 0x00

	CSEG

end
