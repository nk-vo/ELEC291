//  freq_gen.c: Uses timer 2 interrupt to generate a square wave at pin
//  P0.0.  The program allows the user to enter a new frequency.
//  ~C51~

#include <stdio.h>
#include <at89lp51rd2.h>

#define CLK 22118400L // SYSCLK frequency in Hz
#define BAUD 115200L // Baud rate of UART in bps
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))
#define DEFAULT_F 2000L

#define TONEOUT P0_0

unsigned char _c51_external_startup(void)
{	
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O

	// Configure all pins as bidirectional
	P0M0=0x00; P0M1=0x00;    
	P1M0=0x00; P1M1=0x00;    
	P2M0=0x00; P2M1=0x00;    
	P3M0=0x00; P3M1=0x00;
    
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
	#if ((CLK/(16L*BAUD))>0x100L)
	#error "Can not set baud rate because (CLK/(16*BAUD)) > 0x100 "
	#endif
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;

	// Initialize timer 2 for periodic interrupts
	T2CON=0x00;   // Stop Timer2; Clear TF2;
	RCAP2H=(0x10000L-(CLK/(2*DEFAULT_F)))/0x100; // Change reload value for new frequency high
	RCAP2L=(0x10000L-(CLK/(2*DEFAULT_F)))%0x100; // Change reload value for new frequency low
	TH2=0xff; // Set to reload immediately
	TL2=0xff; // Set to reload immediately
	ET2=1; // Enable Timer2 interrupts
	TR2=1; // Start Timer2
	EA=1; // Global interrupt enable

    return 0;
}

void Timer2_ISR (void) interrupt 5
{
	TF2 = 0; // Clear Timer2 interrupt flag
	TONEOUT=!TONEOUT;
}

void main (void)
{
	unsigned long int x, f;
	
	printf("\x1b[2J"); // Clear screen using ANSI escape sequence.
	printf("Variable frequency generator for the AT89LP51RC2.\r\n"
	       "Check pin P0.0 with the oscilloscope.\r\n");

	while(1)
	{
		printf("New frequency=");
		scanf("%lu", &f);
		x=(CLK/(2L*f));
		if(x>0xffff)
		{
			printf("Sorry %lu Hz is out of range.\n", f);
		}
		else
		{
			x=0x10000L-x;
			TR2=0; // Stop timer 2
			RCAP2H=x/0x100; // Change reload value for new frequency high
			RCAP2L=x%0x100; // Change reload value for new frequency low
			TR2=1; // Start timer 2
			
			f=CLK/(2L*(0x10000L-x));
			printf("\nActual frequency: %lu\n", f);
		}
	}
}
