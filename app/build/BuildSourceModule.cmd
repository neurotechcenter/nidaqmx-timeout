@echo off

set "BCI2000=%~1
if "%BCI2000%"=="" set BCI2000=C:\neurotech\bci2000-svn\HEAD
echo. && echo BCI2000 ROOT: %BCI2000%
if not exist "%BCI2000%\" ( echo Not found - you must specify a valid BCI2000 distro root as your command-line argument. && goto :eof )

set "OLDD=%CD%
cd /D "%~dp0..\.."
set "MYROOT=%CD%
cd /D "%OLDD%"

where msbuild >NUL 2>NUL || echo. && echo Could not find the path to MSBuild. && goto :noVS
if "%VSCMD_ARG_TGT_ARCH%"=="" ( echo. && echo VSCMD_ARG_TGT_ARCH is not set.  && goto :noVS )

set BCI2000TARGET=
if "%VSCMD_ARG_TGT_ARCH%"=="x64"   set BCI2000TARGET=x64
if "%VSCMD_ARG_TGT_ARCH%"=="amd64" set BCI2000TARGET=x64
if "%VSCMD_ARG_TGT_ARCH%"=="x86"   set BCI2000TARGET=Win32
if "%BCI2000TARGET%"=="" goto :unsupported
set "CONFIRM=%BCI2000%\build\%BCI2000TARGET%
if not exist "%CONFIRM%\" goto :mismatch

set "MODULE=NIDAQ_mx_Source
set "SECTION=Contrib\SignalSource
set "SOURCES=%BCI2000%\src\contrib\SignalSource\NIDAQ-MX\NIDAQmxADC.*

set "EXE_SRC=%BCI2000%\prog\%MODULE%.exe
set "EXE_DST=%MYROOT%\app\prog\%MODULE%.exe

:: note the linkage of the following lines
msbuild %BCI2000%\build\BCI2000.sln /t:%SECTION%\%MODULE% /p:Configuration=Release /p:Platform=%BCI2000TARGET% && ^
copy /Y "%SOURCES%" "%MYROOT%\app\src\copy\" && ^
copy /Y "%EXE_SRC%" "%EXE_DST%" && ^
dir "%EXE_DST%" && ^
signtool.exe sign /a /t http://timestamp.comodoca.com "%EXE_DST%"  && ^
signtool.exe sign /as /fd sha256 /tr http://timestamp.comodoca.com?td=sha256 /td sha256 "%EXE_DST%"  && ^
echo.

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto :eof

:noVS
echo Use `VisualStudio Win64` or `VisualStudio Win32` to
echo initialize paths and variables needed by Visual Studio.
goto :eof

:mismatch
echo.
echo Visual Studio has been initialized to target %VSCMD_ARG_TGT_ARCH% but
echo %CONFIRM% does not exist.
echo 1 - Run CMake with the appropriate flags in %BCI2000%\build
echo 2 - Launch %BCI2000%\build\BCI2000.sln
echo 3 - Select the "Release" configuration
echo 4 - Confirm the "%BCI2000TARGET%" target platform 
echo 5 - Build the solution once.
goto :eof

:unsupported
echo.
echo Visual Studio has been initialized to target %VSCMD_ARG_TGT_ARCH%.
echo I don't know how to handle that platform.
goto :eof
