// FT230XS SPI in synchronous bit bang mode to program
// some Atmega microcontrollers. Connect as follows:
//
// Atmega328 (dip28) pin:    BO230XS board:
//      (GND) 8  --- GND
//      (VCC) 7  --- VCC
//      (GND) 22 --- GND
//      (PB3) 17 --- TXD
//      (PD0)  2 --- TXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (PB4) 18 --- RXD
//      (PD1)  3 --- RXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (PB5) 19 --- RTS
//      (RST)  1 --- CTS
//      (AVCC)20 --- VCC
//
// Atmega16/32 (dip40) pin:    BO230XS board:
//      (GND) 11, 31      --- GND
//      (VCC) 10, 30, 32  --- VCC
//      (PD0) 14 --- TXD  Use a 10k resistor to connect these two otherwise programing will fail
//      (PD1) 15 --- RXD
//      SPI programming interface:
//      (MOSI) 6 --- TXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (MISO) 7 --- RXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (SCK)  8 --- RTS
//      (RST)  9 --- CTS
//
// Atmega162 (dip40) pin:    BO230XS board:
//      (GND) 20 --- GND
//      (VCC) 40 --- VCC
//      (PD0) 10 --- TXD
//      (PD1) 11 --- RXD
//      SPI programming interface:
//      (MOSI) 6 --- TXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (MISO) 7 --- RXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (SCK)  8 --- RTS
//      (RST)  9 --- CTS
//
// Atmega162 (QFP44) pin:    BO230XS board:
//      (GND) 16,28,39 --- GND
//      (VCC) 6,17,38  --- VCC
//      (PD0) 5 --- TXD
//      (PD1) 7 --- RXD
//      SPI programming interface:
//      (MOSI) 1 --- TXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (MISO) 2 --- RXD (After programming is done, the BO230XS board behaves as USB to serial adapter)
//      (SCK)  3 --- RTS
//      (RST)  4 --- CTS

//  (c) Jesus Calvino-Fraga (2016-2018)
//
//  Compilation instructions:
//
/////////////////////////////////////////////////////////////////////////
//
//  On Windows using visual c:
//
//  cl spi_atmega.c
//
/////////////////////////////////////////////////////////////////////////
//
//  On Linux using gcc:
//
//  $ gcc spi_atmega.c -lpthread libftd2xx.a -o spi_atmega
//
//  To use on Linux the default ftdi driver needs to be disabled first:
//
//  $ sudo rmmod ftdi_sio
//
//  Then we can send the hex file to the AVR micro:
//
//  $ sudo ./spi_atmega -CRYSTAL -p -v blinky.hex
//
//  Then re-enable the default ftdi driver to use the serial port again:
//
//  $ sudo modprobe ftdi_sio

#ifdef __APPLE__
	#define __unix__ 1
#endif

#ifdef __unix__ 
	#ifdef __APPLE__
		#include <termios.h>
	#else
		#include <termio.h>
	#endif
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <fcntl.h>
	#include <sys/signal.h>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <math.h>
	#include <time.h>
	#include <string.h>
	#include <errno.h>
	#include <ctype.h>
	#include <string.h>
	#include <stdbool.h>
	#include <limits.h>
	#include "WinTypes.h"
	
	#define strnicmp strncasecmp 
	#define _strnicmp strncasecmp 
	#define stricmp strcasecmp
	#define _stricmp strcasecmp
	#define MAX_PATH PATH_MAX
#else
	#include <windows.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <time.h>
#endif

#pragma comment(lib, "FTD2XX.lib")
#define FTD2XX_STATIC
#include "ftd2xx.h"

#define MOSI 0x01  // TXD pin
#define MISO 0x02  // RXD pin
#define SCLK 0x04  // RTS pin
#define SS   0x08  // CTS pin
#define OUTPUTS (MOSI|SCLK|SS)

unsigned char bitloc[]={0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80};

#define BUFFSIZE ((64*8*8*2)+10)

FT_HANDLE handle;
DWORD bytes;

unsigned char SPI_Buffer[BUFFSIZE]; // Buffer used to transmit and receive SPI bits
DWORD SPI_Buffer_cnt;
short int Bit_Location[BUFFSIZE/2]; // Location of input bits in SPI_Buffer
DWORD Bit_Location_cnt;
unsigned char Received_SPI[BUFFSIZE/(8*2)]; // Decoded input bits
DWORD Received_SPI_cnt;

#define MEMSIZE 0x8000
unsigned char Flash_Buffer[MEMSIZE];
char HexName[MAX_PATH]="";
unsigned int memsize=MEMSIZE, eesize=1024;

#define BIT7 0x80
#define BIT6 0x40
#define BIT5 0x20
#define BIT4 0x10
#define BIT3 0x08
#define BIT2 0x04
#define BIT1 0x02
#define BIT0 0x01

unsigned char Fuse_Low_Bits;
unsigned char Fuse_High_Bits;
unsigned char Fuse_Extended_Bits;
int b_program=0, b_verify=0;
int Selected_Device=-1;

clock_t startm, stopm;
#define START if ( (startm = clock()) == -1) {printf("Error calling clock");exit(1);}
#define STOP if ( (stopm = clock()) == -1) {printf("Error calling clock");exit(1);}
#define PRINTTIME printf( "%.1f seconds.", ((double)stopm-startm)/CLOCKS_PER_SEC);

char CRYSTAL=0, RC=0, ARDUINO=0;

#define CONFIGFUSE(x,y,z) if (x==1) y|=z; if (x==0) y&=(~z)
// Variables used to configure the fuses.  '-1' means to leave as default.
char BODLEVEL=-1, BODEN=-1, SUT1=-1, SUT0=-1, CKSEL3=-1, CKSEL2=-1, CKSEL1=-1, CKSEL0=-1;
char OCDEN=-1, JTAGEN=-1, SPIEN=-1, CKOPT=-1, EESAVE=-1, BOOTSZ1=-1, BOOTSZ0=-1, BOOTRST=-1;
char CKDIV8=-1, CKOUT=-1, RSTDISBL=-1, DWEN=-1, WDTON=-1, BODLEVEL2=-1, BODLEVEL1=-1, BODLEVEL0=-1;
char M161C=-1;

#ifdef __unix__
int Sleep(long msec)
{
    struct timespec ts;
    int res;

    if (msec < 0)
    {
        errno = EINVAL;
        return -1;
    }

    ts.tv_sec = msec / 1000;
    ts.tv_nsec = (msec % 1000) * 1000000;

    do {
        res = nanosleep(&ts, &ts);
    } while (res && errno == EINTR);

    return res;
}
#endif

void Load_Byte (unsigned char val)
{
	int j;
	
	if((SPI_Buffer_cnt+8)>=BUFFSIZE)
	{
		printf("ERROR: Unable to load %d bytes in buffer.  Max is %d.\n", SPI_Buffer_cnt+8, BUFFSIZE);
		exit(0);
	}
	
	for(j=7; j>=0; j--)
	{
		SPI_Buffer[SPI_Buffer_cnt++]=(val&bitloc[j])?MOSI:0; // prepare bit j
		SPI_Buffer[SPI_Buffer_cnt++]=SCLK|((val&bitloc[j])?MOSI:0); // Clock bit j out
		Bit_Location[Bit_Location_cnt++]=SPI_Buffer_cnt; // The location in the buffer of the received bit
	}
}

void Decode_SPI_Buffer (void)
{
	int i, j;
	
	Received_SPI_cnt=0;
	for(i=0; i<Bit_Location_cnt; )
	{
		Received_SPI[Received_SPI_cnt]=0;
		for(j=7; j>=0; j--)
		{
			Received_SPI[Received_SPI_cnt]|=(SPI_Buffer[Bit_Location[i++]]&MISO)?bitloc[j]:0;
		}
		Received_SPI_cnt++;
	}
}

void Reset_SPI_Buffer(void)
{
	SPI_Buffer_cnt=0;
	Bit_Location_cnt=0;
	Received_SPI_cnt=0;
}

void Send_SPI_Buffer (void)
{
	SPI_Buffer[SPI_Buffer_cnt++]=0; //Need to write one more byte in order to get the last bit
    FT_Write(handle, SPI_Buffer, SPI_Buffer_cnt, &bytes);
    FT_Read(handle, SPI_Buffer, SPI_Buffer_cnt, &bytes);
	Decode_SPI_Buffer();
}

int hex2dec (char hex_digit)
{
   int j;
   j=toupper(hex_digit)-'0';
   if (j>9) j -= 7;
   return j;
}

unsigned char GetByte(char * buffer)
{
	return hex2dec(buffer[0])*0x10+hex2dec(buffer[1]);
}

unsigned short GetWord(char * buffer)
{
	return hex2dec(buffer[0])*0x1000+hex2dec(buffer[1])*0x100+hex2dec(buffer[2])*0x10+hex2dec(buffer[3]);
}

int Read_Hex_File(char * filename)
{
	char buffer[1024];
	FILE * filein;
	int j;
	unsigned char linesize, recordtype, rchksum, value;
	unsigned short address;
	int MaxAddress=0;
	int chksum;
	int line_counter=0;
	int numread=0;
	int TotalBytes=0;

	//Set the flash buffer to its default value
	memset(Flash_Buffer, 0xff, MEMSIZE);

    if ( (filein=fopen(filename, "r")) == NULL )
    {
       printf("Error: Can't open file `%s`.\r\n", filename);
       return -1;
    }

    while(fgets(buffer, sizeof(buffer), filein)!=NULL)
    {
    	numread+=(strlen(buffer)+1);

    	line_counter++;
    	if(buffer[0]==':')
    	{
			linesize = GetByte(&buffer[1]);
			address = GetWord(&buffer[3]);
			recordtype = GetByte(&buffer[7]);
			rchksum = GetByte(&buffer[9]+(linesize*2));
			chksum=linesize+(address/0x100)+(address%0x100)+recordtype+rchksum;

			if (recordtype==1) break; /*End of record*/

			for(j=0; j<linesize; j++)
			{
				value=GetByte(&buffer[9]+(j*2));
				chksum+=value;
				if((address+j)<MEMSIZE)
				{
					Flash_Buffer[address+j]=value;
					TotalBytes++;
				}
			}
			if(MaxAddress<(address+linesize-1)) MaxAddress=(address+linesize-1);

			if((chksum%0x100)!=0)
			{
				printf("ERROR: Bad checksum in file '%s' at line %d\r\n", filename, line_counter);
				return -1;
			}
		}
    }
    fclose(filein);
    printf("%s: Loaded %d bytes.  Highest address is %d.\n", filename, TotalBytes, MaxAddress);

    return MaxAddress;
}

void Check_Status_Bit(void)
{
	do
	{	// Poll RDY/BSY: $F0, $00, $00, data byte out
		Reset_SPI_Buffer();
		Load_Byte(0xf0);
		Load_Byte(0x00);
	    Load_Byte(0x00);
	    Load_Byte(0x00);
	    Send_SPI_Buffer();
    } while (Received_SPI[3]&0x01); // If the LSB in RDY/BSY data byte out is ‘1’,
                                    // a programming operation is still pending.
                                    // Wait until this bit returns ‘0’ before the
                                    // next instruction is carried out.
}

void Dump_Received_SPI (void)
{
	int i;

	for(i=0; i<Received_SPI_cnt; i++)
	{
		if((i&0xf)==0) printf("\n%04x: ", i);
		printf(" %02x", Received_SPI[i]);
	}
	printf("\n");
}

void Fuses_Atmega16 (void)
{
	Fuse_Low_Bits=0xe1;  // default
	Fuse_High_Bits=0x99; // default
	Fuse_Extended_Bits=0xff; // Not used but apparently harmless to program it

	if(CRYSTAL==1) Fuse_Low_Bits=0xff;
	if(RC==1) Fuse_Low_Bits=0xe1; // Use 0xe1 for internal 1MHz RC oscillator
	
	CONFIGFUSE(BODLEVEL, Fuse_Low_Bits, BIT7);
	CONFIGFUSE(BODEN,    Fuse_Low_Bits, BIT6);
	CONFIGFUSE(SUT1,     Fuse_Low_Bits, BIT5);
	CONFIGFUSE(SUT0,     Fuse_Low_Bits, BIT4);
	CONFIGFUSE(CKSEL3,   Fuse_Low_Bits, BIT3);
	CONFIGFUSE(CKSEL2,   Fuse_Low_Bits, BIT2);
	CONFIGFUSE(CKSEL1,   Fuse_Low_Bits, BIT1);
	CONFIGFUSE(CKSEL0,   Fuse_Low_Bits, BIT0);
	
	CONFIGFUSE(OCDEN,    Fuse_High_Bits, BIT7);
	CONFIGFUSE(JTAGEN,   Fuse_High_Bits, BIT6);
	CONFIGFUSE(SPIEN,    Fuse_High_Bits, BIT5);
	CONFIGFUSE(CKOPT,    Fuse_High_Bits, BIT4);
	CONFIGFUSE(EESAVE,   Fuse_High_Bits, BIT3);
	CONFIGFUSE(BOOTSZ1,  Fuse_High_Bits, BIT2);
	CONFIGFUSE(BOOTSZ0,  Fuse_High_Bits, BIT1);
	CONFIGFUSE(BOOTRST,  Fuse_High_Bits, BIT0);
}

void Fuses_Atmega32 (void)
{
	Fuses_Atmega16();
}

void Fuses_Atmega162 (void)
{
	Fuse_Low_Bits=0x62;  // default
	Fuse_High_Bits=0x99; // default
	Fuse_Extended_Bits=0xff;

	if(CRYSTAL==1) Fuse_Low_Bits=0xff;
	if(RC==1) Fuse_Low_Bits=0xe1; // Use 0xe1 for internal 1MHz RC oscillator
	
	CONFIGFUSE(CKDIV8, Fuse_Low_Bits, BIT7);
	CONFIGFUSE(CKOUT,  Fuse_Low_Bits, BIT6);
	CONFIGFUSE(SUT1,   Fuse_Low_Bits, BIT5);
	CONFIGFUSE(SUT0,   Fuse_Low_Bits, BIT4);
	CONFIGFUSE(CKSEL3, Fuse_Low_Bits, BIT3);
	CONFIGFUSE(CKSEL2, Fuse_Low_Bits, BIT2);
	CONFIGFUSE(CKSEL1, Fuse_Low_Bits, BIT1);
	CONFIGFUSE(CKSEL0, Fuse_Low_Bits, BIT0);
	
	CONFIGFUSE(OCDEN,    Fuse_High_Bits, BIT7);
	CONFIGFUSE(JTAGEN,   Fuse_High_Bits, BIT6);
	CONFIGFUSE(SPIEN,    Fuse_High_Bits, BIT5);
	CONFIGFUSE(WDTON,    Fuse_High_Bits, BIT4);
	CONFIGFUSE(EESAVE,   Fuse_High_Bits, BIT3);
	CONFIGFUSE(BOOTSZ1,  Fuse_High_Bits, BIT2);
	CONFIGFUSE(BOOTSZ0,  Fuse_High_Bits, BIT1);
	CONFIGFUSE(BOOTRST,  Fuse_High_Bits, BIT0);
	
	CONFIGFUSE(M161C,      Fuse_High_Bits, BIT4);
	CONFIGFUSE(BODLEVEL2,  Fuse_High_Bits, BIT3);
	CONFIGFUSE(BODLEVEL1,  Fuse_High_Bits, BIT2);
	CONFIGFUSE(BODLEVEL0,  Fuse_High_Bits, BIT1);
}

void Fuses_Atmega328 (void)
{
	if(ARDUINO) 
	{
		Fuse_Low_Bits=0xff;
		Fuse_High_Bits=0xde;
		Fuse_Extended_Bits=0x05;
	}
	else
	{
		Fuse_Low_Bits=0x62;
		Fuse_High_Bits=0xd9;
		Fuse_Extended_Bits=0x07;
	}
		
	if(CRYSTAL) Fuse_Low_Bits=0xff;
	if(RC) Fuse_Low_Bits=0xe2; // Use 0xe2 for internal 8MHz RC oscillator

	CONFIGFUSE(CKDIV8, Fuse_Low_Bits, BIT7);
	CONFIGFUSE(CKOUT,  Fuse_Low_Bits, BIT6);
	CONFIGFUSE(SUT1,   Fuse_Low_Bits, BIT5);
	CONFIGFUSE(SUT0,   Fuse_Low_Bits, BIT4);
	CONFIGFUSE(CKSEL3, Fuse_Low_Bits, BIT3);
	CONFIGFUSE(CKSEL2, Fuse_Low_Bits, BIT2);
	CONFIGFUSE(CKSEL1, Fuse_Low_Bits, BIT1);
	CONFIGFUSE(CKSEL0, Fuse_Low_Bits, BIT0);

	CONFIGFUSE(RSTDISBL, Fuse_High_Bits, BIT7);
	CONFIGFUSE(DWEN,     Fuse_High_Bits, BIT6);
	CONFIGFUSE(SPIEN,    Fuse_High_Bits, BIT5);
	CONFIGFUSE(WDTON,    Fuse_High_Bits, BIT4);
	CONFIGFUSE(EESAVE,   Fuse_High_Bits, BIT3);
	CONFIGFUSE(BOOTSZ1,  Fuse_High_Bits, BIT2);
	CONFIGFUSE(BOOTSZ0,  Fuse_High_Bits, BIT1);
	CONFIGFUSE(BOOTRST,  Fuse_High_Bits, BIT0);

	CONFIGFUSE(BODLEVEL2,  Fuse_High_Bits, BIT2);
	CONFIGFUSE(BODLEVEL1,  Fuse_High_Bits, BIT1);
	CONFIGFUSE(BODLEVEL0,  Fuse_High_Bits, BIT0);
}

int Programming_Enable_Atmega (void)
{
	// Send Programming Enable command: $AC, $53, $00, $00
	Reset_SPI_Buffer();
	Load_Byte(0xac);
	Load_Byte(0x53);
    Load_Byte(0x00); //0x53 is returned at this point if ISP is enabled.
    Load_Byte(0x00); 
	Send_SPI_Buffer();
    if(Received_SPI[2]!=0x53)
    {
        puts("Program Enable command failed.\n");
        Dump_Received_SPI();
        return -1;
    }
    return 0;
} 

int Identify_Atmega (void)
{
	int j;
	unsigned char Signature_Byte[3];
	
    //Read Signature Byte $30, $00, 0000 000aa, data byte out
    for(j=0; j<3; j++)
    {
		Reset_SPI_Buffer();
		Load_Byte(0x30);
		Load_Byte(0x00);
	    Load_Byte((unsigned char)j);
	    Load_Byte(0x00); 
		Send_SPI_Buffer();
		Signature_Byte[j]=Received_SPI[3];
	}

	if(Signature_Byte[0]==0x1e && Signature_Byte[1]==0x94 && Signature_Byte[2]==0x03)
    {
		printf("Atmega16 detected.\n"); fflush(stdout);
		memsize=0x4000;
		eesize=512;
		Fuses_Atmega16();
    }
	else if(Signature_Byte[0]==0x1e && Signature_Byte[1]==0x94 && Signature_Byte[2]==0x04)
    {
		printf("Atmega162 detected.\n"); fflush(stdout);
		memsize=0x4000;
		eesize=512;
		Fuses_Atmega162();
    }
	else if(Signature_Byte[0]==0x1e && Signature_Byte[1]==0x95 && Signature_Byte[2]==0x02)
    {
		printf("Atmega32 detected.\n"); fflush(stdout);
		memsize=0x8000;
		eesize=1024;
		Fuses_Atmega32();
    }
    else if(Signature_Byte[0]==0x1e && Signature_Byte[1]==0x95 && Signature_Byte[2]==0x0f)
    {
		printf("Atmega328P detected.\n"); fflush(stdout);
		memsize=0x8000;
		eesize=1024;
		Fuses_Atmega328();
    }
    else if(Signature_Byte[0]==0x1e && Signature_Byte[1]==0x95 && Signature_Byte[2]==0x14)
    {
		printf("Atmega328 detected.\n"); fflush(stdout);
		memsize=0x8000;
		eesize=1024;
		Fuses_Atmega328();
    }
    else
    {
    	printf("Supported IC NOT detected!\n");
		printf("Signature bytes: 0x%02x 0x%02x 0x%02x\n",
				Signature_Byte[0], Signature_Byte[1], Signature_Byte[2]);
		fflush(stdout);
		return -1;
    }
    return 0;
}

int Load_Flash_Atmega (char * filename)
{
	int j, k, star_count;
	int sendbuff;

    if(Read_Hex_File(filename)<0)
    {
    	return -1;
    }
	
	START;
	// According to the datasheet: "Apply power between VCC and GND while RESET and SCK
	// are set to 0. In some systems, the programmer can not guarantee that SCK is
	// held low during power-up. In this case, RESET must be given a positive pulse
	// of at least two CPU clock cycles duration after SCK has been set to 0."

	Reset_SPI_Buffer();
	for(j=0; j<100; j++) SPI_Buffer[SPI_Buffer_cnt++]=SS;
	SPI_Buffer[SPI_Buffer_cnt++]=0;
	Send_SPI_Buffer();
	FT_W32_PurgeComm(handle, PURGE_TXCLEAR|PURGE_RXCLEAR);

	if(Programming_Enable_Atmega()==-1) return -1;
    
	if(Identify_Atmega()==-1) return -1;

	if(b_program)
	{
	    // Prior to loading a new program we need to erase the flash memory 
		printf("Erasing flash memory: "); fflush(stdout);
		// Chip Erase (Program Memory/EEPROM): $AC, $80, $00, $00
		Reset_SPI_Buffer();
		Load_Byte(0xac);
		Load_Byte(0x80); // Chip erase command
	    Load_Byte(0x00);
	    Load_Byte(0x00);
		Send_SPI_Buffer();
		Check_Status_Bit(); // Wait for the erase command to complete
		printf("# Done.\n"); fflush(stdout);
		
		// Load Extended Address byte: $4D, $00, Extended adr, $00
		Reset_SPI_Buffer();
		Load_Byte(0x4d);
		Load_Byte(0x00);
	    Load_Byte(0x00);
	    Load_Byte(0x00);
		Send_SPI_Buffer();
		
		printf("Writing flash memory: "); fflush(stdout);
		for(j=0; j<memsize; j+=128) // Each page is 128 bytes or 64 words
		{
			Reset_SPI_Buffer();
			sendbuff=0;
		    for(k=0; k<64; k++)
		    {
		    	//Load Program Memory Page, Low byte: $40, $00, adr LSB, low data byte in
				Load_Byte(0x40);
				Load_Byte(0x00);
			    Load_Byte((unsigned char)k);
		    	Load_Byte(Flash_Buffer[j+(k*2)]);
		    	if (Flash_Buffer[j+(k*2)]!=0xff) sendbuff=1;
		    	//Load Program Memory Page, High byte: $48, $00, adr LSB, high data byte in
				Load_Byte(0x48);
				Load_Byte(0x00);
			    Load_Byte((unsigned char)k);
		    	Load_Byte(Flash_Buffer[j+(k*2)+1]);
		    	if (Flash_Buffer[j+(k*2)+1]!=0xff)
		    	{
		    		sendbuff=1;
		    	}
		    }
		    if(sendbuff==1) // Only send pages that are not all 0xff
		    {
				if(star_count==50)
				{
					star_count=0;
					printf("\nWriting flash memory: ");
				}
				printf("#"); fflush(stdout);
				star_count++;
				Send_SPI_Buffer(); // First copy to buffer, then write to flash...
				// Write Program Memory Page: $4C, adr MSB, adr LSB, $00
				Reset_SPI_Buffer();
				Load_Byte(0x4c);
				Load_Byte((unsigned char)((j/2)/256));
				Load_Byte((unsigned char)((j/2)%256));
				Load_Byte(0x00);
				Send_SPI_Buffer();
				Check_Status_Bit(); // Wait for the command to complete
			}
		}
		printf(" Done.\n"); fflush(stdout);
	}

	if(b_verify)
	{
		printf("Verifying flash memory: "); fflush(stdout);
		star_count=0;
		for(j=0; j<memsize; j+=128) // Each page is 128 bytes or 64 words
		{
			Reset_SPI_Buffer();
			sendbuff=0;
		    for(k=0; k<64; k++)
		    {
		    	int memloc=(j/2)+k;
	
				//Read Program Memory, Low byte: $20, adr MSB, adr LSB, low data byte out
				Load_Byte(0x20);
				Load_Byte((unsigned char)(memloc/256));
			    Load_Byte((unsigned char)(memloc%256));
		    	Load_Byte(0x00);
		    	if (Flash_Buffer[j+(k*2)]!=0xff) sendbuff=1;
	
				//Read Program Memory, High byte: $28, adr MSB, adr LSB, high data byte out
				Load_Byte(0x28);
				Load_Byte((unsigned char)(memloc/256));
			    Load_Byte((unsigned char)(memloc%256));
		    	Load_Byte(0x00);
		    	if (Flash_Buffer[j+(k*2)+1]!=0xff) sendbuff=1;
		    }
			if(sendbuff==1)
			{
				if(star_count==50)
				{
					star_count=0;
					printf("\nVerifying flash memory: ");
				}
				printf("#"); fflush(stdout);
				star_count++;
				
				Send_SPI_Buffer();
				for(k=0; k<128; k++)
				{
					if(Received_SPI[(k*4)+3]!=Flash_Buffer[j+k])
					{
						printf("\nFlash memory program error at location %04x\n", (j+k)/2); fflush(stdout);
						Reset_SPI_Buffer();
						SPI_Buffer[SPI_Buffer_cnt++]=SS;
						Send_SPI_Buffer();
						Sleep(100); // Wait for the reset pin to stabilize at logic 1
						return -1;
					}
				}
			}
		}
		printf(" Done.\n"); fflush(stdout);
	}

	if(b_program)
	{
		printf("Writing configuration fuses: "); fflush(stdout);
		
		//Write low Fuse bits: $AC, $A0, $00, data byte in
		
		Reset_SPI_Buffer();
		Load_Byte(0xac);
		Load_Byte(0xa0);
		Load_Byte(0x00);
		Load_Byte(Fuse_Low_Bits);
		Send_SPI_Buffer();
		Check_Status_Bit(); // Wait for the command to complete
		printf("#"); fflush(stdout);
		
		Reset_SPI_Buffer();
		Load_Byte(0xac);
		Load_Byte(0xa8);
		Load_Byte(0x00);
		Load_Byte(Fuse_High_Bits);
		Send_SPI_Buffer();
		Check_Status_Bit(); // Wait for the command to complete
		printf("#"); fflush(stdout);

		Reset_SPI_Buffer();
		Load_Byte(0xac);
		Load_Byte(0xa4);
		Load_Byte(0x00);
		Load_Byte(Fuse_Extended_Bits);
		Send_SPI_Buffer();
		Check_Status_Bit(); // Wait for the command to complete
		printf("#"); fflush(stdout);
		
		printf(" Done.\n"); fflush(stdout);
	}
	
	// Set reset pin to logic 1
	Reset_SPI_Buffer();
	SPI_Buffer[SPI_Buffer_cnt++]=SS;
	Send_SPI_Buffer();
	Sleep(100); // Wait for the reset pin to stabilize at logic 1

    printf("Actions completed in ");
    STOP;
	PRINTTIME;
	printf("\n"); fflush(stdout);

    return 0;
}

int Save_Flash_Atmega (char * filename)
{
	int j, k, star_count;
	int sendbuff, chksum;
	FILE * fileout;
	
    if ( (fileout=fopen(filename, "w")) == NULL )
    {
       printf("Error: Can't create file `%s`.\r\n", filename); fflush(stdout);
       return -1;
    }
    printf("Saving FLASH to file `%s`.\r\n", filename); fflush(stdout);
	
	START;

	Reset_SPI_Buffer();
	for(j=0; j<100; j++) SPI_Buffer[SPI_Buffer_cnt++]=SS;
	SPI_Buffer[SPI_Buffer_cnt++]=0;
	Send_SPI_Buffer();
	FT_W32_PurgeComm(handle, PURGE_TXCLEAR|PURGE_RXCLEAR);

	if(Programming_Enable_Atmega()==-1) return -1;
    
	if(Identify_Atmega()==-1) return -1;

	printf("Reading flash memory: "); fflush(stdout);
	star_count=0;
	for(j=0; j<memsize; j+=128) // Each page is 128 bytes or 64 words
	{
		Reset_SPI_Buffer();
		sendbuff=0;
	    for(k=0; k<64; k++)
	    {
	    	int memloc=(j/2)+k;

			//Read Program Memory, Low byte: $20, adr MSB, adr LSB, low data byte out
			Load_Byte(0x20);
			Load_Byte((unsigned char)(memloc/256));
		    Load_Byte((unsigned char)(memloc%256));
	    	Load_Byte(0x00);

			//Read Program Memory, High byte: $28, adr MSB, adr LSB, high data byte out
			Load_Byte(0x28);
			Load_Byte((unsigned char)(memloc/256));
		    Load_Byte((unsigned char)(memloc%256));
	    	Load_Byte(0x00);
	    }
		Send_SPI_Buffer();
		if(star_count==50)
		{
			star_count=0;
			printf("\nReading flash memory: ");
		}
		printf("#"); fflush(stdout);
		star_count++;
		
		for(k=0; k<128; k++)
		{
			Flash_Buffer[j+k]=Received_SPI[(k*4)+3];
		}
	}
	
	for(j=0; j<memsize; j+=16)
	{
		int k2, write_line;
		
		for(k2=0, write_line=0; k2<16; k2++)
		{
			if(Flash_Buffer[j+k2]!=0xff)
			{
				write_line=1;
				break;
			}
		}
		
		if(write_line)
		{
			fprintf(fileout, ":10%04X00", j); fflush(stdout);
			chksum=0x10+(j/0x100)+(j%0x100);
			for(k=0; k<16; k++)
			{
				fprintf(fileout, "%02X", Flash_Buffer[j+k]); fflush(stdout);
				chksum+=Flash_Buffer[j+k];
			}
			chksum=(0x100-(chksum%0x100))%0x100;
			fprintf(fileout, "%02X\n", chksum);
		}
	}
	fprintf(fileout, ":00000001FF\n");
	fclose(fileout);
	printf("\nDone.\n"); fflush(stdout);
		
	// Set reset pin to logic 1
	Reset_SPI_Buffer();
	SPI_Buffer[SPI_Buffer_cnt++]=SS;
	Send_SPI_Buffer();
	Sleep(100); // Wait for the reset pin to stabilize at logic 1

    printf("Actions completed in ");
    STOP;
	PRINTTIME;
	printf("\n"); fflush(stdout);

    return 0;
}

int Load_Eeprom_Atmega (char * filename)
{
	int j, k, m;

    if(Read_Hex_File(filename)<0)
    {
    	return -1;
    }

	START;

	Reset_SPI_Buffer();
	for(j=0; j<100; j++) SPI_Buffer[SPI_Buffer_cnt++]=SS;
	SPI_Buffer[SPI_Buffer_cnt++]=0;
	Send_SPI_Buffer();
	FT_W32_PurgeComm(handle, PURGE_TXCLEAR|PURGE_RXCLEAR);

	if(Programming_Enable_Atmega()==-1) return -1;
	if(Identify_Atmega()==-1) return -1;

	printf("Writing EEPROM: "); fflush(stdout);
	for(m=0; m<2; m++) // Fixes the problem with corrupted bytes in the ATmega16/32.  Couldn't find what causes the corrupted bytes...
	{
		for(j=0; j<eesize; j++)
		{
		    // Read location first.  If already has the desired value skip writing. 
			Reset_SPI_Buffer();
			Load_Byte(0xa0);
			Load_Byte((unsigned char)(j/0x100));
			Load_Byte((unsigned char)(j%0x100));
		    Load_Byte(0x00);
			Send_SPI_Buffer();
			if (Received_SPI[3]!=Flash_Buffer[j])
			{
			    // Write EEPROM Memory: 1100_0000  00xx_xxaa  bbbb_bbbb  iiii_iiii
				Reset_SPI_Buffer();
				Load_Byte(0xc0);
				Load_Byte((unsigned char)(j/0x100));
				Load_Byte((unsigned char)(j%0x100));
			    Load_Byte(Flash_Buffer[j]);
				Send_SPI_Buffer();
				Check_Status_Bit(); // Wait for the command to complete
			    // Read EEPROM Memory: 1010_0000  00xx_xxaa  bbbb_bbbb  oooo_oooo
				Reset_SPI_Buffer();
				Load_Byte(0xa0);
				Load_Byte((unsigned char)(j/0x100));
				Load_Byte((unsigned char)(j%0x100));
			    Load_Byte(0x00);
				Send_SPI_Buffer();
			    if (Received_SPI[3]!=Flash_Buffer[j]) // Verify
			    {
					printf(" EEPROM write error at location 0x%04x.\n", j); fflush(stdout);
					break;
			    }
		    }
		    if((j%0x20)==0)
		    {
		    	printf("#");
		    	fflush(stdout);
		    }
		}
	}
	printf("\nDone.\n"); fflush(stdout);

	// Set reset pin to logic 1
	Reset_SPI_Buffer();
	SPI_Buffer[SPI_Buffer_cnt++]=SS;
	Send_SPI_Buffer();
	Sleep(100); // Wait for the reset pin to stabilize at logic 1

    printf("Actions completed in ");
    STOP;
	PRINTTIME;
	printf("\n"); fflush(stdout);

    return 0;
}

int Read_Eeprom_Atmega(char * filename)
{
	int j, k;
	int chksum;
	FILE * fileout;
	int write_line;
	
    if ( (fileout=fopen(filename, "w")) == NULL )
    {
       printf("Error: Can't create file `%s`.\r\n", filename); fflush(stdout);
       return -1;
    }
    printf("Saving EEPROM to file `%s`.\r\n", filename); fflush(stdout);

	START;
	
	Reset_SPI_Buffer();
	for(j=0; j<100; j++) SPI_Buffer[SPI_Buffer_cnt++]=SS;
	SPI_Buffer[SPI_Buffer_cnt++]=0;
	Send_SPI_Buffer();
	FT_W32_PurgeComm(handle, PURGE_TXCLEAR|PURGE_RXCLEAR);

	if(Programming_Enable_Atmega()==-1) return -1;
	if(Identify_Atmega()==-1) return -1;

	printf("Reading EEPROM: "); fflush(stdout);
	for(j=0; j<eesize; j+=0x10)
	{
		Reset_SPI_Buffer();
		for(k=0; k<0x10; k++) // Get 16 bytes per USB transaction
		{
		    // Read EEPROM Memory: 1010_0000  00xx_xxaa  bbbb_bbbb  oooo_oooo
			Load_Byte(0xa0);
			Load_Byte((unsigned char)((j+k)/0x100));
			Load_Byte((unsigned char)((j+k)%0x100));
		    Load_Byte(0x00);
	    }
		Send_SPI_Buffer();
		
		write_line=0;
		for(k=0; k<0x10; k++)
		{
			if(Received_SPI[3+(k*4)]!=0xff)
			{
				write_line=1;
				break;
			}
		}
		
		if(write_line==1)
		{
			fprintf(fileout, ":10%04X00", j); fflush(stdout);
			chksum=0x10+(j/0x100)+(j%0x100);
			
			for(k=0; k<0x10; k++)
			{
				fprintf(fileout, "%02X", Received_SPI[3+(k*4)]);
				chksum+=Received_SPI[3+(k*4)];
			}
			chksum=(0x100-(chksum%0x100))%0x100;
			fprintf(fileout, "%02X\n", chksum);
		}
		printf("#"); fflush(stdout);
	}
	fprintf(fileout, ":00000001FF\n");
	fclose(fileout);
	printf(" Done.\n"); fflush(stdout);

	// Set reset pin to logic 1
	Reset_SPI_Buffer();
	SPI_Buffer[SPI_Buffer_cnt++]=SS;
	Send_SPI_Buffer();
	Sleep(100); // Wait for the reset pin to stabilize at logic 1

    printf("Actions completed in ");
    STOP;
	PRINTTIME;
	printf("\n"); fflush(stdout);

    return 0;
}

int List_FTDI_Devices (void)
{
	FT_STATUS ftStatus;
	FT_HANDLE ftHandleTemp;
	DWORD numDevs;
	DWORD Flags;
	DWORD ID;
	DWORD Type;
	DWORD LocId;
	char SerialNumber[16];
	char Description[64];
	int j, toreturn=0;
	LONG PortNumber;
	
	if (Selected_Device>=0) return Selected_Device;
	
	// create the device information list
	ftStatus = FT_CreateDeviceInfoList(&numDevs);
	if (ftStatus == FT_OK)
	{
		//printf("Number of devices is %d\n",numDevs);
	}
	
	if (numDevs > 1)
	{
		printf("More than one device detected.  Use option -d to select device to use:\n");
		for(j=0; j<numDevs; j++)
		{
			ftStatus = FT_GetDeviceInfoDetail(j, &Flags, &Type, &ID, &LocId, SerialNumber, Description, &ftHandleTemp);
			if (ftStatus == FT_OK)
			{
				printf("-d%d: ", j);
				//printf("Flags=0x%x ",Flags);
				//printf("Type=0x%x ",Type);
				printf("ID=0x%x ",ID);
				//printf("LocId=0x%x ",LocId);
				printf("Serial=%s ",SerialNumber);
				printf("Description='%s' ",Description);
				//printf(" ftHandle=0x%x",ftHandleTemp);
				FT_Open(j, &handle);
				FT_GetComPortNumber(handle, &PortNumber);				
				FT_Close(handle);
				printf("Port=COM%d\n", PortNumber); fflush(stdout);
			}
		}
		fflush(stdout);
		exit(-1);
	}
	
	return toreturn;
}

void print_help (char * prn)
{
	printf("Some examples (replace 'somefile.hex' with a valid hex file:\n"
	       "%s -p -v -CRYSTAL somefile.hex   (program/verify configure for external crystal)\n"
	       "%s -p -v -RC somefile.hex        (program/verify configure for internal RC oscillator)\n"
	       "%s -p -v -ARDUINO somefile.hex   (program/verify configure for Arduino bootloader (ATmega328))\n"
	       "%s -f somefile.hex               (save the flash to hex file)\n"
	       "%s -e somefile.hex               (load the eeprom with hex file)\n"
	       "%s -r somefile.hex               (save the eeprom to hex file)\n"
	       "Other options available (x must be replaced with either 0 or 1):\n"
	       "   -BODLEVEL=x BODEN=x SUT1=x SUT0=x CKSEL3=x CKSEL2=x CKSEL1=x CKSEL0=x\n"
	       "   -OCDEN=x -JTAGEN=x -SPIEN=x -CKOPT=x -EESAVE=x -BOOTSZ1=x -BOOTSZ0=x -BOOTRST=x\n"
	       "   -CKDIV8=x -CKOUT=x -RSTDISBL=x -DWEN=x -WDTON=x -BODLEVEL2=x -BODLEVEL1=x -BODLEVEL0=x\n"
	       "   Check the corresponding datasheet for the meaning of the above options.\n", 
	       prn, prn, prn, prn, prn, prn);
}

#define FUSE(X) else if(stricmp("-"#X"=0", argv[j])==0) X=0; else if(stricmp("-"#X"=1", argv[j])==0) X=1

int main(int argc, char ** argv)
{
    int j, k;
	LONG lComPortNumber;
	char buff[256];
	char write_eeprom=0, read_eeprom=0, read_flash=0;

    if(argc<2)
    {
    	printf("Need a filename to proceed.  ");
    	print_help(argv[0]);
    	return 1;
    }

    for(j=1; j<argc; j++)
    {
    	if (stricmp("~~DUMMY~~", argv[j])==0); // Needed before the 'FUSE()' macro
    	
    	FUSE(BODLEVEL); FUSE(BODEN); FUSE(SUT1); FUSE(SUT0);
    	FUSE(CKSEL3); FUSE(CKSEL2); FUSE(CKSEL1); FUSE(CKSEL0);
    	FUSE(OCDEN); FUSE(JTAGEN); FUSE(SPIEN); FUSE(CKOPT); 
    	FUSE(EESAVE); FUSE(BOOTSZ1); FUSE(BOOTSZ0); FUSE(BOOTRST); 
        
		// Additional in the ATmega328
		FUSE(CKDIV8); FUSE(CKOUT); FUSE(RSTDISBL); FUSE(DWEN); 
		
		// Additional in the ATmega162
		FUSE(M161C); 
		
		else if(stricmp("-ARDUINO", argv[j])==0) ARDUINO=1;
		else if(stricmp("-CRYSTAL", argv[j])==0) CRYSTAL=1;
		else if(stricmp("-RC", argv[j])==0)      RC=1;
		
		else if(stricmp("-e", argv[j])==0) write_eeprom=1;
		else if(stricmp("-r", argv[j])==0) read_eeprom=1;
		else if(stricmp("-f", argv[j])==0) read_flash=1;
		else if(stricmp("-p", argv[j])==0) b_program=1;
		else if(stricmp("-v", argv[j])==0) b_verify=1;

		else if(stricmp("-h", argv[j])==0)
		{
    		print_help(argv[0]);
    		return 0;
		}
		else if(strnicmp("-d", argv[j], 2)==0)
		{
			Selected_Device=atoi(&argv[j][2]);
		}
		
    	else strcpy(HexName, argv[j]);
    }
    
    printf("Atmega programmer using BO230X board. (C) Jesus Calvino-Fraga (2016-2018)\n");
    
    if(FT_Open(List_FTDI_Devices(), &handle) != FT_OK)
    {
        puts("Can not open FTDI adapter.\n");
        return 3;
    }
    
    if (FT_GetComPortNumber(handle, &lComPortNumber) == FT_OK)
    { 
    	if (lComPortNumber != -1)
    	{
    		printf("Connected to COM%d\n", lComPortNumber); fflush(stdout);
    		sprintf(buff,"echo COM%d>COMPORT.inc", lComPortNumber);
    		system(buff);
    	}
    }

    FT_SetBitMode(handle, OUTPUTS, FT_BITMODE_SYNC_BITBANG); // Synchronous bit-bang mode
    FT_SetBaudRate(handle, 19200);  // Actually 19200*16, but SPI clock is half of that
	FT_SetLatencyTimer (handle, 5); // Makes checking status bit faster
	
	if(read_eeprom==1)
	{
		Read_Eeprom_Atmega(HexName);
	}
	else if(write_eeprom==1)
	{
		Load_Eeprom_Atmega(HexName);
	}
	else if(read_flash==1)
	{
		Save_Flash_Atmega(HexName);
	}
	else
	{
	    Load_Flash_Atmega(HexName);
	}
	
	FT_SetBitMode(handle, 0x0, FT_BITMODE_RESET); // Back to serial port mode
	FT_Close(handle);
	
	printf("\n");
	
    return 0;
}