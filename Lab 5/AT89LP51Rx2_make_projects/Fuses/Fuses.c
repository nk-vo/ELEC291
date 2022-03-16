//  AT89LP51RC2 with LCD in 4-bit interface mode
//  Copyright (c) 2008-2018 Jesus Calvino-Fraga
//  ~C51~

#include <stdio.h>
#include <at89lp51rd2.h>

#define CLK    22118400L // SYSCLK frequency in Hz
#define BAUD     115200L // Baud rate of UART in bps
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

unsigned char _c51_external_startup(void)
{	
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O
    
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
	#if ((CLK/(16L*BAUD))>0x100L)
	#error "Can not set baud rate because (CLK/(16*BAUD)) > 0x100 "
	#endif
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;

    return 0;
}

void wait_us (unsigned char x)
{
	unsigned int j;
	
	TR0=0; // Stop timer 0
	TMOD&=0xf0; // Clear the configuration bits for timer 0
	TMOD|=0x01; // Mode 1: 16-bit timer
	
	if(x>5) x-=5; // Subtract the overhead
	else x=1;
	
	j=-ONE_USEC*x;
	TF0=0;
	TH0=j/0x100;
	TL0=j%0x100;
	TR0=1; // Start timer 0
	while(TF0==0); //Wait for overflow
}

void waitms (unsigned int ms)
{
	unsigned int j;
	unsigned char k;
	for(j=0; j<ms; j++)
		for (k=0; k<4; k++) wait_us(250);
}

void loadbyte(unsigned int address, unsigned char value)
{
	address;
	ACC=value;
	_asm
		movx @DPTR, A
	_endasm;
}

unsigned char readbyte(unsigned int address)
{
	address;
	ACC=0;
	_asm
		movc a, @a+DPTR
	_endasm;
	return ACC;
}


void SetMode (unsigned char newmode)
{
	// Configure the 'fuses' to run in fast mode. 
	// This becomes effective only after the next power cycle.
	
    // Load the page buffer with the fuse values
    FCON=0x08 ; //Page Buffer Mapping Enabled (FPS = 1)

    // 00 – 01H Clock Source A – CSA[0:1]
    loadbyte(0x00, 0xff); // FFh FFh High Speed Crystal Oscillator on XTAL1A/XTAL2A (XTAL)
    loadbyte(0x01, 0xff);

    // 02 – 03H Start-up Time – SUT[0:1]
    loadbyte(0x02, 0xff); // FFh FFh 16 ms (XTAL)
    loadbyte(0x03, 0xff);

    // 04H Bootloader Jump Bit 
    loadbyte(0x04, 0xff); // FFh: Reset to user application at 0000H

    // 05H External RAM Enable
    loadbyte(0x05, 0xff); // FFh: External RAM enabled at reset (EXTRAM = 1)

    // 06H Compatibility Mode
    loadbyte(0x06, newmode); // 00h: CPU functions is single-cycle Fast mode
    
    // 07H ISP Enable
    loadbyte(0x07, 0xff); // FFh: In-System Programming Enabled
    
    // 08H X1/X2 Mode
    loadbyte(0x08, 0x00); // 00h: X2 Mode (System clock is not divided-by-two)

    // 09H OCD Enable
    loadbyte(0x09, 0xff); // FFh: On-Chip Debug is Disabled

    // 0AH User Signature Programming
    loadbyte(0x0A, 0xff); // FFh: Programming of User Signature Disabled

    // 0BH Tristate Ports
    loadbyte(0x0B, 0x00); // 00h: I/O Ports start in quasi-bidirectional mode after reset

    // 0CH Reserved
    loadbyte(0x0C, 0xff);
    
    // 0D – 0EH Low Power Mode – LPM[0:1]
    loadbyte(0x0D, 0xff); //FFh: Low Power Mode
    loadbyte(0x0E, 0xff);
    
    // 0FH R1 Enable
    loadbyte(0x0F, 0xff); // FFh: 5 Mohm resistor on XTAL1A Disabled
    
    // 10H Oscillator Select
    loadbyte(0x10, 0xff); // FFh: Boot from Oscillator A
    
    // 11 – 12h Clock Source B – CSB[0:1]
    loadbyte(0x11, 0xff); // FFh: Low Frequency Crystal Oscillator on XTAL1B/XTAL2B (XTAL)
    loadbyte(0x12, 0xff);
    
    FCON=0x00; // Page Buffer Mapping Disabled (FPS = 0)
    
    EECON|=0b01000000; //Enable auto-erase on next write sequence  
    FCON=0x54; // Launch the programming by writing the data sequence 54H
    FCON=0xA4; // followed by A4H to FCON register.
    // If launched from internal memory, the CPU idles until programming completes.
	while((FCON&0x01)==0x01);   

    FCON=0x00; //Page Buffer Mapping Disabled (FPS = 0)
	EECON&=0b10111111; // Disable auto-erase
}

void main (void)
{
	unsigned char mode;
	char c;
	
	FCON=0x04; // Map the User Fuses
	mode=readbyte(0x06);
	FCON=0x00; // Map code flash

    // Debounce the reset button!
	if(mode==0x00)
		waitms(500);
	else
		waitms(500/12);
	
	printf("Current mode is '%s'\r\n", mode==0x00?"Fast":"Compatibility");
	printf("1) Set 'Fast' mode\r\n");
	printf("2) Set 'Compatibility' mode\r\n");
	printf("Any other key: no change\r\n");
	printf("Option: ");
	
	c=getchar();
	
	if( (c=='1') && (mode==0xff) ) SetMode(0x00); 
	if( (c=='2') && (mode==0x00) ) SetMode(0xff);
	
	printf("\r\n\Power cycle for changes to take effect\r\n\r\n");
	
	while(1)
	{
		P3_7=!P3_7;
		waitms(500);
	}
}
