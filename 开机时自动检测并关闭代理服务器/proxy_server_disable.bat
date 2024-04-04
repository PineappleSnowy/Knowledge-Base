@echo off
setlocal

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable | findstr "REG_DWORD" >nul
if %errorlevel% equ 0 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
    echo Proxy server has been disabled.
) else (
    echo Proxy server is already disabled.
)

endlocal
exit