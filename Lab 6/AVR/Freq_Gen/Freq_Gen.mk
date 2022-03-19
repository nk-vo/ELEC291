SHELL=cmd
OBJS=Freq_Gen.o usart.o
PORTN=$(shell type COMPORT.inc)

Freq_Gen.elf: $(OBJS)
	avr-gcc -mmcu=atmega328 -Wl,-Map,Freq_Gen.map $(OBJS) -o Freq_Gen.elf
	avr-objcopy -j .text -j .data -O ihex Freq_Gen.elf Freq_Gen.hex
	@echo done!
	
Freq_Gen.o: Freq_Gen.c
	avr-gcc -g -Os -mmcu=atmega328 -c Freq_Gen.c

usart.o: usart.c usart.h
	avr-gcc -g -Os -Wall -mmcu=atmega328p -c usart.c

clean:
	@del *.hex *.elf *.o 2>nul

FlashLoad:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	spi_atmega -CRYSTAL -p -v Freq_Gen.hex

putty:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	cmd /c start putty.exe -serial $(PORTN) -sercfg 19200,8,n,1,N

dummy: Freq_Gen.hex Freq_Gen.map
	@echo Hello from dummy!
	