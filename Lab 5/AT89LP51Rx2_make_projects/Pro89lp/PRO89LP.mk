# Since we are compiling in windows, select 'cmd' as the default shell.  This
# is important because make will search the path for a linux/unix like shell
# and if it finds it will use it instead.  This is the case when cygwin is
# installed.  That results in commands like 'del' and echo that don't work.
SHELL=cmd
Pro89lp.exe: Pro89lp.c
	@docl Pro89lp.c

Pro89lp52.exe: Pro89lp52.c
	@docl Pro89lp52.c
	
clean:
	del Pro89lp.obj Pro89lp.exe

dummy: docl.bat
	@echo hello from dummy!
	
bootloader: C:\Source\crosside\Examples\at89lp\Bootloader\Boot52.hex
	Pro89lp -p -v C:\Source\crosside\Examples\at89lp\Bootloader\Boot52.hex

bootloader52: C:\Source\crosside\Examples\at89lp\Bootloader\Boot52.hex
	Pro89lp52 -p -v C:\Source\crosside\Examples\at89lp\Bootloader\Boot52.hex

LCD: C:\Courses\ELEC291\Jan_2017\Module2\Source\ISR_example.hex
	Pro89lp -p -v C:\Courses\ELEC291\Jan_2017\Module2\Source\ISR_example.hex

Hello: C:\Courses\ELEC291\Jan_2017\Module3\Source\Hello.hex
	Pro89lp -p -v C:\Courses\ELEC291\Jan_2017\Module3\Source\Hello.hex

Hello_v: C:\Courses\ELEC291\Jan_2017\Module3\Source\Hello.hex
	Pro89lp -v C:\Courses\ELEC291\Jan_2017\Module3\Source\Hello.hex

Hello_r:
	Pro89lp -rHello_r.hex

Hello52: C:\Courses\ELEC291\Jan_2017\Module3\Source\Hello.hex
	Pro89lp52 -p -v C:\Courses\ELEC291\Jan_2017\Module3\Source\Hello.hex

lcd: C:\Courses\ELEC291\Jan_2016\Module1\Source\LCD_test_String_4bit_new.asm
	Pro89lp -p -v C:\Courses\ELEC291\Jan_2016\Module1\Source\LCD_test_String_4bit_new.hex

lcd_V: C:\Courses\ELEC291\Jan_2016\Module1\Source\LCD_test_String_4bit_new.asm
	Pro89lp -v C:\Courses\ELEC291\Jan_2016\Module1\Source\LCD_test_String_4bit_new.hex

lcd_rc: C:\Courses\ELEC291\Jan_2016\Module1\Source\LCD_test_String_4bit_new.asm
	Pro89lp -p -v -rc C:\Courses\ELEC291\Jan_2016\Module1\Source\LCD_test_String_4bit_new.hex
	
lcd2: C:\Source\crosside\Examples\at89lp\LCD\LCD_4bit_AT89LP52.c
	Pro89lp -p -v C:\Source\crosside\Examples\at89lp\LCD\LCD_4bit_AT89LP52.hex

read: test.hex
	Pro89lp -rtest.hex

CBUS3_Sleep:
	Pro89lp -sleepC3
