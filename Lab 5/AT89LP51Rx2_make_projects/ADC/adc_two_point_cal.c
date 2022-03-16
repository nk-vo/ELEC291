#include <stdio.h>
#include <at89lp51rd2.h>

// ~C51~ 
 
#define CLK 22118400L
#define BAUD 115200L
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))
//#define BRG_VAL (0x100-(CLK/(32L*BAUD)))

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

void ADC_ISR (void) interrupt 13
{
}

int Read_ADC_Channel2(unsigned char n)
{
    DADC&=~ADCE;
    DADI&=~ACON;
    DADI&=0xf8;
	DADI|=n;
	DADI|=ACON; // Connect multiplexer	
    DADC|=ADCE;
        
	DADC|=GO_BSY; // Start conversion
	while(DADC&GO_BSY); // Wait for conversion to complete
	return ((DADH+2)*256)+DADL;
}

int Read_ADC_Channel(unsigned char n)
{
	unsigned int j;

	TR0=0; // Stop timer 0
	TMOD&=0xf0; // Clear the configuration bits for timer 0
	TMOD|=0x01; // Mode 1: 16-bit timer

	j=-ONE_USEC*200;
	TF0=0;
	TH0=j/0x100;
	TL0=j%0x100;

    DADC&=~ADCE;
    DADI&=~ACON;
    DADI&=0xf8;
	DADI|=n;
	DADI|=ACON; // Connect multiplexer
	DADI|=TRG0; // Start conversion on timer 0 overflow	
    DADC|=ADCE;
    
    IEN1|=0x20; // Enable ADC interrupt
    EA=1;
    
	TR0=1; // Start timer 0
	PCON|=0x01; // Go to idle mode
	TR0=0;
	IEN1&=(~0x20); // Disable ADC interrupt
	
	return ((DADH+2)*256)+DADL;
}
	
void main (void)
{
	#define VDD 5.031 // Measured with multimeter
	float V[2] = { VDD*(2.0/3.0), VDD*(1.0/3.0)};
	float ADC[2];
	float m, v0;
	float result;
	unsigned int j, mask;
	
	CLKREG=0x00; // TPS=0000B
	
	// Configure P0.0 as Input Only (High Impedance).  This is the pin connected
	// to analog input 0.
	P0M0=0x07;
	P0M1=0x00;
	
	printf("\n\nAT89LP51Rx2 ADC test program with self calibration:\n");
	printf("   1) Connect a 150 ohm resistor from P0.1 to VDD\n");
	printf("   2) Connect a 150 ohm resistor from P0.1 to P0.2\n");
	printf("   3) Connect a 150 ohm resistor from P0.2 to GND\n");
	printf("Pick three resistors that are almost identical (less than 0.1%% difference)\n");
	
	DADI=0x00;
	DADC=0x00;

	//DADC=ACK2|ACK1|ACK0; // Slowest possible clock for the ADC
	//DADC=0;
	DADC=ACK1; // CLK/16
	DADC|=ADCE;
	
	// Get slope and offset
	for(ADC[0]=0.0, j=0; j<1024; j++)
	{
		ADC[0]+=Read_ADC_Channel(1);
	}
	ADC[0]/=j;
		
	for(ADC[1]=0.0, j=0; j<1024; j++)
	{
		ADC[1]+=Read_ADC_Channel(2);
	}
	ADC[1]/=j;
	
	m=(V[0]-V[1])/(ADC[0]-ADC[1]);
	v0=V[0]-m*ADC[0];
	
	printf("\nV=m*ADC+v0 where m=%e v0=%e\n\n", m, v0);
	
	while(1)
	{
		for(result=0.0, j=0; j<128; j++)
		{
			result+=Read_ADC_Channel(0);
		}
		result/=j;
		//result=Read_ADC_Channel(0);
		printf("ADC=");
		for(mask=0x200; mask!=0; mask>>=1) putchar((((int)result)&mask)?'1':'0');
		printf(", 0x%04x, %5.3fV\r", (int)result, result*m+v0);
		waitms(100);
		if(RI)
		{
			_asm
			ljmp 0
			_endasm;
		}
	}
}
