/* rexx */

call rxfuncadd sysloadfuncs, rexxutil, sysloadfuncs
call sysloadfuncs

say
say 'Primo tentativo'
retcode = SysIni('USER', 'PM_DisplayDrivers', 'ALL:', 'Keys')
say 'RetCode = ' || retcode
do i = 1 to Keys.0
	say 'Key ' || i || ' = ' || Keys.i
end

say
say 'Secondo tentativo'
retcode = SysIni('USER', 'PM_DISPLAYDRIVERS', 'ALL:', 'Keys')
say 'RetCode = ' || retcode
do i = 1 to Keys.0
	say 'Key ' || i || ' = ' || Keys.i
end
say

exit
