#include <avr/io.h>
#include <stdio.h>
#include "usart.h"

int main( void )
{
	int j;

	usart_init (); // configure the usart and baudrate

	printf("Hello, World!\n");
	for(j=0; j<10; j++)	printf("j= %d\n", j);

	while(1)
	{
		// do nothing
	}
}
