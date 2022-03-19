#include <avr/io.h>
#include <stdio.h>
#include "uart.h"

#include <avr/io.h>
#include <util/delay.h>

int main( void )
{
	unsigned char j=0;
	
	uart_init (); // configure the usart and baudrate

	printf("pwm output test\n");
	
    DDRD |= (1 << DDD6); // PD6 is now an output
    OCR0A = 128; // set PWM for 50% duty cycle
    TCCR0A |= (1 << COM0A1); // set none-inverting mode
    TCCR0A |= (1 << WGM01) | (1 << WGM00); // set fast PWM Mode
    TCCR0B |= (1 << CS00); // set prescaler to none and starts PWM

	while(1)
	{
		OCR0A=j;
		j++;
		_delay_ms(10);
	}
}
