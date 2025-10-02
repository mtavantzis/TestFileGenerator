for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a";
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%";
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%";
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%";
set "fullstamp=%YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%";
echo fullstamp: "%fullstamp%";

for /f "tokens=2 delims==" %%a in ('wmic OS Get lastbootuptime /value') do set "dt=%%a";
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%";
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%";
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%";
set "fullstamp2=%YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%";
echo fullstamp2: "%fullstamp2%";

set "start_date=%fullstamp2%";
set "end_date=%fullstamp%";
datagen.bat -params "date_start=%start_date%;date_end=%end_date%;" -c examples/%1