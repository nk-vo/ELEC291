#include <avr/io.h>
#include <stdio.h>
#include "usart.h"
#include <util/delay.h>

#define EEPROM_Size 512

// From page 22 of ATmega16 user manual:
void EEPROM_write(unsigned int uiAddress, unsigned char ucData)
{
	/* Wait for completion of previous write */
	while(EECR & (1<<EEWE));
	/* Set up address and data registers */
	EEAR = uiAddress;
	EEDR = ucData;
	/* Write logical one to EEMWE */
	EECR |= (1<<EEMWE);
	/* Start eeprom write by setting EEWE */
	EECR |= (1<<EEWE);
}

// From page 22 of ATmega16 user manual:
unsigned char EEPROM_read(unsigned int uiAddress)
{
	/* Wait for completion of previous write */
	while(EECR & (1<<EEWE));
	/* Set up address register */
	EEAR = uiAddress;
	/* Start eeprom read by writing EERE */
	EECR |= (1<<EERE);
	/* Return data from data register */
	return EEDR;
}

int main( void )
{
	unsigned int j, k;
	char myascii[0x10+1];
	char buff[128];
	char buff2[0x10];
	unsigned char val;

	usart_init (); // configure the usart and baudrate
	
	_delay_ms(500); // Give PuTTY a chance to start
	printf("\x1b[2J\x1b[1;1H"); // Clear screen using ANSI escape sequence.
	printf("EEPROM test.\n");

	while(1)
	{
		printf("\nType something to store in EEPROM: ");
		mygets(buff, sizeof(buff));
		printf("\nLocation: ");
		mygets(buff2, sizeof(buff2));
		sscanf(buff2,"%i", &k);
		for(j=0; buff[j]!=0; j++) EEPROM_write(j+k, buff[j]);
	
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
