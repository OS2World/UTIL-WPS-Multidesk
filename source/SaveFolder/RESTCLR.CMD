/**********************************************************************/
/*                                                                    */
/* RESTCLR.CMD                          Part of SAVEFLDR PACKAGE      */
/*                                                                    */
/*                          IBM Internal Use Only                     */
/*                                                                    */
/* Version: 1.0                                                       */
/*                                                                    */
/* Written by:  George Haschek (61804212 at VIEVMA)                   */
/*                                                                    */
/* Description: Restore PM's color and scheme definitions.            */
/*                                                                    */
/* Parameters: None                                                   */
/*                                                                    */
/* Change history:                                                    */
/*                                                                    */
/*    23/04/93 ... Version 1.0                                        */
/*                                                                    */
/**********************************************************************/

/**************/
/* Initialize */
/**************/
If RxFuncQuery('SysLoadFuncs') Then Do
  Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  Call SysLoadFuncs
End
in = 'Colors.Dat'
If Stream(in, 'C', 'QUERY EXISTS') = '' Then Do
  Say "Unable to locate the file COLORS.DAT."
  Exit 28
End

/*************/
/* Now do it */
/*************/
Do Until Lines(in) = 0
  data = Linein(in)
  Parse Var data '[' ini ']' '[' app ']' '[' key ']' data
  Call SysIni ini, app, key, X2C(Strip(data))
End
Call Stream in, 'C', 'CLOSE'
Exit 0
