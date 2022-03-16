@echo off
::This file was created automatically by CrossIDE to compile with C51.
D:
cd "\school\ELEC291\Lab 5\AT89LP51Rx2_make_projects\ADC_SPI\"
"D:\CrossIDE\Call51\Bin\c51.exe" --use-stdout  "D:\school\ELEC291\Lab 5\AT89LP51Rx2_make_projects\ADC_SPI\adc_spi.c"
if not exist hex2mif.exe goto done
if exist adc_spi.ihx hex2mif adc_spi.ihx
if exist adc_spi.hex hex2mif adc_spi.hex
:done
echo done
echo Crosside_Action Set_Hex_File D:\school\ELEC291\Lab 5\AT89LP51Rx2_make_projects\ADC_SPI\adc_spi.hex
