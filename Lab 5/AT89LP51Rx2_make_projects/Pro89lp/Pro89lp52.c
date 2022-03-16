// FT230XS SPI in synchronous bit bang mode to program
// the AT89LP52 microcontroller. Connect as follows:
//
// For the AT89LP51 and AT89LP52:
//    40 DIP:     BO230XS board:
//      (GND) 20 --- GND
//      (VCC) 40 --- VCC
//      (POL) 31 --- GND
//      (MOSI) 6 --- TXD
//      (MISO) 7 --- RXD
//      (SLCK) 8 --- RTS
//      (RST)  9 --- Pin 6 of J3
// (c) Jesus Calvino-Fraga (2016)

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#pragma comment(lib, "FTD2XX.lib")
#define FTD2XX_STATIC
#include "ftd2xx.h"

#define MOSI 0x01  // TXD pin
#define MISO 0x02  // RXD pin
#define SCLK 0x04  // RTS pin
#define SS   0x08  // CTS pin (not used with the AT89LP52)
#define OUTPUTS (MOSI|SCLK|SS)

unsigned char bitloc[]={0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80};

#define BUFFSIZE ((67*8*2)+2)

FT_HANDLE handle;
DWORD bytes;

unsigned char SPI_Buffer[BUFFSIZE]; // Buffer used to transmit and receive SPI bits
DWORD SPI_Buffer_cnt;
short int Bit_Location[BUFFSIZE/2]; // Location of input bits in SPI_Buffer
DWORD Bit_Location_cnt;
unsigned char Received_SPI[BUFFSIZE/(8*2)]; // Decoded input bits
DWORD Received_SPI_cnt;

#define MEMSIZE 0x2000
unsigned char Flash_Buffer[MEMSIZE];
char HexName[MAX_PATH]="";

// Selects source for the system clock:
// CS1 CS0 Selected Source
// FFh FFh High Speed Crystal Oscillator (XTAL)
// FFh 00h Low Speed Crystal Oscillator (XTAL)
// 00h FFh External Clock on XTAL1 (XCLK)
// 00h 00h Internal Auxiliary Oscillator (IRC)
unsigned char CS0=0xff;
unsigned char CS1=0xff;
// Selects time-out delay for the POR/BOD/PWD wake-up period:
// SUT1 SUT0 Selected Time-out
// 00h 00h  1 ms (XTAL);  16 us (XCLK/IRC)
// 00h FFh  2 ms (XTAL); 512 us (XCLK/IRC)
// FFh 00h  4 ms (XTAL);   1 ms (XCLK/IRC)
// FFh FFh 16 ms (XTAL);   4 ms (XCLK/IRC)
unsigned char SUT0=0xff;
unsigned char SUT1=0xff;
unsigned char Compatibility_Mode=0x00; // 0x00: CPU in fast (1 clk per cycle) mode
unsigned char ISP_Enable=0xff; // 0xff: ISP Enabled
unsigned char User_Signature=0xff; // 0xff: User Signature Programming Disabled
unsigned char Tristate_Ports=0xff; // 0xff: I/O Ports start in tri-state mode after reset
unsigned char IAP=0x00; // 0x00: In-Application Programming Enabled
unsigned char R1_Enable=0xff; // 0xff: 5M resistor on XTAL1 Disabled

BOOL b_program=FALSE, b_verify=FALSE;
int Selected_Device=-1;

#define EQ(a,b) (stricmp(a,b)==0)

clock_t startm, stopm;
#define START if ( (startm = clock()) == -1) {printf("Error calling clock");exit(1);}
#define STOP if ( (stopm = clock()) == -1) {printf("Error calling clock");exit(1);}
#define PRINTTIME printf( "%.1f seconds.", ((double)stopm-startm)/CLOCKS_PER_SEC);

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
				if((address+j)<MEMSIZE) Flash_Buffer[address+j]=value;
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

    return MaxAddress;
}

void Check_Status_Bit(void)
{
	do
	{
		Reset_SPI_Buffer();
		Load_Byte(0x60);
		Load_Byte(0x00);
	    Load_Byte(0x00);
	    Load_Byte(0x00);
	    Send_SPI_Buffer();
    } while ((Received_SPI[3]&0x01)==0);
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

int Load_Flash_AT89LP52 (void)
{
	int j, k, star_count;
	int sendbuff;

	START;
	
	// Toggle the CBUS3 pin which is connected to the reset pin of the AT89LP52:
	FT_SetBitMode(handle, (unsigned char)0x88, FT_BITMODE_CBUS_BITBANG);
	Sleep(100); // Wait for the reset pin to stabilize at logic 1
	// Enter 'In System Programming' (ISP) mode by keeping reset low
	FT_SetBitMode(handle, (unsigned char)0x80, FT_BITMODE_CBUS_BITBANG);
	Sleep(100); // Wait for the reset pin to stabilize at logic 0

    FT_SetBitMode(handle, OUTPUTS, FT_BITMODE_SYNC_BITBANG); // Synchronous bit-bang mode

	// Send 'Program Interface Enable' (PIE) command to AT89LP52.
	Reset_SPI_Buffer();
	Load_Byte(0xac);
	Load_Byte(0x53);
    Load_Byte(0x00);
    Load_Byte(0x00); //0x69 is returned if ISP is enabled.
	Send_SPI_Buffer();
    if(Received_SPI[3]!=0x69)
    {
        puts("'Program Interface Enable' (PIE) command fail. AT89LP52 not detected.\n");
        Dump_Received_SPI();
        //return -1;
    }
    
	// Read Atmel Signature Page(2)(6) 00111000 00000000 00bbbbbb DataOut 0 ... DataOut n
	Reset_SPI_Buffer();
	Load_Byte(0x38);
	Load_Byte(0); // 00000000
	Load_Byte(0); // 00bbbbbb
	// The next 64 bytes are don't care...
	for(j=0; j<64; j++) Load_Byte(0x00);
	Send_SPI_Buffer();
	//Dump_Received_SPI();

	if (b_program)
	{
	    // Prior to loading a new program we need to erase the flash memory of the AT89LP52 
		printf("AT89LP52 detected.\nErasing flash memory... "); fflush(stdout);
		Reset_SPI_Buffer();
		Load_Byte(0xac);
		Load_Byte(0x80); // Chip erase command
	    Load_Byte(0x00);
	    Load_Byte(0x00);
		Send_SPI_Buffer();
		Check_Status_Bit(); // Wait for the erase command to complete
		//printf("%02x %02x %02x %02x", Received_SPI[0], Received_SPI[1], Received_SPI[2], Received_SPI[3]);
		//fflush(stdout);
		printf("Done.\n");
		
		star_count=0;
		printf("Loading flash memory: "); fflush(stdout);
		for(j=0; j<MEMSIZE; j+=64) // Each page is 64 bytes
		{
			Reset_SPI_Buffer();
			Load_Byte(0x50); // Write Code Page command
			Load_Byte((unsigned char)(j/0x100));
		    Load_Byte((unsigned char)(j%0x100));
		    sendbuff=0;
		    for(k=0; k<64; k++)
		    {
		    	Load_Byte(Flash_Buffer[j+k]);
		    	if (Flash_Buffer[j+k]!=0xff) sendbuff=1;
		    }
		    if(sendbuff==1) // Only send pages that are not all 0xff
		    {
				if(star_count==50)
				{
					star_count=0;
					printf("\nLoading flash memory: ");
				}
				printf("#"); fflush(stdout);
				star_count++;
				
				Send_SPI_Buffer();
				Check_Status_Bit(); // Wait for the command to complete
			}
		}
		printf(" Done.\n");
	}
	
	if (b_verify)
	{
		star_count=0;
		printf("Verifiying flash memory: "); fflush(stdout);
		for(j=0; j<MEMSIZE; j+=64) // Each page is 64 bytes
		{
			Reset_SPI_Buffer();
			Load_Byte(0x30); // Read Code Page command
			Load_Byte((unsigned char)(j/0x100));
		    Load_Byte((unsigned char)(j%0x100));
		    sendbuff=0;
		    for(k=0; k<64; k++)
		    {
		    	Load_Byte(0);
		    	if (Flash_Buffer[j+k]!=0xff) sendbuff=1;
		    }
		    if(sendbuff)
		    {
				if(star_count==50)
				{
					star_count=0;
					printf("\nVerifiying flash memory: ");
				}
				printf("#"); fflush(stdout);
				star_count++;
				
				Send_SPI_Buffer();
				for(k=0; k<64; k++)
				{
					if(Received_SPI[3+k]!=Flash_Buffer[j+k])
					{
						printf("\nFlash memory program error at location %04x\n", j+k); fflush(stdout);
						return -1;
					}
				}
			}
		}
		printf(" Done.\n"); fflush(stdout);
	}

	if(b_program)
	{
		printf("Writing configuration fuses... "); fflush(stdout);
		Reset_SPI_Buffer();
		Load_Byte(0x71); // Write User Fuses with Auto-Erase command.
		Load_Byte(0x00);
		Load_Byte(0x00);
		Load_Byte(CS0);
		Load_Byte(CS1);
		Load_Byte(SUT0);
		Load_Byte(SUT1);
		Load_Byte(Compatibility_Mode);
		Load_Byte(ISP_Enable);
		Load_Byte(User_Signature);
		Load_Byte(Tristate_Ports);
		Load_Byte(IAP);
		Load_Byte(R1_Enable);
		for(k=0; k<(64-10); k++) Load_Byte(0); // The remaining 54 bytes are all zero:
	
		Send_SPI_Buffer();
		Check_Status_Bit(); // Wait for the command to complete
		printf("Done.\n"); fflush(stdout);
	}

	// Set reset pin to logic 1
	FT_SetBitMode(handle, (unsigned char)0x00, FT_BITMODE_CBUS_BITBANG); // Set reset pin to '1' by making CBUS3 an input
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
				printf("Description=%s ",Description);
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

// After executing this function we can do
// 	FT_SetBitMode(handle, (unsigned char)(val?0x88:0x80), FT_BITMODE_CBUS_BITBANG);
void FTDI_Set_CBUS3_GPIO (void)
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
		if (ft_eeprom_x_series.Cbus3!=FT_X_SERIES_CBUS_IOMODE)
		{
			ft_eeprom_x_series.Cbus3=FT_X_SERIES_CBUS_IOMODE;
			status = FT_EEPROM_Program(handle, &ft_eeprom_x_series, sizeof(ft_eeprom_x_series),
									Manufacturer, ManufacturerId, Description, SerialNumber);
			if (status == FT_OK)
			{
				FT_ResetDevice(handle);
				Sleep(100);
				//printf("WARNING: Pin CBUS3 has been configured as GPIO.\n");
				fflush(stdout);
			}
		}
	}
}

void print_help (char * prn)
{
	printf("Some examples:\n"
	       "%s -p -v -CRYSTAL somefile.hex  (program/verify configure for external crystal)\n"
	       "%s -p -v -RC somefile.hex (program/verify configure for internal 1.8432MHz RC oscillator)\n"
	       "Other options available (xx must be replaced with either 00 or ff):\n"
	       "   -CS0=xx -CS1=xx -SUT0=xx -SUT1=xx -Compatibility_Mode=xx -ISP_Enable=xx\n"
	       "   -User_Signature=xx -Tristate_Ports=xx -IAP=xx -R1_Enable=xx\n"
	       "   Check the datasheet for the meaning of the above options\n", 
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
    	     if(EQ("-CS0=ff", argv[j])) CS0=0xff;
    	else if(EQ("-CS0=00", argv[j])) CS0=0x00;
    	else if(EQ("-CS1=ff", argv[j])) CS1=0xff;
    	else if(EQ("-CS1=00", argv[j])) CS1=0x00;
    	else if(EQ("-SUT0=ff", argv[j])) SUT0=0xff;
    	else if(EQ("-SUT0=00", argv[j])) SUT0=0x00;
    	else if(EQ("-SUT1=ff", argv[j])) SUT1=0xff;
    	else if(EQ("-SUT1=00", argv[j])) SUT1=0x00;
    	else if(EQ("-Compatibility_Mode=ff", argv[j])) Compatibility_Mode=0xff;
    	else if(EQ("-Compatibility_Mode=00", argv[j])) Compatibility_Mode=0x00;
    	else if(EQ("-ISP_Enable=ff", argv[j])) ISP_Enable=0xff;
    	else if(EQ("-ISP_Enable=00", argv[j])) ISP_Enable=0x00;
    	else if(EQ("-User_Signature=ff", argv[j])) User_Signature=0xff;
    	else if(EQ("-User_Signature=00", argv[j])) User_Signature=0x00;
    	else if(EQ("-Tristate_Ports=ff", argv[j])) Tristate_Ports=0xff;
    	else if(EQ("-Tristate_Ports=00", argv[j])) Tristate_Ports=0x00;
    	else if(EQ("-IAP=ff", argv[j])) IAP=0xff;
    	else if(EQ("-IAP=00", argv[j])) IAP=0x00;
    	else if(EQ("-R1_Enable=ff", argv[j])) R1_Enable=0xff;
    	else if(EQ("-R1_Enable=00", argv[j])) R1_Enable=0x00;
    	else if(EQ("-CRYSTAL", argv[j])) {CS0=0xff; CS1=0xff;}
    	else if(EQ("-RC", argv[j])) {CS0=0x00; CS1=0x00;}
    	else if(EQ("-p", argv[j])) b_program=TRUE;
    	else if(EQ("-v", argv[j])) b_verify=TRUE;
    	else if(EQ("-h", argv[j])) {print_help(argv[0]); return 0;}
		else if(strnicmp("-d", argv[j], 2)==0) Selected_Device=atoi(&argv[j][2]);
    	else strcpy(HexName, argv[j]);
    }

    printf("AT89LP52 programmer using the BO230X board. (C) Jesus Calvino-Fraga (2016)\n");
    if(Read_Hex_File(HexName)<0)
    {
    	return 2;
    }

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

	FT_W32_EscapeCommFunction(handle, SETRTS); // To keep SCK low after reset using CBUS3
    FT_SetBitMode(handle, OUTPUTS, FT_BITMODE_SYNC_BITBANG); // Synchronous bit-bang mode
    FT_SetBaudRate(handle, 115200);  // Actually 115200*16, but SPI clock is half of that
	FT_SetLatencyTimer (handle, 5); // Makes checking status bit faster
	FTDI_Set_CBUS3_GPIO(); // Using CBUS3 as reset pin
	
	Load_Flash_AT89LP52();
	
	FT_SetBitMode(handle, 0x0, FT_BITMODE_RESET); // Back to serial port mode
	FT_W32_EscapeCommFunction(handle, CLRRTS); // To keep RTS pin at default value
	FT_Close(handle);
	
	printf("\n");
	
    return 0;
}
