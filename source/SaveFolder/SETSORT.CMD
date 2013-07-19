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
  Call rxfuncadd savloadfuncs, savutil, savloadfuncs
  Call savloadfuncs
End
filename = 'C:\DESKTOP\FOLDER'

Call SavGetEA filename, '.CLASSINFO', 'eadata'
Call SavPutEA filename, '.CLASSINFO', Overlay('01'x,eadata,Pos('0400710B'x,eadata,2)+10)

Say "Please reboot with CAD now, don't shutdown!"
Exit 0
