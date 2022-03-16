//  AT89LP51RC2 with LCD in 4-bit interface mode
//  2008-2022 by Jesus Calvino-Fraga

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <at89lp51rd2.h>


#define CLK    22118400L // SYSCLK frequency in Hz
#define BAUD     115200L // Baud rate of UART in bps
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay

#if (CLK/(16L*BAUD))>0x100
#error Can not set baudrate
#endif
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

#define LCD_RS P3_2
// #define LCD_RW PX_X // Not used in this code, connect the pin to GND
#define LCD_E  P3_3
#define LCD_D4 P3_4
#define LCD_D5 P3_5
#define LCD_D6 P3_6
#define LCD_D7 P3_7
#define CHARS_PER_LINE 16

#define ADC_CE  P2_0
#define BB_MOSI P2_1
#define BB_MISO P2_2
#define BB_SCLK P2_3

char mystr[CHARS_PER_LINE+1];

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
	// If the ports are configured in compatibility mode, this is not needed.
	P0M0=0; P0M1=0;
	P1M0=0; P1M1=0;
	P2M0=0; P2M1=0;
	P3M0=0; P3M1=0;
	
	// Configure Serial Port and Baud Rate
    PCON|=0x80;
	SCON = 0x52;
    BDRCON=0;
    BRL=BRG_VAL;
    BDRCON=BRR|TBCK|RBCK|SPD;
    
	CLKREG=0x00; // TPS=0000B
    
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

void LCD_pulse (void)
{
	LCD_E=1;
	wait_us(40);
	LCD_E=0;
}

void LCD_byte (unsigned char x)
{
	// The accumulator in the 8051 is bit addressable!
	ACC=x; //Send high nible
	LCD_D7=ACC_7;
	LCD_D6=ACC_6;
	LCD_D5=ACC_5;
	LCD_D4=ACC_4;
	LCD_pulse();
	wait_us(40);
	ACC=x; //Send low nible
	LCD_D7=ACC_3;
	LCD_D6=ACC_2;
	LCD_D5=ACC_1;
	LCD_D4=ACC_0;
	LCD_pulse();
}

void WriteData (unsigned char x)
{
	LCD_RS=1;
	LCD_byte(x);
	waitms(2);
}

void WriteCommand (unsigned char x)
{
	LCD_RS=0;
	LCD_byte(x);
	waitms(5);
}

void LCD_4BIT (void)
{
	LCD_E=0; // Resting state of LCD's enable is zero
	//LCD_RW=0; // We are only writing to the LCD in this program
	waitms(20);
	// First make sure the LCD is in 8-bit mode and then change to 4-bit mode
	WriteCommand(0x33);
	WriteCommand(0x33);
	WriteCommand(0x32); // Change to 4-bit mode

	// Configure the LCD
	WriteCommand(0x28);
	WriteCommand(0x0c);
	WriteCommand(0x01); // Clear screen command (takes some time)
	waitms(20); // Wait for clear screen command to finsih.
}

void LCDprint(char * string, unsigned char line, bit clear)
{
	int j;

	WriteCommand(line==2?0xc0:0x80);
	waitms(5);
	for(j=0; string[j]!=0; j++)	WriteData(string[j]);// Write the message
	if(clear) for(; j<CHARS_PER_LINE; j++) WriteData(' '); // Clear the rest of the line
}


unsigned int volatile GetADC(unsigned char channel)
{
	unsigned int adc;
	unsigned char spid;

	ADC_CE=0; //Activate the MCP3008 ADC.
	
	SPIWrite(0x01);//Send the start bit.
	spid=SPIWrite((channel*0x10)|0x80);	//Send single/diff* bit, D2, D1, and D0 bits.
	adc=((spid & 0x03)*0x100);//spid has the two most significant bits of the result.
	spid=SPIWrite(0x00);//It doesn't matter what we send now.
	adc+=spid;//spid contains the low part of the result. 
	
	ADC_CE=1; //Deactivate the MCP3008 ADC.
		
	return adc;
}

float calc_phase(unsigned int interval, float period) {
	float pd;
	interval = interval - (int)(period/2);
	pd = interval * (360.0 / period);
	while(pd > 180 || pd < -180) {
		if(pd < -180) {
			pd += 360;
		}
		else if(pd > 180) {
			pd = 360 - pd;
		}
	}

	return pd;
}

float measure_half_period(int channel){
    float OVcnt=0;
    // Measure half period at ADC CH0 using timer 0
    TR0=0; // Stop Timer 0
    TF0=0; // Clear overflow flag
    TL0=0; // Reset the timer
    TH0=0;
    while (GetADC(channel)>2); // Wait for the signal to be zero
    while (GetADC(channel)<4); // Wait for the signal to be one
    TR0=1; // Start timing
    while (GetADC(channel)>2) // Wait for the signal to be zero
        {
            if (TF0)
            {
            TF0=0;
            OVcnt++;
            }
        }
    TR0=0; // Stop timer 0
    return OVcnt*65536.0+TH0*256.0+TL0; // half_period is "float"
}


#define Vref 3.10 // Reference voltage (measured with multimeter)
#define Vtest 3.04 // Test voltage (measured with multimeter)
#define period 1/59.62
#define sqrt2 1.414213562
#define pi 3.141592654
void main (void)
{
	// unsigned char j;
	// char c;

    
	float half_period, ref_period, peak_ref, peak_test, time_diff, phase_shift;
	float OVcnt = 0;
    char v1[3], v2[3], ps[3];
    char space[] = " ";

	waitms(500); // Gives time to putty to start before sending text
	

	// Configure the LCD
	LCD_4BIT();
	LCDprint("Phasor Voltage", 1, 1);

	while(1)
	{   
        ref_period = measure_half_period(0);
        while (ref_period/22118400 < 0.001) {
            ref_period = measure_half_period(0);
        }
        half_period = ref_period/22118400;

        TR0=0;TF0=0;TL0=0;TH0=0;OVcnt = 0;
        while (GetADC(0)>2); // Wait for the signal to be zero
        while (GetADC(0)<4); // Wait for the signal to be one
        waitms(half_period*500);
        peak_ref = GetADC(0)*Vref/1023.0;
        peak_ref *= sqrt2;

        TR0=0;TF0=0;TL0=0;TH0=0;OVcnt = 0;
        while (GetADC(1)>2); // Wait for the signal to be zero
        while (GetADC(1)<4); // Wait for the signal to be one
        waitms(half_period*500);
        peak_test = GetADC(1)*Vtest/1023.0;
		peak_test *= sqrt2;
        TR0=0;
        while(GetADC(0)!=0);
        while(GetADC(0)==0);
        TR0=1;
        while(GetADC(0)!=0){
            if (TF0)
            {
            TF0=0;
            OVcnt++;
            }
        }
        while(GetADC(0)==0){
            if (TF0)
            {
            TF0=0;
            OVcnt++;
            }
        }
        TR0=0;
        time_diff = OVcnt*65536.0+TH0*256.0+TL0;
        time_diff /= CLK;
        phase_shift = 360*time_diff/period;
        phase_shift = phase_shift*360/pi;
        printf("%5.3f    %5.3f   %5.3f",peak_ref,peak_test,phase_shift);

        sprintf(v1, "Vref %.3f V", peak_ref);
        LCDprint(v1, 2, 1);
        waitms(2000);
        sprintf(v2, "Vtest %.3f V", peak_test);
        LCDprint(v2, 2, 1);
        waitms(2000);
        sprintf(ps, "PS %.3f deg", phase_shift);
        LCDprint(ps, 2, 1);
        waitms(2000);
        

        // printf("\r"); // Carriage return only.
	}
}
