SHELL=cmd
OBJS=pwm.o uart.o
PORTN=$(shell type COMPORT.inc)

pwm.elf: $(OBJS)
	avr-gcc -mmcu=atmega328p $(OBJS) -o pwm.elf
	avr-objcopy -j .text -j .data -O ihex pwm.elf pwm.hex
	@echo done!
	
pwm.o: pwm.c uart.h
	avr-gcc -g -Os -Wall -mmcu=atmega328p -c pwm.c

uart.o: uart.c uart.h
	avr-gcc -g -Os -Wall -mmcu=atmega328p -c uart.c

clean:
	@del *.hex *.elf *.o 2>nul

FlashLoad:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	spi_atmega -p -v -crystal pwm.hex

putty:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	cmd /c start putty.exe -serial $(PORTN) -sercfg 115200,8,n,1,N

dummy: pwm.hex
	@echo Hello dummy!

explorer:
	cmd /c start explorer .