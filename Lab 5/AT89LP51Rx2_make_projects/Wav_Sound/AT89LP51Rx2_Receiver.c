// AT89LP51Rx2_Receiver.c:  This program implements a simple serial port
// communication protocol to program, verify, and read SPI flash memories.  Since
// the program was developed to store wav audio files, it also allows 
// for the playback of said audio.  It is assumed that the wav sampling rate is
// 22050Hz, 8-bit, mono.
//
// Connections:
// 
// AT89LP51Rx2   SPI_FLASH
// (20) P2.0     Pin 6 (SPI_CLK)
// (21) P2.1     Pin 2 (MISO)
// (24) P2.4     Pin 5 (MOSI)
// (25) P2.5     Pin 1 (CS/)
// GND           Pin 4
// 3.3V          Pins 3, 7, 8
//
// The DAC output (P2.3, pin 23) should be connected to the
// input of power amplifier (LM386 or similar)
//
// WARNING: Pins P2.2 and P2.3 are the DAC outputs and can not be used for anything else

#include <stdio.h>
#include <at89lp51rd2.h>

// ~C51~ 
 
#define SYSCLK         22118400L  // Microcontroller system clock frequency in Hz
#define TIMER1_RATE    22050L     // 22050Hz is the sampling rate of the wav file we are playing
#define TIMER1_RELOAD  (0x10000L-(SYSCLK/TIMER1_RATE))
#define BAUD 115200L
#define BRG_VAL (0x100-(SYSCLK/(16L*BAUD)))

// Pins used for bit-bang SPI
#define FLASH_CE P2_5
#define BB_MOSI  P2_4 
#define BB_MISO  P2_1
#define BB_SCLK  P2_0 

#define SPEAKER  P2_6 // Used with a MOSFET to turn off speaker when not in use

// Flash memory commands
#define WRITE_ENABLE     0x06  // Address:0 Dummy:0 Num:0 fMax: 25MHz
#define WRITE_DISABLE    0x04  // Address:0 Dummy:0 Num:0 fMax: 25MHz
#define READ_STATUS      0x05  // Address:0 Dummy:0 Num:1 to infinite fMax: 32MHz
#define READ_BYTES       0x03  // Address:3 Dummy:0 Num:1 to infinite fMax: 20MHz
#define READ_SILICON_ID  0xab  // Address:0 Dummy:3 Num:1 to infinite fMax: 32MHz
#define FAST_READ        0x0b  // Address:3 Dummy:1 Num:1 to infinite fMax: 40MHz
#define WRITE_STATUS     0x01  // Address:0 Dummy:0 Num:1 fMax: 25MHz
#define WRITE_BYTES      0x02  // Address:3 Dummy:0 Num:1 to 256 fMax: 25MHz
#define ERASE_ALL        0xc7  // Address:0 Dummy:0 Num:0 fMax: 25MHz
#define ERASE_BLOCK      0xd8  // Address:3 Dummy:0 Num:0 fMax: 25MHz
#define READ_DEVICE_ID   0x9f  // Address:0 Dummy:2 Num:1 to infinite fMax: 25MHz

volatile unsigned long int playcnt=0;
volatile bit play_flag=0;

unsigned char uart_getc (void)
{
	char c;
	while (!RI);
	RI=0;
	c=SBUF;
	return c;
}

void uart_putc (unsigned char c)
{
	while (!TI);
	TI=0;
	SBUF=c;
}

unsigned char SPIWrite(unsigned char out_byte)
{
	// In the 8051 architecture both ACC and B are bit addressable!
	ACC=out_byte;
	
	BB_MOSI=ACC_7; BB_SCLK=1; B_7=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_6; BB_SCLK=1; B_6=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_5; BB_SCLK=1; B_5=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_4; BB_SCLK=1; B_4=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_3; BB_SCLK=1; B_3=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_2; BB_SCLK=1; B_2=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_1; BB_SCLK=1; B_1=BB_MISO; BB_SCLK=0;
	BB_MOSI=ACC_0; BB_SCLK=1; B_0=BB_MISO; BB_SCLK=0;
	
	return B;
}

unsigned char _c51_external_startup(void)
{
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O

	// Configure all pins as bidirectional
	P0M0=0x00; P0M1=0x00;    
	P1M0=0x00; P1M1=0x00;    
	P2M0=0x00; P2M1=0x00;    
	P3M0=0x00; P3M1=0x00;
	
	// Configure serial port and baudrate   
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
    #if (CLK/(16L*BAUD))>0x100
    #error Can not set baudrate
    #endif
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;

	// Initialize timer 1 for periodic interrupts
	CLKREG=0x00; // TPS=0000B
	TR1=0;
	TF1=0;
	TMOD&=0x0f;
	TMOD|=0x10; // Timer 1 in mode 1: 16-bit timer
	TL1=RL1=TIMER1_RELOAD%0x100; // Initialize reload value low
	TH1=RH1=TIMER1_RELOAD/0x100; // Initialize reload value high
	ET1=1;  // Enable Timer1 interrupts
	TR1=1;  // Start Timer1

	// Configure SPI pins and turn off speaker
	P2M0=0b_1000_1110;
	P2M1=0b_0111_0001;
	BB_MISO=1; // Configured as input
	FLASH_CE=1; // CS=1 for SPI flash memory
	BB_SCLK=0; // Rest state of SCLK=0
	SPEAKER=0; // Turn off speaker.
	
	// Initialize the DAC.  The DAC output we are using is P2.3, but P2.2 is also reserved.
	DADI=0b_1010_0000; // ACON=1
	DADC=0b_0011_1010; // Enabled, DAC mode, Left adjusted, CLK/4
	DADH=0x80; // Middle of scale
	DADL=0;
	DADC|=0b_0100_0000; // Start DAC by GO/BSY=1
	while(DADC&0b_0100_0000); // Wait for DAC to finish
	
	// We can also attach a 8-bit DAC to P0 and use that instead (better sound)
	// Configure P0 for push-pull outputs:
	P0M0=0b_0000_0000;
	P0M1=0b_1111_1111;
	
	EA=1; // Enable interrupts
	
    return 0;
}

// Timer 1 Interrupt Service Routine
void Timer1_ISR (void) interrupt 3
{
	unsigned char val;
	
	if(play_flag)
	{  
		if(playcnt==0)
		{
			FLASH_CE=1; // Disable SPI Flash
			play_flag=0;
			SPEAKER=0; // Turn off speaker.  Removes hissing noise when not playing sound.
			P0=0x80;
			DADH=0x80 ; // middle of range
			DADC|=0b_0100_0000; // Start DAC by setting GO/BSY=1
		}
		else
		{
			SPEAKER=1; // Turn on speaker.
			val=SPIWrite(0x00);
			P0=val;
			DADH=val+0x80; // Output value to DAC.  It is two complemented so +0x80
			DADC|=0b_0100_0000 ; // Start DAC by setting GO/BSY=1
			playcnt--;
		}
	}
}

void Start_Playback (unsigned long int address, unsigned long int numb)
{
	FLASH_CE=1; // Disable SPI Flash
	play_flag=0;
	SPEAKER=0;
    FLASH_CE=0; // Select/enable 25Q32 SPI flash memory.
    SPIWrite(READ_BYTES);
    SPIWrite((unsigned char)((address>>16)&0xff));
    SPIWrite((unsigned char)((address>>8)&0xff));
    SPIWrite((unsigned char)(address&0xff));
    playcnt=numb;
    play_flag=1;
}

void Enable_Write (void)
{
    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
    SPIWrite(WRITE_ENABLE);
	FLASH_CE=1; // Disable 25Q32 SPI flash memory
}

void Check_WIP (void)
{
	unsigned char c;
	do
	{
    	FLASH_CE=0; // Enable 25Q32 SPI flash memory.
	    SPIWrite(READ_STATUS);
	    c=SPIWrite(0x55);
		FLASH_CE=1; // Disable 25Q32 SPI flash memory
	} while (c&0x01);
}

static const unsigned short crc16_ccitt_table[256] = {
    0x0000U, 0x1021U, 0x2042U, 0x3063U, 0x4084U, 0x50A5U, 0x60C6U, 0x70E7U,
    0x8108U, 0x9129U, 0xA14AU, 0xB16BU, 0xC18CU, 0xD1ADU, 0xE1CEU, 0xF1EFU,
    0x1231U, 0x0210U, 0x3273U, 0x2252U, 0x52B5U, 0x4294U, 0x72F7U, 0x62D6U,
    0x9339U, 0x8318U, 0xB37BU, 0xA35AU, 0xD3BDU, 0xC39CU, 0xF3FFU, 0xE3DEU,
    0x2462U, 0x3443U, 0x0420U, 0x1401U, 0x64E6U, 0x74C7U, 0x44A4U, 0x5485U,
    0xA56AU, 0xB54BU, 0x8528U, 0x9509U, 0xE5EEU, 0xF5CFU, 0xC5ACU, 0xD58DU,
    0x3653U, 0x2672U, 0x1611U, 0x0630U, 0x76D7U, 0x66F6U, 0x5695U, 0x46B4U,
    0xB75BU, 0xA77AU, 0x9719U, 0x8738U, 0xF7DFU, 0xE7FEU, 0xD79DU, 0xC7BCU,
    0x48C4U, 0x58E5U, 0x6886U, 0x78A7U, 0x0840U, 0x1861U, 0x2802U, 0x3823U,
    0xC9CCU, 0xD9EDU, 0xE98EU, 0xF9AFU, 0x8948U, 0x9969U, 0xA90AU, 0xB92BU,
    0x5AF5U, 0x4AD4U, 0x7AB7U, 0x6A96U, 0x1A71U, 0x0A50U, 0x3A33U, 0x2A12U,
    0xDBFDU, 0xCBDCU, 0xFBBFU, 0xEB9EU, 0x9B79U, 0x8B58U, 0xBB3BU, 0xAB1AU,
    0x6CA6U, 0x7C87U, 0x4CE4U, 0x5CC5U, 0x2C22U, 0x3C03U, 0x0C60U, 0x1C41U,
    0xEDAEU, 0xFD8FU, 0xCDECU, 0xDDCDU, 0xAD2AU, 0xBD0BU, 0x8D68U, 0x9D49U,
    0x7E97U, 0x6EB6U, 0x5ED5U, 0x4EF4U, 0x3E13U, 0x2E32U, 0x1E51U, 0x0E70U,
    0xFF9FU, 0xEFBEU, 0xDFDDU, 0xCFFCU, 0xBF1BU, 0xAF3AU, 0x9F59U, 0x8F78U,
    0x9188U, 0x81A9U, 0xB1CAU, 0xA1EBU, 0xD10CU, 0xC12DU, 0xF14EU, 0xE16FU,
    0x1080U, 0x00A1U, 0x30C2U, 0x20E3U, 0x5004U, 0x4025U, 0x7046U, 0x6067U,
    0x83B9U, 0x9398U, 0xA3FBU, 0xB3DAU, 0xC33DU, 0xD31CU, 0xE37FU, 0xF35EU,
    0x02B1U, 0x1290U, 0x22F3U, 0x32D2U, 0x4235U, 0x5214U, 0x6277U, 0x7256U,
    0xB5EAU, 0xA5CBU, 0x95A8U, 0x8589U, 0xF56EU, 0xE54FU, 0xD52CU, 0xC50DU,
    0x34E2U, 0x24C3U, 0x14A0U, 0x0481U, 0x7466U, 0x6447U, 0x5424U, 0x4405U,
    0xA7DBU, 0xB7FAU, 0x8799U, 0x97B8U, 0xE75FU, 0xF77EU, 0xC71DU, 0xD73CU,
    0x26D3U, 0x36F2U, 0x0691U, 0x16B0U, 0x6657U, 0x7676U, 0x4615U, 0x5634U,
    0xD94CU, 0xC96DU, 0xF90EU, 0xE92FU, 0x99C8U, 0x89E9U, 0xB98AU, 0xA9ABU,
    0x5844U, 0x4865U, 0x7806U, 0x6827U, 0x18C0U, 0x08E1U, 0x3882U, 0x28A3U,
    0xCB7DU, 0xDB5CU, 0xEB3FU, 0xFB1EU, 0x8BF9U, 0x9BD8U, 0xABBBU, 0xBB9AU,
    0x4A75U, 0x5A54U, 0x6A37U, 0x7A16U, 0x0AF1U, 0x1AD0U, 0x2AB3U, 0x3A92U,
    0xFD2EU, 0xED0FU, 0xDD6CU, 0xCD4DU, 0xBDAAU, 0xAD8BU, 0x9DE8U, 0x8DC9U,
    0x7C26U, 0x6C07U, 0x5C64U, 0x4C45U, 0x3CA2U, 0x2C83U, 0x1CE0U, 0x0CC1U,
    0xEF1FU, 0xFF3EU, 0xCF5DU, 0xDF7CU, 0xAF9BU, 0xBFBAU, 0x8FD9U, 0x9FF8U,
    0x6E17U, 0x7E36U, 0x4E55U, 0x5E74U, 0x2E93U, 0x3EB2U, 0x0ED1U, 0x1EF0U
};

unsigned short crc16_ccitt(unsigned char val, unsigned short crc)
{
    unsigned short tmp;

    tmp = (crc >> 8) ^ val;
    crc = ((unsigned short)(crc << 8U)) ^ crc16_ccitt_table[tmp];
    return crc;
}

// Get a 24-bit number from the serial port and store it into a unsigned long
void get_ulong(unsigned long * lptr)
{
    unsigned char * bytes;
    bytes=(unsigned char *) lptr;
	bytes[3]=0;
	bytes[2]=uart_getc();
	bytes[1]=uart_getc();
	bytes[0]=uart_getc();
}

int main( void )
{
    unsigned char c;
    unsigned int j, n;
    unsigned long start, nbytes;
    unsigned short crc;
	
	playcnt=0;
	play_flag=0;
      
	while(1)
	{
		if (RI)
		{
			c=uart_getc();
			if(c=='#')
			{
				playcnt=0;
				play_flag=0;
				FLASH_CE=1; // Disable 25Q32 SPI flash memory
	
				c=uart_getc();
				switch(c)
				{
					case '0': // Identify command
					    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
					    SPIWrite(READ_DEVICE_ID);
					    c=SPIWrite((unsigned char)(0x00));
					    uart_putc(c);
					    c=SPIWrite((unsigned char)(0x00));
					    uart_putc(c);
					    c=SPIWrite((unsigned char)(0x00));
					    uart_putc(c);
					    FLASH_CE=1; // Disable 25Q32 SPI flash memory
					break;
	
					case '1': // Erase whole flash (takes a long time)
						Enable_Write();
					    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
					    SPIWrite(ERASE_ALL);
					    FLASH_CE=1; // Disable 25Q32 SPI flash memory
					    Check_WIP();
					    uart_putc(0x01);
					break;
					
					case '2': // Load flash page (256 bytes or less)
						Enable_Write();
					    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
					    SPIWrite(WRITE_BYTES);
					    c=uart_getc(); // Address bits 16 to 23
					    SPIWrite(c);
					    c=uart_getc(); // Address bits 8 to 15
					    SPIWrite(c);
					    c=uart_getc(); // Address bits 0 to 7
					    SPIWrite(c);
					    n=uart_getc(); // Number of bytes to write
					    if(n==0) n=256;
					    for(j=0; j<n; j++)
					    {
					    	c=uart_getc();
					    	SPIWrite(c);
					    }
					    FLASH_CE=1; // Disable 25Q32 SPI flash memory
					    Check_WIP();
					    uart_putc(0x01);
					break;
					
					case '3': // Read flash bytes (256 bytes or less)
					    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
					    SPIWrite(READ_BYTES);
					    c=uart_getc(); // Address bits 16 to 23
					    SPIWrite(c);
					    c=uart_getc(); // Address bits 8 to 15
					    SPIWrite(c);
					    c=uart_getc(); // Address bits 0 to 7
					    SPIWrite(c);
					    n=uart_getc(); // Number of bytes to write
					    if(n==0) n=256;
					    for(j=0; j<n; j++)
					    {
					    	c=SPIWrite(0x55);
					    	uart_putc(c);
					    }
					    FLASH_CE=1; // Disable 25Q32 SPI flash memory
					break;
					
					case '4': // Playback a portion of the stored wav file
						get_ulong(&start); // Get the start position
						get_ulong(&nbytes); // Get the number of bytes to playback
						Start_Playback(start, nbytes);
					break;
					
					// WARNING: CRC calculation here is way slower than in the EFM8 or SoC-8052.
					// Modify computer_sender.c so it doesn't time out.
					// Change line:
					//               maxwait=length/300000.0;
					// to:
					//               maxwait=length/30000.0;
					case '5': ; // Calculate and send CRC-16 of ISP flash memory from zero to the 24-bit passed value.
						get_ulong(&nbytes); // Get the total number of bytes used to calculate the crc
					
						crc=0;
					    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
					    SPIWrite(READ_BYTES);
					    SPIWrite(0x00); // Address bits 16 to 23
					    SPIWrite(0x00); // Address bits 8 to 1
					    SPIWrite(0x00); // Address bits 0 to 7
					    
						for(start=0; start<nbytes; start++)
						{
							c=SPIWrite(0x00);
							crc=crc16_ccitt(c, crc); // Calculate CRC here
						}
					    FLASH_CE=1; // Disable 25Q32 SPI flash memory
	
						uart_putc(crc/0x100); // Send high byte of CRC
						uart_putc(crc%0x100); // Send low byte of CRC
					break;
	
					case '6': // Fill flash page (256 bytes or less).
						Enable_Write();
					    FLASH_CE=0; // Enable 25Q32 SPI flash memory.
					    SPIWrite(WRITE_BYTES);
					    c=uart_getc(); // Address bits 16 to 23
					    SPIWrite(c);
					    c=uart_getc(); // Address bits 8 to 15
					    SPIWrite(c);
					    c=uart_getc(); // Address bits 0 to 7
					    SPIWrite(c);
					    c=uart_getc(); // byte to copy to page
					    for(j=0; j<256; j++)
					    {
					    	SPIWrite(c);
					    }
					    FLASH_CE=1; // Disable 25Q32 SPI flash memory
					    Check_WIP();
					    uart_putc(0x01);
					break;
				}
			}
		}
		else // RI==0
		{
			if (P4_5==0)
			{
				while(P4_5==0);
				Start_Playback(0x000000L, 0x3fffffL); // Playback the whole flash memory
			}
		}
    }  
}
