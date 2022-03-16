# Since we are compiling in windows, select 'cmd' as the default shell.  This
# is important because make will search the path for a linux/unix like shell
# and if it finds it will use it instead.  This is the case when cygwin is
# installed.  That results in commands like 'del' and echo that don't work.
SHELL=cmd
CC=c51
COMPORT = $(shell type COMPORT.inc)
OBJS=blinky_at89lp51rc2.obj

blinky_at89lp51rc2.hex: $(OBJS)
	$(CC) $(OBJS)
	@echo Done!
	
blinky_at89lp51rc2.obj: blinky_at89lp51rc2.c
	$(CC) -c blinky_at89lp51rc2.c

clean:
	@del $(OBJS) *.asm *.lkr *.lst *.map *.hex *.map 2> nul

LoadFlash:
	@Taskkill /IM putty.exe /F 2>NUL | wait 500
	..\Pro89lp\Pro89lp -p -v blinky_at89lp51rc2.hex
	
Dummy: blinky_at89lp51rc2.hex blinky_at89lp51rc2.Map
	@echo Nothing to see here!
	
explorer:
	cmd /c start .

		