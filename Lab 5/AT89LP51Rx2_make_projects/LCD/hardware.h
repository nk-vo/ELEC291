#include <at89lp51rd2.h>

#define CLK    22118400L // SYSCLK frequency in Hz
#define BAUD     115200L // Baud rate of UART in bps
#define ONE_USEC (CLK/1000000L) // Timer reload for one microsecond delay

#if (CLK/(16L*BAUD))>0x100
#error Can not set baudrate
#endif
#define BRG_VAL (0x100-(CLK/(16L*BAUD)))

#define LCD_RS P3_2
//#define LCD_RW PX_X // Not used in this code.  Connect pin to GND
#define LCD_E  P3_3
#define LCD_D4 P3_4
#define LCD_D5 P3_5
#define LCD_D6 P3_6
#define LCD_D7 P3_7
#define CHARS_PER_LINE 16

void wait_us (unsigned char x);
void waitms (unsigned int ms);
