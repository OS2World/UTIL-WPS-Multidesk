/**********************************************************************/
/*                                                                    */
/* SAVECLR.CMD                          Part of SAVEFLDR PACKAGE      */
/*                                                                    */
/*                          IBM Internal Use Only                     */
/*                                                                    */
/* Version: 1.0                                                       */
/*                                                                    */
/* Written by:  George Haschek (61804212 at VIEVMA)                   */
/*                                                                    */
/* Description: Save PM colors and schemes.                           */
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
out = 'Colors.Dat'
If Stream(out, 'C', 'QUERY EXISTS') <> '' Then Call SysFileDelete out
Apps.0 = 13
Apps.1 = 'USER PM_ControlPanel'
Apps.2 = 'USER PM_Colors'
Apps.3 = 'USER PM_Default_Colors'
Apps.4 = 'SYSTEM PM_Autumn_Colors'
Apps.5 = 'SYSTEM PM_Lcd_Colors'
Apps.6 = 'SYSTEM PM_Mono_Colors'
Apps.7 = 'SYSTEM PM_Spring_Colors'
Apps.8 = 'SYSTEM PM_Summer_Colors'
Apps.9 = 'SYSTEM PM_System_Colors'
Apps.10 = 'SYSTEM PM_Windows_Colors'
Apps.11 = 'SYSTEM PM_Winter_Colors'
Apps.12 = 'USER PM_AlternateInputMethods'
Apps.13 = 'USER PM_National'

/*************/
/* Now do it */
/*************/
Do i = 1 to Apps.0
  Call SysIni Word(Apps.i,1), Word(Apps.i,2), 'ALL:', 'Keys'
  Do j = 1 to Keys.0
    Call Lineout out, '['||Word(Apps.i,1)||']' '['||Word(Apps.i,2)||']' '['||Keys.j||']' C2X(SysIni(Word(Apps.i,1), Word(Apps.i,2), Keys.j))
  End
End
Call Stream out, 'C', 'CLOSE'
Exit 0
