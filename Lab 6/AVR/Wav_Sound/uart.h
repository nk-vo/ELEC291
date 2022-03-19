#define _BAUD 115200UL
#define F_CPU 16000000UL
#define _UBRR (F_CPU/8)/_BAUD - 1 // Used for UBRRL and UBRRH
#define _DATA 0x03 // Number of data bits in frame = byte tranmission
#define TX_START() UCSR0B |= _BV(TXEN0)	 // Enable TX
#define TX_STOP()  UCSR0B &= ~_BV(TXEN0) // Disable TX
#define RX_START() UCSR0B |= _BV(RXEN0)	 // Enable RX
#define RX_STOP()  UCSR0B &= ~_BV(RXEN0) // Disable RX

void uart_init(void);
unsigned char uart_getc( void );
void uart_putc(unsigned char val);
void uart_puts(char *s);
unsigned char uart_kbhit(void);
int uart_putchar_printf(char var, FILE *stream);
