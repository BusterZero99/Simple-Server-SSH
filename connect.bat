@echo off
setlocal

set "SERVER_USER=user"
set "SERVER_IP=255.255.255.255"
set "SERVER_MAC=ff:ff:ff:ff:ff:ff"
set "BOOT_TIME=120"

echo Checking if server is online...

powershell -command "try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('%SERVER_IP%',22); $c.Close(); exit 0 } catch { exit 1 }"
if %errorlevel%==0 (
    echo Server is already online. Connecting...
    ssh %SERVER_USER%@%SERVER_IP%
    exit /b
)

echo Server is offline. Sending Wake-on-LAN packet...
"%APPDATA%\WOL\wol.exe" %SERVER_MAC% >nul 2>&1

echo Waiting %BOOT_TIME% seconds for server to boot...
ping -n %BOOT_TIME% 127.0.0.1 >nul

echo Checking if server is online...

:retry
powershell -command "try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('%SERVER_IP%',22); $c.Close(); exit 0 } catch { exit 1 }"
if %errorlevel%==0 (
    echo Server is online. Connecting...
    ssh %SERVER_USER%@%SERVER_IP%
    exit /b
)

echo Server not ready yet... waiting...
ping -n 5 127.0.0.1 >nul
goto retry
