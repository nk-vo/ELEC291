#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <at89lp51rd2.h>

// ~C51~  --model-small

#define CLK 22118400L
#define BAUD 115200L
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))
#define sqr(x) (x*x)

float sumx  = 0.0;
float sumx2 = 0.0;
float sumxy = 0.0;
float sumy  = 0.0;
float sumy2 = 0.0;
float x, y, m, b, r;

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


volatile int result;

int Read_ADC_Channel(unsigned char n)
{
	DADI=n;
	DADI|=ACON; // Connect multiplexer
	waitms(10);
	DADC|=GO_BSY; // Start conversion
	while(DADC&GO_BSY); // Wait for conversion to complete
	_asm
		mov _result, _DADL
		mov _result+1, _DADH
		inc _result+1
		inc _result+1
	_endasm;
	return result;
}
 
void main (void)
{
	int j, n;
	unsigned int mask;
	
	CLKREG=0x00; // TPS=0000B
	printf("\n\nAT89LP51rx2 ADC calibration.\nTo finish calibration enter a value > 5.0V.\n\n");
	
	// Configure P0.0 as Input Only (High Impedance)
	P0M0=0x01;
	P0M1=0x00;
	
	// Configure ADC
	DADC=0; //Set internal RC oscillator as the clock for the ADC
	DADC|=ADCE;
	
	n=0;
	while(1)
	{
		printf("Enter new voltage at P0.0: ");
		scanf("%f", &y);
		
		if(y>5.0) break;

		n++;
		// Measure the output of the DAC using the internal uncalibrated ADC:
		x=0.0;
		for(j=0; j<128; j++) // Take the average of several samples to minimize error
		{
			x+=Read_ADC_Channel(0);
		}
		x/=j;

		// Display the results so far in the terminal
		printf("\n%4.0f: %5.3fV\n", x, y);
		
		// Only take into account not saturated results.
		if((x>2.0) && (x<1022.0))
		{
			n++;
			sumx+=x;
			sumx2+=sqr(x);
			sumxy+=(x*y);
			sumy+=y;
			sumy2+=sqr(y);
		}
	}
	
	// Perform linear regression to find the slope and offset
	x=(n * sumxy - sumx * sumy);
	y=(n * sumx2 - sqr(sumx));
	m = x / y;
	printf("\nm=%12.6e\n", m);
	
	x=(sumy * sumx2 - sumx * sumxy);
	b = x / y;
	printf("b=%12.6e\n", b);
	
	x=(sumxy - sumx * sumy / n);
	y=sqrtf((sumx2 - sqr(sumx)/n) * (sumy2 - sqr(sumy)/n));
	r = x / y;
	printf("r=%12.6e\n\n", r);

	// Use the computed calibration parameters to display the voltage in at pin P0.0:
	while(1)
	{
		Read_ADC_Channel(0);
		
		printf("ADC=");
		for(mask=0x200; mask!=0; mask>>=1) putchar((result&mask)?'1':'0');
		printf(", 0x%04x, %5.3fV", result, result*m+b);
		putchar('\r');
		waitms(100);
	}
}
