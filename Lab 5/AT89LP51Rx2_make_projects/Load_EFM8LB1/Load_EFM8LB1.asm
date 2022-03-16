;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1069 (Apr 23 2015) (MSVC)
; This file was generated Fri Mar 11 18:35:06 2022
;--------------------------------------------------------
$name Load_EFM8LB1
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
	public _Bootloader
	public _id
	public _main
	public _C2_DeviceErase
	public _C2_PageErase
	public _C2_BlockWrite
	public _C2_BlockRead
	public _C2_GetRevID
	public _C2_GetDevID
	public _C2_Init
	public _C2_ReadSFR
	public _C2_WriteSFR
	public _C2_Reset
	public _C2_WriteDR
	public _C2_ReadDR
	public _C2_WriteAR
	public _C2_ReadAR
	public __c51_external_startup
	public _W_BUF
	public _R_BUF
	public _C2_WriteSFR_PARM_2
	public _C2_PTR
	public _FLASH_ADDR
	public _NUM_BYTES
	public _Timer0us
	public _waitms
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
_NUM_BYTES:
	ds 1
_FLASH_ADDR:
	ds 2
_C2_PTR:
	ds 1
_C2_WriteSFR_PARM_2:
	ds 1
_main_i_1_106:
	ds 2
_main_k_1_106:
	ds 2
_main_sloc0_1_0:
	ds 2
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
	rseg	R_OSEG
	rseg	R_OSEG
	rseg	R_OSEG
	rseg	R_OSEG
;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	rseg R_ISEG
_R_BUF:
	ds 64
_W_BUF:
	ds 64
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
;	Load_EFM8LB1.c:170: unsigned char _c51_external_startup(void)
;	-----------------------------------------
;	 function _c51_external_startup
;	-----------------------------------------
__c51_external_startup:
	using	0
;	Load_EFM8LB1.c:172: AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
	mov	_AUXR,#0x11
;	Load_EFM8LB1.c:174: PCON|=0x80;
	orl	_PCON,#0x80
;	Load_EFM8LB1.c:175: SCON = 0x52;
	mov	_SCON,#0x52
;	Load_EFM8LB1.c:176: BDRCON=0;
	mov	_BDRCON,#0x00
;	Load_EFM8LB1.c:180: BRL=BRG_VAL;
	mov	_BRL,#0xF4
;	Load_EFM8LB1.c:181: BDRCON=BRR|TBCK|RBCK|SPD;
	mov	_BDRCON,#0x1E
;	Load_EFM8LB1.c:183: return 0;
	mov	dpl,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Timer0us'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;j                         Allocated to registers r2 r3 
;------------------------------------------------------------
;	Load_EFM8LB1.c:186: void Timer0us (unsigned char x)
;	-----------------------------------------
;	 function Timer0us
;	-----------------------------------------
_Timer0us:
	mov	r2,dpl
;	Load_EFM8LB1.c:190: TR0=0; // Stop timer 0
	clr	_TR0
;	Load_EFM8LB1.c:191: TMOD&=0xf0; // Clear the configuration bits for timer 0
	anl	_TMOD,#0xF0
;	Load_EFM8LB1.c:192: TMOD|=0x01; // Mode 1: 16-bit timer
	orl	_TMOD,#0x01
;	Load_EFM8LB1.c:194: if(x>5) x-=5; // Subtract the overhead
	mov	a,r2
	add	a,#0xff - 0x05
	jnc	L003002?
	mov	a,r2
	add	a,#0xfb
	mov	r2,a
	sjmp	L003003?
L003002?:
;	Load_EFM8LB1.c:195: else x=1;
	mov	r2,#0x01
L003003?:
;	Load_EFM8LB1.c:197: j=-ONE_USEC*x;
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
;	Load_EFM8LB1.c:198: TF0=0;
	clr	_TF0
;	Load_EFM8LB1.c:199: TH0=j/0x100;
	mov	ar4,r3
	mov	r5,#0x00
	mov	_TH0,r4
;	Load_EFM8LB1.c:200: TL0=j%0x100;
	mov	r3,#0x00
	mov	_TL0,r2
;	Load_EFM8LB1.c:201: TR0=1; // Start timer 0
	setb	_TR0
;	Load_EFM8LB1.c:202: while(TF0==0); //Wait for overflow
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
;	Load_EFM8LB1.c:205: void waitms (unsigned int ms)
;	-----------------------------------------
;	 function waitms
;	-----------------------------------------
_waitms:
	mov	r2,dpl
	mov	r3,dph
;	Load_EFM8LB1.c:209: for(j=0; j<ms; j++)
	mov	r4,#0x00
	mov	r5,#0x00
L004005?:
	clr	c
	mov	a,r4
	subb	a,r2
	mov	a,r5
	subb	a,r3
	jnc	L004009?
;	Load_EFM8LB1.c:210: for (k=0; k<4; k++) Timer0us(250);
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
	lcall	_Timer0us
	pop	ar6
	pop	ar5
	pop	ar4
	pop	ar3
	pop	ar2
	inc	r6
	sjmp	L004001?
L004007?:
;	Load_EFM8LB1.c:209: for(j=0; j<ms; j++)
	inc	r4
	cjne	r4,#0x00,L004005?
	inc	r5
	sjmp	L004005?
L004009?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_ReadAR'
;------------------------------------------------------------
;i                         Allocated to registers r3 
;addr                      Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:216: unsigned char C2_ReadAR(void)
;	-----------------------------------------
;	 function C2_ReadAR
;	-----------------------------------------
_C2_ReadAR:
;	Load_EFM8LB1.c:222: StrobeC2CK; // Strobe C2CK with C2D driver disabled
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:225: C2D = LOW;                       
	clr	_P2_1
;	Load_EFM8LB1.c:226: C2D_DriverOn; // Enable C2D driver (output)
	orl	_P2M1,#0x02
;	Load_EFM8LB1.c:227: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:228: C2D = HIGH;
	setb	_P2_1
;	Load_EFM8LB1.c:229: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:231: C2D_DriverOff; // Disable C2D driver (input)
	anl	_P2M1,#0xFD
	orl	_P2,#0x02
;	Load_EFM8LB1.c:234: addr = 0;
	mov	r2,#0x00
;	Load_EFM8LB1.c:235: for (i=0;i<8;i++) // Shift in 8 bit ADDRESS field LSB-first
	mov	r3,#0x00
L005003?:
	cjne	r3,#0x08,L005013?
L005013?:
	jnc	L005006?
;	Load_EFM8LB1.c:237: addr >>= 1;                   
	mov	a,r2
	clr	c
	rrc	a
	mov	r2,a
;	Load_EFM8LB1.c:238: StrobeC2CK;     
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:239: if (C2D)
	jnb	_P2_1,L005005?
;	Load_EFM8LB1.c:240: addr |= 0x80;
	orl	ar2,#0x80
L005005?:
;	Load_EFM8LB1.c:235: for (i=0;i<8;i++) // Shift in 8 bit ADDRESS field LSB-first
	inc	r3
	sjmp	L005003?
L005006?:
;	Load_EFM8LB1.c:244: StrobeC2CK; // Strobe C2CK with C2D driver disabled
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:246: return addr; // Return Address register read value
	mov	dpl,r2
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_WriteAR'
;------------------------------------------------------------
;addr                      Allocated to registers r2 
;i                         Allocated to registers r3 
;------------------------------------------------------------
;	Load_EFM8LB1.c:250: void C2_WriteAR(unsigned char addr)
;	-----------------------------------------
;	 function C2_WriteAR
;	-----------------------------------------
_C2_WriteAR:
	mov	r2,dpl
;	Load_EFM8LB1.c:255: StrobeC2CK; // Strobe C2CK with C2D driver disabled
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:258: C2D = HIGH;             
	setb	_P2_1
;	Load_EFM8LB1.c:259: C2D_DriverOn;
	orl	_P2M1,#0x02
;	Load_EFM8LB1.c:260: StrobeC2CK; 
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:261: C2D = HIGH;
	setb	_P2_1
;	Load_EFM8LB1.c:262: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:265: for(i=0;i<8;i++)
	mov	r3,#0x00
L006001?:
	cjne	r3,#0x08,L006010?
L006010?:
	jnc	L006004?
;	Load_EFM8LB1.c:267: C2D = (addr & 0x01);
	mov	a,r2
	rrc	a
	mov	_P2_1,c
;	Load_EFM8LB1.c:268: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:269: addr >>= 1;
	mov	a,r2
	clr	c
	rrc	a
	mov	r2,a
;	Load_EFM8LB1.c:265: for(i=0;i<8;i++)
	inc	r3
	sjmp	L006001?
L006004?:
;	Load_EFM8LB1.c:273: C2D_DriverOff;
	anl	_P2M1,#0xFD
	orl	_P2,#0x02
;	Load_EFM8LB1.c:274: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:276: return;
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_ReadDR'
;------------------------------------------------------------
;i                         Allocated to registers r3 
;dat                       Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:280: unsigned char C2_ReadDR(void)
;	-----------------------------------------
;	 function C2_ReadDR
;	-----------------------------------------
_C2_ReadDR:
;	Load_EFM8LB1.c:286: StrobeC2CK; // Strobe C2CK with C2D driver disabled
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:289: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:290: C2D_DriverOn;
	orl	_P2M1,#0x02
;	Load_EFM8LB1.c:291: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:292: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:293: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:296: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:297: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:298: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:299: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:302: C2D_DriverOff;
	anl	_P2M1,#0xFD
	orl	_P2,#0x02
;	Load_EFM8LB1.c:303: do
L007001?:
;	Load_EFM8LB1.c:305: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:307: while (!C2D); // Strobe C2CK until target transmits a '1'
	jnb	_P2_1,L007001?
;	Load_EFM8LB1.c:310: dat = 0;
	mov	r2,#0x00
;	Load_EFM8LB1.c:311: for (i=0;i<8;i++) // Shift in 8-bit DATA field LSB-first
	mov	r3,#0x00
L007006?:
	cjne	r3,#0x08,L007019?
L007019?:
	jnc	L007009?
;	Load_EFM8LB1.c:313: dat >>= 1;
	mov	a,r2
	clr	c
	rrc	a
	mov	r2,a
;	Load_EFM8LB1.c:314: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:315: if (C2D)
	jnb	_P2_1,L007008?
;	Load_EFM8LB1.c:316: dat  |= 0x80;
	orl	ar2,#0x80
L007008?:
;	Load_EFM8LB1.c:311: for (i=0;i<8;i++) // Shift in 8-bit DATA field LSB-first
	inc	r3
	sjmp	L007006?
L007009?:
;	Load_EFM8LB1.c:320: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:322: return dat;
	mov	dpl,r2
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_WriteDR'
;------------------------------------------------------------
;dat                       Allocated to registers r2 
;i                         Allocated to registers r3 
;------------------------------------------------------------
;	Load_EFM8LB1.c:326: void C2_WriteDR(unsigned char dat)
;	-----------------------------------------
;	 function C2_WriteDR
;	-----------------------------------------
_C2_WriteDR:
	mov	r2,dpl
;	Load_EFM8LB1.c:331: StrobeC2CK; // Strobe C2CK with C2D driver disabled
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:334: C2D = HIGH;
	setb	_P2_1
;	Load_EFM8LB1.c:335: C2D_DriverOn;
	orl	_P2M1,#0x02
;	Load_EFM8LB1.c:336: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:337: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:338: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:341: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:342: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:343: C2D = LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:344: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:347: for (i=0;i<8;i++) // Shift out 8-bit DATA field LSB-first
	mov	r3,#0x00
L008004?:
	cjne	r3,#0x08,L008015?
L008015?:
	jnc	L008007?
;	Load_EFM8LB1.c:349: C2D = (dat & 0x01);
	mov	a,r2
	rrc	a
	mov	_P2_1,c
;	Load_EFM8LB1.c:350: StrobeC2CK;
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:351: dat >>= 1;
	mov	a,r2
	clr	c
	rrc	a
	mov	r2,a
;	Load_EFM8LB1.c:347: for (i=0;i<8;i++) // Shift out 8-bit DATA field LSB-first
	inc	r3
	sjmp	L008004?
L008007?:
;	Load_EFM8LB1.c:355: C2D_DriverOff; // Disable C2D driver for input
	anl	_P2M1,#0xFD
	orl	_P2,#0x02
;	Load_EFM8LB1.c:356: do
L008001?:
;	Load_EFM8LB1.c:358: StrobeC2CK; // Strobe C2CK until target transmits a '1'
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:360: while (!C2D);
	jnb	_P2_1,L008001?
;	Load_EFM8LB1.c:363: StrobeC2CK; // Strobe C2CK with C2D driver disabled
	clr	_P2_0
	setb	_P2_0
;	Load_EFM8LB1.c:365: return;
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_Reset'
;------------------------------------------------------------
;------------------------------------------------------------
;	Load_EFM8LB1.c:369: void C2_Reset(void)
;	-----------------------------------------
;	 function C2_Reset
;	-----------------------------------------
_C2_Reset:
;	Load_EFM8LB1.c:371: C2CK = LOW;   // Put target device in reset state by pulling
	clr	_P2_0
;	Load_EFM8LB1.c:372: Timer0us(20); // C2CK low for >20us
	mov	dpl,#0x14
	lcall	_Timer0us
;	Load_EFM8LB1.c:373: C2CK = HIGH;  // Release target device from reset
	setb	_P2_0
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_WriteSFR'
;------------------------------------------------------------
;sfrdata                   Allocated with name '_C2_WriteSFR_PARM_2'
;sfraddress                Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:381: void C2_WriteSFR (unsigned char sfraddress, unsigned char sfrdata)
;	-----------------------------------------
;	 function C2_WriteSFR
;	-----------------------------------------
_C2_WriteSFR:
;	Load_EFM8LB1.c:383: C2_WriteAR (sfraddress);
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:384: C2_WriteDR (sfrdata);
	mov	dpl,_C2_WriteSFR_PARM_2
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:385: Poll_InBusy; // Wait for input acknowledge
L010001?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L010001?
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_ReadSFR'
;------------------------------------------------------------
;sfraddress                Allocated to registers r2 
;j                         Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:388: unsigned char C2_ReadSFR (unsigned char sfraddress)
;	-----------------------------------------
;	 function C2_ReadSFR
;	-----------------------------------------
_C2_ReadSFR:
;	Load_EFM8LB1.c:391: C2_WriteAR (sfraddress);
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:392: j=C2_ReadDR ();
	lcall	_C2_ReadDR
	mov	r2,dpl
;	Load_EFM8LB1.c:393: Poll_InBusy; // Wait for input acknowledge
L011001?:
	push	ar2
	lcall	_C2_ReadAR
	mov	a,dpl
	pop	ar2
	jb	acc.1,L011001?
;	Load_EFM8LB1.c:394: return j;
	mov	dpl,r2
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_Init'
;------------------------------------------------------------
;------------------------------------------------------------
;	Load_EFM8LB1.c:398: void C2_Init(void)
;	-----------------------------------------
;	 function C2_Init
;	-----------------------------------------
_C2_Init:
;	Load_EFM8LB1.c:400: C2_Reset();    // Reset the target device
	lcall	_C2_Reset
;	Load_EFM8LB1.c:401: Timer0us(2);   // Delay for at least 2us
	mov	dpl,#0x02
	lcall	_Timer0us
;	Load_EFM8LB1.c:409: C2_WriteAR(FPCTL); // Target the C2 FLASH Programming Control register (FPCTL)
	mov	dpl,#0x02
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:410: C2_WriteDR(0x02);  // Write the first key code to enable C2 FLASH programming
	mov	dpl,#0x02
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:411: C2_WriteDR(0x01);  // Write the second key code to enable C2 FLASH programming
	mov	dpl,#0x01
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:412: waitms(20);        // Delay for at least 20ms to ensure the target is ready for C2 FLASH programming
	mov	dptr,#0x0014
	lcall	_waitms
;	Load_EFM8LB1.c:417: C2_WriteSFR(0xFF, 0x80);
	mov	_C2_WriteSFR_PARM_2,#0x80
	mov	dpl,#0xFF
	lcall	_C2_WriteSFR
;	Load_EFM8LB1.c:418: Timer0us(5); //Delay 5 us
	mov	dpl,#0x05
	lcall	_Timer0us
;	Load_EFM8LB1.c:419: C2_WriteSFR(0xEF, 0x02);
	mov	_C2_WriteSFR_PARM_2,#0x02
	mov	dpl,#0xEF
	lcall	_C2_WriteSFR
;	Load_EFM8LB1.c:421: C2_WriteSFR(0xA9, 0x00);
	mov	_C2_WriteSFR_PARM_2,#0x00
	mov	dpl,#0xA9
	ljmp	_C2_WriteSFR
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_GetDevID'
;------------------------------------------------------------
;------------------------------------------------------------
;	Load_EFM8LB1.c:425: unsigned char C2_GetDevID(void)
;	-----------------------------------------
;	 function C2_GetDevID
;	-----------------------------------------
_C2_GetDevID:
;	Load_EFM8LB1.c:427: C2_WriteAR(DEVICEID); // Select DeviceID register for C2 Data register accesses
	mov	dpl,#0x00
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:428: return C2_ReadDR();   // Read and return the DeviceID register
	ljmp	_C2_ReadDR
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_GetRevID'
;------------------------------------------------------------
;------------------------------------------------------------
;	Load_EFM8LB1.c:432: unsigned char C2_GetRevID(void)
;	-----------------------------------------
;	 function C2_GetRevID
;	-----------------------------------------
_C2_GetRevID:
;	Load_EFM8LB1.c:434: C2_WriteAR(REVID);   // Select REVID regsiter for C2 Data register accesses
	mov	dpl,#0x01
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:435: return C2_ReadDR();  // Read and return the DeviceID register
	ljmp	_C2_ReadDR
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_BlockRead'
;------------------------------------------------------------
;i                         Allocated to registers r2 
;status                    Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:445: char C2_BlockRead(void)
;	-----------------------------------------
;	 function C2_BlockRead
;	-----------------------------------------
_C2_BlockRead:
;	Load_EFM8LB1.c:450: C2_WriteAR(FPDAT);      // Select the FLASH Programming Data register for C2 Data register accesses
	mov	dpl,#0xB4
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:451: C2_WriteDR(BLOCK_READ); // Send FLASH block read command
	mov	dpl,#0x06
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:452: Poll_InBusy;            // Wait for input acknowledge
L015001?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L015001?
;	Load_EFM8LB1.c:455: Poll_OutReady;                      // Wait for status information
L015004?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L015004?
;	Load_EFM8LB1.c:456: status = C2_ReadDR();               // Read FLASH programming interface status
	lcall	_C2_ReadDR
	mov	r2,dpl
;	Load_EFM8LB1.c:457: if (status != COMMAND_OK) return 0; // Exit and indicate error
	cjne	r2,#0x0D,L015050?
	sjmp	L015008?
L015050?:
	mov	dpl,#0x00
	ret
L015008?:
;	Load_EFM8LB1.c:459: C2_WriteDR(FLASH_ADDR >> 8);        // Send address high byte to FPDAT
	mov	dpl,(_FLASH_ADDR + 1)
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:460: Poll_InBusy;                        // Wait for input acknowledge
L015009?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L015009?
;	Load_EFM8LB1.c:461: C2_WriteDR(FLASH_ADDR & 0x00FF);    // Send address low byte to FPDAT
	mov	r3,_FLASH_ADDR
	mov	dpl,r3
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:462: Poll_InBusy;                        // Wait for input acknowledge
L015012?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L015012?
;	Load_EFM8LB1.c:463: C2_WriteDR(NUM_BYTES);              // Send block size
	mov	dpl,_NUM_BYTES
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:464: Poll_InBusy;                        // Wait for input acknowledge
L015015?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L015015?
;	Load_EFM8LB1.c:467: Poll_OutReady;                      // Wait for status information
L015018?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L015018?
;	Load_EFM8LB1.c:468: status = C2_ReadDR();               // Read FLASH programming interface status
	lcall	_C2_ReadDR
	mov	r2,dpl
;	Load_EFM8LB1.c:469: if (status != COMMAND_OK)
	cjne	r2,#0x0D,L015055?
	sjmp	L015046?
L015055?:
;	Load_EFM8LB1.c:470: return 0;                        // Exit and indicate error
	mov	dpl,#0x00
;	Load_EFM8LB1.c:473: for (i=0;i<NUM_BYTES;i++)
	ret
L015046?:
	mov	r2,#0x00
L015026?:
	clr	c
	mov	a,r2
	subb	a,_NUM_BYTES
	jnc	L015029?
;	Load_EFM8LB1.c:475: Poll_OutReady;                   // Wait for data ready indicator
L015023?:
	push	ar2
	lcall	_C2_ReadAR
	mov	a,dpl
	pop	ar2
	jnb	acc.0,L015023?
;	Load_EFM8LB1.c:476: *C2_PTR++ = C2_ReadDR();         // Read data from the FPDAT register
	mov	r0,_C2_PTR
	push	ar2
	push	ar0
	lcall	_C2_ReadDR
	mov	a,dpl
	pop	ar0
	pop	ar2
	mov	@r0,a
	inc	_C2_PTR
;	Load_EFM8LB1.c:473: for (i=0;i<NUM_BYTES;i++)
	inc	r2
	sjmp	L015026?
L015029?:
;	Load_EFM8LB1.c:478: return 1;                           // Exit and indicate success
	mov	dpl,#0x01
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_BlockWrite'
;------------------------------------------------------------
;i                         Allocated to registers r2 
;status                    Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:488: char C2_BlockWrite(void)
;	-----------------------------------------
;	 function C2_BlockWrite
;	-----------------------------------------
_C2_BlockWrite:
;	Load_EFM8LB1.c:493: C2_WriteAR(FPDAT);                  // Select the FLASH Programming Data register 
	mov	dpl,#0xB4
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:495: C2_WriteDR(BLOCK_WRITE);            // Send FLASH block write command
	mov	dpl,#0x07
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:496: Poll_InBusy;                        // Wait for input acknowledge
L016001?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L016001?
;	Load_EFM8LB1.c:499: Poll_OutReady;                      // Wait for status information
L016004?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L016004?
;	Load_EFM8LB1.c:500: status = C2_ReadDR();               // Read FLASH programming interface status
	lcall	_C2_ReadDR
	mov	r2,dpl
;	Load_EFM8LB1.c:501: if (status != COMMAND_OK)
	cjne	r2,#0x0D,L016056?
	sjmp	L016008?
L016056?:
;	Load_EFM8LB1.c:502: return 0;                        // Exit and indicate error
	mov	dpl,#0x00
	ret
L016008?:
;	Load_EFM8LB1.c:504: C2_WriteDR(FLASH_ADDR >> 8);        // Send address high byte to FPDAT
	mov	dpl,(_FLASH_ADDR + 1)
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:505: Poll_InBusy;                        // Wait for input acknowledge
L016009?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L016009?
;	Load_EFM8LB1.c:506: C2_WriteDR(FLASH_ADDR & 0x00FF);    // Send address low byte to FPDAT
	mov	r3,_FLASH_ADDR
	mov	dpl,r3
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:507: Poll_InBusy;                        // Wait for input acknowledge
L016012?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L016012?
;	Load_EFM8LB1.c:508: C2_WriteDR(NUM_BYTES);              // Send block size
	mov	dpl,_NUM_BYTES
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:509: Poll_InBusy;                        // Wait for input acknolwedge
L016015?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L016015?
;	Load_EFM8LB1.c:512: Poll_OutReady;                      // Wait for status information
L016018?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L016018?
;	Load_EFM8LB1.c:513: status = C2_ReadDR();               // Read FLASH programming interface status
	lcall	_C2_ReadDR
	mov	r2,dpl
;	Load_EFM8LB1.c:514: if (status != COMMAND_OK)
	cjne	r2,#0x0D,L016061?
	sjmp	L016050?
L016061?:
;	Load_EFM8LB1.c:515: return 0;                        // Exit and indicate error
	mov	dpl,#0x00
;	Load_EFM8LB1.c:518: for (i=0;i<NUM_BYTES;i++)
	ret
L016050?:
	mov	r2,#0x00
L016029?:
	clr	c
	mov	a,r2
	subb	a,_NUM_BYTES
	jnc	L016026?
;	Load_EFM8LB1.c:520: C2_WriteDR(*C2_PTR++);           // Write data to the FPDAT register
	mov	r0,_C2_PTR
	mov	ar3,@r0
	inc	_C2_PTR
	mov	dpl,r3
	push	ar2
	lcall	_C2_WriteDR
	pop	ar2
;	Load_EFM8LB1.c:521: Poll_InBusy;                     // Wait for input acknowledge
L016023?:
	push	ar2
	lcall	_C2_ReadAR
	mov	a,dpl
	pop	ar2
	jb	acc.1,L016023?
;	Load_EFM8LB1.c:518: for (i=0;i<NUM_BYTES;i++)
	inc	r2
;	Load_EFM8LB1.c:524: Poll_OutReady;                      // Wait for last FLASH write to complete
	sjmp	L016029?
L016026?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L016026?
;	Load_EFM8LB1.c:525: return 1;                           // Exit and indicate success
	mov	dpl,#0x01
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_PageErase'
;------------------------------------------------------------
;page                      Allocated to registers r2 
;status                    Allocated to registers r3 
;------------------------------------------------------------
;	Load_EFM8LB1.c:533: char C2_PageErase(void)
;	-----------------------------------------
;	 function C2_PageErase
;	-----------------------------------------
_C2_PageErase:
;	Load_EFM8LB1.c:538: page=(unsigned char)(FLASH_ADDR>>9);// <page> is the 512-byte sector containing the target <FLASH_ADDR>.
	mov	a,(_FLASH_ADDR + 1)
	clr	c
	rrc	a
;	Load_EFM8LB1.c:540: if (page >= (NUM_PAGES-2))          // Check that target page is within range (NUM_PAGES minus 2 for reserved area)
	mov	r2,a
	mov	r3,a
	mov	r4,#0x00
	mov	r5,#0x00
	mov	r6,#0x00
	clr	c
	mov	a,r3
	subb	a,#0x7E
	mov	a,r4
	subb	a,#0x00
	mov	a,r5
	subb	a,#0x00
	mov	a,r6
	xrl	a,#0x80
	subb	a,#0x80
	jc	L017002?
;	Load_EFM8LB1.c:541: return 0;                        // Indicate error if out of range
	mov	dpl,#0x00
	ret
L017002?:
;	Load_EFM8LB1.c:542: C2_WriteAR(FPDAT);                  // Select the FLASH Programming Data register for C2 Data register accesses
	mov	dpl,#0xB4
	push	ar2
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:543: C2_WriteDR(PAGE_ERASE);             // Send FLASH page erase command Wait for input acknowledge
	mov	dpl,#0x08
	lcall	_C2_WriteDR
	pop	ar2
;	Load_EFM8LB1.c:546: Poll_OutReady;                      // Wait for status information
L017003?:
	push	ar2
	lcall	_C2_ReadAR
	mov	a,dpl
	pop	ar2
	jnb	acc.0,L017003?
;	Load_EFM8LB1.c:547: status = C2_ReadDR();               // Read FLASH programming interface status
	push	ar2
	lcall	_C2_ReadDR
	mov	r3,dpl
	pop	ar2
;	Load_EFM8LB1.c:548: if (status != COMMAND_OK)
	cjne	r3,#0x0D,L017037?
	sjmp	L017007?
L017037?:
;	Load_EFM8LB1.c:549: return 0;                        // Exit and indicate error
	mov	dpl,#0x00
	ret
L017007?:
;	Load_EFM8LB1.c:551: C2_WriteDR(page);                   // Send FLASH page number
	mov	dpl,r2
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:552: Poll_InBusy;                        // Wait for input acknowledge
L017008?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L017008?
;	Load_EFM8LB1.c:554: Poll_OutReady;                      // Wait for ready indicator
L017011?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L017011?
;	Load_EFM8LB1.c:555: status = C2_ReadDR();               // Read FLASH programming interface status
	lcall	_C2_ReadDR
	mov	r3,dpl
;	Load_EFM8LB1.c:556: if (status != COMMAND_OK)
	cjne	r3,#0x0D,L017040?
	sjmp	L017015?
L017040?:
;	Load_EFM8LB1.c:557: return 0;                        // Exit and indicate error
	mov	dpl,#0x00
	ret
L017015?:
;	Load_EFM8LB1.c:559: C2_WriteDR(0x00);                   // Dummy write to initiate erase
	mov	dpl,#0x00
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:560: Poll_InBusy;                        // Wait for input acknowledge
L017016?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L017016?
;	Load_EFM8LB1.c:562: Poll_OutReady;                      // Wait for erase operation to complete
L017019?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L017019?
;	Load_EFM8LB1.c:563: return 1;                           // Exit and indicate success
	mov	dpl,#0x01
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'C2_DeviceErase'
;------------------------------------------------------------
;status                    Allocated to registers r2 
;------------------------------------------------------------
;	Load_EFM8LB1.c:570: char C2_DeviceErase(void)
;	-----------------------------------------
;	 function C2_DeviceErase
;	-----------------------------------------
_C2_DeviceErase:
;	Load_EFM8LB1.c:574: C2_WriteAR(FPDAT);          // Select the FLASH Programming Data register for C2 Data register accesses
	mov	dpl,#0xB4
	lcall	_C2_WriteAR
;	Load_EFM8LB1.c:575: C2_WriteDR(DEVICE_ERASE);   // Send Device Erase command
	mov	dpl,#0x03
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:576: Poll_InBusy;                // Wait for input acknowledge
L018001?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L018001?
;	Load_EFM8LB1.c:579: Poll_OutReady;               // Wait for status information
L018004?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L018004?
;	Load_EFM8LB1.c:580: status = C2_ReadDR();        // Read FLASH programming interface status
	lcall	_C2_ReadDR
	mov	r2,dpl
;	Load_EFM8LB1.c:581: if (status != COMMAND_OK)
	cjne	r2,#0x0D,L018036?
	sjmp	L018008?
L018036?:
;	Load_EFM8LB1.c:582: return 0;                 // Exit and indicate error
	mov	dpl,#0x00
	ret
L018008?:
;	Load_EFM8LB1.c:587: C2_WriteDR(0xDE);  // Arming sequence command 1
	mov	dpl,#0xDE
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:588: Poll_InBusy;       // Wait for input acknowledge
L018009?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L018009?
;	Load_EFM8LB1.c:590: C2_WriteDR(0xAD);  // Arming sequence command 2
	mov	dpl,#0xAD
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:591: Poll_InBusy;       // Wait for input acknowledge
L018012?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L018012?
;	Load_EFM8LB1.c:593: C2_WriteDR(0xA5);  // Arming sequence command 3
	mov	dpl,#0xA5
	lcall	_C2_WriteDR
;	Load_EFM8LB1.c:594: Poll_InBusy;       // Wait for input acknowledge
L018015?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jb	acc.1,L018015?
;	Load_EFM8LB1.c:596: Poll_OutReady;     // Wait for erase operation to complete
L018018?:
	lcall	_C2_ReadAR
	mov	a,dpl
	jnb	acc.0,L018018?
;	Load_EFM8LB1.c:598: return 1;          // Exit and indicate success
	mov	dpl,#0x01
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;i                         Allocated with name '_main_i_1_106'
;j                         Allocated to registers r2 r3 
;k                         Allocated with name '_main_k_1_106'
;sloc0                     Allocated with name '_main_sloc0_1_0'
;------------------------------------------------------------
;	Load_EFM8LB1.c:601: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	Load_EFM8LB1.c:607: "By Jesus Calvino-Fraga (2008-2018)\n");
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
;	Load_EFM8LB1.c:609: while(1)
L019024?:
;	Load_EFM8LB1.c:611: printf("\nPress the 'BOOT' button (connected to P4.5) to start.\n\n");
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
;	Load_EFM8LB1.c:612: RLED=LEDOFF;
	setb	_P2_4
;	Load_EFM8LB1.c:613: GLED=LEDOFF;
	setb	_P3_6
;	Load_EFM8LB1.c:614: YLED=LEDOFF;
	setb	_P3_7
;	Load_EFM8LB1.c:615: C2D_DriverOn;
	orl	_P2M1,#0x02
;	Load_EFM8LB1.c:616: C2CK=LOW;
	clr	_P2_0
;	Load_EFM8LB1.c:617: C2D=LOW;
	clr	_P2_1
;	Load_EFM8LB1.c:618: PWR=PWROFF; // Power-off device
	setb	_P2_5
;	Load_EFM8LB1.c:620: while(FGO==1) // Blinking Green LED indicates new device can be inserted
L019001?:
	jnb	_P4_5,L019003?
;	Load_EFM8LB1.c:622: GLED=(!GLED);
	cpl	_P3_6
;	Load_EFM8LB1.c:623: YLED=(!YLED);
	cpl	_P3_7
;	Load_EFM8LB1.c:624: waitms(300);
	mov	dptr,#0x012C
	lcall	_waitms
	sjmp	L019001?
L019003?:
;	Load_EFM8LB1.c:626: GLED=LEDON;
	clr	_P3_6
;	Load_EFM8LB1.c:627: YLED=LEDON;
	clr	_P3_7
;	Load_EFM8LB1.c:628: PWR=PWRON; // Power-on device
	clr	_P2_5
;	Load_EFM8LB1.c:629: waitms(300);
	mov	dptr,#0x012C
	lcall	_waitms
;	Load_EFM8LB1.c:630: C2D_DriverOff;
	anl	_P2M1,#0xFD
	orl	_P2,#0x02
;	Load_EFM8LB1.c:631: C2CK=HIGH;
	setb	_P2_0
;	Load_EFM8LB1.c:632: while(FGO==0);
L019004?:
	jnb	_P4_5,L019004?
;	Load_EFM8LB1.c:633: GLED=LEDOFF;
	setb	_P3_6
;	Load_EFM8LB1.c:634: YLED=LEDOFF;
	setb	_P3_7
;	Load_EFM8LB1.c:637: C2_Reset();        // Reset target
	lcall	_C2_Reset
;	Load_EFM8LB1.c:638: j = C2_GetDevID(); 
	lcall	_C2_GetDevID
	mov	r2,dpl
	mov	r3,#0x00
;	Load_EFM8LB1.c:640: printf("Checking for EFM8LB1 microcontroller...");
	push	ar2
	push	ar3
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
	pop	ar3
	pop	ar2
;	Load_EFM8LB1.c:641: if (j != id[1].device_id)
	mov	dptr,#(_id + 0x0005)
	clr	a
	movc	a,@a+dptr
	mov	r4,a
	mov	r5,#0x00
	mov	a,r2
	cjne	a,ar4,L019061?
	mov	a,r3
	cjne	a,ar5,L019061?
	sjmp	L019008?
L019061?:
;	Load_EFM8LB1.c:643: printf("\nERROR: EFM8LB1 device not present!\n");
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
;	Load_EFM8LB1.c:644: RLED=LEDON;
	clr	_P2_4
;	Load_EFM8LB1.c:645: goto the_end;
	ljmp	L019017?
L019008?:
;	Load_EFM8LB1.c:647: printf(" Done.\n");
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
;	Load_EFM8LB1.c:649: j = C2_ReadSFR(0xAD);
	mov	dpl,#0xAD
	lcall	_C2_ReadSFR
	mov	r4,dpl
	mov	ar2,r4
	mov	r3,#0x00
;	Load_EFM8LB1.c:650: printf("Checking for %s microcontroller...", id[1].description);
	mov	dptr,#(_id + 0x0007)
	clr	a
	movc	a,@a+dptr
	mov	r4,a
	inc	dptr
	clr	a
	movc	a,@a+dptr
	mov	r5,a
	inc	dptr
	clr	a
	movc	a,@a+dptr
	mov	r6,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	mov	a,#__str_5
	push	acc
	mov	a,#(__str_5 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
	pop	ar3
	pop	ar2
;	Load_EFM8LB1.c:651: if (j != id[1].derivative_id)
	mov	dptr,#(_id + 0x0006)
	clr	a
	movc	a,@a+dptr
	mov	r4,a
	mov	r5,#0x00
	mov	a,r2
	cjne	a,ar4,L019062?
	mov	a,r3
	cjne	a,ar5,L019062?
	sjmp	L019010?
L019062?:
;	Load_EFM8LB1.c:653: printf("\nERROR: %s device not present! (%02x)\n", id[1].description, j);
	mov	dptr,#(_id + 0x0007)
	clr	a
	movc	a,@a+dptr
	mov	r4,a
	inc	dptr
	clr	a
	movc	a,@a+dptr
	mov	r5,a
	inc	dptr
	clr	a
	movc	a,@a+dptr
	mov	r6,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	ar6
	mov	a,#__str_6
	push	acc
	mov	a,#(__str_6 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf8
	mov	sp,a
;	Load_EFM8LB1.c:654: RLED=LEDON;
	clr	_P2_4
;	Load_EFM8LB1.c:655: goto the_end;
	ljmp	L019017?
L019010?:
;	Load_EFM8LB1.c:657: printf(" Done.\n");
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
;	Load_EFM8LB1.c:660: C2_Reset();  // Start with a target device reset
	lcall	_C2_Reset
;	Load_EFM8LB1.c:661: C2_Init();   // Enable FLASH programming via C2
	lcall	_C2_Init
;	Load_EFM8LB1.c:663: printf("Erasing the flash memory...");
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
;	Load_EFM8LB1.c:664: C2_DeviceErase(); // Erase entire code space
	lcall	_C2_DeviceErase
;	Load_EFM8LB1.c:665: printf(" Done.\n");
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
;	Load_EFM8LB1.c:667: printf("Verifying that the flash memory is blank...");
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	Load_EFM8LB1.c:669: for (i=NUM_BLOCKS-(PAGE_SIZE/BLOCK_SIZE); i<NUM_BLOCKS; i++) // Perform block reads (0x0000 to 0xFBFF)
	mov	_main_i_1_106,#0xE8
	mov	(_main_i_1_106 + 1),#0x03
L019030?:
	mov	r6,_main_i_1_106
	mov	r7,(_main_i_1_106 + 1)
	mov	r4,#0x00
	mov	r5,#0x00
	clr	c
	mov	a,r6
	subb	a,#0xF0
	mov	a,r7
	subb	a,#0x03
	mov	a,r4
	subb	a,#0x00
	mov	a,r5
	xrl	a,#0x80
	subb	a,#0x80
	jc	L019063?
	ljmp	L019033?
L019063?:
;	Load_EFM8LB1.c:671: FLASH_ADDR = i*BLOCK_SIZE;    // Set target addresss
	mov	_FLASH_ADDR,_main_i_1_106
	mov	a,(_main_i_1_106 + 1)
	anl	a,#0x03
	mov	c,acc.0
	xch	a,_FLASH_ADDR
	rrc	a
	xch	a,_FLASH_ADDR
	rrc	a
	mov	c,acc.0
	xch	a,_FLASH_ADDR
	rrc	a
	xch	a,_FLASH_ADDR
	rrc	a
	xch	a,_FLASH_ADDR
	mov	(_FLASH_ADDR + 1),a
;	Load_EFM8LB1.c:672: NUM_BYTES = BLOCK_SIZE;       // Set number of bytes to read
	mov	_NUM_BYTES,#0x40
;	Load_EFM8LB1.c:673: C2_PTR = R_BUF;               // Initialize C2 pointer to the read buffer
	mov	_C2_PTR,#_R_BUF
;	Load_EFM8LB1.c:674: C2_BlockRead();               // Initiate FLASH read            
	lcall	_C2_BlockRead
;	Load_EFM8LB1.c:675: for (j=0; j<BLOCK_SIZE; j++)  // Check read data
	mov	r2,#0x00
	mov	r3,#0x00
	mov	r4,#0x00
	mov	r5,#0x00
L019026?:
	clr	c
	mov	a,r4
	subb	a,#0x40
	mov	a,r5
	subb	a,#0x00
	jnc	L019032?
;	Load_EFM8LB1.c:677: if (R_BUF[j] != 0xFF)
	mov	a,r4
	add	a,#_R_BUF
	mov	r0,a
	mov	ar6,@r0
	cjne	r6,#0xFF,L019065?
	sjmp	L019028?
L019065?:
;	Load_EFM8LB1.c:679: printf("\nERROR: flash memory is not blank. @%04x=%02x\n", FLASH_ADDR+j, R_BUF[j]);
	mov	_main_sloc0_1_0,r6
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	a,r2
	add	a,_FLASH_ADDR
	mov	r6,a
	mov	a,r3
	addc	a,(_FLASH_ADDR + 1)
	mov	r7,a
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_9
	push	acc
	mov	a,#(__str_9 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	Load_EFM8LB1.c:680: RLED=LEDON;
	clr	_P2_4
;	Load_EFM8LB1.c:681: goto the_end;
	ljmp	L019017?
L019028?:
;	Load_EFM8LB1.c:675: for (j=0; j<BLOCK_SIZE; j++)  // Check read data
	inc	r4
	cjne	r4,#0x00,L019066?
	inc	r5
L019066?:
	mov	ar2,r4
	mov	ar3,r5
	sjmp	L019026?
L019032?:
;	Load_EFM8LB1.c:669: for (i=NUM_BLOCKS-(PAGE_SIZE/BLOCK_SIZE); i<NUM_BLOCKS; i++) // Perform block reads (0x0000 to 0xFBFF)
	inc	_main_i_1_106
	clr	a
	cjne	a,_main_i_1_106,L019067?
	inc	(_main_i_1_106 + 1)
L019067?:
	ljmp	L019030?
L019033?:
;	Load_EFM8LB1.c:685: printf(" Done.\n");
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
;	Load_EFM8LB1.c:687: printf("Copying bootloader to target");
	mov	a,#__str_10
	push	acc
	mov	a,#(__str_10 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	Load_EFM8LB1.c:688: for (i=NUM_BLOCKS-(PAGE_SIZE/BLOCK_SIZE), k=0; i<NUM_BLOCKS; i++, k++) // Perform block write/reads
	mov	r2,#0xE8
	mov	r3,#0x03
	clr	a
	mov	_main_k_1_106,a
	mov	(_main_k_1_106 + 1),a
L019034?:
	mov	ar6,r2
	mov	ar7,r3
	mov	r4,#0x00
	mov	r5,#0x00
	clr	c
	mov	a,r6
	subb	a,#0xF0
	mov	a,r7
	subb	a,#0x03
	mov	a,r4
	subb	a,#0x00
	mov	a,r5
	xrl	a,#0x80
	subb	a,#0x80
	jc	L019068?
	ljmp	L019037?
L019068?:
;	Load_EFM8LB1.c:691: FLASH_ADDR = i*BLOCK_SIZE;
	mov	ar4,r2
	mov	a,r3
	anl	a,#0x03
	mov	c,acc.0
	xch	a,r4
	rrc	a
	xch	a,r4
	rrc	a
	mov	c,acc.0
	xch	a,r4
	rrc	a
	xch	a,r4
	rrc	a
	xch	a,r4
	mov	r5,a
	mov	_FLASH_ADDR,r4
	mov	(_FLASH_ADDR + 1),r5
;	Load_EFM8LB1.c:692: NUM_BYTES = BLOCK_SIZE;
	mov	_NUM_BYTES,#0x40
;	Load_EFM8LB1.c:693: memcpy(W_BUF, &Bootloader[k*BLOCK_SIZE], BLOCK_SIZE);
	mov	r6,_main_k_1_106
	mov	a,(_main_k_1_106 + 1)
	anl	a,#0x03
	mov	c,acc.0
	xch	a,r6
	rrc	a
	xch	a,r6
	rrc	a
	mov	c,acc.0
	xch	a,r6
	rrc	a
	xch	a,r6
	rrc	a
	xch	a,r6
	mov	r7,a
	mov	a,r6
	add	a,#_Bootloader
	mov	r6,a
	mov	a,r7
	addc	a,#(_Bootloader >> 8)
	mov	r7,a
	mov	_memcpy_PARM_2,r6
	mov	(_memcpy_PARM_2 + 1),r7
	mov	(_memcpy_PARM_2 + 2),#0x80
	mov	_memcpy_PARM_3,#0x40
	clr	a
	mov	(_memcpy_PARM_3 + 1),a
	mov	dptr,#_W_BUF
	mov	b,#0x40
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	lcall	_memcpy
;	Load_EFM8LB1.c:695: C2_PTR = W_BUF;
	mov	_C2_PTR,#_W_BUF
;	Load_EFM8LB1.c:696: C2_BlockWrite();
	lcall	_C2_BlockWrite
	pop	ar5
	pop	ar4
;	Load_EFM8LB1.c:699: FLASH_ADDR = i*BLOCK_SIZE;
	mov	_FLASH_ADDR,r4
	mov	(_FLASH_ADDR + 1),r5
;	Load_EFM8LB1.c:700: NUM_BYTES = BLOCK_SIZE;
	mov	_NUM_BYTES,#0x40
;	Load_EFM8LB1.c:701: C2_PTR = R_BUF;
	mov	_C2_PTR,#_R_BUF
;	Load_EFM8LB1.c:702: C2_BlockRead();
	lcall	_C2_BlockRead
;	Load_EFM8LB1.c:704: if (memcmp(R_BUF, W_BUF, BLOCK_SIZE) != 0) // Verify written bytes
	mov	_memcmp_PARM_2,#_W_BUF
	mov	(_memcmp_PARM_2 + 1),#0x00
	mov	(_memcmp_PARM_2 + 2),#0x40
	mov	_memcmp_PARM_3,#0x40
	clr	a
	mov	(_memcmp_PARM_3 + 1),a
	mov	dptr,#_R_BUF
	mov	b,#0x40
	lcall	_memcmp
	mov	a,dpl
	mov	b,dph
	pop	ar3
	pop	ar2
	orl	a,b
	jz	L019014?
;	Load_EFM8LB1.c:706: printf("\nERROR: Memory flash failed.\n");
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
;	Load_EFM8LB1.c:707: RLED=LEDON;
	clr	_P2_4
;	Load_EFM8LB1.c:708: goto the_end;
	sjmp	L019017?
L019014?:
;	Load_EFM8LB1.c:712: putchar('.');
	mov	dpl,#0x2E
	push	ar2
	push	ar3
	lcall	_putchar
	pop	ar3
	pop	ar2
;	Load_EFM8LB1.c:688: for (i=NUM_BLOCKS-(PAGE_SIZE/BLOCK_SIZE), k=0; i<NUM_BLOCKS; i++, k++) // Perform block write/reads
	inc	r2
	cjne	r2,#0x00,L019070?
	inc	r3
L019070?:
	inc	_main_k_1_106
	clr	a
	cjne	a,_main_k_1_106,L019071?
	inc	(_main_k_1_106 + 1)
L019071?:
	ljmp	L019034?
L019037?:
;	Load_EFM8LB1.c:716: printf(" Done.\n");
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
;	Load_EFM8LB1.c:717: printf("\n\nPress the 'BOOT' button to finish.\n");
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
;	Load_EFM8LB1.c:718: GLED=LEDON;
	clr	_P3_6
;	Load_EFM8LB1.c:719: YLED=LEDON;
	clr	_P3_7
;	Load_EFM8LB1.c:720: C2_Reset();
	lcall	_C2_Reset
;	Load_EFM8LB1.c:725: while(FGO==1);
L019017?:
	jb	_P4_5,L019017?
;	Load_EFM8LB1.c:726: waitms(100); //Debounce...
	mov	dptr,#0x0064
	lcall	_waitms
;	Load_EFM8LB1.c:727: while(FGO==0);
L019020?:
	jnb	_P4_5,L019020?
;	Load_EFM8LB1.c:728: waitms(100); //Debounce...
	mov	dptr,#0x0064
	lcall	_waitms
	ljmp	L019024?
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
_id:
	db 0x34	; 52 
	db 0x41	; 65 	A
	db _str_13,(_str_13 >> 8),0x80
	db 0x34	; 52 
	db 0x42	; 66 	B
	db _str_14,(_str_14 >> 8),0x80
	db 0x34	; 52 
	db 0x43	; 67 	C
	db _str_15,(_str_15 >> 8),0x80
	db 0x34	; 52 
	db 0x44	; 68 	D
	db _str_16,(_str_16 >> 8),0x80
	db 0x34	; 52 
	db 0x45	; 69 	E
	db _str_17,(_str_17 >> 8),0x80
	db 0x34	; 52 
	db 0x46	; 70 	F
	db _str_18,(_str_18 >> 8),0x80
	db 0x34	; 52 
	db 0x47	; 71 	G
	db _str_19,(_str_19 >> 8),0x80
	db 0x34	; 52 
	db 0x48	; 72 	H
	db _str_20,(_str_20 >> 8),0x80
	db 0x34	; 52 
	db 0x49	; 73 	I
	db _str_21,(_str_21 >> 8),0x80
	db 0x34	; 52 
	db 0x4a	; 74 	J
	db _str_22,(_str_22 >> 8),0x80
	db 0x34	; 52 
	db 0x4b	; 75 	K
	db _str_23,(_str_23 >> 8),0x80
	db 0x34	; 52 
	db 0x4c	; 76 	L
	db _str_24,(_str_24 >> 8),0x80
	db 0x34	; 52 
	db 0x4d	; 77 	M
	db _str_25,(_str_25 >> 8),0x80
	db 0x34	; 52 
	db 0x4e	; 78 	N
	db _str_26,(_str_26 >> 8),0x80
	db 0x34	; 52 
	db 0x4f	; 79 	O
	db _str_27,(_str_27 >> 8),0x80
	db 0x34	; 52 
	db 0x50	; 80 	P
	db _str_28,(_str_28 >> 8),0x80
	db 0x34	; 52 
	db 0x51	; 81 	Q
	db _str_29,(_str_29 >> 8),0x80
	db 0x34	; 52 
	db 0x52	; 82 	R
	db _str_30,(_str_30 >> 8),0x80
	db 0x34	; 52 
	db 0x53	; 83 	S
	db _str_31,(_str_31 >> 8),0x80
	db 0x34	; 52 
	db 0x54	; 84 	T
	db _str_32,(_str_32 >> 8),0x80
	db 0x34	; 52 
	db 0x61	; 97 	a
	db _str_33,(_str_33 >> 8),0x80
	db 0x34	; 52 
	db 0x64	; 100 	d
	db _str_34,(_str_34 >> 8),0x80
	db 0x34	; 52 
	db 0x65	; 101 	e
	db _str_35,(_str_35 >> 8),0x80
	db 0x34	; 52 
	db 0x68	; 104 	h
	db _str_36,(_str_36 >> 8),0x80
	db 0x34	; 52 
	db 0x69	; 105 	i
	db _str_37,(_str_37 >> 8),0x80
	db 0x34	; 52 
	db 0x6c	; 108 	l
	db _str_38,(_str_38 >> 8),0x80
	db 0x34	; 52 
	db 0x6d	; 109 	m
	db _str_39,(_str_39 >> 8),0x80
	db 0x34	; 52 
	db 0x70	; 112 	p
	db _str_40,(_str_40 >> 8),0x80
	db 0x34	; 52 
	db 0x71	; 113 	q
	db _str_41,(_str_41 >> 8),0x80
	db 0x34	; 52 
	db 0x74	; 116 	t
	db _str_42,(_str_42 >> 8),0x80
	db 0x00	; 0 
	db 0x00	; 0 
	db _str_43,(_str_43 >> 8),0x80
_Bootloader:
	db 0x90	; 144 
	db 0x00	; 0 
	db 0x00	; 0 
	db 0xe4	; 228 	‰
	db 0x93	; 147 	ì
	db 0xf4	; 244 
	db 0x60	; 96 
	db 0x18	; 24 
	db 0xe5	; 229 	Â
	db 0xef	; 239 
	db 0xb4	; 180 	¥
	db 0x10	; 16 
	db 0x08	; 8 
	db 0xe8	; 232 	Ë
	db 0x64	; 100 	d
	db 0xa5	; 165 	•
	db 0x60	; 96 
	db 0x0e	; 14 
	db 0x02	; 2 
	db 0x00	; 0 
	db 0x00	; 0 
	db 0x54	; 84 	T
	db 0x03	; 3 
	db 0x60	; 96 
	db 0xf9	; 249 
	db 0x78	; 120 	x
	db 0x16	; 22 
	db 0x20	; 32 
	db 0xb7	; 183 
	db 0xf4	; 244 
	db 0xd8	; 216 	ÿ
	db 0xfb	; 251 	˚
	db 0x75	; 117 	u
	db 0x81	; 129 	Å
	db 0x10	; 16 
	db 0x02	; 2 
	db 0xfa	; 250 
	db 0x9c	; 156 	ú
	db 0x71	; 113 	q
	db 0xd1	; 209 	—
	db 0x8e	; 142 	é
	db 0x08	; 8 
	db 0x8f	; 143 	è
	db 0x09	; 9 
	db 0xad	; 173 	≠
	db 0x10	; 16 
	db 0x71	; 113 	q
	db 0x38	; 56 
	db 0x50	; 80 	P
	db 0x23	; 35 
	db 0xe5	; 229 	Â
	db 0x0d	; 13 
	db 0xb4	; 180 	¥
	db 0x02	; 2 
	db 0x06	; 6 
	db 0xaf	; 175 
	db 0x09	; 9 
	db 0xae	; 174 	Æ
	db 0x08	; 8 
	db 0x71	; 113 	q
	db 0x2a	; 42 
	db 0xe5	; 229 	Â
	db 0x10	; 16 
	db 0x60	; 96 
	db 0x17	; 23 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0xad	; 173 	≠
	db 0x07	; 7 
	db 0xaf	; 175 
	db 0x09	; 9 
	db 0xae	; 174 	Æ
	db 0x08	; 8 
	db 0x71	; 113 	q
	db 0x31	; 49 
	db 0x05	; 5 
	db 0x09	; 9 
	db 0xe5	; 229 	Â
	db 0x09	; 9 
	db 0x70	; 112 	p
	db 0xec	; 236 	Ï
	db 0x05	; 5 
	db 0x08	; 8 
	db 0x80	; 128 	Ä
	db 0xe8	; 232 	Ë
	db 0x75	; 117 	u
	db 0x0c	; 12 
	db 0x41	; 65 	A
	db 0x22	; 34 
	db 0x71	; 113 	q
	db 0xd1	; 209 	—
	db 0x8e	; 142 	é
	db 0x08	; 8 
	db 0x8f	; 143 	è
	db 0x09	; 9 
	db 0x71	; 113 	q
	db 0xd1	; 209 	—
	db 0x75	; 117 	u
	db 0xa7	; 167 
	db 0x20	; 32 
	db 0x43	; 67 	C
	db 0xce	; 206 	Œ
	db 0x08	; 8 
	db 0xd3	; 211 	”
	db 0xe5	; 229 	Â
	db 0x09	; 9 
	db 0x9f	; 159 
	db 0xe5	; 229 	Â
	db 0x08	; 8 
	db 0x9e	; 158 	û
	db 0x50	; 80 	P
	db 0x14	; 20 
	db 0x85	; 133 
	db 0x09	; 9 
	db 0x82	; 130 	Ç
	db 0x85	; 133 
	db 0x08	; 8 
	db 0x83	; 131 
	db 0xe4	; 228 	‰
	db 0x93	; 147 	ì
	db 0xf5	; 245 	ı
	db 0xca	; 202 
	db 0x05	; 5 
	db 0x09	; 9 
	db 0xe5	; 229 	Â
	db 0x09	; 9 
	db 0x70	; 112 	p
	db 0xe7	; 231 
	db 0x05	; 5 
	db 0x08	; 8 
	db 0x80	; 128 	Ä
	db 0xe3	; 227 	„
	db 0x71	; 113 	q
	db 0xd1	; 209 	—
	db 0xc0	; 192 	¿
	db 0x06	; 6 
	db 0xc0	; 192 	¿
	db 0x07	; 7 
	db 0x71	; 113 	q
	db 0x50	; 80 	P
	db 0xd0	; 208 	–
	db 0x05	; 5 
	db 0xd0	; 208 	–
	db 0x04	; 4 
	db 0xef	; 239 
	db 0x6d	; 109 	m
	db 0x70	; 112 	p
	db 0x02	; 2 
	db 0xee	; 238 	Ó
	db 0x6c	; 108 	l
	db 0x60	; 96 
	db 0x03	; 3 
	db 0x75	; 117 	u
	db 0x0c	; 12 
	db 0x43	; 67 	C
	db 0x22	; 34 
	db 0x71	; 113 	q
	db 0x5f	; 95 
	db 0xe4	; 228 	‰
	db 0xf5	; 245 	ı
	db 0x0e	; 14 
	db 0xf5	; 245 	ı
	db 0x0f	; 15 
	db 0x71	; 113 	q
	db 0xab	; 171 	´
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0xef	; 239 
	db 0x24	; 36 
	db 0xd0	; 208 	–
	db 0xf5	; 245 	ı
	db 0x0d	; 13 
	db 0x75	; 117 	u
	db 0x0c	; 12 
	db 0x40	; 64 
	db 0xb4	; 180 	¥
	db 0x07	; 7 
	db 0x00	; 0 
	db 0x50	; 80 	P
	db 0x5a	; 90 	Z
	db 0x90	; 144 
	db 0xfa	; 250 
	db 0xba	; 186 	∫
	db 0x25	; 37 
	db 0xe0	; 224 	‡
	db 0x73	; 115 	s
	db 0x41	; 65 	A
	db 0xc8	; 200 	»
	db 0x41	; 65 	A
	db 0xd9	; 217 	Ÿ
	db 0x41	; 65 	A
	db 0xe3	; 227 	„
	db 0x41	; 65 	A
	db 0xe3	; 227 	„
	db 0x41	; 65 	A
	db 0xe7	; 231 
	db 0x41	; 65 	A
	db 0xeb	; 235 	Î
	db 0x61	; 97 	a
	db 0x01	; 1 
	db 0x71	; 113 	q
	db 0xd1	; 209 	—
	db 0xef	; 239 
	db 0x64	; 100 	d
	db 0x42	; 66 	B
	db 0x70	; 112 	p
	db 0x03	; 3 
	db 0xee	; 238 	Ó
	db 0x64	; 100 	d
	db 0x34	; 52 
	db 0x60	; 96 
	db 0x3d	; 61 
	db 0x75	; 117 	u
	db 0x0c	; 12 
	db 0x42	; 66 	B
	db 0x80	; 128 	Ä
	db 0x38	; 56 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0x8f	; 143 	è
	db 0x0e	; 14 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0x8f	; 143 	è
	db 0x0f	; 15 
	db 0x80	; 128 	Ä
	db 0x2e	; 46 
	db 0x51	; 81 	Q
	db 0x26	; 38 
	db 0x80	; 128 	Ä
	db 0x2a	; 42 
	db 0x51	; 81 	Q
	db 0x59	; 89 	Y
	db 0x80	; 128 	Ä
	db 0x26	; 38 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0xad	; 173 	≠
	db 0x07	; 7 
	db 0x7e	; 126 
	db 0xfb	; 251 	˚
	db 0x7f	; 127 
	db 0xfe	; 254 	˛
	db 0x71	; 113 	q
	db 0x31	; 49 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0xad	; 173 	≠
	db 0x07	; 7 
	db 0x7e	; 126 
	db 0xfb	; 251 	˚
	db 0x7f	; 127 
	db 0xff	; 255 
	db 0x71	; 113 	q
	db 0x31	; 49 
	db 0x80	; 128 	Ä
	db 0x10	; 16 
	db 0x7f	; 127 
	db 0x40	; 64 
	db 0x71	; 113 	q
	db 0xde	; 222 	ﬁ
	db 0x78	; 120 	x
	db 0x00	; 0 
	db 0xe4	; 228 	‰
	db 0xf6	; 246 	ˆ
	db 0x75	; 117 	u
	db 0xef	; 239 
	db 0x12	; 18 
	db 0x80	; 128 	Ä
	db 0x03	; 3 
	db 0x75	; 117 	u
	db 0x0c	; 12 
	db 0x90	; 144 
	db 0xaf	; 175 
	db 0x0c	; 12 
	db 0x71	; 113 	q
	db 0xde	; 222 	ﬁ
	db 0x80	; 128 	Ä
	db 0x8c	; 140 	å
	db 0x8f	; 143 	è
	db 0x82	; 130 	Ç
	db 0x8e	; 142 	é
	db 0x83	; 131 
	db 0x85	; 133 
	db 0x0e	; 14 
	db 0xb7	; 183 
	db 0x85	; 133 
	db 0x0f	; 15 
	db 0xb7	; 183 
	db 0x43	; 67 	C
	db 0x8f	; 143 	è
	db 0x01	; 1 
	db 0xed	; 237 	Ì
	db 0xf0	; 240 	
	db 0x53	; 83 	S
	db 0x8f	; 143 	è
	db 0xfc	; 252 	¸
	db 0x22	; 34 
	db 0x43	; 67 	C
	db 0x8f	; 143 	è
	db 0x02	; 2 
	db 0xe4	; 228 	‰
	db 0xfd	; 253 	˝
	db 0x61	; 97 	a
	db 0x17	; 23 
	db 0xed	; 237 	Ì
	db 0xf4	; 244 
	db 0x60	; 96 
	db 0x02	; 2 
	db 0x71	; 113 	q
	db 0x17	; 23 
	db 0x22	; 34 
	db 0xc3	; 195 	√
	db 0xee	; 238 	Ó
	db 0x94	; 148 	î
	db 0xfa	; 250 
	db 0x50	; 80 	P
	db 0x10	; 16 
	db 0xed	; 237 	Ì
	db 0x2f	; 47 
	db 0xff	; 255 
	db 0xe4	; 228 	‰
	db 0x3e	; 62 
	db 0xfe	; 254 	˛
	db 0xd3	; 211 	”
	db 0xef	; 239 
	db 0x94	; 148 	î
	db 0x00	; 0 
	db 0xee	; 238 	Ó
	db 0x94	; 148 	î
	db 0xfa	; 250 
	db 0x50	; 80 	P
	db 0x01	; 1 
	db 0x22	; 34 
	db 0xc3	; 195 	√
	db 0x22	; 34 
	db 0x43	; 67 	C
	db 0xce	; 206 	Œ
	db 0x01	; 1 
	db 0xaf	; 175 
	db 0xcb	; 203 	À
	db 0xef	; 239 
	db 0xfe	; 254 	˛
	db 0xad	; 173 	≠
	db 0xcb	; 203 	À
	db 0xed	; 237 	Ì
	db 0xff	; 255 
	db 0xe4	; 228 	‰
	db 0xf5	; 245 	ı
	db 0xa7	; 167 
	db 0x22	; 34 
	db 0x75	; 117 	u
	db 0x97	; 151 	ó
	db 0xde	; 222 	ﬁ
	db 0x75	; 117 	u
	db 0x97	; 151 	ó
	db 0xad	; 173 	≠
	db 0x43	; 67 	C
	db 0xff	; 255 
	db 0x80	; 128 	Ä
	db 0x75	; 117 	u
	db 0xef	; 239 
	db 0x02	; 2 
	db 0xe4	; 228 	‰
	db 0xf5	; 245 	ı
	db 0xa9	; 169 	©
	db 0x75	; 117 	u
	db 0xa4	; 164 	§
	db 0x10	; 16 
	db 0x75	; 117 	u
	db 0xe1	; 225 	·
	db 0x01	; 1 
	db 0x75	; 117 	u
	db 0xe3	; 227 	„
	db 0x40	; 64 
	db 0x75	; 117 	u
	db 0xe4	; 228 	‰
	db 0xd0	; 208 	–
	db 0x75	; 117 	u
	db 0x8e	; 142 	é
	db 0x08	; 8 
	db 0x75	; 117 	u
	db 0x89	; 137 	â
	db 0x90	; 144 
	db 0xd2	; 210 
	db 0x8e	; 142 	é
	db 0x20	; 32 
	db 0x85	; 133 
	db 0xfd	; 253 	˝
	db 0x30	; 48 
	db 0x85	; 133 
	db 0xfd	; 253 	˝
	db 0xc2	; 194 
	db 0x8e	; 142 	é
	db 0xaf	; 175 
	db 0x8d	; 141 
	db 0xef	; 239 
	db 0xfe	; 254 	˛
	db 0xad	; 173 	≠
	db 0x8b	; 139 	ã
	db 0xed	; 237 	Ì
	db 0xff	; 255 
	db 0xee	; 238 	Ó
	db 0xc3	; 195 	√
	db 0x13	; 19 
	db 0xef	; 239 
	db 0x13	; 19 
	db 0xf4	; 244 
	db 0x04	; 4 
	db 0xf5	; 245 	ı
	db 0x8d	; 141 
	db 0x75	; 117 	u
	db 0x89	; 137 	â
	db 0x20	; 32 
	db 0xd2	; 210 
	db 0x8e	; 142 	é
	db 0xd2	; 210 
	db 0x9c	; 156 	ú
	db 0x22	; 34 
	db 0x30	; 48 
	db 0x98	; 152 	ò
	db 0xfd	; 253 	˝
	db 0xc2	; 194 
	db 0x98	; 152 	ò
	db 0xaf	; 175 
	db 0x99	; 153 	ô
	db 0x22	; 34 
	db 0x71	; 113 	q
	db 0xa3	; 163 	£
	db 0xbf	; 191 
	db 0x24	; 36 
	db 0xfb	; 251 	˚
	db 0x71	; 113 	q
	db 0xa3	; 163 	£
	db 0xae	; 174 	Æ
	db 0x07	; 7 
	db 0x8e	; 142 	é
	db 0x10	; 16 
	db 0xee	; 238 	Ó
	db 0x60	; 96 
	db 0x0c	; 12 
	db 0x71	; 113 	q
	db 0xa3	; 163 	£
	db 0xf5	; 245 	ı
	db 0x82	; 130 	Ç
	db 0x75	; 117 	u
	db 0x83	; 131 
	db 0x00	; 0 
	db 0xef	; 239 
	db 0xf0	; 240 	
	db 0x1e	; 30 
	db 0x80	; 128 	Ä
	db 0xf1	; 241 	Ò
	db 0x22	; 34 
	db 0x85	; 133 
	db 0x10	; 16 
	db 0x82	; 130 	Ç
	db 0x75	; 117 	u
	db 0x83	; 131 
	db 0x00	; 0 
	db 0xe0	; 224 	‡
	db 0xff	; 255 
	db 0x15	; 21 
	db 0x10	; 16 
	db 0x22	; 34 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0x8f	; 143 	è
	db 0x0a	; 10 
	db 0x71	; 113 	q
	db 0xc6	; 198 
	db 0x8f	; 143 	è
	db 0x0b	; 11 
	db 0xae	; 174 	Æ
	db 0x0a	; 10 
	db 0xaf	; 175 
	db 0x0b	; 11 
	db 0x22	; 34 
	db 0xc2	; 194 
	db 0x99	; 153 	ô
	db 0x8f	; 143 	è
	db 0x99	; 153 	ô
	db 0x30	; 48 
	db 0x99	; 153 	ô
	db 0xfd	; 253 	˝
	db 0x22	; 34 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0xff	; 255 
	db 0x90	; 144 
	db 0xa5	; 165 	•
	db 0xff	; 255 
__str_0:
	db 0x1B
	db '[2JThis program loads the bootloader into a EFM8LB1 using a'
	db 'n AT89LP51RC2.'
	db 0x0A
	db 'Based on Cygnal application note AN027 and Si'
	db 'licon Labs application note AN127'
	db 0x0A
	db 'By Jesus Calvino-Fraga (20'
	db '08-2018)'
	db 0x0A
	db 0x00
__str_1:
	db 0x0A
	db 'Press the '
	db 0x27
	db 'BOOT'
	db 0x27
	db ' button (connected to P4.5) to start.'
	db 0x0A
	db 0x0A
	db 0x00
__str_2:
	db 'Checking for EFM8LB1 microcontroller...'
	db 0x00
__str_3:
	db 0x0A
	db 'ERROR: EFM8LB1 device not present!'
	db 0x0A
	db 0x00
__str_4:
	db ' Done.'
	db 0x0A
	db 0x00
__str_5:
	db 'Checking for %s microcontroller...'
	db 0x00
__str_6:
	db 0x0A
	db 'ERROR: %s device not present! (%02x)'
	db 0x0A
	db 0x00
__str_7:
	db 'Erasing the flash memory...'
	db 0x00
__str_8:
	db 'Verifying that the flash memory is blank...'
	db 0x00
__str_9:
	db 0x0A
	db 'ERROR: flash memory is not blank. @%04x=%02x'
	db 0x0A
	db 0x00
__str_10:
	db 'Copying bootloader to target'
	db 0x00
__str_11:
	db 0x0A
	db 'ERROR: Memory flash failed.'
	db 0x0A
	db 0x00
__str_12:
	db 0x0A
	db 0x0A
	db 'Press the '
	db 0x27
	db 'BOOT'
	db 0x27
	db ' button to finish.'
	db 0x0A
	db 0x00
_str_13:
	db 'EFM8LB12F64E_QFN32'
	db 0x00
_str_14:
	db 'EFM8LB12F64E_QFP32'
	db 0x00
_str_15:
	db 'EFM8LB12F64E_QSOP24'
	db 0x00
_str_16:
	db 'EFM8LB12F64E_QFN24'
	db 0x00
_str_17:
	db 'EFM8LB12F32E_QFN32'
	db 0x00
_str_18:
	db 'EFM8LB12F32E_QFP32'
	db 0x00
_str_19:
	db 'EFM8LB12F32E_QSOP24'
	db 0x00
_str_20:
	db 'EFM8LB12F32E_QFN24'
	db 0x00
_str_21:
	db 'EFM8LB11F32E_QFN32'
	db 0x00
_str_22:
	db 'EFM8LB11F32E_QFP32'
	db 0x00
_str_23:
	db 'EFM8LB11F32E_QSOP24'
	db 0x00
_str_24:
	db 'EFM8LB11F32E_QFN24'
	db 0x00
_str_25:
	db 'EFM8LB11F16E_QFN32'
	db 0x00
_str_26:
	db 'EFM8LB11F16E_QFP32'
	db 0x00
_str_27:
	db 'EFM8LB11F16E_QSOP24'
	db 0x00
_str_28:
	db 'EFM8LB11F16E_QFN24'
	db 0x00
_str_29:
	db 'EFM8LB10F16E_QFN32'
	db 0x00
_str_30:
	db 'EFM8LB10F16E_QFP32'
	db 0x00
_str_31:
	db 'EFM8LB10F16E_QSOP24'
	db 0x00
_str_32:
	db 'EFM8LB10F16E_QFN24'
	db 0x00
_str_33:
	db 'EFM8LB12F64ES0_QFN32'
	db 0x00
_str_34:
	db 'EFM8LB12F64ES0_QFN24'
	db 0x00
_str_35:
	db 'EFM8LB12F32ES0_QFN32'
	db 0x00
_str_36:
	db 'EFM8LB12F32ES0_QFN24'
	db 0x00
_str_37:
	db 'EFM8LB11F32ES0_QFN32'
	db 0x00
_str_38:
	db 'EFM8LB11F32ES0_QFN24'
	db 0x00
_str_39:
	db 'EFM8LB11F16ES0_QFN32'
	db 0x00
_str_40:
	db 'EFM8LB11F16ES0_QFN24'
	db 0x00
_str_41:
	db 'EFM8LB10F16ES0_QFN32'
	db 0x00
_str_42:
	db 'EFM8LB10F16ES0_QFN24'
	db 0x00
_str_43:
	db 0x00

	CSEG

end
