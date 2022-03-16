#include <stdio.h>
#include <stdlib.h>
#include <at89lp51rd2.h>

#define FT93C66_CE P2_0
#define BB_MOSI P2_1
#define BB_MISO P2_2
#define BB_SCLK P2_3

void SmallDelay (void)
{
	_asm
		nop ; 45 ns @ 22.1148 MHz
		nop ; 90 ns
		nop ; 135 ns 
		nop ; 180 ns 
		nop ; 225 ns 
		nop ; 270 ns 
	_endasm;
}

unsigned int spi_io(unsigned char nbits, unsigned int out_byte)
{
    unsigned char i;
    unsigned int mask;
    
    i=nbits;
    mask=1<<(nbits-1);
    do {
        BB_MOSI = (out_byte & mask)?1:0;
        out_byte <<= 1;
        //SmallDelay();
        BB_SCLK = 1;
        SmallDelay();
        if(BB_MISO) out_byte += 1; 
        BB_SCLK = 0;
        //SmallDelay();
    } while(--i);
    BB_MOSI=0;
    return out_byte;
}

void FT93C66_Poll(void)
{
	unsigned char j;
	unsigned char mscount=0;
	
	SmallDelay();
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	while(BB_MISO==0)
	{
		for(j=0; j<250; j++)
		{
			SmallDelay();
		}
		mscount++;
		if(mscount==200) break;
	}
	FT93C66_CE=0; // De-activate the EEPROM.
}

void FT93C66_Write_Enable(void)
{
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1001_1000_0000); // Send start bit, op code, and enable bits
	FT93C66_CE=0; // De-activate the EEPROM.
	FT93C66_Poll();
}

void FT93C66_Write_Disable(void)
{
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1000_0000_0000); // Send start bit, op code, and disabble bits.
	FT93C66_CE=0; // De-activate the EEPROM.
	FT93C66_Poll();
}

unsigned char FT93C66_Read(unsigned int add)
{
	unsigned char val;
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1100_0000_0000|add); // Send start bit, op code, and A8 down to A0.
	val=spi_io(8, 0xff); // Read 8 bits from the memory location
	FT93C66_CE=0; // De-activate the EEPROM.
	return val;
}

void FT93C66_Erase(unsigned int add)
{
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1110_0000_0000|add); // Send start bit, op code, and A8 down to A0.
	FT93C66_CE=0; // De-activate the EEPROM.
	FT93C66_Poll();
}

void FT93C66_Erase_All(void)
{
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1001_0000_0000); // Send start bit, op code, and A8 down to A0.
	FT93C66_CE=0; // De-activate the EEPROM.
	FT93C66_Poll();
}

void FT93C66_Write(unsigned int add, unsigned char val)
{
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1010_0000_0000|add); // Send start bit, op code, and A8 down to A0.
	spi_io(8, val); // Data to write at memory location.
	FT93C66_CE=0; // De-activate the EEPROM.
	FT93C66_Poll();
}

void FT93C66_Write_All(unsigned char val)
{
	FT93C66_CE=1; // Activate the EEPROM.
	SmallDelay();
	spi_io(12, 0b_1000_1000_0000); // Send start bit, op code, and A8 down to A0.
	spi_io(8, val); // Data to write at memory location.
	FT93C66_CE=0; // De-activate the EEPROM.
	FT93C66_Poll();
}

void FT93C66_Init(void)
{
	FT93C66_CE=0;
	BB_SCLK=0;
	BB_MOSI=0;
	BB_MISO=1;
}
