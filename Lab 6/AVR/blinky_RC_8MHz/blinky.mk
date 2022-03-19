# Since we are compiling in windows, select 'cmd' as the default shell.  This
# is important because make will search the path for a linux/unix like shell
# and if it finds it will use it instead.  This is the case when cygwin is
# installed.  That results in commands like 'del' and echo that don't work.
SHELL=cmd
# Specify the compiler to use
CC= avr-gcc
# Specify the microcontroller
CPU=-mmcu=atmega328p
# C compiler options
COPT= -g -Os $(CPU)
# Object files to link
OBJS= blinky.o

# The default 'target' (output) is blinky.elf and 'depends' on
# the object files listed in the 'OBJS' assignment above.
# These object files are linked together to create Blinky.elf.
# The linked file is converted to hex using program aver-objcopy.
blinky.elf: $(OBJS)
	avr-gcc $(CPU) -Wl,-Map,blinky.map $(OBJS) -o blinky.elf
	avr-objcopy -j .text -j .data -O ihex blinky.elf blinky.hex
	@echo done!

# The object file blinky.o depends on blinky.c. blinky.c is compiled
# to create blinky.o.
blinky.o: blinky.c
	avr-gcc $(COPT) -c blinky.c

# Target 'clean' is used to remove all object files and executables
# associated wit this project
clean:
	@del *.hex *.elf *.o 2> nul

# Target 'FlashLoad' is used to load the hex file to the microcontroller 
# using the flash loader.
FlashLoad:
	spi_atmega -RC -p -v blinky.hex

# Phony targets can be added to show useful files in the file list of
# CrossIDE or execute arbitrary programs:
dummy: blinky.hex blinky.map
	@echo Hello dummy!
	
explorer:
	cmd /c start explorer .
	