#include <avr/io.h>
#include <stdio.h>
#include "uart.h"

// This code is mostly from http://efundies.com/avr-and-printf/

static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar_printf, NULL, _FDEV_SETUP_WRITE);

void uart_init( void)
{
	stdout = &mystdout; // setup our stdio stream

	// Not necessary; initialize anyway
	DDRD |= _BV(PD1);
	DDRD &= ~_BV(PD0);

	// Set baud rate; lower byte and top nibble
	UBRR0H = ((_UBRR) & 0xF00);
	UBRR0L = (uint8_t) ((_UBRR) & 0xFF);

	TX_START();
	RX_START();

	// Set frame format = 8-N-1
	UCSR0C = (_DATA << UCSZ00);
	//UCSR0A bits: RXC0 TXC0 UDRE0 FE0 DOR0 UPE0 U2X0 MPCM0
	UCSR0A|=0x02; // U2X0 double speed
}

void uart_putc(unsigned char val)
{
	while ( !(UCSR0A & (_BV(UDRE0))) ); // Wait for empty transmit buffer
	UDR0 = val; // Start transmission of data
}

unsigned char uart_getc(void)
{
	while ( !(UCSR0A & (_BV(RXC0))) ); // Wait for incoming data
	return UDR0; // Return received data
}

unsigned char uart_kbhit(void)
{
	return (UCSR0A & (1<<RXC0))?1:0; //return nonzero if char waiting polled version
}

void uart_puts(char *s)
{
	while (*s)
	{
		uart_putc(*s); // loop through entire string
		s++;
	}
}

int uart_putchar_printf(char var, FILE *stream)
{
	if (var == '\n') uart_putc('\r'); // translate \n to \r + \n
	uart_putc(var);
	return 0;
}
