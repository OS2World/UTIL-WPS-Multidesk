/* */
If RxFuncQuery('SavLoadFuncs') Then Do
  Call rxfuncadd 'SavLoadFuncs', 'SAVEFLDR', 'SavLoadFuncs'
  Call SavLoadFuncs
End
debug = 1
dumpfile = 'CLASSINFO.DAT'
flderid = ''
pkgfiles. = 0
Call ParseFolder 'E:\DESKTOP\FOLDER OF^FOLDERS'
Say "XFLDERID="xflderid
Exit 0

Parsefolder:
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

    offset = Pos('0400710B'x,classinfo)
    If offset > 0 Then Do
      If Substr(classinfo,offset+10,1) = '01'x Then settings = settings||'SORT=ALWAYS;'
    End
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
      Leave
    End
  End
  cmd.fldername = 'Call SysCreateObject "WPFolder", "'foldername'", "'back'", 'xflderid', "F"'
  out.fldername = C2X(inode) "Folder" fldername flderid 'Title='foldername
Return 0

/*********************************/
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
Return 0
