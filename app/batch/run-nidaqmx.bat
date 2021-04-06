#! ../prog/BCI2000Shell
@cls & "%~dp0..\prog\BCI2000Shell" %0 %* #! && exit /b 0 || exit /b 1\n
#################################################################

system taskkill /F /FI "IMAGENAME eq NIDAQ_mx_Source.exe"
system taskkill /F /FI "IMAGENAME eq DummySignalProcessing.exe"
system taskkill /F /FI "IMAGENAME eq DummyApplication.exe"

system taskkill /F /FI "IMAGENAME eq NIDAQ_~1.exe"
system taskkill /F /FI "IMAGENAME eq DUMMYS~1.exe"
system taskkill /F /FI "IMAGENAME eq DUMMYA~1.exe"

#################################################################

change directory $BCI2000LAUNCHDIR

show window
set title "Well... Here I am."

reset system

set environment GITREV ${system git describe --always --all --long --dirty=+ --broken=!}
set environment SYSLOG system-logs/$YYYYMMDD-$HHMMSS-operator.txt
log This log will be saved in $SYSLOG

startup system localhost --SystemLogFile=$BCI2000LAUNCHDIR/../../$SYSLOG

warn git revision is $GITREV

start executable NIDAQ_mx_Source       --local
start executable DummySignalProcessing --local
start executable DummyApplication      --local

wait for connected

load parameterfile "../parms/like-epocs.prm"

setconfig
