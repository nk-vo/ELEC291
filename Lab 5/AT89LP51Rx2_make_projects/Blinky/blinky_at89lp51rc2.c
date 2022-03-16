#include <stdio.h>
#include <at89lp51rd2.h>

// ~C51~  

void mydelay (void)
{
	unsigned long int j;
	for(j=0; j<500000; j++);
}

void main (void)
{
	P3M0=0;
	P3M1=0;
	while(1)
	{
		P3_7=0;
		mydelay();
		P3_7=1;
		mydelay();
	}
}
