@echo off
for /F "tokens=1,2,3 delims=_" %%i in ('PowerShell -Command "& {Get-Date -format "MM_dd_yyyy"}"') do (
    set MONTH=%%i
    set DAY=%%j
    set YEAR=%%k
)
set filename=Arcade-CrystalCastles_%YEAR%%MONTH%%DAY%.rbf
scp output_files\Arcade-CrystalCastles.rbf root@192.168.1.105:/media/fat/_Other/%filename%