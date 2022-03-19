#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>

unsigned int cnt = 0;

void wait_1ms(void)
{
	unsigned int saved_TCNT1;
	
	saved_TCNT1=TCNT1;
	
	while((TCNT1-saved_TCNT1)<(F_CPU/1000L)); // Wait for 1 ms to pass
}

void waitms(int ms)
{
	while(ms--) wait_1ms();
}

int main(void)
{
	// Set PORTB 0 pin as output, turn it off
	DDRB = 0x01;
	PORTB = 0x00;

	// Turn on timer with no prescaler on the clock.
	TCCR1B |= _BV(CS10); // Check page 110 of ATmega328P datasheet

	while (1)
	{
		PORTB ^= 0x01;	// Toggle the LED connected to pin 14
		waitms(500);
	}
}