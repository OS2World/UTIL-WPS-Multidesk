� �� 0�   d   SAVEFLDR_DIALOGe  SAVEFLDR_LISTf  SAVEFLDR_GENERATEg  SAVEFLDR_SELECT_ALLh  SAVEFLDR_SAVEi  SAVEFLDR_EXITj  SAVEFLDR_HELPk  SAVEFLDR_VIEWLOG,  WAIT_DIALOG- 	WAIT_TEXT. WAIT_PLEASE�  
LOG_DIALOG� LOG_LIST��� 0S�  ProcRealObject�Procrealobj:
obj = C2X(Substr(Arg(1),2,1)||Substr(Arg(1),1,1))
save_obj = Substr(Arg(1),2,1)||Substr(Arg(1),1,1)
If substr(obj,1,1) = '0' Then obj = Substr(obj,2)
If substr(obj,1,1) = '0' Then obj = Substr(obj,2)
If substr(obj,1,1) = '0' Then obj = Substr(obj,2)
objdata = SysIni(inifile,'PM_Abstract:Objects',obj)
iconfile = ''
icondata = ''
icondata= SysIni(inifile,'PM_Abstract:Icons',obj)
If Length(icondata) > 7 Then Do
  iconfile = 'F'||Right(obj,4,'0')||'.ICO'
  Call SysFileDelete iconfile
  Call Charout iconfile, icondata
  Call Stream iconfile, 'C', 'CLOSE'
  jtemp= pkgfiles.0 + 1
  pkgfiles.jtemp = iconfile
  pkgfiles.0 = jtemp
End
If Pos('WPAbstract',objdata) > 0 Then Do
  objtype = Substr(objdata,5,Pos('00'x,Substr(objdata,5))-1)
  If objtype <> 'WPProgram' & objtype <> 'WPShadow' Then Return 1
  Call Parseobj
  If pgm = '' Then Do
    xobj = Right(C2X(Substr(inode,2,1)||Substr(inode,1,1)),4,'0')
    If substr(xobj,1,1) = '0' Then xobj = Substr(xobj,2)
    If substr(xobj,1,1) = '0' Then xobj = Substr(xobj,2)
    If substr(xobj,1,1) = '0' Then xobj = Substr(xobj,2)
    xobjdata = SysIni(inifile,'PM_Abstract:Objects',xobj)
    If xobjdata <> 'ERROR:' Then Do
      If Pos('WPAbstract',xobjdata) > 0 Then Do
        objdata = xobjdata
        Call Parseobj
        parameters = ''
        settings = ''
        If objid <> '' Then pgm = objid
        iconfile = ''
      End
    End
  End
  setup = ''
  If objtype = 'WPShadow' Then Do
    If pgm <> '' Then setup=setup||'SHADOWID='||pgm||';'
    Else Return 1
    objid = ''
  End
  Else Do
    If pgm <> '' Then setup=setup||'EXENAME='||pgm||';'
  End
  If parameters <> '' Then setup=setup||'PARAMETERS='parameters||';'
  If settings <> '' Then setup=setup||settings
  If objid <> '' Then setup=setup||'OBJECTID='||objid||';'
  If iconfile <> '' Then setup = setup||'ICONFILE="||Directory()||"\'||iconfile||';'
  k = out.fldername.0 + 1
  cmd.fldername.k = '  Call SysCreateObject "'objtype'", "'Translate(Translate(Substr(objdata,xpos+17,title_l),'^','0a'x),' ','0d'x)'", "'flderid'", "'setup'", "F"'
  out.fldername.k = '   ' obj objtype": Title="Translate(Translate(Substr(objdata,xpos+17,title_l),'^','0a'x),' ','0d'x) setup
  out.fldername.0 = k
  cmd.fldername.0 = k
  iconfile = ''
End
Return 0Processlaunch�Processlaunch:
fldername = '<WP_LAUNCHPAD>'
Do i = 1 to locs.0
  If Word(locs.i,2) = '<WP_LAUNCHPAD>' Then Do
    Call Plaunch Word(locs.i,1)
    Return 0
  End
End
If debug Then Do
  Call Lineout dumpfile, "WPLauchpad: Not found."
End
Return 0

Plaunch:
obj = Arg(1)
If substr(obj,1,1) = '0' Then obj = Substr(obj,2)
If substr(obj,1,1) = '0' Then obj = Substr(obj,2)
If substr(obj,1,1) = '0' Then obj = Substr(obj,2)
objdata = SysIni(inifile,'PM_Abstract:Objects',obj)
If debug Then Do
  Call Lineout dumpfile, "WPLauchPad:"obj
  Call Hexdump objdata, dumpfile
End
lname = Substr(objdata,Pos('WPAbstract',objdata))
lnamel = C2D(Substr(lname,16,1))
lname = Substr(lname,18,lnamel-1)
launchpad = "Call SysCreateObject 'WPLaunchPad', '"||lname||"', '<WP_DESKTOP>',"
lsetup = 'OBJECTID=<WP_LAUNCHPAD>'
drawer = 0
udrawer = 0
ldataposl = 20
ldata = Substr(objdata,Pos('WPLaunchPad',objdata,8)+ldataposl)
Do Forever
  drawer = drawer + 1
  udrawer = (drawer - 1)/2
  xdrawer = Translate(D2C(drawer*256,2),'00'x,' ')
  If Substr(ldata,1,4) <> '00000400'x Then Leave
  If Substr(ldata,5,2) <> xdrawer Then Iterate
  ldataposl = C2D(Substr(ldata,7,1))
  Do i = 1 to ldataposl by 4
    oid = C2X(Substr(ldata,i+9,1)||Substr(ldata,i+8,1))
    If substr(oid,1,1) = '0' Then oid = Substr(oid,2)
    If substr(oid,1,1) = '0' Then oid = Substr(oid,2)
    If substr(oid,1,1) = '0' Then oid = Substr(oid,2)
    shadowdata = SysIni(inifile,'PM_Abstract:Objects',oid)
    shadowid = Substr(shadowdata,Pos('WPShadow',shadowdata,8)+15,2)
    shadowid = C2X(Substr(shadowid,2,1)||Substr(shadowid,1,1))
    foundit = 0
    Do j = 1 to locs.0
      If Word(locs.j,1) = shadowid Then Do
        If i = 1 Then lsetup = lsetup||';DRAWEROBJECTS='||udrawer
        lsetup = lsetup||','||Word(locs.j,2)
        foundit = 1
        Leave
      End
    End
    If foundit = 0 Then Do
      If debug Then Do
        Call Lineout dumpfile, "WPShadow:"oid
        Call Hexdump shadowdata, dumpfile
      End
      If i = 1 Then lsetup = lsetup||';DRAWEROBJECTS='||udrawer
      inode = Substr(shadowdata,Pos('WPShadow',shadowdata,8)+15,2)
      pgm = Getpath(inode)
      If pgm = '' Then Do
        Call Procrealobj inode
        If result <> 0 Then objid = '<DUMMY>'
        pgm = objid
      End
      lsetup = lsetup||','pgm
    End
  End
  ldata = Substr(ldata,ldataposl+17)
End
launchpad = launchpad lsetup
If debug Then Call Lineout dumpfile, launchpad
Return 0Wait�/***********************************************************/
/* Wait:                                                   */
/*                                                         */
/* Function: You can use this function to inform the user  */
/*          of some lengthy processing. You may supply one */
/*          parameter, the message that should appear.     */
/*          If you call this function while the WAIT panel */
/*          is already active only the message will change.*/
/*                                                         */
/* Calling conventions:                                    */
/*          Call Wait                                      */
/*               ... the default text "Processing..." will */
/*                   be shown in the WAIT panel.           */
/*          Call Wait "message text"                       */
/*               ... the "message text" will be shown in   */
/*                   the WAIT panel.                       */
/*          Call Wait "message text", "title"              */
/*               ... the "message text" will be shown in   */
/*                   the WAIT panel, which has the title   */
/*                   set to the parameter 2.               */
/*                                                         */
/* Note 1:  To remove the wait panel use the "Unwait"      */
/*          function below.                                */
/* Note 2:  This function may not be called from the       */
/*          global "Init()" routine.                       */
/***********************************************************/
Wait:
_wait_message = Arg(1)
If _wait_message = '' Then _wait_message = "Processing..."
If _wait_active = 0 Then Do
  _wait_title = Arg(2)
  If _wait_title = '' Then _wait_title = TextFor(Dialog())
  Call WAIT_DIALOG.Open
  Call WAIT_DIALOG.Text _wait_title
End

PARSE VALUE WAIT_DIALOG.Position() WITH _x _y _cx _cy
_max_char = _cx % 10
If Length(_wait_message) > _max_char Then _cx = _cx + (Length(_wait_message) - _max_char) * 10
PARSE VALUE ScreenSize() WITH _dx _dy
CALL WAIT_DIALOG.Position (_dx - _cx)%2, (_dy - _cy)%2, _cx, _cy
If Length(_wait_message) > _max_char Then Do
  Parse Value FrameFor(Dialog()) With _left _bottom _right _top
  Parse Value WAIT_DIALOG.WAIT_TEXT.Position() With _x _y _cx _cy
  Parse Value WAIT_DIALOG.Position() With . . _cx .
  _cx = _cx - _left - _right - 12
  CALL WAIT_DIALOG.WAIT_TEXT.Position _left+6, _y, _cx, _cy
  Parse Value WAIT_DIALOG.WAIT_PLEASE.Position() With _x _y . _cy
  CALL WAIT_DIALOG.WAIT_PLEASE.Position _left+6, _y, _cx, _cy
End

Call WAIT_DIALOG.WAIT_TEXT.Text _wait_message
_wait_active = 1
Call WAIT_DIALOG.Show
Return 0

/***********************************************************/
/* Unwait:                                                 */
/*          Call this function to remove the "Wait" panel. */
/*          This is usually done when the lengthy          */
/*          processing has ended. This function does not   */
/*          need any parameters.                           */
/***********************************************************/
Unwait:
If _wait_active = 1 Then Call WAIT_DIALOG.Close
_wait_active = 0
Return 0Standard_Routines�3/***********************************************************/
/* The following functions are common in all applications. */
/*                                                         */
/* Position_Dialog:                                        */
/*         Called during "Open" Processing for each dialog.*/
/* Move_Size:                                              */
/*         Called from the "Any" event of each dialog.     */
/* Adjust_controls:                                        */
/*         Called from "Position_Dialog" and "Move_Size".  */
/* Syntax:                                                 */
/*         Handles syntax errors.                          */
/* Get_source:                                             */
/*         Called from the "Syntax" error exit.            */
/* Parse_src:                                              */
/*         Called from the "Syntax" error exit.            */
/***********************************************************/

/*******************************************************/
/* Position the dialog. This function should be called */
/* from the "Open" event of each dialog.               */
/*******************************************************/
Position_Dialog:
_dialog_name = Dialog()
_oldsize._dialog_name = Position()
If save_new_position = 1 Then Do
  Parse Var _dialog_name _posfile '_' .
  _posfile = Strip(Substr(_posfile,1,8))||'.POS'
  If Stream(_posfile, 'C', 'QUERY EXISTS') <> '' Then Do
    _newsize = Linein(_posfile)
    Call Stream _posfile, 'C', 'CLOSE'
    If _newsize <> _oldsize._dialog_name & Word(_newsize,1) > 0 & Word(_newsize,2) > 0 & Word(_newsize,3) > 50 & Word(_newsize,4) > 50 Then Do
      Call Position Word(_newsize,1), Word(_newsize,2), Word(_newsize,3), Word(_newsize,4)
    End
  End
End
Return 0

/***********************************************/
/* Called from the "Any" event of each dialog. */
/***********************************************/
Move_Size:
_event = Event()
If _event = 'Size' | _event = 'Move' Then Do
  _newsize = Position()
  If Word(_newsize,1) = -32000 | Word(_newsize,2) = -32000 Then Return 0
  If Word(_newsize,1) < 0 & Word(_newsize,2) < 0 Then _newsize = Subword(_newsize,1,2) ScreenSize()
  Call Adjust_controls
  _dialog_name = Dialog()
  _oldsize._dialog_name = _newsize
  If save_new_position = 1 Then Do
    Parse Var _dialog_name _posfile '_' .
    _posfile = Strip(Substr(_posfile,1,8))||'.POS'
    Call SysFileDelete _posfile
    Call Lineout _posfile, _oldsize._dialog_name
    Call Stream _posfile, 'C', 'CLOSE'
  End
End
Return 0

/*************************************************/
/* Adjust all controls to fit the new panel size */
/*************************************************/
Adjust_controls:
_dialog_name = Dialog()
_xadjust = Word(_newsize,3) / Word(_oldsize._dialog_name,3)
_yadjust = Word(_newsize,4) / Word(_oldsize._dialog_name,4)
If _xadjust = 1 & _yadjust = 1 Then Return 0
Call Controls _namesstem
Call Hide
Do i = 2 to _namesstem.0
  Parse Value PositionFor(_namesstem.1, _namesstem.i) With _cx _cy _cdx _cdy
  Call PositionFor _namesstem.1, _namesstem.i, Format(_cx*_xadjust,4,0), Format(_cy*_yadjust,4,0), Format(_cdx*_xadjust,4,0), Format(_cdy*_yadjust,4,0)
End
Call Show
Return 0

/***************************/
/* Handle SIGNAL ON SYNTAX */
/***************************/
Syntax:
  If symbol('RC') <> 'LIT' Then __error_rc = rc
  Else __error_rc = 0
  __save_sigl = sigl
  Call Telluser 'Rexx error on line' __save_sigl', RC =' __error_rc  errortext(__error_rc),1
  __src_line = Get_source(__save_sigl)
  Call Telluser 'Source line is: "'||__src_line||'"',1
  __src_parse = Parse_src(__src_line)
  __src_line = ''
  Do Until __src_parse = ''
    Parse Var __src_parse  __src_test  '00'x  __src_parse
    if symbol(__src_test) = 'BAD' then
         __src_line = __src_line || value('__src_test')
    else __src_line = __src_line || value(__src_test)
  end
  Call Telluser 'Source line interpreted as: "' || __src_line || '"',1
  Exit 99

/*********************************************************************
**  Get a complete line of source code
**   - Gets all source even if continued
**     (assumes continued lines end with a comma)
**   - Deletes simple comments
*********************************************************************/
Get_source: procedure
  parse arg src_line_no
  src_line = ''
  string = sourceline(src_line_no)
  cont = 0
  do until cont = 0          /* get rest if line continued */
    do while string <> ''    /* delete comments            */
      parse var string  src '/*' trash '*/' string
      src_line = src_line || src
    end
    src_line = strip(src_line)
    if substr(src_line,length(src_line)) = ',' then do
      src_line = delstr(src_line,length(src_line))
      cont = cont + 1
      string = sourceline(src_line_no + cont)
    end
    else cont = 0
  end
  return src_line

/*********************************************************************
**  parses line of source code
**   - returns source delimited by '00'x
**   - can be converted to an external function
*********************************************************************/
Parse_src: procedure
  parse arg src_line
  quote_list = '''"'
  delim_list = ' +-\/%*|�&=^><,;:()!'

  src_parse = ''
  do while src_line <> ''
    first = verify(src_line,quote_list,'M')
    if first = 1 then do
      quote = substr(src_line,first,1)
      last = pos(quote,src_line,first+1)
      if last = 0 then last = length(src_line)
      next.1 = substr(src_line,last+1,1)
      next.2 = substr(src_line,last+2,1)
      next.1 = translate(next.1)
      string = substr(src_line,first,last)
      if next.1 = 'X' | next.1 = 'B' then do
         if verify(next.2,delim_list||quote_list,'M') <> 0 then do
           last = last+1
           string = substr(src_line,first,last)
         end
      end
    end
    else do
      if first = 0 then first = length(src_line)+1
      string = substr(src_line,1,first-1)
      x = verify(string,delim_list,'M')
      y = verify(string,delim_list)
      if x = 0 then x = length(string)+1
      if y = 0 then y = length(string)+1
      last = max(x,y) - 1
      if substr(string,last+1,1) = '(' then last=last+1
      string = substr(string,1,last)
    end
    src_parse = src_parse || '00'x || string
    src_line = substr(src_line,last+1)
  end
  return  src_parseCheckquotes�Checkquotes:
If Pos('ICONFILE="||',outdata) = 0 Then Do
  noutdata = ''
  qcnt = 0
  lq = LastPos('"',outdata)
  Do i = 1 to Length(outdata)
    If Substr(outdata,i,1) <> '"' Then Do
      noutdata = noutdata||Substr(outdata,i,1)
      Iterate
    End
    If i = lq Then Do
      noutdata = noutdata||Substr(outdata,i)
      Leave
    End
    qcnt = qcnt + 1
    If qcnt = 1 Then Do
      noutdata = noutdata||'"'
      Iterate
    End
    noutdata = noutdata||'"'||'"'
  End
  outdata = noutdata
End
If Pos('OBJECTID=<USER_',outdata) > 0 Then Do
  If Pos(tdrive||'\',outdata) > 0 Then Do
    tpos = Pos(tdrive||'\',outdata)
    outdata = Substr(outdata,1,tpos-1)||'"||tdrive||"'||Substr(outdata,tpos+2)
  End
End
Return 0Parsefolder�%Parsefolder:
  iconfile = ''
  icondata = ''
  settings = ''
  iconview = ''
  treeview = ''
  detailsview = ''
  iconfont = ''
  treefont = ''
  detailsfont = ''
  fldername = Arg(1)
  xrc = SavGetEA(fldername, '.ICON', 'icondata')
  If Length(icondata) > 5 Then Do
    iconfile = 'F'||Right(key,4,'0')||'.ICO'
    Call SysFileDelete iconfile
    Call Charout iconfile, Substr(icondata,5)
    Call Stream iconfile, 'C', 'CLOSE'
    j = pkgfiles.0 + 1
    pkgfiles.j = iconfile
    pkgfiles.0 = j
  End
  xrc = SavGetEA(fldername, '.CLASSINFO', 'classinfo')
  If debug Then Call Lineout dumpfile ,"CLASSINFO:" fldername "("flderid")"
  If debug Then Call Hexdump classinfo, dumpfile

  If Substr(classinfo,13,8) = 'WPFolder' then Do
    offset = Pos('730B4400'x,classinfo)
    If offset > 0 Then Do
      views = Substr(classinfo,offset+4,1)
      If views = '01'x Then iconview = 'NONFLOWED,INVISIBLE'
      If views = '02'x Then iconview = 'NONFLOWED,NORMAL'
/*    If views = '04'x Then iconview = 'NONGRID,NORMAL' */
      If views = '11'x Then iconview = 'FLOWED,INVISIBLE'
      If views = '12'x Then iconview = 'FLOWED,NORMAL'
      If views = '22'x Then iconview = 'NONFLOWED,MINI'
      If views = '24'x Then iconview = 'NONGRID,MINI'
      If views = '32'x Then iconview = 'FLOWED,MINI'
      views = Substr(classinfo,offset+8,3)
      If views = '444010'x Then treeview = 'NOLINES,NORMAL'
      If views = '440010'x Then treeview = 'NOLINES,NORMAL'
      If views = '644010'x Then treeview = 'NOLINES,MINI'
      If views = '640010'x Then treeview = 'NOLINES,MINI'
      If views = '414010'x Then treeview = 'NOLINES,INVISIBLE'
      If views = '410010'x Then treeview = 'NOLINES,INVISIBLE'
      If views = '644050'x Then treeview = 'LINES,MINI'
      If views = '640050'x Then treeview = 'LINES,MINI'
      If views = '414050'x Then treeview = 'LINES,INVISIBLE'
      If views = '410050'x Then treeview = 'LINES,INVISIBLE'
    End

    offset = Pos('0400740B'x,classinfo)
    If offset > 0 Then Do
      offset = offset + 6
      If Substr(classinfo,offset,1) = '01'x Then Do
        iconfont = Substr(classinfo,offset+2)
        Parse Var iconfont iconfont '00'x .
        offset = offset + Length(iconfont) + 3
      End
      If Substr(classinfo,offset,1) = '02'x Then Do
        iconfont = Substr(classinfo,offset+2)
        Parse Var iconfont iconfont '00'x .
        offset = offset + Length(iconfont) + 3
      End
      If Substr(classinfo,offset,1) = '03'x Then Do
        treefont = Substr(classinfo,offset+2)
        Parse Var treefont treefont '00'x .
        offset = offset + Length(treefont) + 3
      End
      If Substr(classinfo,offset,1) = '05'x Then Do
        detailsfont = Substr(classinfo,offset+2)
        Parse Var detailsfont detailsfont '00'x .
        offset = offset + Length(detailsfont) + 3
      End
    End
/*
    offset = Pos('0400710B'x,classinfo)
    If offset > 0 Then Do
      If Substr(classinfo,offset+10,1) = '01'x Then settings = settings||'SORT=ALWAYS;'
    End
*/
  End

  If Pos('00'x||'WPObject',classinfo) > 0 Then Do
    wpobject = Substr(classinfo,Pos('00'x||'WPObject',classinfo)+1)
    If Bitand(Substr(wpobject,28,1),'20'x) <> '00'x Then settings = Strip(settings||'TEMPLATE=YES;')
    If Substr(wpobject,32,1) = '01'x Then settings = Strip(settings||'MINWIN=HIDE;')
    If Substr(wpobject,32,1) = '02'x Then settings = Strip(settings||'MINWIN=VIEWER;')
    If Substr(wpobject,32,1) = '03'x Then settings = Strip(settings||'MINWIN=DESKTOP;')
    If Substr(wpobject,36,1) = '01'x Then settings = Strip(settings||'CCVIEW=YES;')
    If Substr(wpobject,36,1) = '02'x Then settings = Strip(settings||'CCVIEW=NO;')
  End

  If flderid = '' Then flderid = '<USER_'||Translate(fldername,'____'," ^'"||'"')||'>'
  If iconview <> '' Then settings = settings||'ICONVIEW='||iconview||';'
  If treeview <> '' Then settings = settings||'TREEVIEW='||treeview||';'
  If iconfont <> '' Then settings = settings||'ICONFONT='||iconfont||';'
  If treefont <> '' Then settings = settings||'TREEFONT='||treefont||';'
  If detailsfont <> '' Then settings = settings||'DETAILSFONT='||detailsfont||';'
  If iconfile <> '' Then settings = settings||'ICONFILE="||Directory()||"\'||iconfile||';'
  xflderid = '"OBJECTID='flderid||';'||settings||'"'
  back='<WP_DESKTOP>'
  Do j = 1 to length(fldername)-1
    If Substr(fldername,length(fldername)-j,1) = '\' then Do
      back=Substr(fldername,1,length(fldername)-j-1)
      If Translate(back) = Translate(desktop) Then back = '<WP_DESKTOP>'
      Leave
    End
  End
  cmd.fldername = 'Call SysCreateObject "WPFolder", "'foldername'", "'back'", 'xflderid', "F"'
  out.fldername = C2X(inode) "Folder" fldername flderid 'Title='foldername
Return 0OUTPUT_SAVE�OUTPUT_SAVE:
If oflag = 0 | cmdfile = '' Then Do
  cmdfile = Translate(FilePrompt('*.CMD','Output file name','Save'))
  If cmdfile = '' Then Return 0
  If Stream(cmdfile, 'C', 'QUERY EXISTS') <> '' Then Do
    xrc = RxMessageBox("The output file" cmdfile "already exists, do you want to overwrite it?", "SaveFldr", "YESNO", "QUERY")
    If xrc <> 6 Then Return 0
  End
End
cmdfile = Translate(Strip(cmdfile))
Call SysFileDelete cmdfile
Call Wait "Creating output files."
Call Make_output
done = 0
If exitswi = 1 Then Exit 0
/************************************/
/* Clean the output data structures */
/************************************/
out. = 0
cmd. = 0
Do i = 1 to desk.0
  f = Translate(desk.i)
  out.f = f
  cmd.f = f
End
Call Unwait
Return 0Telluser�/*************************************************************/
/* Telluser:                                                 */
/*                                                           */
/* Function: Writes a message box with a single "OK" button. */
/*         This routine can be used for notification and     */
/*         error messages. It accepts two parameters, the    */
/*         message text, and a flag. If the flag is "0" or   */
/*         omitted, the message is just displayed, if it     */
/*         is "1", the message is logged in a file. The      */
/*         name of the file is the name of the dialog with   */
/*         the extension of ".LOG".                          */
/*                                                           */
/* Calling Conventions:                                      */
/*         Call Telluser "message_text"                      */
/*              ... displays the "message test" in a message */
/*                  box.                                     */
/*         Call Telluser "message_text", 1                   */
/*              ... displays the "message text" in a message */
/*                  box, and also writes the message, a time */
/*                  stamp, and the dialog name to a log file.*/
/*                                                           */
/* Note:    This function may not be called from the global  */
/*          "Init()" routine.                                */
/*************************************************************/
Telluser:
__tell_log = Arg(2)
If __tell_log = '' Then __tell_log = 0
If __tell_log <> '0' Then Do
  Parse Source . . __tell_logfile '.' .
  __tell_logfile = Strip(__tell_logfile||'.LOG')
  Call Lineout __tell_logfile, Date('U') Time() Dialog()||":" Arg(1)
  Call Lineout __tell_logfile, "     Last event:" Event()", control:" Control()", class:" Class()
  Call Stream __tell_logfile, 'C', 'CLOSE'
End
Call RxMessageBox Arg(1), Dialog(), 'OK', 'INFORMATION'
Return 0Init�/**************/
/* Initialize */
/**************/
Init:
Signal On Syntax
If RxFuncQuery('SysLoadFuncs') Then Do
  Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  Call SysLoadFuncs
End
_wait_active = 0
save_new_position = 1Parseobj�>/********************************/
/* Parse the object information */
/********************************/
/* Note: This routine tries to interpret the various undocumented */
/*       fields of the object data. This routine might not work   */
/*       future OS/2 releases.                                    */
Parseobj:
xpos = LastPos('WPAbstract',objdata)
title_l = C2D(Substr(objdata,xpos+15,1))-1
objid = Substr(objdata,Pos('WPObject',objdata))
If objid <> '' Then Do
  If lastpos('<',objid) > 0 & lastpos('>',objid) > 0 Then Do
    objid = Substr(objdata,Lastpos('<',objdata),Lastpos('>',objdata)-Lastpos('<',objdata)+1)
  End
  Else Do
    objid = ''
  End
End
pgm = ''
parameters = ''
settings = ''
If Substr(objdata,35,12) = 'WPProgramRef' Then Do
  If debug Then Do
    Call Lineout dumpfile, "WPProgramRef:"obj
    Call Hexdump objdata, dumpfile
  End
  saveobjdata = objdata
  objdata = Substr(objdata,1,Pos('WPAbstract',objdata))
  If Substr(objdata,48,4) = '04000B00'x Then Do
    pgmdatapos = Pos('04000B00'x,objdata,35)
    pgmdataposl = C2D(Substr(objdata,pgmdatapos+4,1))
    pgmtype = Substr(objdata,pgmdatapos+18,1)
    Select
/*
  Here is the information you are looking for.
  PROG_31_ENH               WIN-OS2 Full Screen Enhanced
  PROG_31_ENHSEAMLESSVDM    WIN-OS2 Separate Session Enhanced
  PROG_31_ENHSEAMLESSCOMMON WIN-OS2 Common Session Enhanced
*/
      When pgmtype = '00'x Then settings = 'PROGTYPE=PM;'
      When pgmtype = '01'x Then settings = 'PROGTYPE=FULLSCREEN;'
      When pgmtype = '02'x Then settings = 'PROGTYPE=WINDOWABLEVIO;'
      When pgmtype = '03'x Then settings = 'PROGTYPE=PM;'
      When pgmtype = '04'x Then settings = 'PROGTYPE=VDM;'
      When pgmtype = '07'x Then settings = 'PROGTYPE=WINDOWEDVDM;'
      When pgmtype = '0C'x Then settings = 'PROGTYPE=WIN;'
      When pgmtype = '0D'x Then settings = 'PROGTYPE=SEPARATEWIN;'
      When pgmtype = '0E'x Then settings = 'PROGTYPE=WINDOWEDWIN;'
      When pgmtype = '0F'x Then settings = 'PROGTYPE=SEPARATEWIN;'
      When pgmtype = '10'x Then settings = 'PROGTYPE=WINDOWEDWIN;'
      When pgmtype = '11'x Then settings = 'PROGTYPE=PROG_31_ENHSEAMLESSVDM;'
      When pgmtype = '12'x Then settings = 'PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;'
      When pgmtype = '13'x Then settings = 'PROGTYPE=PROG_31_ENH;'
      When pgmtype = '14'x Then settings = 'PROGTYPE=WIN;'
      Otherwise Do
        settings = 'PROGTYPE=????????'
      End
    End
    pgm = Getpath(Substr(objdata,pgmdatapos+6,2))
    If pgm = '' & Substr(objdata,pgmdatapos+6,2) = 'FFFF'x Then pgm = '*'
    startupdir = Getpath(Substr(objdata,pgmdatapos+10,2))
    If startupdir <> '' Then settings = Strip(settings||'STARTUPDIR='||startupdir||';')
    pgmdatapos = pgmdatapos+pgmdataposl
    If Pos('04000A00'x,objdata,pgmdatapos) > 0 Then Do
      pgmpos = Pos('04000A00'x,objdata,pgmdatapos)
      pgml = C2D(Substr(objdata,pgmpos+4,1))-5
      If Substr(objdata,pgmpos+6,2) = '0000'x Then Do
        xpgm = Substr(objdata,pgmpos+8,pgml)
        Parse Var xpgm xpgm '00'x .
        pgml = Length(xpgm)+9
        If pgm = '' Then pgm = xpgm
      End
      Else Do
        pgml = 6
      End
      If Substr(objdata,pgmpos+pgml,2) = '0100'x Then Do
        parameters = Substr(objdata,pgmpos+pgml+2)
        Parse Var parameters parameters '00'x .
        pgml = pgml+Length(parameters)+3
      End
      If Substr(objdata,pgmpos+pgml,2) = '0200'x Then Do
        ico = Substr(objdata,pgmpos+pgml+2)
        Parse Var ico ico '00'x .
        If ico <> '' Then settings = Strip(settings||'ICONFILE='||Strip(ico)||';')
      End
    End
    If Pos('04000600'x,objdata,pgmdatapos) > 0 Then Do
      setuppos = Pos('04000600'x,objdata,pgmdatapos)
      setupl = (C2D(Substr(objdata,setuppos+4,1))-2)+(C2D(Substr(objdata,setuppos+5,1))*256)
      xsettings = Translate(Substr(objdata,setuppos+6,setupl),';','00'x)||';'
      If xsettings <> '' Then Do
        ysettings = ''
        Do Forever
          Parse Var xsettings sl ';' xsettings
          If sl = '' Then Leave
          sl = 'SET' sl
          ysettings = ysettings||sl||';'
        End
        settings = Strip(settings||ysettings)
      End
    End
    openflags = Substr(objdata,Pos('04000700'x,objdata,pgmdatapos)+7,1)
    If Bitand(openflags,'04'x) <> '00'x Then settings = Strip(settings||'MINIMIZED=YES;')
    If Bitand(openflags,'80'x) <> '00'x Then settings = Strip(settings||'NOAUTOCLOSE=YES;')
    objdata = saveobjdata
    Call Setwpobject Substr(objdata,Pos('WPObject',objdata))
    Return 0
  End
  If Substr(objdata,48,4) = '02000100'x Then Do
    pgmdatapos = Pos('02000100'x,objdata,35)
    If pgmdatapos > 0 Then Do
      pgmtype = Substr(objdata,pgmdatapos+6,1)
      Select
        When pgmtype = '00'x Then settings = 'PROGTYPE=PM;'
        When pgmtype = '01'x Then settings = 'PROGTYPE=FULLSCREEN;'
        When pgmtype = '02'x Then settings = 'PROGTYPE=WINDOWABLEVIO;'
        When pgmtype = '03'x Then settings = 'PROGTYPE=PM;'
        When pgmtype = '04'x Then settings = 'PROGTYPE=VDM;'
        When pgmtype = '07'x Then settings = 'PROGTYPE=WINDOWEDVDM;'
        When pgmtype = '0C'x Then settings = 'PROGTYPE=WIN;'
        When pgmtype = '0D'x Then settings = 'PROGTYPE=SEPARATEWIN;'
        When pgmtype = '0E'x Then settings = 'PROGTYPE=WINDOWEDWIN;'
        When pgmtype = '0F'x Then settings = 'PROGTYPE=SEPARATEWIN;'
        When pgmtype = '10'x Then settings = 'PROGTYPE=WINDOWEDWIN;'
        Otherwise settings = 'PROGTYPE=????????'
      End
      pgmpos = Pos('02000200'x,objdata,pgmdatapos)
      If pgmpos > 0 Then Do
        pgm = Getpath(Substr(objdata,pgmpos+6,2))
        If pgm = '' Then Do
          If Substr(objdata,pgmpos+6,2) = 'FFFF'x Then pgm = '*'
        End
      End
      Else Do
        pgmpos = Pos('03000900'x,objdata,pgmdatapos)
        If pgmpos > 0 Then Do
          pgml = C2D(Substr(objdata,pgmpos+4,1))-1
          pgm = Substr(objdata,pgmpos+6,pgml)
        End
        Else Do
          pgm = '????????.???'
          pgmpos = 1
        End
      End
      dirpos = Pos('04000400'x,objdata,pgmpos)
      If dirpos > 0 Then Do
        dirinode = Substr(objdata,dirpos+4,2)
        If dirinode <> '0000'x Then settings = Strip(settings||'STARTUPDIR='||Getpath(dirinode))||';'
      End
      parmpos = Pos('03000300'x,objdata,pgmpos)
      If parmpos > 0 Then Do
        parml = C2D(Substr(objdata,parmpos+4,1))-1
        If parml > 0 Then parameters = Substr(objdata,parmpos+6,parml)
      End
      If Pos('04000600'x,objdata,pgmpos) > 0 Then Do
        setuppos = Pos('04000600'x,objdata,pgmpos)
        setupl = C2D(Substr(objdata,setuppos+4,1))-2
        xsettings = Translate(Substr(objdata,setuppos+6,setupl),';','00'x)||';'
        If xsettings <> '' Then Do
          ysettings = ''
          Do Forever
            Parse Var xsettings sl ';' xsettings
            If sl = '' Then Leave
            sl = 'SET' sl
            ysettings = ysettings||sl||';'
          End
          settings = Strip(settings||ysettings)
        End
      End
      openflags = Substr(objdata,Pos('04000700'x,objdata,pgmpos)+7,1)
      If Bitand(openflags,'04'x) <> '00'x Then settings = Strip(settings||'MINIMIZED=YES;')
      If Bitand(openflags,'80'x) <> '00'x Then settings = Strip(settings||'NOAUTOCLOSE=YES;')
      objdata = saveobjdata
      Call Setwpobject Substr(objdata,Pos('WPObject',objdata))
      Return 0
    End
  End
  Call Telluser "Unsupported object:" obj". Please run SAVEFLDR with the /d flag, and send the file SAVEFLDR.DAT to 61804212 AT VIEVMA."
  If debug Then Call Lineout dumpfile, "Unsupported object:" obj
End
If Pos('WPShadow',objdata,8) > 0 Then Do
  If debug Then Do
    Call Lineout dumpfile, "WPShadow:"obj
    Call Hexdump objdata, dumpfile
  End
  inode = Substr(objdata,Pos('WPShadow',objdata,8)+15,2)
  pgm = Getpath(inode)
End
Return 0Processfolder�/******************************/
/* Get the folder information */
/******************************/
Processfolder:
something = 0
folderdir = Translate(Arg(1))
foldername = Arg(2)
Call SysIni inifile,'PM_Abstract:FldrContent', 'ALL:', 'fldrs'
iconfile = ''
Do i = 1 to fldrs.0
  key = fldrs.i
  flderid = ''
  Do j = 1 to locs.0
    If Word(locs.j,1) = key Then Do
      flderid = Word(locs.j,2)
      Leave
    End
  End
  inode = Right(fldrs.i,4,'0')
  inode = X2C(Substr(inode,3,2)||Substr(inode,1,2))
  fldername = Getpath(inode)
  If fldername = '' Then Iterate
  If fldername <> folderdir Then Do
    If Length(fldername) <> Length(folderdir) Then Iterate
/* Note: On HPFS drives the directory name of the folder */
/*       obtained via the nodes may not be exactly the   */
/*       same as the uppercase directory name due to NLS */
/*       problems. Therefore the following (clumsy) code */
/*       to determine if they are really the same.       */
    PARSE UPPER VAR fldername xfldername
    PARSE UPPER VAR folderdir xfolderdir
    If xfldername <> xfolderdir Then Do
      tfile = xfldername||'\SAVEFLDR.TMP'
      tfile2 = xfolderdir||'\SAVEFLDR.TMP'
      Call Lineout tfile, 'Test'
      Call Stream tfile, 'C', 'CLOSE'
      If Stream(tfile2, 'C', 'QUERY EXISTS') = '' Then Do
        Call SysFileDelete tfile
        Iterate
      End
      Call SysFileDelete tfile
      fldername = folderdir
    End
  End
  something = 1

  Call Parsefolder folderdir
  iconfile = ''
  objs = SysIni(inifile, 'PM_Abstract:FldrContent', key)
  If debug Then Call Lineout dumpfile ,"FldrContent: key="key
  If debug Then Call Hexdump objs, dumpfile
  If Length(objs) < 4 Then Leave
  Do j = 1 to Length(objs) by 4
    Call Procrealobj Substr(objs,j,2)
  End
End
flderid = ''
If something = 0 Then Do
  Call Parsefolder folderdir
End
Return 0Setwpobject�/***************************/
/* Get the object settings */
/***************************/
Setwpobject: Procedure Expose settings objtypes. filters. save_obj
wpobject = Arg(1)
If Bitand(Substr(wpobject,28,1),'20'x) <> '00'x Then settings = Strip(settings||'TEMPLATE=YES;')
If Substr(wpobject,32,1) = '01'x Then settings = Strip(settings||'MINWIN=HIDE;')
If Substr(wpobject,32,1) = '02'x Then settings = Strip(settings||'MINWIN=VIEWER;')
If Substr(wpobject,32,1) = '02'x Then settings = Strip(settings||'MINWIN=DESKTOP;')
If Substr(wpobject,36,1) = '01'x Then settings = Strip(settings||'CCVIEW=YES;')
If Substr(wpobject,36,1) = '02'x Then settings = Strip(settings||'CCVIEW=NO;')
objnum = C2D(save_obj)+131072
If objtypes.objnum <> '' Then settings = Strip(settings||'ASSOCTYPE='||objtypes.objnum';')
If filters.objnum <> '' Then settings = Strip(settings||'ASSOCFILTER='||filters.objnum';')
Return 0Make_Output�/**************************/
/* Write the command file */
/**************************/
Make_output:
x0a = "'0a'x"
outf = 0
Do i = 1 to desk.0
  f = Translate(desk.i)
  If Word(cmd.f,1) <> 'Call' Then Iterate
  If outf = 0 Then Do
    outhdr = "/* Created by SAVEFLDR Version" ver "at" Date() Time() "*/"
    Call Lineout cmdfile, "/"||Copies('*',Length(outhdr)-2)||"/"
    Call Lineout cmdfile, outhdr
    Call Lineout cmdfile, "/"||Copies('*',Length(outhdr)-2)||"/"
    Call Lineout cmdfile, " "
    Call Lineout cmdfile, "If RxFuncQuery('SysLoadFuncs') Then Do"
    Call Lineout cmdfile, "  Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'"
    Call Lineout cmdfile, "  Call SysLoadFuncs"
    Call Lineout cmdfile, "End"
    Call Lineout cmdfile, " "
    Call Lineout cmdfile, "Parse Upper Arg argstring"
    Call Lineout cmdfile, "verbose = Wordpos('/V',argstring)"
    Call Lineout cmdfile, "If verbose > 0 Then argstring = Subword(argstring,1,verbose-1) Subword(argstring,verbose+1)"
    Call Lineout cmdfile, "Parse Var argstring tdrive ."
    Call Lineout cmdfile, "If tdrive = '' Then tdrive = '"||tdrive||"'"
    Call Lineout cmdfile, "tdrive = Strip(tdrive)"
    Call Lineout cmdfile, " "
    outf = 1
  End
  Parse Var cmd.f . ',' '"'cfolder'"' .
  Call Writeit cmdfile, cmd.f
  Call Lineout cmdfile, 'If Result <> 1 Then Say "Unable to create the folder' cfolder'."'
  Call Lineout cmdfile, 'Else If verbose <> 0 Then Say "The folder' cfolder' has been created."'
  If debug Then Call Lineout dumpfile, out.f
  Do j = 1 to out.f.0
    Do Forever
      If Pos('0a'x,cmd.f.j) = 0 Then Leave
      Parse Var cmd.f.j l '0a'x r
      cmd.f.j = l||'"||'x0a'||"'||r
    End
    Call Writeit cmdfile, cmd.f.j
    Parse Var cmd.f.j . ',' '"'otitle'"' .
    Call Lineout cmdfile, '  If Result <> 1 Then Say "Unable to create the object' otitle 'in the folder' cfolder'."'
    Call Lineout cmdfile, '  Else If verbose <> 0 Then Say "The object' otitle 'has been created in the folder' cfolder'."'
    If debug Then Call Lineout dumpfile, out.f.j
  End
  Call Lineout cmdfile, " "
End
desk.0 = desk.0 - 1
If outf = 0 Then Do
  Call Telluser "No objects are to be saved."
End
Else Do
  Call Lineout cmdfile, "Exit 0"
  Call Stream cmdfile, 'C', 'CLOSE'
  drive = Filespec('D',cmdfile)
  If drive = '' Then drive = Filespec('D',Directory())
  path = Filespec('P',cmdfile)
  If path = '' Then path = Filespec('P',Directory()||'\')
  pkgfile = Filespec('N',cmdfile)
  Parse Var pkgfile pkgfile '.' .
  pkgfile = Translate(drive||path||Strip(pkgfile)||'.FIL')
  Call SysFileDelete pkgfile
  Do i = 1 to pkgfiles.0
    Call Lineout pkgfile, pkgfiles.i
    If Translate(Directory()||'\') <> Translate(drive||path) Then Do
      '@COPY' pkgfiles.i drive||path '>nul 2>nul'
      If rc = 0 Then Call SysFileDelete pkgfiles.i
    End
  End
  Call Lineout pkgfile, Filespec('N',cmdfile)
  Call Stream pkgfile, 'C', 'CLOSE'
  pkgfiles. = 0
End
Return 0GetName�/*****************************************************/
/* Get the folder names from the desktop directories */
/*****************************************************/
Getname: Procedure Expose list. fldrfiles. allfolders
dir = Arg(1)
right = Arg(2)
Call SysFileTree dir||'\*.*', 'dirs', 'DO'
If dirs.0 > 0 Then Do
  Do i = 1 to dirs.0
    Call Getname dirs.i, right + 2
  End
End
If allfolders = 0 Then Do
  xrc = SavGetEA(dir, '.CLASSINFO', 'classinfo')
  Parse Var classinfo . 'WPObject' wpobjectinfo
  If Pos('<WP_',wpobjectinfo) > 0 Then Return 0
End
longname = ''
xrc = SavGetEA(dir, '.LONGNAME', 'longname')
If longname = '' Then longname = '    ' dir
x = list.0 + 1
list.x = Copies(' ',right)||Translate(Substr(longname,5),'^ ','0a0d'x)
fldrfiles.x = dir
list.0 = x
Return 0Writeit�/***********************/
/* Write the .CMD file */
/***********************/
Writeit: Procedure Expose desktop tdrive
fn = Arg(1)
data = Arg(2)
f = Pos('C',data)-1
If f < 0 Then f = 0
Call Lineout fn, Copies(' ',f)||Subword(data,1,2)||','
data = Subword(data,3)
i = 0
delim = ','
quote = '"'
Do Forever
  i = i + 1
  If i = 4 Then delim = ';' 
  x = Pos(delim,data)
  If delim = ',' Then Do
    If Substr(data,1,x) = '"'||desktop||'",' Then Do
      Call Lineout fn, Copies(' ',f)||'       "<WP_DESKTOP>",,'
    End
    Else Do
      outdata = Copies(' ',f)||'     ' Substr(data,1,x)','
      If Pos(tdrive||'\',outdata) > 0 & i = 3 Then Do
        tpos = Pos(tdrive||'\',outdata)
        outdata = Substr(outdata,1,tpos-1)||'"||tdrive||"'||Substr(outdata,tpos+2)
      End
      If outdata = '"'||tdrive||'",,' & i = 3 Then outdata = Copies(' ',f)||'     ' "tdrive"||',,'
      Call Lineout fn, outdata
    End
    data = Strip(Substr(data,x+1))
    If x = 0 Then Leave
  End
  Else Do
    If Substr(data,x+1,1) = '"' Then Do
      outdata = Copies(' ',f)||'     ' Substr(data,1,x+1)||',,'
      Call Checkquotes
      Call Lineout fn, outdata
      data = Strip(Substr(data,Lastpos(',',data)+1))
      Leave
    End
    Else Do
      outdata = Copies(' ',f)||'     ' Substr(data,1,x)||'"||,'
      Call Checkquotes
      Call Lineout fn, outdata
      data = '"'||Substr(data,x+1)
    End
  End
End
x = LastPos(',',data)
If x > 0 Then Do
  If Substr(data,x+1,1) <> '"' Then Do
    outdata = Copies(' ',f)||'     ' Substr(data,1,x)||'"||,'
    Call Checkquotes
    Call Lineout fn, outdata
  End
  data = Strip(Substr(data,x+1))
End
outdata = Copies(' ',f)||'     ' data
Call Checkquotes
Call Lineout fn, outdata
Return 0Hexdump�	/*********************************/
/* Dump the data in hex and char */
/*********************************/
Hexdump: Procedure
val = Arg(1)
outfile = Arg(2)
hex_string2 = Xrange("00"x, "1F"x)||'FF'x
table_o = Copies("FA"x, Length(hex_string2))
lines = Length(val)/16
Parse Var lines lines '.' .
rest = Length(val) - (lines*16)
curpos = 0
index = 1
data. = ''
data.0 = 0
Do i = 1 to lines
  data.i = Right(curpos,5) D2X(curpos,4)' '
  Do 8
    data.i = data.i C2X(Substr(val,index,2))
    index = index + 2
  End
  data.i = Left(data.i,53) "'"Translate(Substr(val,curpos+1,16),table_o,hex_string2)"'"
  curpos = curpos + 16
  data.0 = i
End
If rest > 0 Then Do
  i = data.0 + 1
  data.i = Right(curpos,5) D2X(curpos,4)' '
  Do Forever
    If rest <= 0 Then Leave
    If rest >= 2 Then Do
      data.i = data.i C2X(Substr(val,index,2))
      index = index + 2
      rest = rest - 2
    End
    Else Do
      data.i = data.i C2X(Substr(val,index,1))
      index = index + 1
      rest = rest - 1
    End
  End
  data.i = Left(data.i,53) "'"Translate(Substr(val,curpos+1,16),table_o,hex_string2)"'"
  data.0 = i
End
Call Lineout outfile, "Data length="Length(val)
Do i = 1 to data.0
  Call Lineout outfile, data.i
End
Return 0Getpath�/***********************************************/
/* Loop through the nodes to get the path info */
/***********************************************/
Getpath: Procedure Expose nodes.
gpinode = Arg(1)
If nodes.gpinode = '' Then Return ''
gp = Substr(nodes.gpinode,33,Length(nodes.gpinode)-33)
gpparent = Substr(nodes.gpinode,9,2)
If gpparent <> '0000'x Then Do
  Do Until gpparent = '0000'x
    gp = Substr(nodes.gpparent,33,Length(nodes.gpparent)-33)||'\'||gp
    gpparent = Substr(nodes.gpparent,9,2)
  End
End
Return gp�� �d 0�  �  �  ��          �   W @ � d ��          �  y e ��        ' �  1  f 0��       
 G  �8  4  g R��        i  �p  "  h n��        �  ��  !  i ���        �  ��     j ���        �  ��  1  k ���SaveFldr X.X 3             9.WarpSans Generate          9.WarpSans Select all          9.WarpSans Save          9.WarpSans Exit          9.WarpSans Help          9.WarpSans View Log          9.WarpSans ���d 0�+  �d KeyECall Eventdata 'KEYEVENT'
If keyevent.1 = 'F1' Then '@VIEW SAVEFLDR'ExitoIf done = 1 Then Do
  Do i = 1 to pkgfiles.0
    Call SysFileDelete pkgfiles.i
  End
End
Call SavDropFuncsAnyCall Move_SizeInit�GCall Position_Dialog

If RxFuncQuery('SavLoadFuncs') Then Do
  Call rxfuncadd 'SavLoadFuncs', 'SAVEFLDR', 'SavLoadFuncs'
  Call SavLoadFuncs
End
/* xrc = SavSetPriority(2,1,31) */

/****************************************/
/* Tell user that we are alive and well */
/****************************************/
ver = '2.3'
Call SAVEFLDR_DIALOG.Text "SaveFldr" ver
Call Wait "Initializing."

/**********************/
/* Get the debug flag */
/**********************/
debug = 0
allfolders = 1
recursive = 0
comments = 0
cmdfile = ''
oflag = 0
launchpad = 0
Parse Arg argstring
saveargstring = argstring
If WordPos('/D',Translate(argstring)) > 0 Then Do
  debug = 1
  argstring = Subword(argstring,1,Wordpos('/D',Translate(argstring))-1)||Subword(argstring,Wordpos('/D',Translate(argstring))+1)
End
If WordPos('/U',Translate(argstring)) > 0 Then Do
  allfolders = 0
  argstring = Subword(argstring,1,Wordpos('/U',Translate(argstring))-1) Subword(argstring,Wordpos('/U',Translate(argstring))+1)
End
If WordPos('/A',Translate(argstring)) > 0 Then Do
  comments = 1
  argstring = Subword(argstring,1,Wordpos('/A',Translate(argstring))-1) Subword(argstring,Wordpos('/A',Translate(argstring))+1)
End
If WordPos('/S',Translate(argstring)) > 0 Then Do
  recursive = 1
  argstring = Subword(argstring,1,Wordpos('/S',Translate(argstring))-1) Subword(argstring,Wordpos('/S',Translate(argstring))+1)
End
If WordPos('/DBCS',Translate(argstring)) > 0 Then Do
  Options 'EXMODE'
  argstring = Subword(argstring,1,Wordpos('/DBCS',Translate(argstring))-1) Subword(argstring,Wordpos('/DBCS',Translate(argstring))+1)
End
If Wordpos('/O',Translate(argstring)) > 0 Then Do
  cmdfile = Strip(Strip(Substr(argstring,Pos('/O',Translate(argstring))+3)),'B','"')
  argstring = Substr(argstring,1,Pos('/O',Translate(argstring))-1)
  oflag = 1
End

foldername = Strip(Strip(argstring),'B','"')

/**************/
/* Initialize */
/**************/
inifile = Value('USER_INI',,'OS2ENVIRONMENT')
sysinifile = Value('SYSTEM_INI',,'OS2ENVIRONMENT')
oldver = SysIni(inifile,'SAVEFLDR','Version')
If ver <> oldver Then Do
  Call SysIni inifile ,'SAVEFLDR','Version',ver
  Call SysCreateObject 'WPProgram', 'Save Folder^Contents', '<WP_DESKTOP>', 'PROGTYPE=PM;EXENAME='||Directory()||'\SAVEFLDR.EXE;OBJECTID=<SAVE_FOLDER>;STARTUPDIR='||Directory()||';ICONFILE='||Directory()||'\SAVEFLDR.ICO;PARAMETERS=/S;', 'U'
End
dumpfile = 'SAVEFLDR.DAT'
If debug Then Do
  Call Wait "Creating debug information."
  Call SysFileDelete dumpfile
  Call Lineout dumpfile, "Debugging information of SaveFolder version" ver "on" Date() Time()"."
  Call Lineout dumpfile, "Please send this file to criguada@tin.it"
  Call Lineout dumpfile, " "
  Call Lineout dumpfile, "SAVEFLDR argstring:" saveargstring
  Call Stream dumpfile, 'C', 'CLOSE'
  '@SYSLEVEL >>'dumpfile
  Parse Version With rexxversion
  Call Lineout dumpfile, "Rexx version:" rexxversion
End

/*****************/
/* Get the nodes */
/*****************/
Call Wait "Reading the node table."
handlesapp = SysIni(sysinifile,'PM_Workplace:ActiveHandles', 'HandlesAppName')
If handlesapp = 'ERROR:' Then handlesapp = 'PM_Workplace:Handles'
block1 = ''
Do i = 1 to 999
  block = SysIni('SYSTEM', handlesapp, 'BLOCK'||i)
  If block = 'ERROR:' Then Do
    If i = 1 Then Do
      Say "Unable to locate the INODE table, you are probably using a version of OS/2 not supported (too old or too new)."
      Exit 8
    End
    Leave
  End
  block1 = block1||block
End
l = 0
nodes. = ''
Do Until l >= Length(block1)
  If Substr(block1,l+5,4) = 'DRIV' Then Do
    xl = Pos('00'x||'NODE'||'01'x,block1,l+5)-l
    If xl <= 0 Then Leave
    l = l + xl
    Iterate
  End
  Else Do
    If Substr(block1,l+1,4) = 'DRIV' Then Do
      xl = Pos('00'x||'NODE'||'01'x,block1,l+1)-l
      If xl <= 0 Then Leave
      l = l + xl
      Iterate
    End
    Else Do
      data = Substr(block1,l+1,32)
      xl = C2D(Substr(block1,l+31,1))
      If xl <= 0 Then Leave
      data = data||Substr(block1,l+33,xl+1)
      l = l + Length(data)
    End
  End
  xnode = Substr(data,7,2)
  nodes.xnode = data
  If Debug Then Do
    Call Lineout dumpfile, "NODES."||C2X(xnode)"="
    Call Hexdump data, dumpfile
  End
End

/*************************************************/
/* Get the name of the current desktop directory */
/*************************************************/
Call Wait "Getting the desktop directories."
objnum = SysIni(inifile, 'PM_Workplace:Location', '<WP_DESKTOP>')
desktop = Getpath(Substr(objnum,1,2))
If Debug Then Call Lineout dumpfile, "DESKTOP:" desktop

If foldername <> '' & recursive = 1 Then Do
  desktop = foldername
  foldername = ''
End

tdrive = Filespec('D', desktop)

If foldername = '' Then Do
/****************************************/
/* Get the desktop directory file names */
/****************************************/
  Call SysFileTree desktop||'\*', 'xdesk', 'DSO'
/**********************************/
/* Set the output data structures */
/**********************************/
  out. = 0
  cmd. = 0
  desk. = ''
  f = Translate(desktop)
  out.f = f
  cmd.f = f
  desk.1 = desktop
  desk.0 = 1
  Do i = 1 to xdesk.0
    j = desk.0 + 1
    desk.j = xdesk.i
    desk.0 = j
    f = Translate(xdesk.i)
    out.f = f
    cmd.f = f
    If Debug Then Do
      Call Lineout dumpfile, "OUT/CMD:" f
      Call Hexdump out.f, dumpfile
    End
  End
End

/*****************************/
/* Get the association types */
/*****************************/
Call Wait "Getting the associations."
objtypes. = ''
Call SysIni inifile,'PMWP_ASSOC_TYPE', 'ALL:', 'types'
Do i = 1 to types.0
  objids = SysIni(inifile,'PMWP_ASSOC_TYPE', types.i)
  Do Forever
    If objids = '' Then Leave
    x = Pos('00'x,objids)
    objid = Substr(objids,1,x-1)
    If objid = '' Then Leave
    If objtypes.objid <> '' Then objtypes.objid = objtypes.objid||','
    objtypes.objid = objtypes.objid||types.i
    objids = Substr(objids,x+1)
    If Debug Then Do
      Call Lineout dumpfile, "OBJTYPES:" objid
      Call Hexdump objtypes.objid, dumpfile
    End
  End
End

/*******************************/
/* Get the association filters */
/*******************************/
filters. = ''
Call SysIni inifile,'PMWP_ASSOC_FILTER', 'ALL:', 'types'
Do i = 1 to types.0
  objids = SysIni(inifile,'PMWP_ASSOC_FILTER', types.i)
  Do Forever
    If objids = '' Then Leave
    x = Pos('00'x,objids)
    objid = Substr(objids,1,x-1)
    If filters.objid <> '' Then filters.objid = filters.objid||','
    filters.objid = filters.objid||types.i
    If Debug Then Call Lineout dumpfile, "FILTER:" objid
    If debug Then Call Hexdump filters.objid, dumpfile
    objids = Substr(objids,x+1)
  End
End

/******************************************/
/* Get the object id's of all WPS objects */
/******************************************/
Call Wait "Getting the id's of all objects."
Call SysIni inifile,'PM_Workplace:Location', 'ALL:', 'locs'
Do i = 1 to locs.0
  objnum = SysIni(inifile, 'PM_Workplace:Location', locs.i)
  If locs.i = '<WP_LAUNCHPAD>' Then launchpad = 1
  locs.i = C2X(Substr(objnum,2,1)||Substr(objnum,1,1)) locs.i
  If Debug Then Call Lineout dumpfile, "LOCS:" i
  If debug Then Call Hexdump locs.i, dumpfile
End
launchpad = 0

If debug Then Do
  Call SysIni inifile,'PM_Abstract:FldrContent', 'ALL:', 'fldrs'
  Do i = 1 to fldrs.0
    Call Lineout dumpfile, "FldrContent:" fldrs.i
    Call Hexdump Sysini(inifile,'PM_Abstract:FldrContent',fldrs.i), dumpfile
  End
End

pkgfiles. = 0
list. = 0
fldrfiles. = 0
If foldername = '' Then Do
/*********************/
/* Create the tables */
/*********************/
  Call Wait "Creating the internal tables."
  list.0 = 0
  fldrfiles.0 = 0
  Call Getname desktop, 0
  fldrlist. = 0
  fldrdirs. = 0
  j = 0
  Do i = list.0 to 1 by -1
    j = j + 1
    fldrlist.j = Substr(list.i,3)
    If allfolders = 1 Then fldrlist.j = list.i
    Call SAVEFLDR_LIST.Add fldrlist.j
    fldrdirs.j = fldrfiles.i
  End
  fldrlist.0 = j
  If launchpad = 1 Then Do
    Call SAVEFLDR_LIST.Add '<WP_LAUNCHPAD>'
    launchpad = 0
    j = fldrdirs.0 + 1
    fldrdirs.j = '<WP_LAUNCHPAD>'
    fldrfiles.0 = j
    j = fldrfiles.0 + 1
    fldrfiles.j = '<WP_LAUNCHPAD>'
    fldrfiles.0 = j
    j = fldrlist.0 + 1
    fldrlist.j = '<WP_LAUNCHPAD>'
    fldrlist.0 = j
    j = desk.0 + 1
    desk.j = '<WP_LAUNCHPAD>'
    desk.0 = j
  End
/**************/
/* Main logic */
/**************/
  Call SAVEFLDR_DIALOG.Show
  Call Unwait
  done = 0
End
Else Do
  done = 1
  out. = 0
  cmd. = 0
  desk. = 0
  xrc = SavGetEA(foldername, '.longname', 'longname')
  title = Translate(Substr(longname,5),'^ ','0a0d'x)
  If title = '' Then title = foldername
  tdrive = Filespec('D',foldername)
  f = foldername
  out.f = f
  cmd.f = f
  i = desk.0 + 1
  desk.i = f
  desk.0 = i
  Call Wait 'Processing "'title'"'
  Call Processfolder Translate(foldername), title
  exitswi = 1
  Call Unwait
  Call OUTPUT_SAVE
End�k ClickCall LOG_DIALOG.Open�j Click'@VIEW SAVEFLDR'�i Click�/***************************************/
/* Process button SAVEFLDR_DIALOG_EXIT */
/***************************************/
If done = 0 Then Exit 0
Else Do
/**************************************************************/
/* Now create the .CMD file, and if requested, the debug file */
/**************************************************************/
  exitswi = 1
  Call OUTPUT_SAVE
End�h Click�exitswi = 0
If done = 1 Then Do
/**************************************************************/
/* Now create the .CMD file, and if requested, the debug file */
/**************************************************************/
  saveit = 1
  Call OUTPUT_SAVE
End�g ClickTDo i = 1 to fldrlist.0
  Call SAVEFLDR_DIALOG.SAVEFLDR_LIST.Select i, 'Select'
End�f Click�loopi = SAVEFLDR_DIALOG.SAVEFLDR_LIST.Select()
If loopi <= 0 Then Do
  Call RxMessageBox "Please select a folder from the list.", "ERROR", "OK", "EXCLAMATION"
End
Else Do
  Do While loopi > 0
    curdir = loopi
    curfldr = Strip(SAVEFLDR_DIALOG.SAVEFLDR_LIST.Item(loopi))
    Call Wait 'Processing "'curfldr'"'
    If curfldr = '<WP_LAUNCHPAD>' Then Do
      fldername = '<WP_LAUNCHPAD>'
      Call Processlaunch
    End
    Else Do
      Call Processfolder fldrdirs.curdir, curfldr
    End
    Call SAVEFLDR_DIALOG.SAVEFLDR_LIST.Select loopi, 'U'
    loopi = SAVEFLDR_DIALOG.SAVEFLDR_LIST.Select(loopi,'Next')
  End
  log.0 = 0
  Do i = 1 to desk.0
    f = Translate(desk.i)
    If Word(cmd.f,1) <> 'Call' Then Iterate
    j = log.0 + 1
    log.j = cmd.f
    log.0 = j
    Do j = 1 to cmd.f.0
      k = log.0 + 1
      log.k = ' ' cmd.f.j
      log.0 = k
    End
  End
  Call SAVEFLDR_VIEWLOG.Enable
  Call Unwait
  done = 1
End�� �,0�   �   �  ��          h �  # A � 5 ,��q          u �  �  -����        v  �  � 
 .����SaveFldr     Please wait... � ��0f   f   �  ��          J   �; 2 � ���a          e  �  � �����SAVEFLDR - Display Log     ����0;   ��Init1Do i = 1 to log.0
  Call LOG_LIST.Add log.i
End�