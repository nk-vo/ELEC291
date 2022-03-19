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

void PrintNumber(int N, int Base, int digits)
{ 
	char HexDigit[]="0123456789ABCDEF";
	int j;
	#define NBITS sizeof(int)
	char buff[NBITS+1];
	buff[NBITS]=0;

	j=NBITS-1;
	while ( (N>0) | (digits>0) )
	{
		buff[j--]=HexDigit[N%Base];
		N/=Base;
		if(digits!=0) digits--;
	}
	usart_pstr(&buff[j+1]);
}

int main( void )
{
	unsigned int adc;
	unsigned long int v;
	
	usart_init (); // configure the usart and baudrate
	DDRB |= 0x01;
	PORTB |= 0x01;

	usart_pstr("\r\nADC test\r\n");

	while(1)
	{
		adc=ReadChannel(0);
		v=(adc*5000L)/1023L;
		usart_pstr("ADC[0]=0x");
		PrintNumber(adc, 16, 3);
		usart_pstr(", ");
		PrintNumber(v/1000, 10, 1);
		usart_pstr(".");
		PrintNumber(v%1000, 10, 3);
		usart_pstr("V          \r");
		PORTB ^= 0x01;
		_delay_ms(500);
	}
}
