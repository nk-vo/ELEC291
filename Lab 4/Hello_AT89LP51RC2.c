//  AT89LP51RC2 "Hello, World!" example.
//  ~C51~

#include <stdio.h>
#include <at89lp51rd2.h>

#define CLK    22118400L // SYSCLK frequency in Hz
#define BAUD     115200L // Baud rate of UART in bps
#if ((CLK/(16L*BAUD))>0x100L)
#error "Can not set baud rate because (CLK/(16*BAUD)) > 0x100 "
#endif
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

unsigned char _c51_external_startup(void)
{	
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is I/O
    
	// Configure serial port and baud rate
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;

    return 0;
}

void main (void)
{
	printf("Hello, World!\n");
}
