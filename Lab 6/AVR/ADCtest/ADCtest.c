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
	ADCSRA |= (1<<ADSC); // a transformation "single conversion"
	while ( ADCSRA & (1<<ADSC) );
	ADCSRA &= ~(1<<ADEN); // Disable ADC
	return ADCW;
}

int main( void )
{
	unsigned int adc;
	float voltage, temperature;
	usart_init (); // configure the usart and baudrate
	DDRB |= 0x01;
	PORTB |= 0x01;

	printf("\nADC test\n");

	while(1)
	{
		adc=ReadChannel(0);
		voltage = (adc*5.0)/1023.0;
		temperature = 100 *( voltage - 2.73);
		printf("%f\n", temperature);
		// printf("ADC[0]=0x%03x, %fV\r", adc, (adc*5.0)/1023.0);
		// PORTB ^= 0x01;
		if (temperature >= 26 && temperature < 30) {
			PORTB &= (~0x01);
			_delay_ms(500);
		}
		else if (temperature >= 30) {
			PORTB ^= 0x01;
			_delay_ms(500);
		}
		else {
			PORTB |= 0x01;
			_delay_ms(500);
		}
		
		
	}
}
