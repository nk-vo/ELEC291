#include <avr/io.h>
#include <stdio.h>
#include "usart.h"

static FILE mystdout = FDEV_SETUP_STREAM(usart_putchar_printf, NULL, _FDEV_SETUP_WRITE);

// Mostly from page 172 of ATmega16 user manual:
void usart_init( void)
{
	stdout = &mystdout; // setup our stdio stream

	/* Set baud rate */
	UBRR0H = (unsigned char)(_UBRR>>8);
	UBRR0L = (unsigned char)_UBRR;

	/* Enable receiver and transmitter */
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	/* Set frame format: 8data, 2 stop bit */
	UCSR0C = (1<<URSEL0)|(1<<USBS0)|(3<<UCSZ00);
}

// Mostly from page 173 of ATmega162 user manual:
void usart_putchar(char data)
{
	/* Wait for empty transmit buffer */
	while ( !( UCSR0A & (1<<UDRE0)) );
	/* Put data into buffer, sends the data */
	UDR0 = data;
}

// Mostly from page 176 of ATmega162 user manual:
char usart_getchar(void)
{
	/* Wait for data to be received */
	while ( !(UCSR0A & (1<<RXC0)) );
	/* Get and return received data from buffer */
	return UDR0;
}

unsigned char usart_kbhit(void)
{
	return (UCSR0A & (1<<RXC0))?1:0; // return nonzero if char waiting polled version
}

void usart_pstr(char *s)
{
	while (*s)
	{
		usart_putchar(*s); // loop through entire string
		s++;
	}
}

int usart_putchar_printf(char var, FILE *stream)
{
	if (var == '\n') usart_putchar('\r'); // translate \n to \r + \n
	usart_putchar(var);
	return 0;
}

int mygets(char * rxstr, int max)
{
	int j=0;
	char c;

	while( j<(max-1) )
	{
		c=usart_getchar();
		if(c=='\r') break;
		rxstr[j++]=c;
		usart_putchar(c); // echo
	}
	rxstr[j]=0;

	return j;
}
