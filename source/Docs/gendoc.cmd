@echo off
call html2ipf.cmd -SORT- index.html

echo .
echo Remember to change the � symbol to �.

pause

del mudesk.ipf 2> \DEV\NUL
del mudesk.inf 2> \DEV\NUL
ren index.ipf mudesk.ipf
call inf.cmd mudesk.ipf

echo Done!
