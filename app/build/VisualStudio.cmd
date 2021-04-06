@echo off

set "SELF=%~f0
set ARCH=Win64
if /I @%1==@Win32 ( set ARCH=%1 && shift )
if /I @%1==@Win64 ( set ARCH=%1 && shift )
if "%~1"=="" "%SELF%" %ARCH% 12 auto 15 14 11 10

set "TRIED="
:iterate
if @%1==@ goto :finished
set "VSVERSION=%~1"
set "TRIED=%TRIED% %VSVERSION%"
shift

::echo hello %VSVERSION%
set "VSBASE="

if "%VSVERSION%"=="auto" goto :auto

if "%VSVERSION%"=="2019" ( set "VSYEAR=2019" && set "VSVERSION=16" && goto :knownPost2019 )
if "%VSVERSION%"=="16"   ( set "VSYEAR=2019" && set "VSVERSION=16" && goto :knownPost2019 )

if "%VSVERSION%"=="2017" ( set "VSYEAR=2017" && set "VSVERSION=15" && goto :knownPost2017 )
if "%VSVERSION%"=="15"   ( set "VSYEAR=2017" && set "VSVERSION=15" && goto :knownPost2017 )

if "%VSVERSION%"=="2010" ( set "VSYEAR=2010" && set "VSVERSION=10" && set "VSBASE=%VS100COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="10"   ( set "VSYEAR=2010" && set "VSVERSION=10" && set "VSBASE=%VS100COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="2012" ( set "VSYEAR=2012" && set "VSVERSION=11" && set "VSBASE=%VS110COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="11"   ( set "VSYEAR=2012" && set "VSVERSION=11" && set "VSBASE=%VS110COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="2013" ( set "VSYEAR=2013" && set "VSVERSION=12" && set "VSBASE=%VS120COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="12"   ( set "VSYEAR=2013" && set "VSVERSION=12" && set "VSBASE=%VS120COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="2015" ( set "VSYEAR=2015" && set "VSVERSION=14" && set "VSBASE=%VS140COMNTOOLS%" && goto :knownPost2010 )
if "%VSVERSION%"=="14"   ( set "VSYEAR=2015" && set "VSVERSION=14" && set "VSBASE=%VS140COMNTOOLS%" && goto :knownPost2010 )

echo Unknown IDE version %VSVERSION%
goto :iterate

:auto
set "VSWHEREBIN=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHEREBIN%" ( echo cannot use "auto" mode - cannot locate vswhere.exe utility && goto :iterate )
for /F "tokens=1,2 delims==" %%i in ('"%VSWHEREBIN%" -property installationPath') do set "VSBASE=%%i"
for /F "tokens=1 delims==." %%i in ('"%VSWHEREBIN%" -property installationVersion') do set "VSVERSION=%%i"
if not "%VSBASE%"=="" set "VSBASE=%VSBASE%\"
set "VSRELPATH=VC\Auxiliary\Build\vcvarsall.bat"
set "VS64BITARG=x64"
set "VS32BITARG=x86"
goto :finished

:knownPost2017
set "VSBASE="
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles%\Microsoft Visual Studio\%VSYEAR%\BuildTools\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles%\Microsoft Visual Studio\%VSYEAR%\Community\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles%\Microsoft Visual Studio\%VSYEAR%\Professional\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles%\Microsoft Visual Studio\%VSYEAR%\Enterprise\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles(x86)%\Microsoft Visual Studio\%VSYEAR%\BuildTools\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles(x86)%\Microsoft Visual Studio\%VSYEAR%\Community\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles(x86)%\Microsoft Visual Studio\%VSYEAR%\Professional\"
if not exist "%VSBASE%" set "VSBASE=%ProgramFiles(x86)%\Microsoft Visual Studio\%VSYEAR%\Enterprise\"
if not exist "%VSBASE%" ( set "VSBASE=" && goto :iterate )
set "VSRELPATH=VC\Auxiliary\Build\vcvarsall.bat"
set "VS64BITARG=x64"
set "VS32BITARG=x86"
goto :finished

:knownPost2010
if "%VSBASE%"=="" goto :iterate
set "VSRELPATH=..\..\VC\vcvarsall.bat"
set "VS64BITARG=amd64"
set "VS32BITARG="
goto :finished


:finished
if "%VSBASE%"=="" ( echo failed to find Microsoft Visual Studio version[s]%TRIED% && exit /b 1 )
if not exist "%VSBASE%" ( echo failed to locate "%VSBASE%%VSRELPATH%" && set "VSBASE=" && goto :iterate )
set "VS_USE_CMAKE_ARCH_FLAG="
if %VSVERSION% GEQ 16 set "VS_USE_CMAKE_ARCH_FLAG=-A" 

if not exist "%VSBASE%%VSRELPATH%" ( echo failed to locate "%VSBASE%%VSRELPATH%" - is the Visual Studio installation complete, including the necessary C++ components? && goto :eof )
::echo "%VSBASE%%VSRELPATH%" [ %VS64BITARG% ]
if /I @%ARCH%==@Win32 call "%VSBASE%%VSRELPATH%" %VS32BITARG%
if /I @%ARCH%==@Win64 call "%VSBASE%%VSRELPATH%" %VS64BITARG%


