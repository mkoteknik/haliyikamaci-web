@echo off
"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -export -inkey ios_distribution.key -in ios_distribution.cer -out build_certificate.p12 -passout pass:123 -legacy
if %errorlevel% neq 0 (
    echo Legacy flag failed, trying manual algos...
    "C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -export -inkey ios_distribution.key -in ios_distribution.cer -out build_certificate.p12 -passout pass:123 -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1
)

if %errorlevel% neq 0 ( exit /b %errorlevel% )

powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('build_certificate.p12')) | Out-File -FilePath CERT_B64_FINAL.txt -NoNewline -Encoding ascii"
echo DONE
