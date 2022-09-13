@echo off

rem Build mos6502 diagnostic kernel 
pushd ..\..\..\CC\CCdiagnose
call build.bat
popd

rem Copy ROM file
copy ..\..\..\CC\CCdiagnose\diagnose.rom .\rtl\

rem Run Apio/iverilog/Gtkw simulation
pushd rtl
del ccastle_tb.vcd
del ccastle_tb.out
apio sim
popd