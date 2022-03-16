SHELL=cmd
CC=c51
COPT=
LOPT=
OBJS=BlinkyISR.obj

BlinkyISR.hex: $(OBJS)
	$(CC) $(LOPT) $(OBJS)
	@echo Done!
	
BlinkyISR.obj: BlinkyISR.c
	$(CC) $(COPT) -c BlinkyISR.c

clean:
	@del $(OBJS) *.asm *.lkr *.lst *.map *.hex *.map 2> nul

LoadFlash:
	..\Pro89lp\Pro89lp -p -v BlinkyISR.hex

Dummy: BlinkyISR.hex BlinkyISR.Map
	@echo Nothing to see here!
	
explorer:
	cmd /c start explorer .
		