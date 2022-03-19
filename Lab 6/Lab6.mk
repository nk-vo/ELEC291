SHELL=cmd
PORTN=$(shell type COMPORT.inc)
CC=avr-gcc
CPU=-mmcu=atmega328p
COPT=-g -Os -Wall $(CPU)
OBJS=Lab6.o usart.o

Lab6.elf: $(OBJS)
	avr-gcc $(CPU) $(OBJS) -Wl,-u,vfprintf -lprintf_flt -lm -o Lab6.elf
	avr-objcopy -j .text -j .data -O ihex Lab6.elf Lab6.hex
	@echo done!
	
Lab6.o: Lab6.c usart.h
	avr-gcc $(COPT) -c Lab6.c

usart.o: usart.c usart.h
	avr-gcc $(COPT) -c usart.c

clean:
	@del *.hex *.elf $(OBJS) 2>nul

LoadFlash:
	@Taskkill /IM putty.exe /F 2>nul| wait 500
	spi_atmega -p -v -crystal Lab6.hex

putty:
	@Taskkill /IM putty.exe /F 2>nul| wait 500
	cmd /c start putty.exe -serial $(PORTN) -sercfg 19200,8,n,1,N

dummy: Lab6.hex
	@echo Hello dummy!
	