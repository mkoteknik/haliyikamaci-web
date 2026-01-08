@echo off
set OPENSSL_CONF=C:\Program Files\Git\usr\ssl\openssl.cnf
"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -export -inkey ios_distribution.key -in ios_distribution.cer -out build_certificate.p12 -passout pass:haliyikamaci
if %errorlevel% neq 0 (
    echo Error generating P12
    exit /b %errorlevel%
)
echo P12 Generated Successfully as build_certificate.p12
