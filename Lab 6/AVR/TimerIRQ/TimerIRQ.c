#include <avr/io.h>
#include <avr/interrupt.h>

unsigned int cnt = 0;

ISR(TIMER1_OVF_vect)
{
	cnt++;
	if(cnt>100)
	{
		cnt=0;
		PORTB ^= 0x01;	// Toggle the LED connected to pin 14
	}
}

int main(void)
{
	// Set PORTB 0 pin as output, turn it off
	DDRB = 0x01;
	PORTB = 0x00;

	// Turn on timer with no prescaler on the clock for fastest
	// triggering of the interrupt service routine.
	TCCR1B |= _BV(CS10);
	TIMSK1 |= _BV(TOIE1);

	sei(); // Turn interrupts on.

	while (1)
	{
	}
}