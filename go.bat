if not exist "%~dp0app/prog/Operator.ini" copy "%~dp0app\prog\Operator.ini.template" "%~dp0app\prog\Operator.ini"
"%~dp0app/batch/run-nidaqmx.bat"
