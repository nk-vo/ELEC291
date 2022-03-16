# Since we are compiling in windows, select 'cmd' as the default shell.  This
# is important because make will search the path for a linux/unix like shell
# and if it finds it will use it instead.  This is the case when cygwin is
# installed.  That results in commands like 'del' and echo that don't work.
SHELL=cmd
CC=c51
COMPORT = $(shell type COMPORT.inc)
OBJS=LCD_4bit_AT89LP51RC2.obj hardware.obj LCD.obj

LCD_4bit_AT89LP51RC2.hex: $(OBJS)
	$(CC) $(OBJS)
	@del *.asm *.lst *.lkr 2> nul
	@echo Done!
	
LCD_4bit_AT89LP51RC2.obj: LCD_4bit_AT89LP51RC2.c hardware.h LCD.h
	$(CC) -c LCD_4bit_AT89LP51RC2.c

hardware.obj: hardware.c hardware.h
	$(CC) -c hardware.c

LCD.obj: LCD.c LCD.h
	$(CC) -c LCD.c

clean:
	@del $(OBJS) *.asm *.lkr *.lst *.map *.hex *.map 2> nul

LoadFlash:
	@Taskkill /IM putty.exe /F 2>NUL | wait 500
	..\Pro89lp\Pro89lp -p -v LCD_4bit_AT89LP51RC2.hex
	cmd /c start putty -serial $(COMPORT) -sercfg 115200,8,n,1,N

putty:
	@Taskkill /IM putty.exe /F 2>NUL | wait 500
	cmd /c start putty -serial $(COMPORT) -sercfg 115200,8,n,1,N

Dummy: LCD_4bit_AT89LP51RC2.hex LCD_4bit_AT89LP51RC2.Map
	@echo Nothing to see here!
	
explorer:
	cmd /c start .
		