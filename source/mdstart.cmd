/* Pre-Login Rexx script file for MultiDesk */

BootDrive = arg(1)
LastUser = arg(2)

/* --- !! This part is for the multi-user management of WarpCenter !! --- */
/* --- !! Do not delete it if you're interested in having multiple !! --- */
/* --- !! WarpCenter configurations.                               !! --- */

if LastUser = '' then exit

/* Read in all CFG file lines, to find users_tree option */
linein('.\mudesk.cfg', 1, 0)
do i=1 by 1 until Lines('.\mudesk.cfg') = 0
    ThisLine = linein('.\mudesk.cfg')
    if Abbrev(ThisLine, 'users_tree=') = 1 then leave
end

if Abbrev(ThisLine, 'users_tree=') = 1 then
    parse value ThisLine with . '=' UTreePath
else
    UTreePath = BootDrive || ':\Users'

if Right(UTreePath, 1) \= '\' then
    UTreePath = UTreePath||'\'

DestPath = UTreePath || LastUser || '\WC'
'@copy ' || BootDrive || ':\OS2\DLL\dock*.cfg ' || DestPath || ' 1> nul 2> nul'
'@copy ' || BootDrive || ':\OS2\DLL\SCENTER.CFG ' || DestPath || ' 1> nul 2> nul'

/* --- !!     End of the multi-user WarpCenter management part     !! --- */

exit

