@echo off
::This file was created automatically by CrossIDE to compile with C51.
D:
cd "\school\ELEC291\Lab 6\"
"D:\CrossIDE\Call51\Bin\c51.exe" --use-stdout  "D:\school\ELEC291\Lab 6\Lab6.c"
if not exist hex2mif.exe goto done
if exist Lab6.ihx hex2mif Lab6.ihx
if exist Lab6.hex hex2mif Lab6.hex
:done
echo done
echo Crosside_Action Set_Hex_File D:\school\ELEC291\Lab 6\Lab6.hex
