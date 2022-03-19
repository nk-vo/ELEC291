#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#include "usart.h"

int main( void )
{
	usart_init (); // configure the usart and baudrate

	// Configure PB1 for input.  Information here:
	// http://www.elecrom.com/avr-tutorial-2-avr-input-output/
	DDRB  &= 0b11111101; // PB1 is input
	PORTB |= 0b00000010; // Activate pull-up in PB1

	printf("Push button test for ATmega328P. Connect push-button between PB1 and GND.\n");

	while(1)
	{
		printf("PB1 (pin 15)=%c\r", (PINB&0b00000010)?'1':'0');
		_delay_ms(300);
	}
}
