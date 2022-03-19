SHELL=cmd
PORTN=$(shell type COMPORT.inc)

# Compile using Microsoft Visual C.  Check docl.bat.
spi_atmega.exe: spi_atmega.c
	@docl spi_atmega.c
	
clean:
	del spi_atmega.obj spi_atmega.exe

dummy: docl.bat ..\blinky\blinky.hex eeprom.hex flash.hex
	@echo hello from dummy target!
	
load1_XTAL:
	spi_atmega -p -v -crystal ..\blinky\blinky.hex

load1_RC:
	spi_atmega -p -v -RC ..\blinky\blinky.hex
	
load2:
	@Taskkill /IM putty.exe /F 2>nul | wait 500
	spi_atmega -p -v -CRYSTAL ..\usart\usart.hex
	cmd /c start putty -serial $(PORTN) -sercfg 19200,8,n,1,N

write_eeprom: 
	spi_atmega -e ..\blinky\blinky.hex

read_eeprom:
	spi_atmega -r eeprom.hex

read_flash:
	spi_atmega -f flash.hex
