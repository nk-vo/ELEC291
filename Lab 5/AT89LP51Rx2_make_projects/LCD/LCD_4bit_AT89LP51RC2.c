//  AT89LP51RC2 with LCD in 4-bit interface mode
//  2008-2018 Jesus Calvino-Fraga

#include <stdio.h>
#include "hardware.h"
#include "LCD.h"

char mystr[CHARS_PER_LINE+1];

void main (void)
{
	unsigned char j;
	char c;
	
	waitms(500); // Gives time to putty to start before sending text
	
	// Configure the LCD
	LCD_4BIT();
	
   	// Display something in the LCD
	LCDprint("LCD 4-bit test:", 1, 1);
	LCDprint("Hello, World!", 2, 1);
	
	// Send text to putty
	printf("LCD test.\nType something and press <Enter>\n(it will show in the LCD, %d characters max): ", CHARS_PER_LINE);
	
	while(1)
	{
		if(RI)
		{
			// We don't use gets() here because we can overflow mystr[]
			for(j=0; j<CHARS_PER_LINE; j++)
			{
				c=getchar();
				if((c=='\n')||(c=='\r'))
				{
					mystr[j]=0;
					LCDprint(mystr, 2, 1);
					break;
				}
				mystr[j]=c;
			}
			if(j==CHARS_PER_LINE)
			{
				mystr[j]=0;
				LCDprint(mystr, 2, 1);
			}
			printf("\nType something: ");
		}
	}
}
