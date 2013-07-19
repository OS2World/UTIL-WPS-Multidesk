@echo off
setlocal
set wpipath=h:\warpin
set beginlibpath=%wpipath%;
%wpipath%\wic md-0-1-9.wpi -a 1 -cpkg1 *
endlocal
