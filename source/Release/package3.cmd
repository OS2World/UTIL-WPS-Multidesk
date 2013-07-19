@echo off
setlocal
set wpipath=h:\warpin
set beginlibpath=%wpipath%;
%wpipath%\wic md-0-1-9.wpi -a 3 -cpkg3 *
endlocal
