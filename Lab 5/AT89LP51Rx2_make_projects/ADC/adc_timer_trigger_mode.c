#include <stdio.h>
#include <at89lp51rd2.h>

// ~C51~ 
 
#define CLK 22118400L
#define BAUD 115200L
#define BRG_VAL (0x100-(CLK/(32L*BAUD)))

unsigned char _c51_external_startup(void)
{
	// Configure ports as a bidirectional with internal pull-ups.
	P0M0=0;	P0M1=0;
	P1M0=0;	P1M1=0;
	P2M0=0;	P2M1=0;
	P3M0=0;	P3M1=0;
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
	P4M0=0;	P4M1=0;
    
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;
    
    return 0;
}

void wait (void)
{
	_asm	
		;For a 22.1184MHz crystal one machine cycle 
		;takes 12/22.1184MHz=0.5425347us
	    mov R2, #5
	L3:	mov R1, #250
	L2:	mov R0, #184
	L1:	djnz R0, L1 ; 2 machine cycles-> 2*0.5425347us*184=200us
	    djnz R1, L2 ; 200us*250=0.05s
	    djnz R2, L3 ; 0.05s*5=0.25s
	    ret
    _endasm;
}

volatile int result;

void ADC_ISR(void) interrupt ((0x63-0x03)/8)
{
	_asm
		mov _result+0, _DADL
		mov _result+1, _DADH
		inc _result+1
		inc _result+1
		mov a, _DADL
		cpl a
		mov P2, a
	_endasm;
}
	
void main (void)
{
	int mask;
	
	CLKREG=0x00; // TPS=0000B
	
	// Re-configure P0.0 as Input Only (High Impedance).  This is the pin connected
	// to analog input 0.
	
	P0M0=0x01;
	P0M1=0x00;

	DADC=ACK2|ACK1|ACK0;
	DADC=ADCE;
	DADI=0|TRG0; // Channel 0 selected, trigger with timer 0 overflow
	
	IEN1=EADC;
	EA=1;

	printf("\n\nAT89LP51RB2 ADC test program (using TRG0).\n");
	
	while(1)
	{
		TMOD=0x01;
		TCON=0x00;
		TH0=0xff;
		TL0=0x00;
		DADI|=ACON; // Connect
		TR0=1; 
		PCON|=IDL;
		TR0=0;
		DADI&=~ACON; // Disconnect		
		printf("ADC=");
		for(mask=0x200; mask!=0; mask>>=1) putchar((result&mask)?'1':'0');
		putchar('\r');
		wait();
	}
}
