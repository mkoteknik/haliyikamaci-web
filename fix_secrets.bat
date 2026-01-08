@echo off
"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -export -inkey ios_distribution.key -in ios_distribution.cer -out build_certificate.p12 -passout pass:123
if %errorlevel% neq 0 ( exit /b %errorlevel% )

powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('build_certificate.p12')) | Out-File -FilePath CERT_B64_FINAL.txt -NoNewline -Encoding ascii"
powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('Hali_Yikamaci_App_Store.mobileprovision')) | Out-File -FilePath PROV_B64_FINAL.txt -NoNewline -Encoding ascii"
echo DONE
