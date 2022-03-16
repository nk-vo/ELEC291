#include <stdio.h>
#include <at89lp51rd2.h>

// ~C51~ 
 
#define CLK 22118400L
#define BAUD 115200L
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

unsigned char _c51_external_startup(void)
{
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
    
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;
    
    return 0;
}

void wait_us (unsigned char x)
{
	unsigned int j;
	
	TR0=0; // Stop timer 0
	TMOD&=0xf0; // Clear the configuration bits for timer 0
	TMOD|=0x01; // Mode 1: 16-bit timer
	
	if(x>5) x-=5; // Subtract the overhead
	else x=1;
	
	j=-ONE_USEC*x;
	TF0=0;
	TH0=j/0x100;
	TL0=j%0x100;
	TR0=1; // Start timer 0
	while(TF0==0); //Wait for overflow
}

void waitms (unsigned int ms)
{
	unsigned int j;
	unsigned char k;
	for(j=0; j<ms; j++)
		for (k=0; k<4; k++) wait_us(250);
}

int Read_ADC_Channel(unsigned char n)
{
	DADI=n;
	DADI|=ACON; // Connect multiplexer
	DADC|=GO_BSY; // Start conversion
	while(DADC&GO_BSY); // Wait for conversion to complete
	return ((DADH+2)*256)+DADL;
}
	
void main (void)
{
	int mask, result;
	
	CLKREG=0x00; // TPS=0000B
	
	// Configure P0.0 as Input Only (High Impedance).  This is the pin connected
	// to analog input 0.
	
	P0M0=0b_0000_0001;
	P0M1=0b_0000_0000;

	DADC=0; // ADC clock is internal RC oscillator divided by 4 (about 2 MHz)
	DADC|=ADCE;
	
	DADI=0;     // Channel 0 selected
	DADI|=ACON; // Channel 0 enabled

	printf("\n\nAT89LP51xx2 ADC test program.\n");
	
	while(1)
	{
		result=Read_ADC_Channel(0);
		printf("ADC=");
		for(mask=0x200; mask!=0; mask>>=1) putchar((result&mask)?'1':'0');
		printf(", 0x%03x, %5.3fV", result, result*5.0/1023.0);
		putchar('\r');
		waitms(100);
	}
}
