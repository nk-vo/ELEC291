#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#define output_low(port,pin) port &= ~(1<<pin)
#define output_high(port,pin) port |= (1<<pin)
#define set_input(portdir,pin) portdir &= ~(1<<pin)
#define set_output(portdir,pin) portdir |= (1<<pin)
 
int main(void)
{
   set_output(DDRD, 6);  
 
   while (1)
   {
     output_high(PORTD, 6);
     _delay_ms(500);
     output_low(PORTD, 6);
     _delay_ms(500);
   }
}