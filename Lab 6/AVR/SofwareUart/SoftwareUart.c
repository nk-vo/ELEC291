#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#define sBAUD 9600
#define sOUTPORT PORTB
#define sINPORT  PINB
#define sTXD (1<<PB0) // PB0 is used as sTXd, Pin14 of ATmega328p (DIP28)
#define sRXD (1<<PB1) // PB1 is used as sRXD, Pin15 of ATmega328p (DIP28)

unsigned char echo=0;

void ConfigureSoftwareUART (void)
{
	DDRB |= sTXD;    // Configure pin sTXD as output
	PORTB |= sTXD;   // Default state of transmit pin is 1
	DDRB &= (~sRXD); // Configure pin sRXD as input
}

void SendByte (unsigned char c)
{
	unsigned char i;
	
	// Send start bit
	sOUTPORT &= (~sTXD);
  	_delay_us(1E6/sBAUD);
  	// Send 8 data bits
	for (i=0; i<8; i++)
  	{
    	if( c & 1 )
    	{
      		sOUTPORT |= sTXD;
      	}
    	else
      	{
      		sOUTPORT &= (~sTXD);
      	}
    	c >>= 1;
		_delay_us(1E6/sBAUD);
 	}
 	// Send the stop bit
	sOUTPORT |= sTXD;
	_delay_us(1E6/sBAUD);
}

unsigned char GetByte (void)
{
	unsigned char c, i;
	
	// Wait for input pin to change to zero (start bit)
	while(sINPORT&sRXD); 
	// Wait one and a half bit-time to sample in the middle of incomming bits
	_delay_us((3*1E6)/(2*sBAUD));
	// Receive 8 data bits
	for (i=0, c=0; i<8; i++)
  	{
  		c>>=1;
  		if(sINPORT&sRXD) c|=0x80;
		_delay_us(1E6/sBAUD);
	}
	if(echo==1) SendByte(c); // If echo activated send back what was received
	if(c==0x05) // Control+E activates echo
	{
		echo=1;
	}
	if(c==0x06) // Control+F de-activates echo
	{
		echo=0;
	}
	return c;
}

void SendString(char * s)
{
	while(*s != 0) SendByte(*s++);
}

void GetString(char * s, int nmax)
{
	unsigned char c;
	int n;
	
	while(1)
	{
		c=GetByte();
		if( (c=='\n') || (c=='\r') || n==(nmax-1) )
		{
			*s=0;
			return;
		}
		else
		{
			*s=c;
			s++;
			n++;
		}
	}
}

int main(void)
{
	char buff[80];
	unsigned char i;
	
	ConfigureSoftwareUART();
	SendString("Hello, World!  Using software (bit-bang) UART\r\n");
	while(1) 
	{
		SendString("\r\nType Something: ");
		GetString(buff, sizeof(buff)-1);
		SendString("\r\nYou typed: ");
		SendString(buff);		
	}
	return 0;
}
