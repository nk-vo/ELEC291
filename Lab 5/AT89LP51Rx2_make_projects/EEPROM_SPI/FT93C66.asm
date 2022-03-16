;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1069 (Apr 23 2015) (MSVC)
; This file was generated Fri Mar 11 18:37:38 2022
;--------------------------------------------------------
$name FT93C66
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
	public _FT93C66_Init
	public _FT93C66_Write_All
	public _FT93C66_Write
	public _FT93C66_Erase_All
	public _FT93C66_Erase
	public _FT93C66_Read
	public _FT93C66_Write_Disable
	public _FT93C66_Write_Enable
	public _FT93C66_Poll
	public _spi_io
	public _SmallDelay
	public _FT93C66_Write_PARM_2
	public _spi_io_PARM_2
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
_spi_io_PARM_2:
	ds 2
_FT93C66_Write_PARM_2:
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
; Interrupt vectors
;--------------------------------------------------------
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
;Allocation info for local variables in function 'SmallDelay'
;------------------------------------------------------------
;------------------------------------------------------------
;	FT93C66.c:10: void SmallDelay (void)
;	-----------------------------------------
;	 function SmallDelay
;	-----------------------------------------
_SmallDelay:
	using	0
;	FT93C66.c:19: _endasm;
	
	  nop ; 45 ns @ 22.1148 MHz
	  nop ; 90 ns
	  nop ; 135 ns
	  nop ; 180 ns
	  nop ; 225 ns
	  nop ; 270 ns
	 
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'spi_io'
;------------------------------------------------------------
;out_byte                  Allocated with name '_spi_io_PARM_2'
;nbits                     Allocated to registers r2 
;i                         Allocated to registers r2 
;mask                      Allocated to registers r3 r4 
;------------------------------------------------------------
;	FT93C66.c:22: unsigned int spi_io(unsigned char nbits, unsigned int out_byte)
;	-----------------------------------------
;	 function spi_io
;	-----------------------------------------
_spi_io:
	mov	r2,dpl
;	FT93C66.c:28: mask=1<<(nbits-1);
	mov	ar3,r2
	mov	r4,#0x00
	dec	r3
	cjne	r3,#0xff,L003012?
	dec	r4
L003012?:
	mov	b,r3
	inc	b
	mov	r3,#0x01
	mov	r4,#0x00
	sjmp	L003014?
L003013?:
	mov	a,r3
	add	a,r3
	mov	r3,a
	mov	a,r4
	rlc	a
	mov	r4,a
L003014?:
	djnz	b,L003013?
;	FT93C66.c:29: do {
L003003?:
;	FT93C66.c:30: BB_MOSI = (out_byte & mask)?1:0;
	mov	a,r3
	anl	a,_spi_io_PARM_2
	mov	r5,a
	mov	a,r4
	anl	a,(_spi_io_PARM_2 + 1)
	orl	a,r5
	add	a,#0xff
	mov	_P2_1,c
;	FT93C66.c:31: out_byte <<= 1;
	mov	a,(_spi_io_PARM_2 + 1)
	xch	a,_spi_io_PARM_2
	add	a,acc
	xch	a,_spi_io_PARM_2
	rlc	a
	mov	(_spi_io_PARM_2 + 1),a
;	FT93C66.c:33: BB_SCLK = 1;
	setb	_P2_3
;	FT93C66.c:34: SmallDelay();
	push	ar2
	push	ar3
	push	ar4
	lcall	_SmallDelay
	pop	ar4
	pop	ar3
	pop	ar2
;	FT93C66.c:35: if(BB_MISO) out_byte += 1; 
	jnb	_P2_2,L003002?
	inc	_spi_io_PARM_2
	clr	a
	cjne	a,_spi_io_PARM_2,L003016?
	inc	(_spi_io_PARM_2 + 1)
L003016?:
L003002?:
;	FT93C66.c:36: BB_SCLK = 0;
	clr	_P2_3
;	FT93C66.c:38: } while(--i);
	djnz	r2,L003003?
;	FT93C66.c:39: BB_MOSI=0;
	clr	_P2_1
;	FT93C66.c:40: return out_byte;
	mov	dpl,_spi_io_PARM_2
	mov	dph,(_spi_io_PARM_2 + 1)
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Poll'
;------------------------------------------------------------
;j                         Allocated to registers r3 
;mscount                   Allocated to registers r2 
;------------------------------------------------------------
;	FT93C66.c:43: void FT93C66_Poll(void)
;	-----------------------------------------
;	 function FT93C66_Poll
;	-----------------------------------------
_FT93C66_Poll:
;	FT93C66.c:48: SmallDelay();
	lcall	_SmallDelay
;	FT93C66.c:49: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:50: SmallDelay();
	lcall	_SmallDelay
;	FT93C66.c:51: while(BB_MISO==0)
	mov	r2,#0x00
L004003?:
	jb	_P2_2,L004005?
;	FT93C66.c:53: for(j=0; j<250; j++)
	mov	r3,#0xFA
L004008?:
;	FT93C66.c:55: SmallDelay();
	push	ar2
	push	ar3
	lcall	_SmallDelay
	pop	ar3
	pop	ar2
	djnz	r3,L004008?
;	FT93C66.c:53: for(j=0; j<250; j++)
;	FT93C66.c:57: mscount++;
	inc	r2
;	FT93C66.c:58: if(mscount==200) break;
	cjne	r2,#0xC8,L004003?
L004005?:
;	FT93C66.c:60: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Write_Enable'
;------------------------------------------------------------
;------------------------------------------------------------
;	FT93C66.c:63: void FT93C66_Write_Enable(void)
;	-----------------------------------------
;	 function FT93C66_Write_Enable
;	-----------------------------------------
_FT93C66_Write_Enable:
;	FT93C66.c:65: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:66: SmallDelay();
	lcall	_SmallDelay
;	FT93C66.c:67: spi_io(12, 0b_1001_1000_0000); // Send start bit, op code, and enable bits
	mov	_spi_io_PARM_2,#0x80
	mov	(_spi_io_PARM_2 + 1),#0x09
	mov	dpl,#0x0C
	lcall	_spi_io
;	FT93C66.c:68: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:69: FT93C66_Poll();
	ljmp	_FT93C66_Poll
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Write_Disable'
;------------------------------------------------------------
;------------------------------------------------------------
;	FT93C66.c:72: void FT93C66_Write_Disable(void)
;	-----------------------------------------
;	 function FT93C66_Write_Disable
;	-----------------------------------------
_FT93C66_Write_Disable:
;	FT93C66.c:74: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:75: SmallDelay();
	lcall	_SmallDelay
;	FT93C66.c:76: spi_io(12, 0b_1000_0000_0000); // Send start bit, op code, and disabble bits.
	mov	_spi_io_PARM_2,#0x00
	mov	(_spi_io_PARM_2 + 1),#0x08
	mov	dpl,#0x0C
	lcall	_spi_io
;	FT93C66.c:77: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:78: FT93C66_Poll();
	ljmp	_FT93C66_Poll
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Read'
;------------------------------------------------------------
;add                       Allocated to registers r2 r3 
;val                       Allocated to registers 
;------------------------------------------------------------
;	FT93C66.c:81: unsigned char FT93C66_Read(unsigned int add)
;	-----------------------------------------
;	 function FT93C66_Read
;	-----------------------------------------
_FT93C66_Read:
	mov	r2,dpl
	mov	r3,dph
;	FT93C66.c:84: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:85: SmallDelay();
	push	ar2
	push	ar3
	lcall	_SmallDelay
	pop	ar3
	pop	ar2
;	FT93C66.c:86: spi_io(12, 0b_1100_0000_0000|add); // Send start bit, op code, and A8 down to A0.
	mov	_spi_io_PARM_2,r2
	mov	a,#0x0C
	orl	a,r3
	mov	(_spi_io_PARM_2 + 1),a
	mov	dpl,#0x0C
	lcall	_spi_io
;	FT93C66.c:87: val=spi_io(8, 0xff); // Read 8 bits from the memory location
	mov	_spi_io_PARM_2,#0xFF
	clr	a
	mov	(_spi_io_PARM_2 + 1),a
	mov	dpl,#0x08
	lcall	_spi_io
;	FT93C66.c:88: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:89: return val;
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Erase'
;------------------------------------------------------------
;add                       Allocated to registers r2 r3 
;------------------------------------------------------------
;	FT93C66.c:92: void FT93C66_Erase(unsigned int add)
;	-----------------------------------------
;	 function FT93C66_Erase
;	-----------------------------------------
_FT93C66_Erase:
	mov	r2,dpl
	mov	r3,dph
;	FT93C66.c:94: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:95: SmallDelay();
	push	ar2
	push	ar3
	lcall	_SmallDelay
	pop	ar3
	pop	ar2
;	FT93C66.c:96: spi_io(12, 0b_1110_0000_0000|add); // Send start bit, op code, and A8 down to A0.
	mov	_spi_io_PARM_2,r2
	mov	a,#0x0E
	orl	a,r3
	mov	(_spi_io_PARM_2 + 1),a
	mov	dpl,#0x0C
	lcall	_spi_io
;	FT93C66.c:97: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:98: FT93C66_Poll();
	ljmp	_FT93C66_Poll
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Erase_All'
;------------------------------------------------------------
;------------------------------------------------------------
;	FT93C66.c:101: void FT93C66_Erase_All(void)
;	-----------------------------------------
;	 function FT93C66_Erase_All
;	-----------------------------------------
_FT93C66_Erase_All:
;	FT93C66.c:103: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:104: SmallDelay();
	lcall	_SmallDelay
;	FT93C66.c:105: spi_io(12, 0b_1001_0000_0000); // Send start bit, op code, and A8 down to A0.
	mov	_spi_io_PARM_2,#0x00
	mov	(_spi_io_PARM_2 + 1),#0x09
	mov	dpl,#0x0C
	lcall	_spi_io
;	FT93C66.c:106: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:107: FT93C66_Poll();
	ljmp	_FT93C66_Poll
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Write'
;------------------------------------------------------------
;val                       Allocated with name '_FT93C66_Write_PARM_2'
;add                       Allocated to registers r2 r3 
;------------------------------------------------------------
;	FT93C66.c:110: void FT93C66_Write(unsigned int add, unsigned char val)
;	-----------------------------------------
;	 function FT93C66_Write
;	-----------------------------------------
_FT93C66_Write:
	mov	r2,dpl
	mov	r3,dph
;	FT93C66.c:112: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:113: SmallDelay();
	push	ar2
	push	ar3
	lcall	_SmallDelay
	pop	ar3
	pop	ar2
;	FT93C66.c:114: spi_io(12, 0b_1010_0000_0000|add); // Send start bit, op code, and A8 down to A0.
	mov	_spi_io_PARM_2,r2
	mov	a,#0x0A
	orl	a,r3
	mov	(_spi_io_PARM_2 + 1),a
	mov	dpl,#0x0C
	lcall	_spi_io
;	FT93C66.c:115: spi_io(8, val); // Data to write at memory location.
	mov	_spi_io_PARM_2,_FT93C66_Write_PARM_2
	mov	(_spi_io_PARM_2 + 1),#0x00
	mov	dpl,#0x08
	lcall	_spi_io
;	FT93C66.c:116: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:117: FT93C66_Poll();
	ljmp	_FT93C66_Poll
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Write_All'
;------------------------------------------------------------
;val                       Allocated to registers r2 
;------------------------------------------------------------
;	FT93C66.c:120: void FT93C66_Write_All(unsigned char val)
;	-----------------------------------------
;	 function FT93C66_Write_All
;	-----------------------------------------
_FT93C66_Write_All:
	mov	r2,dpl
;	FT93C66.c:122: FT93C66_CE=1; // Activate the EEPROM.
	setb	_P2_0
;	FT93C66.c:123: SmallDelay();
	push	ar2
	lcall	_SmallDelay
;	FT93C66.c:124: spi_io(12, 0b_1000_1000_0000); // Send start bit, op code, and A8 down to A0.
	mov	_spi_io_PARM_2,#0x80
	mov	(_spi_io_PARM_2 + 1),#0x08
	mov	dpl,#0x0C
	lcall	_spi_io
	pop	ar2
;	FT93C66.c:125: spi_io(8, val); // Data to write at memory location.
	mov	_spi_io_PARM_2,r2
	mov	(_spi_io_PARM_2 + 1),#0x00
	mov	dpl,#0x08
	lcall	_spi_io
;	FT93C66.c:126: FT93C66_CE=0; // De-activate the EEPROM.
	clr	_P2_0
;	FT93C66.c:127: FT93C66_Poll();
	ljmp	_FT93C66_Poll
;------------------------------------------------------------
;Allocation info for local variables in function 'FT93C66_Init'
;------------------------------------------------------------
;------------------------------------------------------------
;	FT93C66.c:130: void FT93C66_Init(void)
;	-----------------------------------------
;	 function FT93C66_Init
;	-----------------------------------------
_FT93C66_Init:
;	FT93C66.c:132: FT93C66_CE=0;
	clr	_P2_0
;	FT93C66.c:133: BB_SCLK=0;
	clr	_P2_3
;	FT93C66.c:134: BB_MOSI=0;
	clr	_P2_1
;	FT93C66.c:135: BB_MISO=1;
	setb	_P2_2
	ret
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST

	CSEG

end
