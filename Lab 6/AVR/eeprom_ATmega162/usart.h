#define _BAUD 19200UL
#define F_CPU 16000000UL
#define _UBRR (F_CPU/16/_BAUD-1) // Used for UBRRL and UBRRH

void usart_init(void);
char usart_getchar( void );
void usart_putchar( char data );
void usart_pstr(char *s);
unsigned char usart_kbhit(void);
int usart_putchar_printf(char var, FILE *stream);
int mygets(char * rxstr, int max);
