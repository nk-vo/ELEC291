//  AT89LP51RC2 with LCD in 4-bit interface mode
//  Copyright (c) 2008-2018 Jesus Calvino-Fraga
//  ~C51~

#include <stdio.h>
#include <at89lp51rd2.h>

#define CLK    22118400L // SYSCLK frequency in Hz
#define BAUD     115200L // Baud rate of UART in bps
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

unsigned char _c51_external_startup(void)
{	
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
    
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
	#if ((CLK/(16L*BAUD))>0x100L)
	#error "Can not set baud rate because (CLK/(16*BAUD)) > 0x100 "
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
	waitms(100);  // Debounce the reset button!
	printf("Hello, World!\n");
	
	while(1)
	{
		P3_7=!P3_7;
		waitms(500);
	}
}
