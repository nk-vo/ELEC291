SHELL=cmd
CC= avr-gcc
CPU=-mmcu=atmega328p
COPT= -g -Os $(CPU)
OBJS= SoftwareUart.o

COMPORT = $(shell type COMPORT.inc)

SoftwareUart.elf: $(OBJS)
	avr-gcc $(CPU) -Wl,-Map,SoftwareUart.map $(OBJS) -o SoftwareUart.elf
	avr-objcopy -j .text -j .data -O ihex SoftwareUart.elf SoftwareUart.hex
	@echo done!

SoftwareUart.o: SoftwareUart.c
	avr-gcc $(COPT) -c SoftwareUart.c

clean:
	@del *.hex *.elf *.o 2> nul

FlashLoad:
	@Taskkill /IM putty.exe /F 2>nul| wait 500
	spi_atmega -CRYSTAL -p -v SoftwareUart.hex

putty:
	@Taskkill /IM putty.exe /F 2>nul| wait 500
	cmd /c start putty.exe -serial $(COMPORT) -sercfg 9600,8,n,1,N

dummy: SoftwareUart.hex SoftwareUart.map
	@echo Hello dummy!
	
explorer:
	cmd /c start explorer .
	