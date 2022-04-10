SHELL=cmd
OBJS=Servo.o usart.o
PORTN=$(shell type COMPORT.inc)

Servo.elf: $(OBJS)
	avr-gcc -mmcu=atmega328 -Wl,-Map,Servo.map $(OBJS) -o Servo.elf
	avr-objcopy -j .text -j .data -O ihex Servo.elf Servo.hex
	@echo done!
	
Servo.o: Servo.c
	avr-gcc -g -Os -mmcu=atmega328 -c Servo.c

usart.o: usart.c usart.h
	avr-gcc -g -Os -Wall -mmcu=atmega328p -c usart.c

clean:
	@del *.hex *.elf *.o 2>nul

FlashLoad:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	spi_atmega -CRYSTAL -p -v Servo.hex
	cmd /c start putty.exe -serial $(PORTN) -sercfg 19200,8,n,1,N

putty:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	cmd /c start putty.exe -serial $(PORTN) -sercfg 19200,8,n,1,N

dummy: Servo.hex Servo.map
	@echo Hello from dummy!
	