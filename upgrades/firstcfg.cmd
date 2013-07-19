/******************************************************
* WarpIn after-installation rexx script for MultiDesk *
*******************************************************
* $Id: firstcfg.cmd,v 1.2 2001/10/04 14:54:11 u570082 Exp $
******************************************************/

Parms = Arg(1)
Parse Value Parms With BtDsk UsrIni SstIni TgtPath rest

if (Parms = '') | (TgtPath = '') | (SstIni = '') | (UsrIni = '') |,
   ((rest \= '') & (rest \= 'DEBUG')) then
do
    say ''
    say 'INFORMATION'
    say 'This script is to be used from WarpIn. It cannot be used alone.'
    say 'If you have already installed MultiDesk, you can safely delete'
    say 'this file.'
    exit
end

if rest = 'DEBUG' then
    Debug = 1
else
    Debug = 0

/* If WarpIn's bug is still here, try to cope with it */
if BtDsk = '?:\' then do
    rc = RxFuncQuery('SysBootDrive')
    if rc \= 0 then do
        rc = RxFuncAdd('SysBootDrive', 'RexxUtil', 'SysBootDrive')
        if rc = 0 then BtDsk = SysBootDrive() || '\'
    end; else
        BtDsk = SysBootDrive() || '\'
end

if Debug then say 'BootDisk = ' || BtDsk

/* If we're not already in the target directory, change to it */
if directory() \= TgtPath then drc = directory(TgtPath)

if stream('mudesk.bnr', 'c', 'query exists') = '' then do
    aFile = 'mudesk.bnr'
    drc = lineout(aFile,,1)   /* Open the file and position to the beginning */
    drc = lineout(aFile, 'OS/2 Warp 4 (Merlin)')
    drc = lineout(aFile, 'Kernel Internal revision 14.040_W4 on an i686')
    drc = lineout(aFile)      /* Close the file */
end

if stream('mudesk.dat', 'c', 'query exists') = '' then do
    aFile = 'mudesk.dat'
    drc = lineout(aFile,,1)   /* Open the file and position to the beginning */
    aLine = 'admin;admin;'||BtDsk||'os2\pmshell.exe;'||UsrIni||';'||SstIni||';'||BtDsk||'users\admin\admin.env'
    drc = lineout(aFile, aLine)
    drc = lineout(aFile)      /* Close the file */
end

if stream('mudesk.cfg', 'c', 'query exists') = '' then do
    aFile = 'mudesk.cfg'
    drc = lineout(aFile,,1)   /* Open the file and position to the beginning */
    drc = lineout(aFile, '# -- MuDesk configuration file --')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '# !!!! Don''t put spaces around the "=" symbol !!!!')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '#-----------------------------------------------------------------------------')
    drc = lineout(aFile, '# The system will automatically login this user after default_user_timeout')
    drc = lineout(aFile, '# seconds, if this variable is set. You can comment it out, or leave it blank')
    drc = lineout(aFile, '# to disable automatic login.')
    drc = lineout(aFile, '# Note that setting the timeout to 0 will also disable auto-login.')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, 'default_user=')
    drc = lineout(aFile, 'default_user_timeout=0')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '#-----------------------------------------------------------------------------')
    drc = lineout(aFile, '# The root user is the user that has access to all the log files, the')
    drc = lineout(aFile, '# config files, etc. Here you tell how the root user is named. Default is')
    drc = lineout(aFile, '# ''root''.')
    drc = lineout(aFile, '#         !! IT IS NOT POSSIBLE TO SET DEFAULT_USER = ROOT_USER !!')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, 'root_user=admin')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '#-----------------------------------------------------------------------------')
    drc = lineout(aFile, '# If this is set to YES, then MuDesk will NOT ask to enter a password. Also,')
    drc = lineout(aFile, '# this enables starting the default_user by simply pressing "ENTER" when the')
    drc = lineout(aFile, '# login prompt shows. Default is NO.')
    drc = lineout(aFile, '# Note however that log files, config files, etc are still locked to everyone')
    drc = lineout(aFile, '# but the root_user (which will always require a password).')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, 'relaxed_security=NO')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '#-----------------------------------------------------------------------------')
    drc = lineout(aFile, '# After ssaver_timeout seconds without user interaction, the screen will be')
    drc = lineout(aFile, '# blanked. Note that screen blanking is never disabled. If you do not specify')
    drc = lineout(aFile, '# it, it will be set to the default of 120 seconds.')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, 'ssaver_timeout=120')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '#-----------------------------------------------------------------------------')
    drc = lineout(aFile, '# If this is set to YES, all logins will be logged to the log_users_file file.')
    drc = lineout(aFile, '# Note that this file will be readable only by the root user.')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, 'log_users=NO')
    drc = lineout(aFile, 'log_users_file=')
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '#-----------------------------------------------------------------------------')
    drc = lineout(aFile, '# This is where the users tree is created by default. This is only used by')
    drc = lineout(aFile, '# administration program. This should exists (you have to create it, the')
    drc = lineout(aFile, '# program won''t do it), and should be located on the boot drive (although')
    drc = lineout(aFile, '# this is not mandatory).')
    drc = lineout(aFile, '# You can override this setting on a one-by-one basis, by using the')
    drc = lineout(aFile, '# administration program.')
    drc = lineout(aFile, '#')
    aLine = 'users_tree='||BtDsk||'Users'
    drc = lineout(aFile, aLine)
    drc = lineout(aFile, '#')
    drc = lineout(aFile, '# -- end of cfg file --')
    drc = lineout(aFile)      /* Close the file */
end

if stream('last', 'c', 'query exists') = '' then do
    aFile = 'last'
    drc = lineout(aFile,,1)   /* Open the file and position to the beginning */
    aLine = 'admin'
    drc = lineout(aFile, aLine)
    drc = lineout(aFile)      /* Close the file */
end

/* Try to create the user directory */
drc = make_directory(BtDsk || 'Users')
if drc = 0 then do
    drc = make_directory(BtDsk || 'Users\admin')
    if drc = 0 then do
        aFile = BtDsk ||'Users\admin\admin.env'
        drc = lineout(aFile,,1)   /* Open the file and position to the beginning */

        if (Value('HOME',, 'OS2ENVIRONMENT') = '') |,
           (Value('HOME',, 'OS2ENVIRONMENT') = ' '),
        then
            aLine = 'HOME=' || BtDsk || 'Users\admin'
        else
            aLine = 'HOME=' || Value('HOME',, 'OS2ENVIRONMENT')

        if Debug then say aLine
        drc = lineout(aFile, aLine)

        if (Value('USER',, 'OS2ENVIRONMENT') = '') |,
           (Value('USER',, 'OS2ENVIRONMENT') = ' '),
        then
            aLine = 'USER=admin'
        else
            aLine = 'USER=' || Value('USER',, 'OS2ENVIRONMENT')

        if Debug then say aLine
        drc = lineout(aFile, aLine)

        aLine = 'USER=' || Value('USER',, 'OS2ENVIRONMENT')
        drc = lineout(aFile)      /* Close the file */

        drc = make_directory(BtDsk || 'Users\admin\WC')
        if drc = 0 then do
            DestPath = BtDsk || 'Users\admin\WC'
            '@copy ' || BtDsk || 'OS2\DLL\dock*.cfg ' || DestPath || ' 1> nul 2> nul'
            '@copy ' || BtDsk || 'OS2\DLL\SCENTER.CFG ' || DestPath || ' 1> nul 2> nul'
        end

        /* Try to see if multimedia is installed; if so, copy MMPM.INI */
        EnvMMBase = Strip(Value('MMBASE',, 'OS2ENVIRONMENT'))
        if Right(EnvMMBase, 1) = ';' then EnvMMBase = Left(EnvMMBase, Length(EnvMMBase) - 1)
        if (EnvMMBase \= '') then do
            if Right(EnvMMBase, 1) \= '\' then EnvMMBase = EnvMMBase || '\'
            drc = make_directory(BtDsk || 'Users\admin\MMOS2')
            if drc = 0 then do
                DestPath = BtDsk || 'Users\admin\MMOS2'
                '@copy ' || EnvMMBase || 'MMPM.INI ' || DestPath || ' 1> nul 2> nul'
            end
        end

        '@copy .\mdstart.usr ' || BtDsk || 'Users\admin\mdstart.cmd 1> nul 2> nul'
    end
end

exit 0


make_directory: procedure
    /* get the argument */
    parse arg TheDir rest

    /* try to use SysMkDir, if possible */
    mdrc = RxFuncQuery('SysMkDir')
    if mdrc \= 0 then do
        mdrc = RxFuncAdd('SysMkDir', 'RexxUtil', 'SysMkDir')
        if mdrc = 0 then
            drc = SysMkDir(TheDir)
        else do
            '@md ' || TheDir || ' 1> nul 2> nul'
            drc = rc
        end
    end; else
        drc = SysMkDir(TheDir)

    return drc
/* end procedure make_directory */

