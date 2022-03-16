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

	P1M0=0; P1M1=0;    
	P2M0=0; P2M1=0;    
	P3M0=0; P3M1=0;    
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
    #if (CLK/(16L*BAUD))>0x100
    #error Can not set baudrate
    #endif
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
    DADC&=~ADCE;
    DADI&=~ACON;
    DADI&=0xf8;
	DADI|=DIFF;
	DADI|=n;
	DADI|=ACON; // Connect multiplexer	
    DADC|=ADCE;
        
	DADC|=GO_BSY; // Start conversion
	while(DADC&GO_BSY); // Wait for conversion to complete
	return (DADH*256)+DADL;
}

void main (void)
{
	#define VDD 4.96 // Measured with multimeter
	float result;
	unsigned mask;
	
	CLKREG=0x00; // TPS=0000B
	
	// Configure P0 as Input Only (High Impedance).  
	P0M0=0xff;
	P0M1=0x00;
	
	waitms(500);
	printf("\n\nAT89LP51Rx2 ADC test program in differential mode.\n");
	
	DADI=0x00;
	DADC=0x00;

	DADC=ACK1; // CLK/16
	DADC|=ADCE;
	
	while(1)
	{
		result=Read_ADC_Channel(0);
		printf("ADC=");
		for(mask=0x200; mask!=0; mask>>=1) putchar((((int)result)&mask)?'1':'0');
		printf(", 0x%04x, %5.3fV\r", (int)result, result*VDD/1023);
		waitms(100);
		if(RI)
		{
			_asm
			ljmp 0
			_endasm;
		}
	}
}
