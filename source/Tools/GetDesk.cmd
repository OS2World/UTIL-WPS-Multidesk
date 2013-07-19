/**********************************************************************/
/*                                                                    */
/* GETDESK.CMD                                                        */
/*                                                                    */
/* Version: 1.2                                                       */
/*                                                                    */
/* Written by:  Georg Haschek (haschek at vnet.ibm.com)               */
/*                                                                    */
/* Description: Return the desktop's directory name to the caller.    */
/*                                                                    */
/* captured from a message in a public CompuServe forum               */
/**********************************************************************/

rc = rxFuncAdd( 'sysLoadFuncs', 'rexxUtil', 'SysLoadFuncs' )
call sysLoadFuncs

say GetDesktopDirectory()
exit

/**************/
/* Initialize */
/**************/

GetDesktopDirectory: PROCEDURE; /* expose (exposeList) */
  Return Getpath( Substr( SysIni( "USER",,
                  "PM_Workplace:Location", "<WP_DESKTOP>" ),1,2 ) )

/***********************************************/
/* Loop through the nodes to get the path info */
/***********************************************/
Getpath: Procedure Expose nodes. /* (exposeList) */
  If Getnodes( ) <> 0 Then
    Return ""

  gpinode = Arg( 1 )

  If nodes.gpinode = "" Then
    Return ""

  gp = Substr( nodes.gpinode,33,Length( nodes.gpinode )-33 )
  gpparent = Substr( nodes.gpinode,9,2 )

  If gpparent <> "0000"x Then
  Do
    Do Until gpparent = "0000"x
      gp = Substr( nodes.gpparent,33,Length( nodes.gpparent )-33 ) || ,
           "\" || gp
      gpparent = Substr( nodes.gpparent,9,2 )
    End
  End
Return gp

/*****************/
/* Get the nodes */
/*****************/
Getnodes: Procedure Expose nodes. /* (exposeList) */
  handlesapp = SysIni( "SYSTEM","PM_Workplace:ActiveHandles",,
                       "HandlesAppName" )

  If handlesapp = "ERROR:" Then
    handlesapp = "PM_Workplace:Handles"

  block1 = ""
  Do i = 1 to 999
    block = SysIni( "SYSTEM", handlesapp, "BLOCK" || i )
    If block = "ERROR:" Then
    Do
      If i = 1 Then
      Do
        call ShowWarning ,
               "Unable to locate the NODE table, you are probably",
               "using OS/2 2.0 without the Service Pack."
        Return 1
      End
      Leave
    End
    block1 = block1 || block
  End

  l = 0
  nodes. = ""
  Do Until l >= Length( block1 )
    If Substr( block1,l+5,4 ) = "DRIV" Then
    Do
      xl = Pos( "00"x || "NODE" || "01"x, block1,l+5 )-l
      If xl <= 0 Then
        Leave
      l = l + xl
      Iterate
    End
    Else
    Do
      If Substr( block1,l+1,4 ) = "DRIV" Then
      Do
        xl = Pos( "00"x || "NODE" || "01"x, block1,l+1 )-l
        If xl <= 0 Then
          Leave
        l = l + xl
        Iterate
      End
      Else
      Do
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

