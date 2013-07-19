/**********************************************************************/
/*                                                                    */
/* SetSort.CMD                          Part of WPSMAIL PACKAGE       */
/*                                                                    */
/*                          IBM Internal Use Only                     */
/*                                                                    */
/* Version: 2.1                                                       */
/*                                                                    */
/* Written by:  George Haschek (61804212 at VIEVMA)                   */
/*                                                                    */
/* Description: Set the "Always maintain sort order" flag for all     */
/*              Folders                                               */
/*                                                                    */
/**********************************************************************/
Trace 'O'
If RxFuncQuery('SavLoadFuncs') Then Do
  Call rxfuncadd savloadfuncs, savfldr, savloadfuncs
  Call savloadfuncs
End

If RxFuncQuery('SysLoadFuncs') Then Do
  Call rxfuncadd sysloadfuncs, sysutil, sysloadfuncs
  Call sysloadfuncs
End

filename = 'E:\DESKTOP\APPS'

Call SavGetEA filename, '.CLASSINFO', 'eadata1'
say 'Data (Sav): ' || eadata1

say '------------------------------------------'
Call SysGetEA filename, '.CLASSINFO', 'eadata2'
say 'Data (Sys): ' || eadata2

say '------------------------------------------'
if eadata1 = eadata2 then
	say "Calls are identical."
else
	say "Calls are different."

Exit 0
