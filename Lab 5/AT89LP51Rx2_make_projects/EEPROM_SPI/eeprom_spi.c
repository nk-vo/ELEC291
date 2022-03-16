#include <stdio.h>
#include <stdlib.h>
#include <at89lp51rd2.h>
#include "FT93C66.h"

// ~C51~ 
 
#define CLK 22118400L
#define BAUD 115200L
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay

#if (CLK/(16L*BAUD))>0x100
#error Can not set baudrate
#endif
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

unsigned int ErrCnt, SeedCnt;

unsigned char _c51_external_startup(void)
{
	AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is a general purpose I/O

	P0M0=0x00; P0M1=0x00;    
	P1M0=0x00; P1M1=0x00;    
	P2M0=0x00; P2M1=0x00;//P2M1=0b_0000_1011;    
	P3M0=0x00; P3M1=0x00;    
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

void Test (unsigned char testval)
{
	unsigned char j;
	unsigned int k;
	unsigned int cnt=0;
	
	FT93C66_Write_All(testval);

	for(k=0; k<0x200; k++)
	{
		j=FT93C66_Read(k);
		if(j!=testval)
		{
			if(cnt==0) printf("\n0x%02x failed at:", testval);
			ErrCnt++;
			if( ((cnt&0x0f)==0) && (cnt>0) ) printf("\n               ");
			cnt++;
			printf(" %03x", k);
		}
	}
}


void main (void)
{
	volatile unsigned char i=0, j=0;
	volatile unsigned int k, m;
	
	code unsigned char pattern[]={
		 0x00,  0xff,  0x55,  0xaa,  0x0f,  0xf0,  0x5a,  0xa5,
		 0x01,  0x02,  0x04,  0x08,  0x10,  0x20,  0x40,  0x80,
		~0x01, ~0x02, ~0x04, ~0x08, ~0x10, ~0x20, ~0x40, ~0x80 };
	
	waitms(500);
	
	while(1)
	{
		FT93C66_Init();
	
		printf(
			"\n\nAT89LP51Rx2 SPI EEPROM test program.\n"
			"\nSelect option:\n"
			"   1) Pattern test\n"
			"   2) Random test\n"
			"   3) Write Memory location\n"
			"   4) Read Memory location\n"
			"   5) Memory Location test\n"
			"   6) Display Memory\n"
			"   7) Fill Memory\n"
			"   8) Erase Memory\n"
			"Option: ");
		
		while(RI==0)
		{
			SeedCnt++;
		}

		switch(getchar())
		{
			case '1':
				FT93C66_Write_Enable();
			
				ErrCnt=0;		
				printf("\nPattern testing all memory locations.\n");
			
				for(i=0; i<sizeof(pattern); i++) Test(pattern[i]);
				if(ErrCnt>0)
				{
					printf("\nThere were %d ERROR(s).\n", ErrCnt);
				}
				else
				{
					printf("\nNo errors.  Memory works fine!\n");
				}
		
				FT93C66_Write_Disable();
				break;
			
			case '2':
				FT93C66_Write_Enable();
				printf("\nRandom testing all memory locations.\n");
				srand(SeedCnt);
				for(k=0; k<0x200; k++)
				{
					i=rand()&0xff;
					FT93C66_Write(k, i);
					j=FT93C66_Read(k);
					if((k&0xf)==0)
					{
						printf("\n%03x: ", k);
					}
					printf(" %02x", j);			
					if(j!=i) break;
				}
				if(j!=i)
				{
					printf("\nERROR at location %03x.  Wrote %02x but read %02x\n", k, i, j);
				}
				else
				{
					printf("\nTest pass\n");
				}
				FT93C66_Write_Disable();
				break;
			
			case '3':
				printf("\nAddress: ");
				scanf("%x", &k);
				waitms(10);
				printf("\nValue: ");
				scanf("%x", &m);
				
				FT93C66_Write_Enable();
				FT93C66_Write(k, m);
				j=FT93C66_Read(k);
				FT93C66_Write_Disable();

				printf("\n[%03x]: %02x\n", k, j);			

				break;

			case '4':
				printf("\nAddress: ");
				scanf("%x", &k);
				j=FT93C66_Read(k);
				printf("\n[%03x]: %02x\n", k, j);			
				break;
				
			case '5':
				FT93C66_Write_Enable();
				printf("\nLocation to test: ");
				scanf("%x", &k);

				i=0;
				ErrCnt=0;
				do
				{
					FT93C66_Write(k, i);
					j=FT93C66_Read(k);
					if((i&0xf)==0)
					{
						printf("\n%03x: ", i);
					}
					printf(" %02x", j);			
					if(j!=i) ErrCnt++;
					i++;
				} while (i!=0);
				printf("\nThere were %d error(s).\n", ErrCnt);
				
				FT93C66_Write_Disable();
				break;
			
			case '6':
				printf("\nMemory contains:\n");
				for(k=0; k<0x200; k++)
				{
					j=FT93C66_Read(k);
					if((k&0xf)==0)
					{
						printf("\n%03x: ", k);
					}
					printf(" %02x", j);			
				}
				printf("\n");
				break;

			case '7':
				FT93C66_Write_Enable();
				printf("\nValue: ");
				scanf("%x", &m);
				FT93C66_Write_All(m);
				FT93C66_Write_Disable();
				break;

			case '8':
				FT93C66_Write_Enable();
				FT93C66_Erase_All();
				FT93C66_Write_Disable();
				break;
			
			default:
				break;
		}
	}
}
