#include <stdio.h>
#include <at89lp51rd2.h>
#include <math.h>

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
	P2M0=0xff; P2M1=0xff;    
	P3M0=0x00; P3M1=0x00;    
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

void main (void)
{
	unsigned int j;
	xdata unsigned char sine[256];
	unsigned char delay=50;
	
	CLKREG=0x00; // TPS=0000B
	
	waitms(50);	
	printf("\n\nAT89LP51Rx2 R-2R DAC test program.\n");
	
	for(j=0; j<256; j++)
	{
		sine[j]=128+127.0*sinf(j*2*PI/255);
	}
	
	while(1)
	{
		for(j=0; j<256; j++)
		{
			if(P3_6)
			{
				P0=j;
				wait_us(delay);
			}
			else
			{
				P0=sine[j];
				wait_us(delay);
			}
		}
		if(RI)
		{
			_asm
			ljmp 0
			_endasm;
		}
		if(P4_5==0)
		{
			delay+=5;
			if(delay>100) delay=5;
			while (P4_5==0);
		}
	}
}
