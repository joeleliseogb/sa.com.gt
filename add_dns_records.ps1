dnscmd 127.0.0.1 /RecordAdd sa.com.gt cuentas A 169.58.70.76
dnscmd 127.0.0.1 /RecordAdd sa.com.gt correo A 169.58.70.76
dnscmd 127.0.0.1 /RecordAdd sa.com.gt cdpe A 169.58.70.76
dnscmd 127.0.0.1 /RecordAdd sa.com.gt donpollo A 169.58.70.76
dnscmd 127.0.0.1 /RecordAdd sa.com.gt webmail A 169.58.70.76
dnscmd 127.0.0.1 /RecordAdd sa.com.gt * A 169.58.70.76
Add-Content -Path 'C:\Windows\System32\drivers\etc\hosts' -Value "
127.0.0.1 cuentas.sa.com.gt correo.sa.com.gt cdpe.sa.com.gt donpollo.sa.com.gt webmail.sa.com.gt sa.com.gt"
ipconfig /flushdns
