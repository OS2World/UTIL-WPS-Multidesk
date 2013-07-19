@echo off
call package1.cmd
call package2.cmd
call package3.cmd
setlocal
set wpipath=h:\warpin
set beginlibpath=%wpipath%;
%wpipath%\wic md-0-1-9.wpi -s multidesk.wis
endlocal
