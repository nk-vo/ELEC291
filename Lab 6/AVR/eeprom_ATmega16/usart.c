#include <avr/io.h>
#include <stdio.h>
#include "usart.h"

static FILE mystdout = FDEV_SETUP_STREAM(usart_putchar_printf, NULL, _FDEV_SETUP_WRITE);

// Mostly from page 150 of ATmega16 user manual:
void usart_init( void)
{
	stdout = &mystdout; // setup our stdio stream

	/* Set baud rate */
	UBRRH = (unsigned char)(_UBRR>>8);
	UBRRL = (unsigned char)_UBRR;

	/* Enable receiver and transmitter */
	UCSRB = (1<<RXEN)|(1<<TXEN);
	/* Set frame format: 8data, 2 stop bit */
	UCSRC = (1<<URSEL)|(1<<USBS)|(3<<UCSZ0);
}

// Mostly from page 151 of ATmega16 user manual:
void usart_putchar(char data)
{
	/* Wait for empty transmit buffer */
	while ( !( UCSRA & (1<<UDRE)) );
	/* Put data into buffer, sends the data */
	UDR = data;
}

// Mostly from page 154 of ATmega16 user manual:
char usart_getchar(void)
{
	/* Wait for data to be received */
	while ( !(UCSRA & (1<<RXC)) );
	/* Get and return received data from buffer */
	return UDR;
}

unsigned char usart_kbhit(void)
{
	return (UCSRA & (1<<RXC))?1:0; // return nonzero if char waiting polled version
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
