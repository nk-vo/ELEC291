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

	P0M0=0x00; P0M1=0xff; // Port 0 in Push-Pull mode
	P1M0=0x00; P1M1=0x00;    
	P2M0=0xff; P2M1=0x00; // Port 2 in input mode   
	P3M0=0x00; P3M1=0x00;    
	P4M0=0x00; P2M1=0x00; 
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

#define BIT_DELAY 20

int SA_ADC(unsigned char channel)
{
	ACSRA=0; // Disable and disconnect comparator A
	
	// Select one out of three inputs.  Input 1 is connected to the output of the DAC, so it is not available
	// 0 0 AIN0 (P2.4)
	// 0 1 AIN1 (P2.5)  <-- Connected to the output of the DAC
	// 1 0 AIN2 (P2.6)
	// 1 1 AIN3 (P2.7)
	
	switch (channel)
	{
		case 0:
			break;
		default:
		case 1:
			return 0;
		case 2:
			ACSRA|=0b_1000_0000;
			break;	
		case 3:
			ACSRA|=0b_1100_0000;
			break;			
	}
	ACSRA|=(CONA|CENA);  // Enable and connect comparator A

	P0=0;
	wait_us(BIT_DELAY);
	
	P0_7=1;	wait_us(BIT_DELAY); P0_7=(AREF&CMPA)?1:0;
	P0_6=1; wait_us(BIT_DELAY);	P0_6=(AREF&CMPA)?1:0;
	P0_5=1;	wait_us(BIT_DELAY);	P0_5=(AREF&CMPA)?1:0;
	P0_4=1;	wait_us(BIT_DELAY);	P0_4=(AREF&CMPA)?1:0;
	P0_3=1;	wait_us(BIT_DELAY);	P0_3=(AREF&CMPA)?1:0;
	P0_2=1;	wait_us(BIT_DELAY);	P0_2=(AREF&CMPA)?1:0;
	P0_1=1;	wait_us(BIT_DELAY);	P0_1=(AREF&CMPA)?1:0;
	P0_0=1;	wait_us(BIT_DELAY);	P0_0=(AREF&CMPA)?1:0;

	return P0;
}

void main (void)
{
	#define VDD 4.95
	unsigned int result;
	unsigned char j;
	
	CLKREG=0x00; // TPS=0000B
	
	waitms(50);	
	printf("\n\nAT89LP51Rx2 R-2R DAC test program.\n");
	
	while(1)
	{
		for(j=0; j<4; j++)
		{
			if(j!=1)
			{
				result=SA_ADC(j);
				result+=SA_ADC(j);
				result+=SA_ADC(j);
				result+=SA_ADC(j);
				printf("ADC%d=", j);
				printf("0x%04x, %5.3fV ", (int)result, (result*VDD)/(255.0*4.0));
			}
		}
		printf("\r");

		if(RI)
		{
			_asm
			ljmp 0
			_endasm;
		}
	}
}
