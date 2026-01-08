@echo off
set OPENSSL_CONF=C:\Program Files\Git\usr\ssl\openssl.cnf
"C:\Program Files\Git\usr\bin\openssl.exe" req -new -newkey rsa:2048 -nodes -keyout ios_distribution.key -out ios_distribution.csr -subj "/emailAddress=mobile@haliyikamaci.com/CN=Hali Yikamaci Bul/C=TR"
if %errorlevel% neq 0 (
    echo Error generating CSR
    exit /b %errorlevel%
)
echo CSR Generated Successfully
