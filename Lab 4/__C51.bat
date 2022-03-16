@echo off
::This file was created automatically by CrossIDE to compile with C51.
D:
cd "\school\ELEC291\Lab 4\"
"D:\CrossIDE\Call51\Bin\c51.exe" --use-stdout  "D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.c"
if not exist hex2mif.exe goto done
if exist LCD_4bit_AT89LP51RC2.ihx hex2mif LCD_4bit_AT89LP51RC2.ihx
if exist LCD_4bit_AT89LP51RC2.hex hex2mif LCD_4bit_AT89LP51RC2.hex
:done
echo done
echo Crosside_Action Set_Hex_File D:\school\ELEC291\Lab 4\LCD_4bit_AT89LP51RC2.hex
