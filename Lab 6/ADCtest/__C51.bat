@echo off
::This file was created automatically by CrossIDE to compile with C51.
D:
cd "\school\ELEC291\Lab 6\AVR\ADCtest\"
"D:\CrossIDE\Call51\Bin\c51.exe" --use-stdout  "D:\school\ELEC291\Lab 6\AVR\ADCtest\ADCtest.c"
if not exist hex2mif.exe goto done
if exist ADCtest.ihx hex2mif ADCtest.ihx
if exist ADCtest.hex hex2mif ADCtest.hex
:done
echo done
echo Crosside_Action Set_Hex_File D:\school\ELEC291\Lab 6\AVR\ADCtest\ADCtest.hex
