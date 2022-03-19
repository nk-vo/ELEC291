SHELL=cmd
OBJS=eeprom.o usart.o
PORTN=$(shell type COMPORT.inc)

eeprom.elf: $(OBJS)
	avr-gcc -mmcu=atmega162 $(OBJS) -o eeprom.elf
	avr-objcopy -j .text -j .data -O ihex eeprom.elf eeprom.hex
	@echo done!
	
eeprom.o: eeprom.c usart.h
	avr-gcc -g -Os -Wall -mmcu=atmega162 -c eeprom.c

usart.o: usart.c usart.h
	avr-gcc -g -Os -Wall -mmcu=atmega162 -c usart.c

clean:
	@del *.hex *.elf *.o 2>nul

FlashLoad:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	spi_atmega -p -v -crystal -EESAVE=0 eeprom.hex
	cmd /c start putty.exe -serial $(PORTN) -sercfg 19200,8,n,1,N -v

putty:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	cmd /c start putty.exe -serial $(PORTN) -sercfg 19200,8,n,1,N -v

dummy: eeprom.hex
	@echo Hello dummy!

explorer:
	cmd /c start explorer .