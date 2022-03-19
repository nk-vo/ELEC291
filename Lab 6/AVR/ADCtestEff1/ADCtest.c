// This code is mostly from http://efundies.com/avr-and-printf/

#define F_CPU 16000000UL

#include <avr/io.h>
#include <stdio.h>
#include <stdbool.h>
#include <util/delay.h>
#include "usart.h"

unsigned int ReadChannel(unsigned char mux)
{
	ADCSRA = (1<<ADEN) | (1<<ADPS1) | (1<<ADPS0); // frequency prescaler
	ADMUX = mux; // channel select
	ADMUX |= (1<<REFS1) | (1<<REFS0); 
	ADCSRA |= (1<<ADSC); // Start conversion
	while ( ADCSRA & (1<<ADSC) ) ;
	ADCSRA |= (1<<ADSC); // a transformation “single conversion”
	while ( ADCSRA & (1<<ADSC) );
	ADCSRA &= ~(1<<ADEN); // Disable ADC
	return ADCW;
}

int main( void )
{
	unsigned int adc;
	unsigned long int v;
	
	usart_init (); // configure the usart and baudrate
	DDRB |= 0x01;
	PORTB |= 0x01;

	printf("\nADC test\n");

	while(1)
	{
		adc=ReadChannel(0);
		v=(adc*5000L)/1023L;
		printf("ADC[0]=0x%03x, %ld.%03ldV\r", adc, v/1000, v%1000);
		PORTB ^= 0x01;
		_delay_ms(500);
	}
}
