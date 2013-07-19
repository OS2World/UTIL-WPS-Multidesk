/* Pre-Login Rexx script file for MultiDesk */

BootDrive = arg(1)
LastUser = arg(2)
UTreePath = arg(3)

/* --- !! Do not edit/delete the lines of the section below here.  !! --- */

if LastUser = '' then exit

if Right(UTreePath, 1) \= '\' then
    UTreePath = UTreePath||'\'

/* Save previous user MMPM.INI file, if multimedia is installed */
EnvMMBase = Strip(Value('MMBASE',, 'OS2ENVIRONMENT'))
if Right(EnvMMBase, 1) = ';' then EnvMMBase = Left(EnvMMBase, Length(EnvMMBase) - 1)
if (EnvMMBase \= '') then do
    if Right(EnvMMBase, 1) \= '\' then EnvMMBase = EnvMMBase || '\'
    MMINIPath = UTreePath || LastUser || '\MMOS2'
    '@' || BootDrive || ':\os2\attrib.exe -S -R ' || EnvMMBase || 'mmpm.ini'
    '@copy ' || EnvMMBase || 'mmpm.ini ' || MMINIPath || ' 1> nul 2> nul'
    '@' || BootDrive || ':\os2\attrib.exe +S +R ' || EnvMMBase || 'mmpm.ini'
end

/* Save previous user WarpCenter configuration */
DestPath = UTreePath || LastUser || '\WC'
'@copy ' || BootDrive || ':\OS2\DLL\dock*.cfg ' || DestPath || ' 1> nul 2> nul'
'@copy ' || BootDrive || ':\OS2\DLL\SCENTER.CFG ' || DestPath || ' 1> nul 2> nul'

/* --- !! End of the non-editable section. You can add/edit below. !! --- */

exit

