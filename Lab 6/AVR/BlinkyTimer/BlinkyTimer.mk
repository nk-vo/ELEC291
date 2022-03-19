SHELL=cmd
BlinkyTimer.elf: BlinkyTimer.o
	avr-gcc -mmcu=atmega328 -Wl,-Map,BlinkyTimer.map BlinkyTimer.o -o BlinkyTimer.elf
	avr-objcopy -j .text -j .data -O ihex BlinkyTimer.elf BlinkyTimer.hex
	@echo done!
	
BlinkyTimer.o: BlinkyTimer.c
	avr-gcc -g -Os -mmcu=atmega328 -c BlinkyTimer.c

clean:
	@del *.hex *.elf *.o 2>nul

FlashLoad:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	spi_atmega -CRYSTAL -p -v BlinkyTimer.hex

dummy: BlinkyTimer.hex BlinkyTimer.map
	@echo Hello from dummy!
	