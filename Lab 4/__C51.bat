@echo off
::This file was created automatically by CrossIDE to compile with C51.
D:
cd "\school\ELEC291\Lab 4\"
"D:\CrossIDE\Call51\Bin\c51.exe" --use-stdout  "D:\school\ELEC291\Lab 4\FINALWORKINGmylabadc_spi.c"
if not exist hex2mif.exe goto done
if exist FINALWORKINGmylabadc_spi.ihx hex2mif FINALWORKINGmylabadc_spi.ihx
if exist FINALWORKINGmylabadc_spi.hex hex2mif FINALWORKINGmylabadc_spi.hex
:done
echo done
echo Crosside_Action Set_Hex_File D:\school\ELEC291\Lab 4\FINALWORKINGmylabadc_spi.hex
