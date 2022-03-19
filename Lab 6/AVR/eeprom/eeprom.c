#include <avr/io.h>
#include <stdio.h>
#include "usart.h"
#include <util/delay.h>

#define EEPROM_Size 1024

void EEPROM_write(unsigned int uiAddress, unsigned char ucData)
{
	/* Wait for completion of previous write */
	while(EECR & (1<<EEPE));
	/* Set up address and Data Registers */
	EEAR = uiAddress;
	EEDR = ucData;
	/* Write logical one to EEMPE */
	EECR |= (1<<EEMPE);
	/* Start eeprom write by setting EEPE */
	EECR |= (1<<EEPE);
}

unsigned char EEPROM_read(unsigned int uiAddress)
{
	/* Wait for completion of previous write */
	while(EECR & (1<<EEPE));
	/* Set up address register */
	EEAR = uiAddress;
	/* Start eeprom read by writing EERE */
	EECR |= (1<<EERE);
	/* Return data from Data Register */
	return EEDR;
}

int main( void )
{
	unsigned int j, k;
	char myascii[0x10+1];
	char buff[128];
	unsigned char val;

	usart_init (); // configure the usart and baudrate
	
	_delay_ms(500); // Give PuTTY a chance to start
	printf("\x1b[2J\x1b[1;1H"); // Clear screen using ANSI escape sequence.
	printf("EEPROM test.\n");

	while(1)
	{
		printf("\nType something to store in EEPROM: ");
		mygets(buff, sizeof(buff));
		for(j=0; buff[j]!=0; j++) EEPROM_write(j, buff[j]);
	
		printf("\nEEPROM Content:\n");
		
		for(j=0, k=0; j<EEPROM_Size; j++)
		{
			if(k==0) printf("%04X: ", j);
			val=EEPROM_read(j);
			myascii[k]=((val>20)&&(val<0x7f))?val:'.';	
			printf(" %02X", val);
			if(++k==0x10)
			{
				myascii[k]=0;
				printf("   %s\n", myascii);
				k=0;
			}
		}
	}
}
