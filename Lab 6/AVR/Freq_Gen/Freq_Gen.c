#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <stdlib.h>
#include "usart.h"

#define DEF_FREQ 15000L
#define OCR1_RELOAD ((F_CPU/(2*DEF_FREQ))+1)

volatile unsigned int reload;

// 'Timer 1 output compare A' Interrupt Service Routine
ISR(TIMER1_COMPA_vect)
{
	OCR1A = OCR1A + reload;
	PORTB ^= 0b00000011; // Toggle PB0 and PB1
}

void main (void)
{
	char buff[32];
	unsigned long newF;
	
	reload=OCR1_RELOAD; // Reload value for default output frequency 

	DDRB=0b00000011; // PB1 (pin 15) and PB0 (pin 14) are our outputs
	PORTB |= 0x01; // PB0=NOT(PB1)
	TCCR1B |= _BV(CS10);   // set prescaler to Clock/1
	TIMSK1 |= _BV(OCIE1A); // output compare match interrupt for register A
	
	sei(); // enable global interupt

	usart_init(); // configure the usart and baudrate
	
	printf("Square wave generator for ATmega328p\r\n");
	printf("By Jesus Calvino-Fraga (c) 2018\r\n");
	
	while(1)
    {
    	printf("Frequency: ");
    	usart_gets(buff, sizeof(buff)-1);
    	newF=atol(buff);

	    if(newF>111000L)
	    {
	       printf("\r\nWarning: The maximum frequency that can be generated is around 111000Hz.\r\n");
	       newF=111000L;
	    }
	    if(newF>0)
	    {
			reload=(F_CPU/(2L*newF))+1;  
		    printf("\r\nFrequency set to: %ld\r\n", F_CPU/((reload-1)*2L));
        }
    }
}