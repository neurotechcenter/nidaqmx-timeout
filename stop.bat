@echo off

set "SECONDS=%1
if "%SECONDS%"=="" set SECONDS=14400

timeout %SECONDS%

echo quit | "%~dp0app\prog\BCI2000Shell.exe"

timeout 2

taskkill /F /FI "IMAGENAME eq NIDAQ_mx_Source.exe"
taskkill /F /FI "IMAGENAME eq DummySignalProcessing.exe"
taskkill /F /FI "IMAGENAME eq DummyApplication.exe"

taskkill /F /FI "IMAGENAME eq NIDAQ_~1.exe"
taskkill /F /FI "IMAGENAME eq DUMMYS~1.exe"
taskkill /F /FI "IMAGENAME eq DUMMYA~1.exe"
