#include <at89lp51rd2.h>

#define CLK 22118400L // SYSCLK frequency in Hz
#define TIMER_0_FREQ 1000L // For a 1 ms tick

volatile unsigned int TickCount=0;

unsigned char _c51_external_startup(void)
{	
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O

	// Configure all pins as bidirectional
	P0M0=0x00; P0M1=0x00;    
	P1M0=0x00; P1M1=0x00;    
	P2M0=0x00; P2M1=0x00;    
	P3M0=0x00; P3M1=0x00;
    
	// Initialize timer 0 for periodic interrupts
	TR0=0;
	TF0=0;
	TMOD&=0xf0;
	TMOD|=0x01; // Timer 0 in mode 1: 16-bit timer
	#if (CLK/(TIMER_0_FREQ)>0xFFFFL)
		#error Timer 0 reload value is incorrect because CLK/(TIMER_0_FREQ) > 0xFFFFL
	#endif
	RH0=(0x10000L-(CLK/(TIMER_0_FREQ)))/0x100; // Initialize reload value
	RL0=(0x10000L-(CLK/(TIMER_0_FREQ)))%0x100; // Initialize reload value
	ET0=1; // Enable Timer0 interrupts
	TR0=1; // Start Timer0
	EA=1;  // Enable global interrupts

    return 0;
}

void Timer0_ISR (void) interrupt 1
{
	TickCount++;
	if(TickCount==500)
	{
		TickCount=0;
		P3_7=!P3_7; // Toggle P3_7 (where the LED is)
	}
}

void main (void)
{
	while(1)
	{
	}
}
