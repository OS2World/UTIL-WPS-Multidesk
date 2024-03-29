� �� 0U  d   MultiDeskMain�   �  UsersContainer�  SaveBtn�  
DiscardBtn�  ManageDeskBtn�  HintsBox�   �  	CtrlClose�  CtrlMin�  CtrlMaxRest0 
NewUserBtn1 TrashBtn2 CtrlMove�   �   ,  	MsgBoxDlg/	 MessageText.  �  InputValueDlg�	 
MessageMLE� 
InputField� OKBtn� 	CancelBtn�  LogDlg� LogList� HideBtnX  IniSetupDlgY	  [  a
 SourceUserCBox\ GroupsContainer] SUI_CopyBtn^ SUI_ExitBtn_ SUI_MoreBtn`  �  
IniCopyDlg�	  �  �
 SourceUserBox� SourceINIList� CopyEntryBtn� RemoveEntryBtn� DestINIList�  �  � ICD_DoneBtn��� 0�L  Init�/* Let's initialize the dialog */

/* -- Load all the auxiliary functions' libraries -------------- */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

call RxFuncAdd 'AFLoadFuncs', 'AuxFuncs', 'AFLoadFuncs'
call AFLoadFuncs

call RxFuncAdd  'FastIniStart',   'FastIni',  'FastIniStart';
call RxFuncAdd  'FastIniEnd',     'FastIni',  'FastIniEnd';

/* -- End of aux libs load ------------------------------------- */

/* Set up... */
ADDRESS "NULL"
CRLF = '0D0A'X
MD_AllowMove = 0

/* Initialize the log dialog (don't show) */
LogDlg.Open(, 'MuDesk - Log window', 'N')

/* Initialize the main window (don't show) */
MultiDeskMain.Open()
MultiDeskMain.Hide()

/* Set container's colors */
MultiDeskMain.UsersContainer.Color('-', '#10')
MultiDeskMain.UsersContainer.Color('+', '#6')

/* See if we have a saved position */
rc = Stream('muadmin.ini', 'C', 'Query Exists')
if rc = '' then do
    /* Center the window on the screen */
    parse value MultiDeskMain.Position() with x y cx cy
    parse value ScreenSize() with dx dy
    MultiDeskMain.Position((dx - cx)%2, (dy - cy)%2, cx, cy)
end; else do
    FastIniStart('MuAdmin.ini', 'MDMI_HIni')
    MultiDeskMain.Position( SysIni('MuAdmin.ini', 'Main', 'X'),
                            SysIni('MuAdmin.ini', 'Main', 'Y'),
                            SysIni('MuAdmin.ini', 'Main', 'DX'),
                            SysIni('MuAdmin.ini', 'Main', 'DY'))
    FastIniEnd(MDMI_HIni)
end

/* Set the minimum window size to 640x480 */
MultiDeskMain.Range(640, 480)

/* Can we access the DAT file? */
rc = Stream('mudesk.dat', 'C', 'Query Exists')
if rc = '' then do
    MsgText = 'I cannot find the file mudesk.dat.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    exit
end

/* Can we access the CFG file? */
rc = Stream('mudesk.cfg', 'C', 'Query Exists')
if rc = '' then do
    MsgText = 'I cannot find the file mudesk.cfg.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    exit
end

CfgLine = linein('mudesk.dat', 1, 1)

if CfgLine = '' then do
    rc = Stream('mudesk.dat', 'S')
    if rc \= 'READY' then do
        MsgText = 'You must be root to edit user profiles.'
        MsgTitle = 'Security Warning'
        action = MyMessageBox(MsgText||';'||MsgTitle)
        exit
    end
end

/* Notify a 'size' event, to let the window react to the sizing due to saved */
/* positions _before_ it is shown. This avoids flashing controls.            */
/* Notify('MultiDeskMain', 'Size') */

/* show the main window */
/* MultiDeskMain.Show() */

IniCopyGrp�/* Copy a group of INI entries from one set of INI files to another */

/* Init error flag */
ICG_Error_Flag = 0

/* Get parms */
ICG_Parms = Arg(1)
Parse Value ICG_Parms With ICG_SourceUser ';;' ICG_IniGrp

/* Get source user's User and System ini files */
do ICG_i = 1 to UsersContainer_items.0
	ICG_Name = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICG_i)
	if ICG_Name = ICG_SourceUser then do
		ICG_UIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICG_i, 5)
		ICG_SIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICG_i, 6)
		Leave
	end
end

/* Get new user's User and System ini files */
do ICG_i = 1 to UsersContainer_items.0
	ICG_Name = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICG_i)
	if ICG_Name = NewUserName then do
		ICG_NU_UIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICG_i, 5)
		ICG_NU_SIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICG_i, 6)
		Leave
	end
end

if (ICG_UIni = '')|(ICG_SIni = '')|(ICG_NU_UIni = '')|(ICG_NU_SIni = '') then do
	say 'Source and/or destination user has no INI files.'
	say '-------------------------'
	return 1
end

Parse Value ICG_IniGrp With . ';' ICG_Grp ';' ICG_Ini
if ICG_Ini = 'User' then do
	ICG_Ini = ICG_UIni
	FastIniStart(ICG_UIni, 'ICG_HIni')
	FastIniStart(ICG_NU_UIni, 'ICG_HNUIni')
end; else do
	ICG_Ini = ICG_SIni
	FastIniStart(ICG_SIni, 'ICG_HIni')
	FastIniStart(ICG_NU_SIni, 'ICG_HNUIni')
end

If Right(ICG_Grp, 1) = '*' then do
	/* Read all applications in the ini file */
	SysIni(ICG_Ini, 'All:', 'ICG_Apps.')
	do ICG_i = 1 to ICG_Apps.0
		if Abbrev(ICG_Apps.ICG_i, Left(ICG_Grp, Length(ICG_Grp) - 1), Length(ICG_Grp) -1) = 1 then do
			say 'Copying '|| ICG_Apps.ICG_i ||'...'

			if ICG_Ini = ICG_UIni then
				DRC_rc = DoRealCopy(ICG_Apps.ICG_i, ICG_Ini, ICG_NU_UIni)
			else
				DRC_rc = DoRealCopy(ICG_Apps.ICG_i, ICG_Ini, ICG_NU_SIni)

			if DRC_rc < 0 then do
				say '** Error copying '|| ICG_Apps.ICG_i || ' **'
				ICG_Error_Flag = 1
			end
		end
	end
end; else do
	if Pos('@', ICG_Grp) \= 0 then do
		Parse Value Icg_Grp With ICG_GrpApp '@' ICG_GrpKey
        	ICG_TmpVal = c2x(SysIni(ICG_Ini, ICG_GrpApp, ICG_GrpKey))
		if ICG_Ini = ICG_UIni then
			DRC_rc = SysIni(ICG_NU_UIni, ICG_GrpApp, ICG_GrpKey, x2c(ICG_TmpVal))
		else
			DRC_rc = SysIni(ICG_NU_SIni, ICG_GrpApp, ICG_GrpKey, x2c(ICG_TmpVal))

		if (DRC_rc \= '') | (ICG_TmpVal = 'ERROR:') then do
			say '** Error copying '|| ICG_GrpApp || ' **'
			ICG_Error_Flag = 1
		end
	end; else do
		say 'Copying '|| ICG_Grp ||'...'

		if ICG_Ini = ICG_UIni then
			DRC_rc = DoRealCopy(ICG_Grp, ICG_Ini, ICG_NU_UIni)
		else
			DRC_rc = DoRealCopy(ICG_Grp, ICG_Ini, ICG_NU_SIni)

		if DRC_rc < 0 then do
			say '** Error copying '|| ICG_Grp || ' **'
			ICG_Error_Flag = 1
		end
	end
end

FastIniEnd(ICG_HIni)
FastIniEnd(ICG_HNUIni)

say 'All done!!'
say '-------------------------'

return ICG_Error_Flag


/*----------------------------------+
| Do the real copying between INIs  |
+----------------------------------*/
DoRealCopy: Procedure
  DRC_IniApp = arg(1)
  DRC_SourceIniName = arg(2)
  DRC_DestIniName = arg(3)

  /* Query all keys for selected app */
  if SysIni(DRC_SourceIniName, DRC_IniApp, 'All:', 'DRC_Keys') \= '' then
	return -1

  DRC_Error = 0
  do DRC_i = 1 to DRC_Keys.0
        DRC_TmpVal = c2x(SysIni(DRC_SourceIniName, DRC_IniApp, DRC_Keys.DRC_i))
	if SysIni(DRC_DestIniName, DRC_IniApp, DRC_Keys.DRC_i, x2c(DRC_TmpVal)) \= '' then
		DRC_Error = 1
  end
  if DRC_Error = 1 then return -1
Return 0
AddGroup�AG_Parms = arg(1)
Parse Value AG_Parms With AG_GroupName ';' AG_icon ';' AG_Description

AG_item = IniSetupDlg.GroupsContainer.Add(AG_GroupName, AG_icon)
AG_data.0 = 3
AG_data.1 = AG_icon
AG_data.2 = AG_GroupName
AG_data.3 = AG_Description
IniSetupDlg.GroupsContainer.SetStem(AG_data., AG_item)

return ''
GetDesktopDirectory�/*---------------------------------------------------------------------+
| This routine is based on GetDesk.cmd by Georg Haschek (see below     |
| for the original header by Georg)                                    |
+---------------------------------------------------------------------*/

/**********************************************************************/
/* GETDESK.CMD                                                        */
/* Version: 1.2                                                       */
/* Written by:  Georg Haschek (haschek at vnet.ibm.com)               */
/* Description: Return the desktop's directory name to the caller.    */
/* captured from a message in a public CompuServe forum               */
/**********************************************************************/

ADDRESS "NULL"

GDD_Parms = Arg(1)
Parse Value GDD_Parms With GDD_User_Ini ';' GDD_System_Ini

GDD_User_Ini = AFGetAbsPath(GDD_User_Ini, 'C')
if GDD_User_Ini = 'ERROR' then
	return ""

GDD_System_Ini = AFGetAbsPath(GDD_System_Ini, 'C')
if GDD_System_Ini = 'ERROR' then
	return ""

Return Getpath(Substr(SysIni(GDD_User_Ini, "PM_Workplace:Location", "<WP_DESKTOP>"), 1, 2))

/*---------------------------------------------+
| Loop through the nodes to get the path info  |
+---------------------------------------------*/
Getpath: Procedure Expose nodes. GDD_System_Ini

  If Getnodes() <> 0 Then
    Return ""

  gpinode = Arg(1)

  If nodes.gpinode = "" Then
    Return ""

  gp = Substr(nodes.gpinode, 33, Length(nodes.gpinode) - 33)
  gpparent = Substr(nodes.gpinode, 9, 2)

  If gpparent <> "0000"x Then Do
    Do Until gpparent = "0000"x
      gp = Substr(nodes.gpparent, 33, Length(nodes.gpparent) - 33) || "\" || gp
      gpparent = Substr(nodes.gpparent, 9, 2)
    End
  End
Return gp

/*---------------+
| Get the nodes  |
+---------------*/
Getnodes: Procedure Expose nodes. GDD_System_Ini

  handlesapp = SysIni(GDD_System_Ini, "PM_Workplace:ActiveHandles", "HandlesAppName")

  If handlesapp = "ERROR:" Then
    handlesapp = "PM_Workplace:Handles"

  block1 = ""
  Do i = 1 to 999
    block = SysIni(GDD_System_Ini, handlesapp, "BLOCK" || i)
    If block = "ERROR:" Then Do
      If i = 1 Then
        Return -1
      Leave
    End
    block1 = block1 || block
  End

  l = 0
  nodes. = ""
  Do Until l >= Length( block1 )
    If Substr( block1,l+5,4 ) = "DRIV" Then Do
      xl = Pos( "00"x || "NODE" || "01"x, block1,l+5 )-l
      If xl <= 0 Then
        Leave
      l = l + xl
      Iterate
    End; Else Do
      If Substr( block1,l+1,4 ) = "DRIV" Then Do
        xl = Pos( "00"x || "NODE" || "01"x, block1,l+1 )-l
        If xl <= 0 Then
          Leave
        l = l + xl
        Iterate
      End; Else Do
        data = Substr( block1,l+1,32 )
        xl = C2D( Substr( block1,l+31,1 ) )
        If xl <= 0 Then
          Leave
        data = data || Substr( block1,l+33,xl+1 )
        l = l + Length( data )
      End
    End
    xnode = Substr( data,7,2 )
    nodes.xnode = data
  End
Return 0
CustomizeTemplate�/* Customizes a template file by substituting predefined strings */

parse value arg(1) with CT_UTreePath ';' CT_Ini ';' CT_UserName

if CT_Ini = 'user' then
    CT_TemplateName = CT_UTreePath||'\uit.rc'
else
    CT_TemplateName = CT_UTreePath||'\sit.rc'

linein(CT_TemplateName, 1, 0)   /* Open the template for reading */

drop CT_TLines.         /* Just to be sure */
do CT_Count=1 by 1 until Lines(CT_TemplateName) = 0
    CT_TLines.CT_Count = linein(CT_TemplateName)
end
CT_TLines.0 = CT_Count

if CT_Ini = 'user' then
    CT_NewName = CT_UTreePath||'\MDINI.RC'
else
    CT_NewName = CT_UTreePath||'\MDINISYS.RC'

lineout(CT_NewName,,1)      /* Open new INI for writing */
do CT_Count=1 to CT_TLines.0 by 1
    do forever
        CT_Pos = Pos('<@@', CT_TLines.CT_Count)
        if CT_Pos \= 0 then do
            CT_NewLine = left(CT_TLines.CT_Count, CT_Pos - 1)
            if Substr(CT_TLines.CT_Count, CT_Pos + 3, 1) = 'b' then
                CT_NewLine = CT_NewLine||AFGetBootDrive()||':'
            else do
                CT_UTreePath = AFGetAbsPath(CT_UTreePath, 'C')
                if CT_UTreePath = 'ERROR' then return -1
                CT_NewLine = CT_NewLine||CT_UTreePath
            end
            CT_Pos = Pos('@@>', CT_TLines.CT_Count)
            if CT_Pos = 0 then return -1
            CT_NewLine = CT_NewLine||Substr(CT_TLines.CT_Count, CT_Pos + 3)
            CT_TLines.CT_Count = CT_NewLine
        end; else do
            leave
        end
    end
    lineout(CT_NewName, CT_TLines.CT_Count)
end

/* Close the files */
Lineout(CT_TemplateName)
Lineout(CT_NewName)

/* Free up memory (? Does rexx do garbage collection?) */
drop CT_NewName CT_TemplateName CT_UserName CT_Count
drop CT_Pos CT_NewLine CT_UTreePath CT_Ini
drop CT_TLines.

/* Tell the caller all done OK */
return 0
CreateStandardTree�4/* Creates a standard tree for a user */

aUserName = arg(1)

/* Read in all CFG file lines, to find users_tree option */
linein('mudesk.cfg', 1, 0)
do i=1 by 1 until Lines('mudesk.cfg') = 0
    ThisLine = linein('mudesk.cfg')
    if Abbrev(ThisLine, 'users_tree=') = 1 then leave
end

if Abbrev(ThisLine, 'users_tree=') = 1 then
    parse value ThisLine with . '=' UTreePath
else do
    BootDrive = AFGetBootDrive()
    UTreePath = BootDrive||':\Users'
    rcdir = SysMkDir(UTreePath)
    if (rcdir = 0)|(rcdir = 5) then
        nop
    else do
        MsgText = 'The "users_tree" option is not specified in the config '
        MsgText = MsgText||'file, and the creation of the default users'' '
        MsgText = MsgText||'directory ('||UTreePath||') failed. Aborting.'
        MsgTitle = 'Error'
        action = MyMessageBox(MsgText||';'||MsgTitle)
        return -1
    end
end

if Right(UTreePath, 1) \= '\' then
    UTreePath = UTreePath||'\'

/* Show the log window */
LogDlg.Show()

/* Let's create the user dir */
say 'Creating user tree...'

if SysMkDir(UTreePath||aUserName) \= 0 then do
    MsgText = 'Sorry, could not create the tree for the user.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end
say 'Created directory '||UTreePath||aUserName||'.'

if SysMkDir(UTreePath||aUserName||'\WC') \= 0 then do
    MsgText = 'Sorry, could not create the WarpCenter directory for the user.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end
say 'Created directory '||UTreePath||aUserName||'\WC.'

/* Now copy mdstart.cmd script to the user dir */
address 'CMD' 'copy .\mdstart.usr '||UTreePath||aUserName||'\mdstart.cmd'
if Stream(UTreePath||aUserName||'\mdstart.cmd', 'C', 'Query Exists') = '' then do
    MsgText = 'An error occurred copying the startup script to the user dir. '
    MsgText = MsgText||'Aborting.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end
say 'Startup script template copied to the user directory.'

/* Now copy user_ini and system_ini templates to the user dir */
address 'CMD' 'copy .\uit.rc '||UTreePath||aUserName||'\uit.rc'
if Stream(UTreePath||aUserName||'\uit.rc', 'C', 'Query Exists') = '' then do
    MsgText = 'An error occurred copying templates to the user dir. '
    MsgText = MsgText||'Aborting.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end
say 'User_ini template copied to the user directory.'

address 'CMD' 'copy .\sit.rc '||UTreePath||aUserName||'\sit.rc'
if Stream(UTreePath||aUserName||'\sit.rc', 'C', 'Query Exists') = '' then do
    MsgText = 'An error occurred copying templates to the user dir. '
    MsgText = MsgText||'Aborting.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end
say 'System_ini template copied to the user directory.'

say 'Customizing templates for the user '||aUserName||'...'

rc = CustomizeTemplate(UTreePath||aUserName||';'||'user'||';'||aUserName)
if rc = 0 then
    say 'User_ini template processing done.'
else do
    MsgText = 'An error occurred customizing the user_ini template '
    MsgText = MsgText||'for the user '||aUserName||'. Aborting.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end

rc = CustomizeTemplate(UTreePath||aUserName||';'||'system'||';'||aUserName)
if rc = 0 then
    say 'System_ini template processing done.'
else do
    MsgText = 'An error occurred customizing the user_ini template '
    MsgText = MsgText||'for the user '||aUserName||'. Aborting.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end

say 'Removing templates from the user directory...'
rc = SysFileTree(UTreePath||aUserName||'\uit.rc', DummyStem., 'F', '*****', '+----')
if (rc \= 0)|(DummyStem.0 = 0) then
    say 'Error deleting User_ini template. (???) Continuing...'
else do
    rc = SysFileDelete(UTreePath||aUserName||'\uit.rc')
    if rc \= 0 then
        say 'Error deleting User_ini template. (???) Continuing...'
    else
        say 'User_ini template removed'
end

rc = SysFileTree(UTreePath||aUserName||'\sit.rc', DummyStem., 'F', '*****', '+----')
if (rc \= 0)|(DummyStem.0 = 0) then
    say 'Error deleting System_ini template. (???) Continuing...'
else do
    rc = SysFileDelete(UTreePath||aUserName||'\sit.rc')
    if rc \= 0 then
        say 'Error deleting System_ini template. (???) Continuing...'
    else
        say 'System_ini template removed'
end

say 'Compiling the INI files...'
CST_CurDir = Directory()
CST_NewDir = Directory(UTreePath||aUsername)
if Compare(Translate(CST_NewDir), Translate(UTreePath||aUserName)) = 0 then do
    address 'CMD' 'MAKEINI OS2.INI MDINI.RC'
    if rc \= 0 then do
        MsgText = 'Error creating the user_ini. Aborting.'
        MsgTitle = 'Error'
        action = MyMessageBox(MsgText||';'||MsgTitle)
        return -1
    end
    say 'User_ini file compiled successfully.'
    address 'CMD' 'MAKEINI OS2SYS.INI MDINISYS.RC'
    if rc \= 0 then do
        MsgText = 'Error creating the system_ini. Aborting.'
        MsgTitle = 'Error'
        action = MyMessageBox(MsgText||';'||MsgTitle)
        return -1
    end
    say 'System_ini file compiled successfully.'
end; else do
    Directory(CST_CurDir)
    MsgText = 'Cannot change to the '||UTreePath||aUserName' directory. '
    MsgText = MsgText||'Aborting.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    return -1
end
Directory(CST_Curdir)
Drop CST_CurDir CST_NewDir

say 'Creating default user environment file...'
CST_EnvFile = UTreePath||aUserName||'\'||aUserName||'.env'
rc = lineout(CST_EnvFile,,1)
rc = (rc)|(lineout(CST_EnvFile, 'USERNAME='||aUserName))
rc = (rc)|(lineout(CST_EnvFile, 'USER='||aUserName))
rc = (rc)|(lineout(CST_EnvFile, 'LOGNAME='||aUserName))
rc = (rc)|(lineout(CST_EnvFile, 'HOME='||UTreePath||aUserName))
if rc = 1 then do
    MsgText = 'An error was detected while writing the user '
    MsgText = MsgText||'environment file. A partial file or no file '
    MsgText = MsgText||'could have been generated. Please review '
    MsgText = MsgText||'the '||CST_EnvFile||' file to be sure '
    MsgText = MsgText||'all is correct. Generation will now continue...'
    MsgTitle = 'Warning'
    action = MyMessageBox(MsgText||';'||MsgTitle)
end
lineout(CST_EnvFile)    /* close the file */

say 'All done!!'
say '-------------------------'
return 0

MyInputBox�/* This displays a modal generic input box */
ADDRESS "NULL"

Drop aText
aText = arg(1)
MIB_action = ModalFor('InputValueDlg')

return MIB_action
RemoveItemFromStem�/* Removes an item from stem. The stem MUST contain the number */
/* of items in the stem.0 variable                             */
/***************************************************************/
ADDRESS "NULL"

RIFS_Parms = arg(1)
Parse Value RIFS_Parms with RIFS_aStem ';' RIFS_anItem

/* Copy the stem to a new stem, leaving out the item to delete */
RIFS_work2 = 1   /* Init the counter for the second (new) stem  */
do RIFS_work=1 to value(RIFS_aStem||.0) by 1
    if value(RIFS_aStem||.RIFS_work) \= RIFS_anItem then do
        RIFS_WorkStem.RIFS_work2 = value(RIFS_aStem||.RIFS_work)
        RIFS_work2 = RIFS_work2 + 1
    end
end
RIFS_WorkStem.0 = RIFS_work2 - 1

/* Copy back the new stem on the old */
interpret RIFS_aStem||.||" = ''"
do RIFS_work = 0 to RIFS_WorkStem.0 by 1
    interpret RIFS_aStem||.RIFS_work||" = RIFS_WorkStem.RIFS_work"
end

return value(RIFS_aStem||.0)
MyMessageBox�ADDRESS "NULL"

Drop Parms aText aTitle

MMB_Parms = arg(1)
Parse Value MMB_Parms with aText ';' aTitle

aTitle = 'MultiDesk - '||aTitle
MMB_action = ModalFor('MsgBoxDlg')

return MMB_action
�� �d 0B  B  �  ��           �  n A X� d ���    	 �	 � �   � � ��      %   , �-  � � -��    
 j
 u   �/ 	   � ���    
 �
 �   �L 	   � ���    
 �
 �   �2	   � ���       "@` �i 	 �  � #��         H  �+  � � I��    
 �
 �  �N� 	  � ���    
 �
 �   �N� 	  � ���    
 �
    �N� 	  � ��    
 7
 B   �N+ 	  0M��    
 r
 }   �N  	  1���    
 �
 �   �N 	  2���     �  �0 �  " � � ���       @ �)  #� � ��    BILLBOARD admin2:#1 !         9.WarpSans                9         
                  9.WarpSans               ICONBUTTON mdicons:#2 !         9.WarpSans               ICONBUTTON mdicons:#3 !         9.WarpSans               ICONBUTTON mdicons:#7 !         9.WarpSans               CANVAS  !         9.WarpSans                9         
         
         9.WarpSans               ICONBUTTON mdctrls:#1 !         9.WarpSans               ICONBUTTON mdctrls:#3 !         9.WarpSans               ICONBUTTON mdctrls:#2 !         9.WarpSans               ICONBUTTON mdctrls:#6 !         9.WarpSans               ICONBUTTON mdctrls:#7 !         9.WarpSans               ICONBUTTON mdctrls:#8 !         9.WarpSans               CANVAS  !         9.WarpSans               CANVAS  !         9.WarpSans               ���d 0�A  �d InitMultiDeskMain.Show()Notifye/* Notified events */
EventData('MDMN_Data')
if MDMN_Data.1 = 'Size' then signal D100__I100__Size
	LoseFocus|/* disable moving (if it is enabled) */
if MD_AllowMove = 1 then do
	MD_AllowMove = 0
	CtrlMove.Text('mdctrls:#8')
end
Key�if MD_AllowMove = 1 then do
	EventData(aKey.)
	if aKey.2 = 'CONTROL' then do
		parse value MultiDeskMain.Position() with MDMK_x MDMK_y MDMK_dx MDMK_dy
		select
			when aKey.1 = 'LEFT' then
				MultiDeskMain.Position(MDMK_x - 1)
			when aKey.1 = 'RIGHT' then
				MultiDeskMain.Position(MDMK_x + 1)
			when aKey.1 = 'UP' then
				MultiDeskMain.Position(MDMK_x, MDMK_y + 1)
			when aKey.1 = 'DOWN' then
				MultiDeskMain.Position(MDMK_x, MDMK_y - 1)
			otherwise do
				MD_AllowMove = 0
				CtrlMove.Text('mdctrls:#8')
			end
		end
	end; else do
		MD_AllowMove = 0
		CtrlMove.Text('mdctrls:#8')
	end
end
Size�/* get dialog/frame position and size */
parse value MultiDeskMain.Position() with x y dx dy
parse value MultiDeskMain.Frame() with left bottom right top

/* sets the canvas position */
C201.Position(86, 15, dx - 86 - 30, dy - 22 - top)

/* sets the rectangle position */
C202.Position(90, 20, dx - 90 - 34, dy - 30 - top)

/* sets the container position */
UsersContainer.Position(94, 75, dx - 94 - 40, dy - 87 - top)

/* set buttons position and size */
parse value ManageDeskBtn.Position() with x y mdx mdy
ManageDeskBtn.Position(dx - 38 - 40 - 2, y, 40, 40)

parse value SaveBtn.Position() with x y dx dy
SaveBtn.Position(x, y, 40, 40)

parse value DiscardBtn.Position() with x y dx dy
DiscardBtn.Position(x, y, 40, 40)

/* set the hints box position and size */
parse value MultiDeskMain.Position() with x y dx dy
parse value HintsBox.Position() with x y hdx hdy
HintsBox.Position(x, y, dx - 214 - 96, hdy)

/* set controls position and size */
parse value MultiDeskMain.Position() with x y dx dy
CtrlClose.Position(dx - 26, dy - 32, 18, 18)
CtrlMin.Position(dx - 26, dy - 59, 18, 18)
CtrlMaxRest.Position(dx - 26, dy - 87, 18, 18)

NewUserBtn.Position(dx - 26, 113, 18, 18)
TrashBtn.Position(dx - 26, 85, 18, 18)
CtrlMove.Position(dx - 26, 18, 18, 18)

/* sets the second canvas position */
parse value C209.Position() with cx cy cdx cdy
C209.Position(cx, cy, cdx, dy - 22 - top)
�2Click�/* move the window */

/* set up a new function to change pointers? (AuxFuncs.dll) */

/* Set the 'move' flag to true */
MD_AllowMove = 1

/* 'Activate' the icon */
CtrlMove.Text('mdctrls:#9')

/* Give focus to the main window */
MultiDeskMain.Focus()
�1Click�/* Delete current user (the selected one) */
TB_Item = UsersContainer.Select()

if TB_Item = 0 then do
    MsgText = 'There are no items to delete.'
    MsgTitle = 'Info'
    action = MyMessageBox(MsgText||';'||MsgTitle)
end; else do
    TB_UserEnv = UsersContainer.Item(TB_Item, 7)
    TB_TempPos = LastPos('\', TB_UserEnv) - 1

    if TB_TempPos < 0 then
        TB_UserDir = ''
    else
        TB_UserDir = Left(TB_UserEnv, LastPos('\', TB_UserEnv) - 1)

    if (TB_UserDir \= '')&(Stream(TB_UserDir||'\*', 'C', 'Query Exists') \= '') then do
        MsgText = 'Delete directory '||TB_UserDir||' ?'||CRLF
        MsgText = MsgText||'NOTE that this will remove the user''s desktop too, '
        MsgText = MsgText||'if it is located in the user''s directory tree.'
        MsgTitle = 'MultiDesk - Delete User Directory'
        if RxMessageBox(MsgText, MsgTitle, 'YesNo', 'Query') = 6 then do
            if AFDelTree(TB_UserDir) = 'ERROR' then do
                MsgText = 'I could not remove the directory tree. '
                MsgText = MsgText||'You will have to do it yourself.'
                MsgTitle = 'Delete User Directory'
                action = MyMessageBox(MsgText||';'||MsgTitle)
            end; else
                say 'Removed user directory.'
        end
    end

    TB_UserIni = UsersContainer.Item(TB_Item, 5)
    TB_SystemIni = UsersContainer.Item(TB_Item, 6)
    if TB_UserIni \= '' then do
        if Stream(TB_UserIni, 'C', 'Query Exists') \= '' then do
            TB_UserDesktop = GetDesktopDirectory(TB_UserIni||';'||TB_SystemIni)
            if TB_UserDesktop \= '' then do
                MsgText = 'Delete directory '||TB_UserDesktop||' ? (DON''T DO IT '
                MsgText = MsgText||'IF THE DESKTOP IS CURRENTLY RUNNING!)'
                MsgTitle = 'MultiDesk - Delete User Desktop'
                if RxMessageBox(MsgText, MsgTitle, 'YesNo', 'Query') = 6 then do
                    MsgText = 'ARE YOU SURE?'
                    MsgTitle = 'MultiDesk - Delete User Desktop'
                    if RxMessageBox(MsgText, MsgTitle, 'YesNo', 'Query') = 6 then do
                        if AFDelTree(TB_UserDir) = 'ERROR' then do
                            MsgText = 'I could not remove the directory tree. '
                            MsgText = MsgText||'You will have to do it yourself.'
                            MsgTitle = 'MultiDesk - Delete User Desktop'
                            action = MyMessageBox(MsgText||';'||MsgTitle)
                        end; else
                            say 'Removed user desktop.'
                    end
                end
            end
        end
    end

    MsgText = 'Remove user?'
    MsgTitle = 'MultiDesk - Delete User'
    if RxMessageBox(MsgText, MsgTitle, 'YesNo', 'Query') = 6 then do
        UsersContainer.Delete(TB_Item)
        RemoveItemFromStem('UsersContainer_items'||';'||TB_Item)
        say 'Removed user.'
    end
end

say 'All done!!'
say '-------------------------'

signal D100__I207__Click    /* SaveBtn.Click() */
�0Click�/* Create a new entry in the users' container */
MsgText = 'Please enter a name for the new user:'
NewUserName = MyInputBox(MsgText)

do NUB_count = 1 to UsersContainer_items.0
    if Translate(UsersContainer.Item(UsersContainer_items.NUB_count)) = Translate(NewUserName) then do
        MsgText = 'Duplicate username'
        MsgTitle = 'Error'
        action = MyMessageBox(MsgText||';'||MsgTitle)
        signal return
    end
end

if NewUserName \= '@CANCELLED@' then do
    NUB_i = UsersContainer.Item()
    NUB_i = NUB_i + 1                   /* increment the items number */
    UsersContainer_items.0 = NUB_i      /* remember the items number  */

    icon = 'MDICONS:#10'
    NUB_item = UsersContainer.Add(NewUserName, icon)
    UsersContainer_items.NUB_i = NUB_item   /* remember the item value */
    data.0 = 7
    data.1 = icon
    data.2 = NewUserName
    data.3 = ' '
    data.4 = ' '
    data.5 = ' '
    data.6 = ' '
    data.7 = ' '
    UsersContainer.SetStem(data., NUB_item)

    MsgText = 'Do you want to create a standard tree for this user?'
    MsgTitle = 'MultiDesk - User '||NewUserName
    if RxMessageBox(MsgText, MsgTitle, 'YesNo', 'Query') = 6 then do
        if CreateStandardTree(NewUserName) \= 0 then do
            MsgText = 'An error occurred while creating the tree for the new user. '
            MsgText = MsgText||'You shouldn''t tell the program to remove the '
            MsgText = MsgText||'directories and files that have been created, '
            MsgText = MsgText||'so that you can look at the files and try to '
            MsgText = MsgText||'understand what has happened.'||CRLF
            MsgText = MsgText||'It is up to you to remove the whole user '
            MsgText = MsgText||'directory, when you''re done. Please do it, to '
            MsgText = MsgText||'avoid future problems.'||CRLF
            MsgText = MsgText||'You can, however, let the program remove '
            MsgText = MsgText||'the user from the container view.'
            MsgTitle = 'Error'
            action = MyMessageBox(MsgText||';'||MsgTitle)
            UsersContainer.Select(UsersContainer_items.NUB_i)

            /* Even if something went wrong, try to set the UserEnv file, */
            /* so that th remove routine can remove the partially created */
            /* user tree.                                                 */
            if UTreePath \= '' then do
                data.7 = UTreePath||NewUserName||'\'||NewUserName||'.env'
                UsersContainer.SetStem(data., NUB_item)
            end

            signal D100__I305__Click    /* TrashBtn.Click() */
        end; else do
            data.0 = 7
            data.1 = icon
            data.2 = NewUserName
            data.3 = 'newpass'
            data.4 = AFGetBootDrive()||':\OS2\PMSHELL.EXE'
            data.5 = UTreePath||NewUserName||'\OS2.INI'
            data.6 = UTreePath||NewUserName||'\OS2SYS.INI'
            data.7 = UTreePath||NewUserName||'\'||NewUserName||'.env'
            UsersContainer.SetStem(data., NUB_item)
        end

        MsgText = 'Do you want to customize the INI files?'
        MsgTitle = 'MultiDesk - User '||NewUserName
        if RxMessageBox(MsgText, MsgTitle, 'YesNo', 'Query') = 6 then do
            action = ModalFor('IniSetupDlg')
        end
    end

    signal D100__I207__Click    /* SaveBtn.Click() */
end
�� Click�if CtrlMaxRest.Text() = 'mdctrls:#2' then do /* this is the max button */
	parse value MultiDeskMain.Position() with mdeskx mdesky mdeskdx mdeskdy
	parse value ScreenSize() with screenx screeny
	MultiDeskMain.Position(0, 0, screenx, screeny)
	CtrlMaxRest.Text('mdctrls:#4')
	CtrlMaxRest.Hint('Restore �Desk Administrator')
end; else do
	CtrlMaxRest.Text('mdctrls:#2')
	CtrlMaxRest.Hint('Maximize �Desk Administrator')
	MultiDeskMain.Position(mdeskx, mdesky, mdeskdx, mdeskdy)
end
�� ClickMultiDeskMain.Hide('U')�� Click�/* On exit, save position and size of the dialog */
parse value MultiDeskMain.Position() with MDME_x MDME_y MDME_dx MDME_dy

MDME_Error = 0

FastIniStart('MuAdmin.ini', 'MDMI_HIni')
if SysIni('MuAdmin.ini', 'Main', 'X', MDME_x) \= '' then MDME_Error = 1
if SysIni('MuAdmin.ini', 'Main', 'Y', MDME_y) \= '' then MDME_Error = 1
if SysIni('MuAdmin.ini', 'Main', 'DX', MDME_dx) \= '' then MDME_Error = 1
if SysIni('MuAdmin.ini', 'Main', 'DY', MDME_dy) \= '' then MDME_Error = 1
FastIniEnd(MDMI_HIni)

if MDME_Error = 1 then
	say 'Error saving size and position of main window.'
else
	say 'Size and position saved.'

say '-------------------------'

/* close the main window */
MultiDeskMain.Close()
exit�� Init@HintsBox.Font('9.WarpSans')
HintsBox.IsDefault('ControlHint')
�� Click�/* Delete all items in container */
UsersContainer.Delete()

/* Unallocate the "data" stem */
Drop DB_Data.

/* Then reinit container: code copied from MultiDeskMain_UsersContainer_Init */

/* Read in all DAT file lines */
linein('mudesk.dat', 1, 0)
do DB_i=1 by 1 until Lines('mudesk.dat') = 0
    CfgLines.DB_i = linein('mudesk.dat')
end

CfgLines.0 = DB_i
UsersContainer_items.0 = DB_i  /* remember the items number */

/* Read in all CFG file lines, to find root_user */
linein('mudesk.cfg', 1, 0)
do DB_i=1 by 1 until Lines('mudesk.cfg') = 0
    ThisLine = linein('mudesk.cfg')
    if Abbrev(ThisLine, 'root_user') = 1 then leave
end

if Abbrev(ThisLine, 'root_user') = 1 then
    root_user = Substr(ThisLine, 11)
else
    root_user = 'root'

/* Create container items */
do DB_i=1 to CfgLines.0 by 1
    Parse Value CfgLines.DB_i With ThisUserName ';' RestOfLine
    if ThisUserName = root_user then
        icon = 'MDICONS:#11'
    else
        icon = 'MDICONS:#10'
    DB_Item = UsersContainer.Add(ThisUserName, icon)
    UsersContainer_items.DB_i = DB_Item  /* remember the item value */
    data.0 = 7
    data.1 = icon
    Parse Value RestOfLine With Passwd ';' WPSPath ';' UserINIPath ';' SystemINIPath ';' UserEnvPath
    data.2 = ThisUserName
    data.3 = Passwd
    data.4 = WPSPath
    data.5 = UserINIPath
    data.6 = SystemINIPath
    data.7 = UserEnvPath
    UsersContainer.SetStem(data., DB_Item)
end
�� Click�
/* Retrieves and then saves all data in the container */

TempCfgFile = SysTempFileName('mudesk??.???')
If TempCfgFile = '' then do
    MsgTitle = 'Error'
    MsgText = 'Cannot create temporary file'
    action = MyMessageBox(MsgText||';'||MsgTitle)
    exit
end

Lineout(TempCfgFile,,1)                  /* create the file */
do SB_i = 1 to UsersContainer_items.0
    SB_data. = ''
    UsersContainer.GetStem('SB_data', UsersContainer_items.SB_i)

    NewLine = SB_data.2
    do SB_j = 3 to SB_data.0
        NewLine = NewLine||';'||SB_data.SB_j
    end

    Lineout(TempCfgFile, NewLine)
end

Lineout('mudesk.dat')                   /* Close the file, in case it is open, */
					/* otherwise we can't delete it.       */

SysFileDelete('mudesk.dat')             /* Now that we have created the new    */
                                        /* file without problems, we can       */
                                        /* delete the original.                */

Lineout(TempCfgFile)                    /* Close the file */
SB_command = "ren "||TempCfgFile||" mudesk.dat"
address "CMD" SB_command            	/* ..and rename the new one */
drop SB_command

/* +-- finished saving --+ */
MsgTitle = 'Information'
MsgText = 'All data saved.'
action = MyMessageBox(MsgText||';'||MsgTitle)
�� Click�/* Create a new entry in the users' container */

i = UsersContainer.Item()
i = i + 1                       /* increment the items number */
UsersContainer_items.0 = i      /* remember the items number  */

icon = 'MDICONS:#10'
item = UsersContainer.Add('New_user', icon)
UsersContainer_items.i = item  /* remember the item value */
data.0 = 6
data.1 = icon
data.2 = 'New_user'
data.3 = ''
data.4 = ''
data.5 = ''
data.6 = ''
UsersContainer.SetStem(data., item)
Changed�/* One of the fields of an item has changed */

EventData('Changed')

/* Changed.1 = item  */
/* Changed.2 = field */

if (Changed.2 = 2) then do
	MsgText = 'Renaming a user by direct editing is not supported.'
	MsgText = MsgText || CRLF || 'Use the "Manage desktop" button instead.'
	MyMessageBox(MsgText||';'||MsgTitle)
        signal D100__I208__Click    /* DiscardBtn.Click() */
end

if (Changed.2 = 3) then do
	NewPasswd = UsersContainer.Item(Changed.1, Changed.2)
	itoa64 = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	NewSalt = ""
	do 8
		NewSalt = NewSalt || substr( itoa64, random( 0, 63 ) + 1, 1 )
	end
	NewCPasswd = AFCrypt(NewPasswd, NewSalt)
	UsersContainer.Item(Changed.1, Changed.2, NewCPasswd)
end

If (Changed.2 = 4)|(Changed.2 = 5)|(Changed.2 = 6) then do
    ThisPath = UsersContainer.Item(Changed.1, Changed.2)
    rc = Stream(ThisPath, 'C', 'Query Exists')
    if rc = '' then do
        MsgText = 'The specified file does not exists!'
        MsgTitle = 'Warning'
        MyMessageBox(MsgText||';'||MsgTitle)
    end
end
Init�/* Set container in DETAIL view, with WarpSans font */
UsersContainer.View('D')
UsersContainer.Font('9.WarpSans')

/* Set up the container format */
format.0 = 7
format.1 = '=_!'
format.2 = '_.'
format.3 = '_!'
format.4 = '_!'
format.5 = '_!'
format.6 = '_!'
format.7 = '_!'
UsersContainer.SetStem(format., 'F')

/* Set up column titles */
title.0 = 7
title.1 = '=MDICONS:#9'
title.2 = 'Name'
title.3 = 'Password'
title.4 = 'RunWorkplace'
title.5 = 'User_INI'
title.6 = 'System_INI'
title.7 = 'Environment file'
UsersContainer.SetStem(title., 0)

/* Read in all DAT file lines */
linein('mudesk.dat', 1, 0)
do i=1 by 1 until Lines('mudesk.dat') = 0
    CfgLines.i = linein('mudesk.dat')
end

CfgLines.0 = i
UsersContainer_items.0 = i  /* remember the items number */

/* Read in all CFG file lines, to find root_user */
linein('mudesk.cfg', 1, 0)
do i=1 by 1 until Lines('mudesk.cfg') = 0
    ThisLine = linein('mudesk.cfg')
    if Abbrev(ThisLine, 'root_user=') = 1 then leave
end

if Abbrev(ThisLine, 'root_user=') = 1 then
    root_user = Substr(ThisLine, 11)
else
    root_user = 'root'

/* Create container items */
do i=1 to CfgLines.0 by 1
    Parse Value CfgLines.i With ThisUserName ';' RestOfLine
    if ThisUserName = root_user then
        icon = 'MDICONS:#11'
    else
        icon = 'MDICONS:#10'
    item = UsersContainer.Add(ThisUserName, icon)
    UsersContainer_items.i = item  /* remember the item value */
    data.0 = 7
    data.1 = icon
    Parse Value RestOfLine With Passwd ';' WPSPath ';' UserINIPath ';' SystemINIPath ';' UserEnvPath
    data.2 = ThisUserName
    data.3 = Passwd
    data.4 = WPSPath
    data.5 = UserINIPath
    data.6 = SystemINIPath
    data.7 = UserEnvPath
    UsersContainer.SetStem(data., item)
end
����d 0A  ,2Click to move the window around (arrow keys)1Click to delete user0Click to create new user� Maximize �Desk Administrator� Minimize �Desk Administrator� Close �Desk Administrator� Manage user's desktop� Discard changes� Accept and save changes>� �Desk Administrator - Copyright 2000-2001 Cristiano Guadagnino�� �,0�   �   �  ��          h �  d w � ? ,��n       
   r  �  � - /s ��        �  �5   (  .� ���Desk                       	   OK             ���,0p  �,Init�/* Center the window on the screen */
parse value MsgBoxDlg.Position() with x y cx cy
parse value ScreenSize() with dx dy
MsgBoxDlg.Position((dx - cx)%2, (dy - cy)%2, cx, cy)

/* Set title and message */
MsgBoxDlg.Text(aTitle)
MessageText.Text(aText)

MsgBoxDlg.Show()
�.ClickD/* Close the modal dialog and return */
MsgBoxDlg.Close()
return 0�� ��0�   �   �  ��          �   � - � Z ����       
   �  �  � > �� ��         �  �  �  �� �         �  �   (  �����        �   �s   (  ������Desk - Input Value                                        ,    OK Cancel ����0>  ��Open8/* Set focus to the input field */
InputField.Focus()
Init�/* Center Dialog */
parse value InputValueDlg.Position() with x y cx cy
parse value ScreenSize() with dx dy
InputValueDlg.Position((dx - cx)%2, (dy - cy)%2, cx, cy)

/* Set MLE text */
MessageMLE.Text(aText)

InputValueDlg.Show()
��Clickv/* simply return to the caller with a code to indicate cancel action */
InputValueDlg.Close()
return '@CANCELLED@'
��Click|if InputField.Text() \= '' then do
	TempSaveValue = InputField.Text()
	InputValueDlg.Close()
	return TempSaveValue
end
�� ��0�   �   �  ��          h   � : � Z ���t          x  �  � K �y ��        �   �S   (  ������Desk - Log                 Close ����0  ��Timer�/* Look if there are any more messages in the listbox */
if LogList.Item() = LogList_Items then
	nop
else do
	LogList_Items = LogList.Item()
	if LogDlg.Visible() = 0 then do
		LogDlg.Show()
		LogDlg.Top()
	end
end
Exit-/* On exit, reopen itself */
LogDlg.Open()
Open�/* Selects the last item, to make the listbox scroll to the end (?) */
numitems = LogDlg.LogList.Item()
LogDlg.LogList.Select(numitems)
Init�/* Position dialog */
parse value LogDlg.Position() with x y cx cy
LogDlg.Position(0, 0, cx, cy)

/* Set up a timer to look for messages in the listbox */
LogList_Items = 0
LogDlg.Timer(500)

/* Set the list as the default recipient for 'say' instructions */
LogDlg.LogList.IsDefault('Say')
��Click*/* Hide the log window */
LogDlg.Hide()
�� �X0�  �  �  ��          �  � 3 � � X��7      
  ; � d � = YR��        n � X 5 
 [����         { �9  � K a|��      %   �9 �  � D \���        � �  2 
 ]����        �  �8  2 
 ^����        �  ��  2 
 _����     �  �   �  � H `�����Desk - Setting up INIs...    Here you can choose...                   	   Source user:                                              Copy Exit More... CANVAS  ���X0G  �XOpen�/* Fill the drop-down list */
do ISD_i=1 to UsersContainer_items.0 by 1
	ISD_item = UsersContainer_Items.ISD_i
	ISD_Name = MultiDeskMain.UsersContainer.Item(ISD_item, 2)
	if ISD_Name = NewUserName then
		nop
	else
		SourceUserCBox.Add(ISD_name, 'A', ISD_item)
end

/* Let's select the first item, so that the box isn't empty */
SourceUserCBox.Select(1)

/* Fix a visual glitch */
C609.Bottom()
Init�/* Center the window on the screen */
parse value IniSetupDlg.Position() with x y cx cy
parse value ScreenSize() with dx dy
IniSetupDlg.Position((dx - cx)%2, (dy - cy)%2, cx, cy)

/* Set container's colors */
GroupsContainer.Color('-', '#15')
GroupsContainer.Color('+', '#7')

IniSetupDlg.Show()

/* Be sure the container is on top */
C608.Top()
GroupsContainer.Top()
C609.Bottom()
�_ClickR/* Open up the INI Copy Dialog in modal mode */
action = ModalFor('IniCopyDlg')
�^Click"IniSetupDlg.Close()

return ''
�]Click�/* Get all selected entries in the container */
SUICB_SelItem = GroupsContainer.Select()	/* first selected item */

/* Can I access the groups.csv file? */
rc = Stream('Groups.csv', 'C', 'Query Exists')
if rc = '' then do
	MsgText = 'I cannot find the file Groups.csv.'
	MsgTitle = 'Copy INI entries'
	action = MyMessageBox(MsgText||';'||MsgTitle)
	signal D600__I606__Click		/* SUI_ExitBtn.Click() */
end

/* Read in all file lines from the Groups file */
linein('Groups.csv', 1, 0)
do SUICB_j=1 by 1 until Lines('Groups.csv') = 0
	GrpLines.SUICB_j = linein('Groups.csv')
end
GrpLines.0 = SUICB_j

ICG_RC = 0
do forever
	SUICB_Group = GroupsContainer.Item(SUICB_SelItem, 2)
	do SUICB_i = 1 to GrpLines.0 by 1
		Parse Value GrpLines.SUICB_i With GrpName ';' SUICB_Rest
		if GrpName = SUICB_Group then
			ICG_RC = ICG_RC | IniCopyGrp(SourceUserCBox.Item(SourceUserCBox.Select()) || ';;' || GrpLines.SUICB_i)
	end

	SUICB_SelItem = GroupsContainer.Select(SUICB_SelItem, 'N')
	if SUICB_SelItem = 0 then leave		/* no more selected items */
end /* do forever */

/* Also copy the "Necessary" group, which is necessary :-)) */
do SUICB_i = 1 to GrpLines.0 by 1
	Parse Value GrpLines.SUICB_i With GrpName ';' SUICB_Rest
	if GrpName = 'Necessary' then
		ICG_RC = ICG_RC | IniCopyGrp(SourceUserCBox.Item(SourceUserCBox.Select()) || ';;' || GrpLines.SUICB_i)
end

if ICG_RC \= 0 then do
	MsgTitle = 'Error'
	MsgText = 'At least an error was detected while copying INI entries.'
	MsgText = MsgText || CRLF || 'Please take a look at the log window.'
	action = MyMessageBox(MsgText||';'||MsgTitle)
end; else do
	MsgTitle = 'Copy INI entries'
	MsgText = 'Finished copying.'
	action = MyMessageBox(MsgText||';'||MsgTitle)
end
�\Init�/* Set container in DETAIL view, with WarpSans font */
GroupsContainer.View('D')
GroupsContainer.Font('9.WarpSans')

/* Set up the container format */
GC_format.0 = 3
GC_format.1 = '=_!'
GC_format.2 = '_!'
GC_format.3 = '_!'
GroupsContainer.SetStem(GC_format., 'F')

/* Set up column titles */
GC_title.0 = 3
GC_title.1 = 'Icon'
GC_title.2 = 'Group'
GC_title.3 = 'Description'
GroupsContainer.SetStem(GC_title., 0)

/* Create container items */
GC_icon = 'MDICONS:#13'

GC_Desc = 'Copies printers, and printer and spooler settings.'
AddGroup('Printers'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies window and dialog font settings, color and sound schemes, national settings, etc.'
AddGroup('Preferences'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies display driver and display resolution settings.'
AddGroup('Display'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies installed font settings.'
AddGroup('Fonts'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies some Netscape-related settings.'
AddGroup('Netscape'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies some java-related settings.'
AddGroup('Java'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies classes and class replacements.'
AddGroup('Classes'||';'||GC_icon||';'||GC_Desc)

GC_Desc = 'Copies XWorkplace-related settings (you need the above group also).'
AddGroup('XWorkplace'||';'||GC_icon||';'||GC_Desc)
�YInit�Text601 = 'Here you are presented with some groups of customizations, '
Text601 = Text601||'that you may choose to copy from another user''s INI files.'||CRLF||CRLF
Text601 = Text601||'1. Put the name of the source user in the edit field below'||CRLF
Text601 = Text601||'2. Select the groups you want to copy from that user'||CRLF
Text601 = Text601||'3. Click on the "Copy" button to begin copying.'||CRLF
Text601 = Text601||'4. Go to (1), or click on the "Exit" button when you''re done.'
C601.Text(Text601)
�� ��0d  d  �  ��    
      X  h H � ���p      
 � t � �  �W��        � � � B 
 �����         � �F ^ � 1 ����         � �  � m ����        �  �� F   ����    
 
    ��  	  �����          ��  � m ���        8 �  Y 	 �����        M ��  \ 	 �����        _  �  
 �����Copy custom INI entries    Be sure you know what you're doing before doing your own changes to the destination INI file. With this interface you may overwrite settings that have already been made by the administration program, or even ruin your desktop. 4                  	         9.WarpSans          Source user:           9.WarpSans                    9.WarpSans          >>          9.WarpSans          ICONBUTTON mdctrls:#7           9.WarpSans          Source user INI keys New user INI keys Done ����0w  ��Open�/* Fill the drop-down list */
do ICD_i=1 to UsersContainer_items.0 by 1
  ICD_item = UsersContainer_Items.ICD_i
  ICD_Name = MultiDeskMain.UsersContainer.Item(ICD_item, 2)
  if ICD_Name = NewUserName then
      nop
  else
      SourceUserBox.Add(ICD_name, 'A', ICD_item)
end

/* Fix a visual glitch */
SourceUserBox.Bottom()

/* Get new user system and user INI files for local dialog use */
do ICD_i = 1 to UsersContainer_items.0
    ICD_Name = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICD_i)
    if ICD_Name = NewUserName then do
        ICD_NU_UIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICD_i, 5)
        ICD_NU_SIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.ICD_i, 6)
        Leave
    end
end
Init�/* Center the window on the screen */
parse value IniCopyDlg.Position() with x y cx cy
parse value ScreenSize() with dx dy
IniCopyDlg.Position((dx - cx)%2, (dy - cy)%2, cx, cy)

IniCopyDlg.Show()
��Click�
/* Remove all selected DestINIList entries */
/*******************************************/

REB_SelIdx = DestINIList.Select()

/* Apply FastINI to INIs */
FastIniStart(ICD_NU_UIni, 'REB_HNUUIni')
FastIniStart(ICD_NU_SIni, 'REB_HNUSIni')

REB_Error = 0
do while REB_SelIdx \= 0
    if DestIniList.Item(REB_SelIdx, 'D') = 'U' then
        REB_NUIni = ICD_NU_UIni
    else
        REB_NUIni = ICD_NU_SIni

    REB_IniApp = DestINIList.Item(REB_SelIdx, 'V')
    if SysIni(REB_NUIni, REB_IniApp, 'DELETE:') = '' then
        say 'Removed application ' || REB_IniApp
    else do
        say 'Error removing application ' || REB_IniApp
        REB_Error = 1
    end

    REB_SelIdx = DestINIList.Select(REB_SelIdx, 'N')
end

if REB_Error = 1 then do
    MsgText = 'At least one error occurred removing custom INI keys.'
    MsgTitle = 'Error'
    action = MyMessageBox(MsgText||';'||MsgTitle)
end; else
    say 'Done removing custom INI keys.'

/* Now refresh the destination INI listbox */
DestINIList.Delete()

SysIni(ICD_NU_UIni, 'All:', 'REB_Apps.')
do REB_i = 1 to REB_Apps.0
    DestINIList.Add(REB_Apps.REB_i, 'A', 'U')
end

SysIni(ICD_NU_SIni, 'All:', 'REB_Apps.')
do REB_i = 1 to REB_Apps.0
    DestINIList.Add(REB_Apps.REB_i, 'A', 'S')
end

/* End FastINI operations */
FastIniEnd(REB_HNUUIni)
FastIniEnd(REB_HNUSIni)
��ClickBsay '-------------------------'
IniCopyDlg.Close()

return ''
��Click�/* Copy all selected SourceINIList entries */
/*******************************************/

CEB_SelIdx = SourceINIList.Select()

/* Apply FastINI to all four INIs */
FastIniStart(ICD_UIni, 'CEB_HUIni')
FastIniStart(ICD_SIni, 'CEB_HSIni')
FastIniStart(ICD_NU_UIni, 'CEB_HNUUIni')
FastIniStart(ICD_NU_SIni, 'CEB_HNUSIni')

do while CEB_SelIdx \= 0
    if SourceIniList.Item(CEB_SelIdx, 'D') = 'U' then do
        CEB_Ini = ICD_UIni
        CEB_NUIni = ICD_NU_UIni
    end; else do
        CEB_Ini = ICD_SIni
        CEB_NUIni = ICD_NU_SIni
    end

    CEB_IniApp = SourceINIList.Item(CEB_SelIdx, 'V')

    /* Query all keys for selected app */
    if SysIni(CEB_Ini, CEB_IniApp, 'All:', 'CEB_Keys') \= '' then do
        MsgText = 'Could not query key list for the application ' || CEB_IniApp
        MsgTitle = 'Error'
        action = MyMessageBox(MsgText||';'||MsgTitle)
        iterate /* go to the next selected app */
    end

    CEB_Error = 0
    do CEB_i = 1 to CEB_Keys.0
        CEB_TmpVal = c2x(SysIni(CEB_Ini, CEB_IniApp, CEB_Keys.CEB_i))
        if SysIni(CEB_NUIni, CEB_IniApp, CEB_Keys.CEB_i, x2c(CEB_TmpVal)) \= '' then
            CEB_Error = 1
    end

    if CEB_Error = 1 then do
        MsgText = 'At least one error occurred while copying keys'
        MsgText = MsgText || ' for the application ' || CEB_IniApp
        MsgTitle = 'Error'
        action = MyMessageBox(MsgText||';'||MsgTitle)
    end; else
        say 'Application ' || CEB_IniApp || ' successfully copied.'

    CEB_SelIdx = SourceINIList.Select(CEB_SelIdx, 'N')
end

say 'Done copying custom INI keys.'

/* Now refresh the destination INI listbox */
DestINIList.Delete()

SysIni(ICD_NU_UIni, 'All:', 'CEB_Apps.')
do CEB_i = 1 to CEB_Apps.0
    DestINIList.Add(CEB_Apps.CEB_i, 'A', 'U')
end

SysIni(ICD_NU_SIni, 'All:', 'CEB_Apps.')
do CEB_i = 1 to CEB_Apps.0
    DestINIList.Add(CEB_Apps.CEB_i, 'A', 'S')
end

/* End FastINI operations */
FastIniEnd(CEB_HUIni)
FastIniEnd(CEB_HSIni)
FastIniEnd(CEB_HNUUIni)
FastIniEnd(CEB_HNUSIni)

/* Deselect items in the source listbox */
do CEB_i = 1 to SourceINIList.Item()
    SourceINIList.Select(CEB_i, 'U')
end
��Enter�/* Fill the source listbox on selecting a source user */
SUB_Source = SourceUserBox.Item(SourceUserBox.Select(), 'V')

/* Get source user's User and System ini files */
do SUB_i = 1 to UsersContainer_items.0
    SUB_Name = MultiDeskMain.UsersContainer.Item(UsersContainer_items.SUB_i)
    if SUB_Name = SUB_Source then do
        ICD_UIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.SUB_i, 5)
        ICD_SIni = MultiDeskMain.UsersContainer.Item(UsersContainer_items.SUB_i, 6)
        Leave
    end
end

/* First delete all ListBox items, otherwise we get duplicates */
IniCopyDlg.SourceINIList.Delete()
IniCopyDlg.DestINIList.Delete()

/* Apply FastINI to all four INIs */
FastIniStart(ICD_UIni, 'SUB_HUIni')
FastIniStart(ICD_SIni, 'SUB_HSIni')
FastIniStart(ICD_NU_UIni, 'SUB_HNUUIni')
FastIniStart(ICD_NU_SIni, 'SUB_HNUSIni')

/* Read all apps from both source INIs */
SysIni(ICD_UIni, 'All:', 'SUB_Apps.')
do SUB_i = 1 to SUB_Apps.0
    SourceINIList.Add(SUB_Apps.SUB_i, 'A', 'U')
end

SysIni(ICD_SIni, 'All:', 'SUB_Apps.')
do SUB_i = 1 to SUB_Apps.0
    SourceINIList.Add(SUB_Apps.SUB_i, 'A', 'S')
end

/* Read all apps from both destination INIs */
SysIni(ICD_NU_UIni, 'All:', 'SUB_Apps.')
do SUB_i = 1 to SUB_Apps.0
    DestINIList.Add(SUB_Apps.SUB_i, 'A', 'U')
end

SysIni(ICD_NU_SIni, 'All:', 'SUB_Apps.')
do SUB_i = 1 to SUB_Apps.0
    DestINIList.Add(SUB_Apps.SUB_i, 'A', 'S')
end

/* End FastINI operations */
FastIniEnd(SUB_HUIni)
FastIniEnd(SUB_HSIni)
FastIniEnd(SUB_HNUUIni)
FastIniEnd(SUB_HNUSIni)
�