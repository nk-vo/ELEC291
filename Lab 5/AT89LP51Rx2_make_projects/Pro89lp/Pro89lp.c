/////////////////////////////////////////////////////////////////////////////
//
//  Pro89lp.c:  FT230XS SPI in synchronous bit bang mode to program
//              the AT89LP series of microcontrollers.
// 
// Copyright (C) 2012-2022  Jesus Calvino-Fraga, jesusc (at) ece.ubc.ca
// 
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 2, or (at your option) any
// later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
//
/////////////////////////////////////////////////////////////////////////////
//
// Compile using Visual C on Windows:
// cl Pro89lp.c
//
// Make sure ftd2xx.dll, ftd2xx.h, and ftd2xx.lib are present in the same folder.
//
/////////////////////////////////////////////////////////////////////////
//
//  On Linux using gcc:
//
//  $ gcc Pro89lp.c -lpthread libftd2xx.a -o Pro89lp
//
//  To use on Linux the default ftdi driver needs to be disabled first:
//
//  $ sudo rmmod ftdi_sio
//
//  Then we can send the hex file to the AT89LP micro:
//
//  $ sudo ./Pro89lp -p -v blinky.hex
//
//  Then re-enable the default ftdi driver to use the serial port again:
//
//  $ sudo modprobe ftdi_sio
//
/////////////////////////////////////////////////////////////////////////////
//
// Connect the AT89LP microcontroller as follows.  In all cases TXD/RXD of the
// BO230XS board can be connected to the RXD/TXD pins of the microncontroller
// to use the BO230XS as USB to serial adapter after programming is completed.
// Finally, if a crystal is configured at the first flashing, it must be
// present in pins XTAL1/XTAL2 for subsequent flashing operations.
//
// For the AT89LP52 and AT89LP51:
//    40 DIP:     BO230XS board:
//      (GND) 20 --- GND
//      (VCC) 40 --- VCC
//      (POL) 31 --- GND
//      (MOSI) 6 --- TXD
//      (MISO) 7 --- RXD
//      (SLCK) 8 --- RTS
//      (RST)  9 --- BUS 3 (Pin 6 of J3)
//
// For the AT89LP51xx2:
//    40 DIP:     BO230XS board:
//      (GND) 20 --- GND
//      (VCC) 40 --- VCC
//      (POL) 31 --- GND
//      (SS)   5 --- CTS
//      (MOSI) 6 --- TXD
//      (MISO) 7 --- RXD
//      (SLCK) 8 --- RTS
//      (RST)  9 --- BUS 3 (Pin 6 of J3)
//
// For the AT89LP6440 and AT89LP3240:
//    40 DIP:     BO230XS board:
//      (GND) 20 --- GND
//      (VCC) 40 --- Important: Need to step down the 5V to 3.3V
//      (SS)   5 --- CTS
//      (MOSI) 6 --- TXD
//      (MISO) 7 --- RXD
//      (SLCK) 8 --- RTS
//      (RST)  9 --- BUS 3 (Pin 6 of J3)
//
// For the AT89LP828 and AT89LP428:
//    28 DIP:     BO230XS board:
//      (GND)  7 --- GND
//      (VCC) 21 --- VCC
//      (SS)  23 --- CTS
//      (MOSI)24 --- TXD
//      (MISO)25 --- RXD
//      (SLCK)26 --- RTS
//      (RST) 12 --- BUS 3 (Pin 6 of J3)
//
// For the AT89LP2052 and AT89LP4052:
//    20 DIP:     BO230XS board:
//      (GND) 10 --- GND
//      (VCC) 20 --- VCC
//      (SS)  16 --- CTS
//      (MOSI)17 --- TXD
//      (MISO)18 --- RXD
//      (SLCK)19 --- RTS
//      (RST)  1 --- BUS 3 (Pin 6 of J3) (Note: Reset is active high.  A pull-down resistor of 1k is needed)
//
// For the AT89LP213 and AT89LP214:
//    14 DIP:     BO230XS board:
//      (GND)  4 --- GND
//      (VCC)  9 --- VCC
//      (SS)  13 --- CTS
//      (MOSI) 1 --- TXD
//      (MISO)14 --- RXD
//      (SLCK) 2 --- RTS
//      (RST)  3 --- BUS 3 (Pin 6 of J3)
//
// For the AT89LP216:
//    14 DIP:     BO230XS board:
//      (GND)  4 --- GND
//      (VCC) 11 --- VCC
//      (SS)  15 --- CTS
//      (MOSI) 1 --- TXD
//      (MISO)16 --- RXD
//      (SLCK) 2 --- RTS
//      (RST)  3 --- BUS 3 (Pin 6 of J3)

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

struct _AT89LP_part_ID
{
	  char name[0x20];
	  int size;
	  char ID_Str[7];
	  unsigned char buff_size; // Needed when programming
};

struct _AT89LP_part_ID AT89LP_part_ID[] = {
	{"AT89LP213",   0x800,   "1E27FF", 32 },
	{"AT89LP214",   0x800,   "1E28FF", 32 },
	{"AT89LP216",   0x800,   "1E29FF", 32 },
	{"AT89LP2052",  0x800,   "1E25FF", 32 },
	{"AT89LP4052",  0x1000,  "1E45FF", 32 },
	{"AT89LP428",   0x1000,  "1E40FF", 64 },
	{"AT89LP828",   0x2000,  "1E42FF", 64 },
	{"AT89LP51",    0x1000,  "1E5405", 64 },
	{"AT89LP52",    0x2000,  "1E5406", 64 },
	{"AT89LP3240",  0x8000,  "1E32FC", 64 },
	{"AT89LP6440",  0x10000, "1E64FF", 64 },
	{"AT89LP51RB2", 0x6000,  "1E6272", 64 },
	{"AT89LP51RC2", 0x8000,  "1E6372", 64 },
	{"AT89LP51IC2", 0x8000,  "1E6369", 64 },
	{"AT89LP51RD2", 0x10000, "1E6472", 64 },
	{"AT89LP51ED2", 0x10000, "1E6465", 64 },
	{"AT89LP51ID2", 0x10000, "1E6469", 64 },
	{"NOT FOUND",   0x0000,  "000000", 0  }
	};

int memsize;
char ID_Str[7];
char Name_Str[0x100];
int buff_size;
unsigned char Atmel_Signature[0x100];
volatile int header_offset=0;

#define BUFFSIZE ((67*8*2)+100)

FT_HANDLE handle=NULL;
DWORD bytes;

unsigned char SPI_Buffer[BUFFSIZE]; // Buffer used to transmit and receive SPI bits
DWORD SPI_Buffer_cnt;
short int Bit_Location[BUFFSIZE/2]; // Location of input bits in SPI_Buffer
DWORD Bit_Location_cnt;
unsigned char Received_SPI[BUFFSIZE/(8*2)]; // Decoded input bits
DWORD Received_SPI_cnt;

#define MEMSIZE 0x10000
unsigned char Flash_Buffer[MEMSIZE];
char HexName[MAX_PATH]="";
char OutName[MAX_PATH]="";

// Input option switches
BOOL b_Compt=FALSE, b_X1X2=FALSE;
char s_ClockSource[10]="Crystal", s_StartupTime[10]="16 ms";
BOOL b_program=FALSE, b_verify=FALSE, b_read=FALSE;
BOOL b_debug=FALSE, b_sleepC3=FALSE;
int Selected_Device=-1;

#define EQ(a,b) (stricmp(a,b)==0)

clock_t startm, stopm;
#define START if ( (startm = clock()) == -1) {printf("Error calling clock");GetOutAfterError(1);}
#define STOP if ( (stopm = clock()) == -1) {printf("Error calling clock");GetOutAfterError(1);}
#define PRINTTIME printf( "%.1f seconds.", ((double)stopm-startm)/CLOCKS_PER_SEC);

void GetOutAfterError (int val)
{
	if(handle!=NULL)
	{
		FT_SetBitMode(handle, 0x00, FT_BITMODE_CBUS_BITBANG); // Set CBUS3 as input
		FT_SetBitMode(handle, 0x0, FT_BITMODE_RESET); // Back to serial port mode
		FT_Close(handle);
	}
	exit(val);
}

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
		GetOutAfterError(0);
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
	int numloaded=0;

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
					numloaded++;
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
    printf("%s: %d bytes loaded\n", filename, numloaded);
    fflush(stdout);

    return MaxAddress;
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

void Set_SS_to (int x)
{
	SPI_Buffer[SPI_Buffer_cnt++]=x?SS:0x00;
	SPI_Buffer[SPI_Buffer_cnt++]=x?SS:0x00;
	SPI_Buffer[SPI_Buffer_cnt++]=x?SS:0x00;
	SPI_Buffer[SPI_Buffer_cnt++]=x?SS:0x00;
}

void Set_RST_to (int x)
{
	FT_SetBitMode(handle, (unsigned char)(x?0x88:0x80), FT_BITMODE_CBUS_BITBANG);
	Sleep(20);
	FT_W32_PurgeComm(handle, PURGE_TXCLEAR|PURGE_RXCLEAR);
	FT_SetBitMode(handle, OUTPUTS, FT_BITMODE_SYNC_BITBANG); // Back to synchronous bit-bang mode
	Sleep(20);
}

BOOL ProgramInterfaceEnable (void)
{
	// Important: try the LP51/LP52 first
	//Set_RST_to(1); // Not needed I think
	Set_RST_to(0); // Put the LP51/LP52 into program mode (reset pin is zero)
	
	// Program Enable(1) 10101100 01010011 xxxxxxxx xxxxxxxx (0110 1001)(2)
	Reset_SPI_Buffer();
	Load_Byte(0xac);
	Load_Byte(0x53);
	Load_Byte(0x00);
	Load_Byte(0x00); // Send dummy byte. 69h should be returned if ISP is enabled.
	Send_SPI_Buffer();

	// For the LP51/LP52 a 69h is returned
	if(Received_SPI[3]==0x69)
	{
		//printf("Found AT89LP52 or AT89LP51\n"); fflush(stdout);
		header_offset=2;
		return 0;
	}

	// Now try the AT89LP42x group or AT89LP51Rxx group.  Includes AT89LP6440.
	// Program Interface Enable (MUST be first command!) 10101100 01010011
	Reset_SPI_Buffer();
	Set_SS_to(1);
	Set_SS_to(0);
	Load_Byte(0xaa);
	Load_Byte(0x55);
	Load_Byte(0xac);
	Load_Byte(0x53);
	Load_Byte(0x00); // Send dummy low address byte. 53h should be returned on MISO if ISP is enabled.
	Set_SS_to(1);
	Send_SPI_Buffer();
	
	if(Received_SPI[4]==0x53)
	{
		//printf("Found AT89LP42x or AT89LP51Rxx\n"); fflush(stdout);
		header_offset=0;
		return 0;
	}

	// Maybe is a LP2052/LP4052 (Reset is active high for these ones)
	// Execute this sequence to enter ISP when the device is already operational:
	//
	// 1. Bring SS (P1.4) to “H”.
	// 2. Tri-state MISO (P1.6).
	// 3. Bring RST to “H”.
	// 4. Bring SCK (P1.7) to “L”.
	//
	// Unfortunatelly nothing is returned from these ones, so we can not verify
	// that the command was suscesful.
	
	Set_RST_to(0);
	Reset_SPI_Buffer();
	SPI_Buffer[SPI_Buffer_cnt++]=SS;
	FT_Write(handle, SPI_Buffer, SPI_Buffer_cnt, &bytes);
	FT_Read(handle, SPI_Buffer, SPI_Buffer_cnt, &bytes);

	Set_RST_to(1);// Put the at89lp into program mode (reset pin is one)

	//Program Enable(1) 10101010 10101100 01010011
	Reset_SPI_Buffer();
	Set_SS_to(0);
	Load_Byte(0xaa);
	Load_Byte(0xac);
	Load_Byte(0x53);
	Set_SS_to(1);
	Send_SPI_Buffer();

	header_offset=1;
	return 0;
}

void BusyFlag (void)
{
    time_t ltime1, ltime2;

	time(&ltime2);
    ltime1=ltime2+2;

	Received_SPI[5-header_offset]=0;
	while( ((Received_SPI[5-header_offset]&0x01)==0) && (ltime2<ltime1) ) // Busy flag is zero when busy
	{
		// Read Status 01100000 xxxxxxxx xxxxxxxx Status Out		
		Reset_SPI_Buffer();
		Set_SS_to(0);
		if(header_offset<2) Load_Byte(0xaa);
		if(header_offset<1) Load_Byte(0x55);
		Load_Byte(0x60); // 01100000
		Load_Byte(0x00); // xxxxxxxx
		Load_Byte(0x00); // xxxxxxxx
		Load_Byte(0x00); // Status Out
		Set_SS_to(1);
		Send_SPI_Buffer();
      
        time(&ltime2);
	}
	
	if (ltime2>=ltime1)
	{
		printf("ERROR: Checking 'Busy Flag' timed out.\n"); fflush(stdout);
		GetOutAfterError(5);
	}
}

// CBUS3 is used as reset, but must be configured for GPIO first.
void FTDI_Set_CBUS3_Mode (unsigned char pinmode)
{
	FT_STATUS status;
	char Manufacturer[64];
	char ManufacturerId[64];
	char Description[64];
	char SerialNumber[64];
	
	FT_EEPROM_HEADER ft_eeprom_header;
	FT_EEPROM_X_SERIES ft_eeprom_x_series;
	
	ft_eeprom_header.deviceType = FT_DEVICE_X_SERIES; // FTxxxx device type to be accessed
	ft_eeprom_x_series.common = ft_eeprom_header;
	ft_eeprom_x_series.common.deviceType = FT_DEVICE_X_SERIES;
	
	status = FT_EEPROM_Read(handle, &ft_eeprom_x_series, sizeof(ft_eeprom_x_series),
							Manufacturer, ManufacturerId, Description, SerialNumber);
	if (status == FT_OK)
	{
		if (ft_eeprom_x_series.Cbus3!=pinmode)
		{
			ft_eeprom_x_series.Cbus3=pinmode;
			status = FT_EEPROM_Program(handle, &ft_eeprom_x_series, sizeof(ft_eeprom_x_series),
									Manufacturer, ManufacturerId, Description, SerialNumber);
			if (status == FT_OK)
			{
				FT_ResetDevice(handle);
				Sleep(100);
				printf("WARNING: Pin CBUS3 has been configured as '");
				switch(pinmode)
				{	
					case FT_X_SERIES_CBUS_TRISTATE:
						printf("Tristate");
						break;
					case FT_X_SERIES_CBUS_TXLED:
						printf("Tx LED");
						break;
					case FT_X_SERIES_CBUS_RXLED:
						printf("Rx LED");
						break;
					case FT_X_SERIES_CBUS_TXRXLED:
						printf("Tx and Rx LED");
						break;
					case FT_X_SERIES_CBUS_PWREN:
						printf("Power Enable");
						break;
					case FT_X_SERIES_CBUS_SLEEP:
						printf("Sleep");
						break;
					case FT_X_SERIES_CBUS_DRIVE_0:
						printf("Drive pin to logic 0");
						break;
					case FT_X_SERIES_CBUS_DRIVE_1:
						printf("Drive pin to logic 1");
						break;
					case FT_X_SERIES_CBUS_IOMODE:
						printf("IO Mode for CBUS bit-bang");
						break;
					case FT_X_SERIES_CBUS_TXDEN:
						printf("Tx Data Enable");
						break;
					case FT_X_SERIES_CBUS_CLK24:
						printf("24MHz clock");
						break;
					case FT_X_SERIES_CBUS_CLK12:
						printf("12MHz clock");
						break;
					case FT_X_SERIES_CBUS_CLK6:
						printf("6MHz clock");
						break;
					case FT_X_SERIES_CBUS_BCD_CHARGER:
						printf("Battery charger detected");
						break;
					case FT_X_SERIES_CBUS_BCD_CHARGER_N:
						printf("Battery charger detected inverted");
						break;
					case FT_X_SERIES_CBUS_I2C_TXE:
						printf("I2C Tx empty");
						break;
					case FT_X_SERIES_CBUS_I2C_RXF:
						printf("I2C Rx full");
						break;
					case FT_X_SERIES_CBUS_VBUS_SENSE:
						printf("Detect VBUS");
						break;
					case FT_X_SERIES_CBUS_BITBANG_WR:
						printf("Bit-bang write strobe");
						break;
					case FT_X_SERIES_CBUS_BITBANG_RD:
						printf("Bit-bang read strobe");
						break;
					case FT_X_SERIES_CBUS_TIMESTAMP:
						printf("Toggle output when a USB SOF token is received");
						break;
					case FT_X_SERIES_CBUS_KEEP_AWAKE:
						printf("Keep awake");
						break;
					default:
						printf("Something that is probably not correct!");
						break;
				}
				printf("'\n"
				       "Please unplug/plug the BO230XS board for the changes to take effect\n"
				       "and try again.\n");
				fflush(stdout);
				GetOutAfterError(0);
			}
		}
	}
}

int StartCommunication(void) 
{
	int j, address;

	if(ProgramInterfaceEnable()==1)
	{
		printf("SPI communication with micro controller failed.\n"); fflush(stdout);
		GetOutAfterError(1);
	}
	
	//Identify the microcontroller
	if(header_offset==2) // The LP51/LP52 is a bit different
	{
		Reset_SPI_Buffer();
		Load_Byte(0x38);
		Load_Byte(0); // 00000000
		Load_Byte(0); // 00bbbbbb
		// The next 64 bytes are don't care...
		for(j=0; j<64; j++) Load_Byte(0x00);
		Send_SPI_Buffer();
	}
	else
	{
		// Read Atmel Signature Page(2)(6) 00111000 00000000 00bbbbbb DataOut 0 ... DataOut n
		Reset_SPI_Buffer();
		Set_SS_to(0);
		if(header_offset<2) Load_Byte(0xaa);
		if(header_offset<1) Load_Byte(0x55);
		Load_Byte(0x38);
		Load_Byte(0); // 00000000
		Load_Byte(0); // 00bbbbbb
		// The next 16 bytes are don't care...
		for(j=0; j<16; j++) Load_Byte(0x00);
		Set_SS_to(1);
		Send_SPI_Buffer();
	}

	//Save the first 16 bytes
	for(j=0; j<16; j++)
	{
		Atmel_Signature[j]=Received_SPI[j+5-header_offset];
	}
	sprintf(ID_Str, "%02X%02X%02X", Atmel_Signature[0], Atmel_Signature[1], Atmel_Signature[2]);

	//In debug mode, we need to see what is returned:
	if(b_debug)
	{
		for(j=0; j<16; j++)
		{
			printf("%02x ", Received_SPI[j]);
		}
		printf("\n"); fflush(stdout);
	}

	for(j=0; AT89LP_part_ID[j].size!=0; j++)
	{
		if( strcmp(ID_Str, AT89LP_part_ID[j].ID_Str)==0 )
		{
			memsize=AT89LP_part_ID[j].size;
			strcpy(Name_Str, AT89LP_part_ID[j].name);
			buff_size=AT89LP_part_ID[j].buff_size;
			printf("%s detected.\n", Name_Str); fflush(stdout);
			return 0;
		}
	}

	printf("ERROR: Not a recognized AT89LP.\n"); fflush(stdout);
	return 1;
}

void Flash_AT89LP(void) 
{
	int j, k, address, star_count;	
	BOOL DoSend;

	START;

	if(StartCommunication()!=0)
	{
        return;
	}

	if(b_program)
	{
		// Chip Erase 10001010
	    printf("Erasing..."); fflush(stdout);
		if(header_offset!=2)
		{
			Reset_SPI_Buffer();
			Set_SS_to(0);
			if(header_offset<2) Load_Byte(0xaa);
			if(header_offset<1) Load_Byte(0x55);
			Load_Byte(0x8a);
			Set_SS_to(0);
			Set_SS_to(1);
			Send_SPI_Buffer();
		}
		else // For the LP51/LP52, which is a bit different
		{
			Reset_SPI_Buffer();
			Load_Byte(0xac);
			Load_Byte(0x80);
			Load_Byte(0x00);
			Load_Byte(0x00);
			Send_SPI_Buffer();
		}
		BusyFlag();
		printf(" Done.\n"); fflush(stdout);

		// Load flash
		star_count=0;
		printf("Loading flash memory: "); fflush(stdout);
		for(address=0; address<memsize; address+=buff_size)
		{
			// Write Code Page 01010000 000aaaaa aabbbbbb DataIn 0 ... DataIn n
			Reset_SPI_Buffer();
			if(header_offset<2) Set_SS_to(0);
			if(header_offset<2) Load_Byte(0xaa);
			if(header_offset<1) Load_Byte(0x55);
			Load_Byte(0x50);
			Load_Byte((unsigned char)(address/0x100)); // 000aaaaa
			Load_Byte((unsigned char)(address%0x100)); // aabbbbbb
			
			for(k=0, DoSend=FALSE; k<buff_size; k++)	
			{
				Load_Byte(Flash_Buffer[k+address]);
				if(Flash_Buffer[k+address]!=0xff) DoSend=TRUE;
			}
			
			if(DoSend)
			{
				if(header_offset<2) Set_SS_to(1);
				Send_SPI_Buffer();
				BusyFlag();
				
				if(star_count==50)
				{
					star_count=0;
					printf("\nLoading flash memory: ");
				}
				printf("#"); fflush(stdout);
				star_count++;
			}
		}
		printf(" Done.\n"); fflush(stdout);
	}

	if(b_verify)
	{
		// Verify that the Flash was written correctly...
		star_count=0;
		printf("Verifiying flash memory: "); fflush(stdout);
	
		for(address=0; address<memsize; address+=buff_size)
		{
			// Read Code Page 00110000 000aaaaa aabbbbbb DataOut 0 ... DataOut n
			Reset_SPI_Buffer();
			if(header_offset<2) Set_SS_to(0);
			if(header_offset<2) Load_Byte(0xaa);
			if(header_offset<1) Load_Byte(0x55);
			Load_Byte(0x30);
			Load_Byte((unsigned char)(address/0x100)); // 000aaaaa
			Load_Byte((unsigned char)(address%0x100)); // aabbbbbb
			for(j=0, DoSend=FALSE; j<buff_size; j++)
		    {
		    	Load_Byte(0);
		    	if (Flash_Buffer[j+address]!=0xff) DoSend=TRUE;
		    }

			if(DoSend)
			{
				if(star_count==50)
				{
					star_count=0;
					printf("\nVerifiying flash memory: ");
				}
				printf("#"); fflush(stdout);
				star_count++;
				
				if(header_offset<2) Set_SS_to(1);
				Send_SPI_Buffer();
		
				if(memcmp(&Flash_Buffer[address], &Received_SPI[5-header_offset], buff_size)!=0)
				{
					// Find the location of the missmatch
					for(k=0; k<buff_size; k++)
					{
						if(Flash_Buffer[address+k]!=Received_SPI[k+5-header_offset])
						{
							printf("\nError at address %04XH\n", address+k); fflush(stdout);
							return;
						}
					}
				}
			}
		}
		printf(" Done.\n"); fflush(stdout);
	}

	if(b_program)
	{
		printf("Writing fuses..."); fflush(stdout);
	
		//Write User Fuses 11100001 00000000 00bbbbbb DataIn 0 ... DataIn n
		//Write User Fuses with Auto-Erase 11110001 00000000 00bbbbbb DataIn 0 ... DataIn n
		Reset_SPI_Buffer();
		Set_SS_to(0);
		if(header_offset<2) Load_Byte(0xaa);
		if(header_offset<1) Load_Byte(0x55);
		Load_Byte(0xf1); // 11110001
		Load_Byte(0x00); // 00000000
		Load_Byte(0x00); // 00bbbbbb
	
		if( (strcmp(Name_Str, "AT89LP428")==0)  ||  // Tested
			(strcmp(Name_Str, "AT89LP828")==0)  ||  // Tested
			(strcmp(Name_Str, "AT89LP3240")==0) ||  // Tested
			(strcmp(Name_Str, "AT89LP6440")==0) )   // Tested
		{
	
			// Selects source for the system clock
			// CS1 CS0 Selected Source
			// 00h 00h High Speed Crystal Oscillator (XTAL)
			// 00h FFh Low Speed Crystal Oscillator (XTAL)
			// FFh 00h External Clock on XTAL1 (XCLK)
			// FFh FFh Internal RC Oscillator (IRC)
	
			switch (s_ClockSource[0])
			{
				case 'C': Load_Byte(0x00); Load_Byte(0x00); break;
				default:
				case 'R': Load_Byte(0xFF); Load_Byte(0xFF); break;
			}
	
			// Selects time-out delay for the POR/BOD/PWD wake-up period:
			// SUT1 SUT0 Selected Time-out
			// 00h 00h  1 ms (XTAL);  16 us (XCLK/IRC)
			// 00h FFh  2 ms (XTAL); 512 us (XCLK/IRC)
			// FFh 00h  4 ms (XTAL);   1 ms (XCLK/IRC)
			// FFh FFh 16 ms (XTAL);   4 ms (XCLK/IRC)
			switch (s_StartupTime[1])
			{
				case '1': Load_Byte(0x00); Load_Byte(0x00); break;
				case '2': Load_Byte(0x00); Load_Byte(0xFF); break;
				case '4': Load_Byte(0xFF); Load_Byte(0x00); break;
				case '6': Load_Byte(0xFF); Load_Byte(0xFF); break;
			}
	
			Load_Byte(0xff); // FFH: RST pin functions as reset
			Load_Byte(0xff); // FFH: Brown-out Detector Enabled
			Load_Byte(0xff); // FFH: On-chip Debug Disabled
			Load_Byte(0xff); // FFH: In-System Programming Enabled
			Load_Byte(0x00); // 00H: Programming of User Signature Enabled
			Load_Byte(0x00); // 00H: I/O Ports start in quasi-bidirectional mode after reset
			Load_Byte(0x00); // 00H: Do not use (OCD Interface)
			Load_Byte(0x00); // 00H: In-Application Programming Enabled
	
			Set_SS_to(1);
			Send_SPI_Buffer();
			BusyFlag();
		}
		else if ( (strcmp(Name_Str, "AT89LP51RD2")==0) ||  // Tested
				  (strcmp(Name_Str, "AT89LP51ED2")==0) ||  // Tested
				  (strcmp(Name_Str, "AT89LP51ID2")==0) ||
				  (strcmp(Name_Str, "AT89LP51RB2")==0) ||  // Tested.  DIP40/LQFP44 packages.
				  (strcmp(Name_Str, "AT89LP51RC2")==0) ||  // Tested
				  (strcmp(Name_Str, "AT89LP51IC2")==0)
				  )
		{
	
			// Selects source for the system clock when using OSCA:
			// CSA1 CSA0 Selected Source
			// FFh  FFh  High Speed Crystal Oscillator on XTAL1A/XTAL2A (XTAL)
			// FFh  00h  Low Power Crystal Oscillator on XTAL1A/XTAL2A (XTAL)
			// 00h  FFh  External Clock on XTAL1A (XCLK)
			// 00h  00h  Internal 8 MHz RC Oscillator (IRC)
	
			switch (s_ClockSource[0])
			{
				case 'C': Load_Byte(0xFF); Load_Byte(0xFF); break;
				default:
				case 'R': Load_Byte(0x00); Load_Byte(0x00); break;
			}
			
			// Selects time-out delay for the POR/BOD/PWD wake-up period:
			// SUT1 SUT0 Selected Time-out
			// 00h 00h  1 ms (XTAL);  16 us (XCLK/IRC)
			// 00h FFh  2 ms (XTAL); 512 us (XCLK/IRC)
			// FFh 00h  4 ms (XTAL);   1 ms (XCLK/IRC)
			// FFh FFh 16 ms (XTAL);   4 ms (XCLK/IRC)
			switch (s_StartupTime[1])
			{
				case '1': Load_Byte(0x00); Load_Byte(0x00); break;
				case '2': Load_Byte(0x00); Load_Byte(0xFF); break;
				case '4': Load_Byte(0xFF); Load_Byte(0x00); break;
				case '6': Load_Byte(0xFF); Load_Byte(0xFF); break;
			}
			Load_Byte(0xff);                               // Bootloader jump bit.  ff:run user code
			Load_Byte(0xff);                               // External RAM Enable. ff: enabled.
			Load_Byte((unsigned char)((b_Compt)?0xff:0x00)); // Compatibility mode. 00: single cycle fast mode, ff: compativility mode (slow)
			Load_Byte(0xff);                               // FFh: In-System Programming Enabled
			Load_Byte((unsigned char)((b_X1X2)?0xff:0x00));// X1/X2.  00: X2 (Clock not divided by two)
			Load_Byte(0xff);                               // FFh: On-Chip Debug is Disabled (chip bricks if enabled!)
			Load_Byte(0x00);                               // 00h: Programming of User Signature Enabled
			Load_Byte(0x00);                               // 00h: I/O Ports start in quasi-bidirectional mode after reset
			Load_Byte(0x00);                               // 00: EEPROM is not erased during chiperase
			Load_Byte(0xff);
			Load_Byte(0xff);
			Load_Byte(0xff);
			Load_Byte(0xff);
			Load_Byte(0xff);
			Load_Byte(0xff);
			
			Set_SS_to(1);
			Send_SPI_Buffer();
			BusyFlag();
		}
		else if( (strcmp(Name_Str, "AT89LP213")==0)  || // Tested
	             (strcmp(Name_Str, "AT89LP214")==0)  || // Tested
	             (strcmp(Name_Str, "AT89LP216")==0) )   // Tested
		{
			// Selects source for the system clock:
			// CS1 CS0 Selected Source
			// 00h 00h Crystal Oscillator (XTAL)
			// 00h FFh Reserved
			// FFh 00h External Clock on XTAL1 (XCLK)
			// FFh FFh Internal RC Oscillator (IRC)
	
			switch (s_ClockSource[0])
			{
				case 'C': Load_Byte(0x00); Load_Byte(0x00); break;
				default:
				case 'R': Load_Byte(0xFF); Load_Byte(0xFF); break;
			}
	
			// Selects time-out delay for the POR/BOD/PWD wake-up period:
			// SUT1 SUT0 Selected Time-out
			// 00h 00h  1 ms (XTAL);  16 us (XCLK/IRC)
			// 00h FFh  2 ms (XTAL); 512 us (XCLK/IRC)
			// FFh 00h  4 ms (XTAL);   1 ms (XCLK/IRC)
			// FFh FFh 16 ms (XTAL);   4 ms (XCLK/IRC)
			switch (s_StartupTime[1])
			{
				case '1': Load_Byte(0x00); Load_Byte(0x00); break;
				case '2': Load_Byte(0x00); Load_Byte(0xFF); break;
				case '4': Load_Byte(0xFF); Load_Byte(0x00); break;
				case '6': Load_Byte(0xFF); Load_Byte(0xFF); break;
			}
	
			Load_Byte(0xff); // FFh: RST pin functions as reset
			Load_Byte(0xff); // FFh: Brown-out Detector Enabled
			Load_Byte(0xff); // FFh: On-chip Debug Disabled
			Load_Byte(0xff); // FFh: In-System Programming Enabled
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x01 )?0xff:0x00) ); // RC oscillator frequency adjustment
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x02 )?0xff:0x00) );
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x04 )?0xff:0x00) );
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x08 )?0xff:0x00) );
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x10 )?0xff:0x00) );
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x20 )?0xff:0x00) );
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x40 )?0xff:0x00) );
			Load_Byte( (unsigned char)( ( Atmel_Signature[8] & 0x80 )?0xff:0x00) );
			Load_Byte(0xff); // 00h: Programming of User Signature Enabled
			Load_Byte(0x00); // 00h: I/O Ports start in quasi-bidirectional mode after reset
			Load_Byte(0x00); // 00h: Do not use (OCD Interface Select)
	
			Set_SS_to(1);
			Send_SPI_Buffer();
			BusyFlag();
		}
		else if( (strcmp(Name_Str, "AT89LP51")==0)  ||  // Tested
	             (strcmp(Name_Str, "AT89LP52")==0) )    // Tested
		{
			// The protocol for the LP51/LP52 is too different from the ones
			// above, so start over...
			
			Reset_SPI_Buffer();
			Load_Byte(0x71); // 01110001
			Load_Byte(0x00); // 00000000
			Load_Byte(0x00); // 00bbbbbb
	
			// Selects source for the system clock:
			// CS1 CS0 Selected Source
			// FFh FFh High Speed Crystal Oscillator (XTAL)
			// FFh 00h Low Speed Crystal Oscillator (XTAL)
			// 00h FFh External Clock on XTAL1 (XCLK)
			// 00h 00h Internal 1.8MHz Auxiliary Oscillator (IRC)
			switch (s_ClockSource[0])
			{
				case 'C': Load_Byte(0xFF); Load_Byte(0xFF); break;
				default:
				case 'R': Load_Byte(0x00); Load_Byte(0x00); break;
			}
	
			// Selects time-out delay for the POR/BOD/PWD wake-up period:
			// SUT1 SUT0 Selected Time-out
			// 00h 00h  1 ms (XTAL);  16 us (XCLK/IRC)
			// 00h FFh  2 ms (XTAL); 512 us (XCLK/IRC)
			// FFh 00h  4 ms (XTAL);   1 ms (XCLK/IRC)
			// FFh FFh 16 ms (XTAL);   4 ms (XCLK/IRC)
			switch (s_StartupTime[1])
			{
				case '1': Load_Byte(0x00); Load_Byte(0x00); break;
				case '2': Load_Byte(0x00); Load_Byte(0xFF); break;
				case '4': Load_Byte(0xFF); Load_Byte(0x00); break;
				case '6': Load_Byte(0xFF); Load_Byte(0xFF); break;
			}
	
			Load_Byte((unsigned char)((b_Compt)?0xff:0x00)); // 0xff: CPU in slow (12 clks per cycle) mode; 0x00: CPU in fast (1 clk per cycle) mode
			Load_Byte(0xff); // FFh: In-System Programming Enabled
			Load_Byte(0x00); // 00h: Programming of User Signature Enabled
			Load_Byte(0x00); // 00h: I/O Ports start in quasi-bidirectional mode after reset
			Load_Byte(0x00); // 00h: In-Application Programming Enabled
			Load_Byte(0xff); // 5M resistor on XTAL1 Disabled
			
			for(j=10; j<64; j++) Load_Byte(0);
	
			Set_SS_to(1);
			Send_SPI_Buffer();
			BusyFlag();
		}
		else if( (strcmp(Name_Str, "AT89LP2052")==0)  ||  // Tested
	             (strcmp(Name_Str, "AT89LP4052")==0) )    // Tested
		{
			// Write User Fuses(3) 10101010 11100001 xxxxxxxx xxxxxxxx 1111FFFF
			// Check datasheet: Figure 23-17. Write User Fuses Sequence.
			Reset_SPI_Buffer();
			Set_SS_to(0);
			Load_Byte(0xaa);
			Load_Byte(0xE1); // 11100001
			Load_Byte(0x00); // 00000000
			Load_Byte(0x00); // 00000000
			// From table 23.1 Programming Command Summary:
			//  Bit 0 ISP Enable*            Enable = 0/Disable = 1
			//  Bit 1 XTAL Osc Bypass        Enable = 0/Disable = 1
			//  Bit 2 User Row Programming   Enable = 0/Disable = 1
			//  Bit 3 System Clock Out       Enable = 0/Disable = 1
			Load_Byte(0xfe); // Keep ISP enabled: bit0 = 0

			Set_SS_to(1);
			Send_SPI_Buffer();
			BusyFlag();
		}
		else
		{
			printf("WARNING: Don't know how to write fuses for the %s\n", Name_Str); fflush(stdout);
		}
		printf(" Done.\n"); fflush(stdout);
	}
	
	if(b_read)
	{
		FILE * fileout;
		BOOL DoSave;
		int chksum;
		char str[0x100];
		
		if ( (fileout=fopen(OutName, "w")) == NULL )
	    {
	       printf("Error: Can't create file `%s`.\r\n", OutName);
	       return;
	    }
	    
		star_count=0;
		printf("Reading flash memory: "); fflush(stdout);
	
		for(address=0; address<memsize; address+=buff_size)
		{
			// Read Code Page 00110000 000aaaaa aabbbbbb DataOut 0 ... DataOut n
			Reset_SPI_Buffer();
			Set_SS_to(0);
			if(header_offset<2) Load_Byte(0xaa);
			if(header_offset<1) Load_Byte(0x55);
			Load_Byte(0x30);
			Load_Byte((unsigned char)(address/0x100)); // 000aaaaa
			Load_Byte((unsigned char)(address%0x100)); // aabbbbbb
			for(j=0, DoSend=FALSE; j<buff_size; j++) Load_Byte(0);
			Set_SS_to(1);
			Send_SPI_Buffer();

			if(star_count==50)
			{
				star_count=0;
				printf("\nReading flash memory: ");
			}
			printf("#"); fflush(stdout);
			star_count++;
			for(j=0; j<buff_size; j++)
			{
				if( (j&0xf)==0 )
				{
					sprintf(str, ":10%04X00", address+j);
					chksum=0x10+(address+j)/0x100+(address+j)%0x100;
					DoSave=FALSE;
				}
				sprintf(&str[9+((j&0xf)*2)], "%02X", Received_SPI[j+5-header_offset]);
				chksum+=Received_SPI[j+5-header_offset];
				if (Received_SPI[j+5-header_offset]!=0xff) DoSave=TRUE;

				if( (j&0xf)==0x0f )
				{
					if(DoSave==TRUE)
					{
						fprintf(fileout, "%s%02X\n", str, -chksum&0xff);
					}
				}
			}
		}
		fprintf(fileout, ":00000001FF\n");
		printf(" Done.\n"); fflush(stdout);
	    
	    fclose(fileout);
	}
   
    printf("Actions completed in ");
    STOP;
	PRINTTIME;
	printf("\n"); fflush(stdout);
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
				printf("Description=%s ",Description);
				//printf(" ftHandle=0x%x",ftHandleTemp);
				FT_Open(j, &handle);
				FT_GetComPortNumber(handle, &PortNumber);				
				FT_Close(handle);
				printf("Port=COM%d\n", PortNumber); fflush(stdout);
			}
		}
		fflush(stdout);
		GetOutAfterError(-1);
	}
	
	return toreturn;
}

void print_help (char * prn)
{
	printf("Some examples:\n"
	       "%s -p -v -CRYSTAL somefile.hex  (program/verify configure for external crystal)\n"
	       "%s -p -v -RC somefile.hex (program/verify configure for internal RC oscillator)\n"
	       "Other options available:\n"
	       "   -Compatibility      For 12 clocks per cycle.\n"
	       "   -X2                 In fast mode, 2 clocks per cycle.\n"
	       "   -s1                 Set start-up time to  1 ms.\n" 
	       "   -s2                 Set start-up time to  2 ms.\n" 
	       "   -s4                 Set start-up time to  4 ms.\n" 
	       "   -s16                Set start-up time to 16 ms.\n" 
	       "   -rmyfile.hex        Read flash and save to myfile.hex\n", 
	       prn, prn);
}

int main(int argc, char ** argv)
{
    int j, k;
	LONG lComPortNumber;
	char buff[256];

    if(argc<2)
    {
    	printf("Need a filename to proceed. ");
    	print_help(argv[0]);
    	return 1;
    }

    for(j=1; j<argc; j++)
    {
    	     if(EQ("-Compatibility", argv[j])) b_Compt=TRUE;
    	else if(EQ("-X2", argv[j])) b_X1X2=TRUE;
    	else if(EQ("-CRYSTAL", argv[j])) strcpy( s_ClockSource, "Crystal");
    	else if(EQ("-RC", argv[j])) strcpy( s_ClockSource, "RC");
    	else if(EQ("-p", argv[j])) b_program=TRUE;
    	else if((argv[j][0]=='-') && (toupper(argv[j][1])=='R'))
    	{
    		b_read=TRUE;
    		strcpy(OutName, &argv[j][2]);
    	}
    	else if(EQ("-v", argv[j])) b_verify=TRUE;
    	else if(EQ("-h", argv[j])) {print_help(argv[0]); return 0;}
    	else if(EQ("-s1",  argv[j])) strcpy( s_StartupTime, " 1ms");
    	else if(EQ("-s2",  argv[j])) strcpy( s_StartupTime, " 2ms");
    	else if(EQ("-s4",  argv[j])) strcpy( s_StartupTime, " 4ms");
    	else if(EQ("-s16", argv[j])) strcpy( s_StartupTime, "16ms");
    	else if(EQ("-debug", argv[j])) b_debug=TRUE;
    	else if(EQ("-sleepC3", argv[j])) b_sleepC3=TRUE;
		else if(strnicmp("-d", argv[j], 2)==0) Selected_Device=atoi(&argv[j][2]);
    	else strcpy(HexName, argv[j]);
    }

    printf("AT89LP ISP/SPI programmer using the BO230X board. (C) Jesus Calvino-Fraga (2016-2017)\n");
    
    if(b_program || b_verify)
    {
	    if(Read_Hex_File(HexName)<0)
	    {
	    	return 2;
	    }
    }

    if(FT_Open(List_FTDI_Devices(), &handle) != FT_OK)
    {
        puts("Can not open FTDI adapter.\n");
        return 3;
    }
    
    if(b_sleepC3)
    {
    	b_debug=TRUE;
		FTDI_Set_CBUS3_Mode(FT_X_SERIES_CBUS_SLEEP); // Factory defult for CBUS3
		return 0;
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
    
	FT_W32_EscapeCommFunction(handle, SETRTS); // To keep SCK low before reset is applied
    FT_SetBitMode(handle, OUTPUTS, FT_BITMODE_SYNC_BITBANG); // Synchronous bit-bang mode
    FT_SetBaudRate(handle, 125000);  // Actually 125000*16, but SPI clock is half of that
	FT_SetLatencyTimer (handle, 5); // Makes checking status bit faster
	FTDI_Set_CBUS3_Mode(FT_X_SERIES_CBUS_IOMODE); // Using CBUS3 as reset pin requires this configuration
	
	Flash_AT89LP();
	
	FT_SetBitMode(handle, 0x00, FT_BITMODE_CBUS_BITBANG); // Set CBUS3 as input
	FT_SetBitMode(handle, 0x0, FT_BITMODE_RESET); // Back to serial port mode
	FT_W32_EscapeCommFunction(handle, CLRRTS); // Default value of RTS when we are done
	FT_Close(handle);
	
    return 0;
}
