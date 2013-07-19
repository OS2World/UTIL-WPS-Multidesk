.* EBOOKIE (BKMTAGS.DEF)
:userdoc.
.nameit symbol=prod text='SAVEFLDR'
.nameit symbol=ver text='2.1c'
:title.&prod. Version &ver. User's Guide
:h1.Introduction
:p.Did you ever want to save the definition of program- and shadow
objects of a folder you created, so you can restore it whenever and
wherever you want?  Well, then &prod. is for you.  It creates a .CMD
file which contains the necessary commands to re-create the folders
and all "Abstract" (i.e. Program and Shadow) objects.
:p.Please note that this package is :hp2.IBM INTERNAL USE ONLY:ehp2..
:lblbox.IMPORTANT NOTE
:p.Since this program uses information from undocumented and
frequently changing data structures, it might NOT work on all current
and future OS/2 versions.
:p.I have tested it with:  OS/2 2.0 GA (German), OS/2 2.0 (US) with
the Service Pack applied, OS/2 2.1 (beta 2, "December" release),
and OS/2 2.1 (beta 3, "March" release), the OS/2 2.1 GA version
(German, US, and UK), and OS/2 2.1 US with the SP.
:p.However, the output might not be 100% correct, you may have to edit
the resulting .CMD file.
:elblbox.
:h2.PACKAGE File Contents
:p.The &prod. PACKAGE, available from OS2TOOLS, contains the
following files:
:dl compact tsize=30.
:dthd.File
:ddhd.Description
:dt.&prod. RAMBIN:dd.The executable code. This expands to:
:dl compact tsize=30.
:dt.&prod..EXE:dd.The program.
:dt.&prod..ICO:dd.The &prod. icon.
:dt.&prod..INF:dd.The User's Guide in "view" format.
:dt.&prod..DLL:dd.This contains supporting functions.
:dt.SAVECLR.CMD:dd.Save color definitions and schemes.
:dt.RESTCLR.CMD:dd.Restore color definitions and schemes.
:p.
:edl.
:dt.&prod. ANNOUNCE:dd.A short description.
:edl.
:h2.Additional Information
:p.If you want to have a look at the source code, send the
following request:
:xmp.
REQUEST SAVEFLDS PACKAGE FROM 61804212 AT VIEVMA
:exmp.
:p.In order to look at the code you will also need the DRDIALOG
PACKAGE from OS2TOOLS, which provides the environment to display the
panels.
:p.If you need some support, use the &prod. FORUM on IBMPC. I will try
to respond to bug reports and suggestions as fast as possible.
:h2.Restrictions
:p.&prod. is not capable of saving and restoring everything, some
manual intervention may still be required. The following is a list of
known restrictions:
:ol.
:li.Most of the folder settings, like "Always maintain sort order", or
everything you find in the "Include" notebook tab, will :hp2.not:ehp2.
be restored.  You will have to set that manually after you have
re-created the folder.
:li.The restored folders will be allocated in the folders they were
originally located. However, if the parent folder does not exist on
the target system, the object creation will fail. For example, you
have a folder called "Applications", and within that a folder
"DrDialog". If you try to restore the "DrDialog" folder before you
have restored the "Applications" folder, it will fail.
:li.If you restore your folders on a system where the desktop
directory is located on a different disk, or has a different file
name, you will have to change all folder definitions in the output of
SAVEFLDR, except for the desktop itself, if the original folders have
not had an id.
:p.For example, on your OS/2 2.0 system the desktop was called
"OS&xclm.2 2.0 Desktop", and on your OS/2 2.1 system the desktop is
called "Desktop", you will have to change all references of
"OS&xclm.2 2.0 Desktop" to "Desktop" before you try to re-create any
folders.
:li.Shadows of program objects will not restore correctly if the
original program object has no ID. It will point to the file system
object (the .EXE file) instead.
:eol.
:h1.Installation
:p.To install &prod. you have to do the following:
:ol.
:li.Download the file &prod. RAMBIN in :hp2.binary:ehp2. to your PC
as &prod..RAM.
:li.Unpack &prod..RAM using LOADRAM2 (available on OS2TOOLS).
:li.Optionally add the directory where you have installed &prod. to
your LIBPATH and PATH in CONFIG.SYS.
If you don't do this, you will always have to start &prod. from the
directory where you have installed it, or from the "Save Folder
Contents" icon which will be automatically created on your desktop.
:li.Run &prod. from an OS/2 command prompt.
This will add a "Save Folder Contents" program object to your desktop.
You may move this object away from the desktop into any folder you
like.
:eol.
:h1.Using &prod.
:p.You may start &prod. from either the "Save Folder Contents" program
object, from an OS/2 command prompt, or by dropping a folder on the
&prod. object.
It needs some time to start, and then presents you with a list of all
folders you have on your desktop, or all folders contained within the
folder you dropped on &prod..  Folders which have been created during
the OS/2 installation process will be shown, except you have specified
the "/U" command line option.  Refer to :hdref refid=sdialog. for
more information about this dialog.
:h2.Command Line Options
&prod. supports two command switches:
:dl tsize=25.
:dthd.Flag
:ddhd.Function
:dt./U:dd.Display only folders you, or some other program
created after the system has been installed. The default is to show
all folders, including the system folders.
:dt./D:dd.The debug flag. If you specify this option a file called
&prod..DAT will be created in the current directory. It contains
information which i need to debug any problems you may find.
:p.If you have any problems with &prod., please run it with the /D
flag, and send the resulting file to 61804212 at VIEVMA.
:note.Processing will be slower if you specify this option.
:dt./S:dd.Display subdirectories as well. This option only applies if
you drop a folder on the &prod. object. If this option is not
specified, only the folder dropped will be shown in the list. This
flag is set by default.
:dt./O filename:dd.Specify the output .CMD file name and path. If this
option is specified, the output will be stored under the specified
name. If the files already exist, they will be erased without any
questions. This option can be useful if you want to run &prod. in
batch mode.
:edl.
:h2 id=sdialog.The &prod. Dialog
:p.This dialog is used to select the folders you want to save.
It contains the following controls:
:dl tsize=25.
:dthd.Control
:ddhd.Function
:dt.List Box:dd.This list box contains the names of all folders you
have on your desktop. If you have selected the /U command line option,
you will see only the folders you have created.
You may select one or more folders from this list.
:dt.Generate:dd.Press this push button to process the selected
folders. You may iterate through the process of selecting and
processing folders, the output will be accumulated into one .CMD file.
:dt.Select all:dd.Press this button to select all shown folders.
:dt.Save:dd.Saves the output accumulated up to this point.
:hdref refid=fdialog. will be displayed.
:dt.Exit:dd.Press this button to exit from &prod..  If you have
processed some folders, but not yet saved the output, it will ask you
where you want to store the results.
Refer to :hdref refid=fdialog. for more information about saving the
results.
:dt.Help:dd.If you press this button you will be able to view the
User's Guide (this document).
:edl.
:h2 id=fdialog.The "Save as" Dialog
:p.This dialog will be activated when some output needs to be written,
that means that you have pressed the "Generate" button in
:hdref refid=sdialog.. This is a standard OS/2 dialog. Select the
output name of the .CMD file, and all other files (the .FIL and maybe
some .ICO files) will be stored in the directory you selected.
:h1.Using the Output of &prod.
:p.&prod. creates a .CMD file which can be used to re-create the
objects which have been saved.
For example, i ran &prod. against my "Appls", and the "Information"
folder, which created the following output:
:xmp.
/************************************************************/
/* Created by SAVEFLDR Version 2.1 at 28 Feb 1994 10&colon.58&colon.11 */
/************************************************************/

If RxFuncQuery('SysLoadFuncs') Then Do
  Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  Call SysLoadFuncs
End

Parse Upper Arg argstring
verbose = Wordpos('/V',argstring)
If verbose > 0 Then argstring = Subword(argstring,1,verbose-1) Subword(argstring,verbose+1)
Parse Var argstring tdrive .
If tdrive = '' Then tdrive = 'C:'

Call SysCreateObject,
      "WPFolder",,
      "Appls",,
       "<WP_DESKTOP>",,
      "OBJECTID=<P75_APPLS>;"||,
      "ICONVIEW=NONGRID,NORMAL;"||,
      "ICONFONT=8.Helv;",,
      "F"
If Result <> 1 Then Say "Unable to create the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "CPU Monitor",,
        "<P75_APPLS>",,
        "EXENAME=E:\MONITOR\MONITOR.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=E:\MONITOR;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object CPU Monitor in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "Freelance for OS/2",,
        "<P75_APPLS>",,
        "EXENAME=F:\FLG16\FLG.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=F:\FLG16;"||,
        "ASSOCFILTER=*.PRS;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Freelance for OS/2 in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "PageMaker for OS/2",,
        "<P75_APPLS>",,
        "EXENAME=F:\ALDUS\PMPM.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=F:\ALDUS;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object PageMaker for OS/2 in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "PageMaker 4",,
        "<P75_APPLS>",,
        "EXENAME=F:\PM4\PM4.EXE;"||,
        "PROGTYPE=PROG_31_ENH;"||,
        "STARTUPDIR=F:\PM4;"||,
        "SET IDLE_SECONDS=10;"||,
        "SET DPMI_MEMORY_LIMIT=64;"||,
        "SET VIDEO_RETRACE_EMULATION=0;"||,
        "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
        "SET VIDEO_8514A_XGA_IOTRAP=0;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object PageMaker 4 in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "Win 3.1 ^Full Screen",,
        "<P75_APPLS>",,
        "EXENAME=C:\OS2\MDOS\WINOS2\PROGMAN.EXE;"||,
        "PROGTYPE=PROG_31_ENH;"||,
        "STARTUPDIR=C:\OS2\MDOS\WINOS2;"||,
        "SET IDLE_SECONDS=10;"||,
        "SET EMS_MEMORY_LIMIT=0;"||,
        "SET XMS_MEMORY_LIMIT=0;"||,
        "SET DPMI_MEMORY_LIMIT=64;"||,
        "SET VIDEO_RETRACE_EMULATION=0;"||,
        "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
        "SET VIDEO_8514A_XGA_IOTRAP=0;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Win 3.1 ^Full Screen in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "DeskPic",,
        "<P75_APPLS>",,
        "EXENAME=F:\DESKPIC\DESKPIC.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=F:\DESKPIC;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object DeskPic in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "Organizer",,
        "<P75_APPLS>",,
        "EXENAME=F:\ORGANIZE\ORGANIZE.EXE;"||,
        "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"||,
        "STARTUPDIR=F:\ORGANIZE;"||,
        "SET IDLE_SECONDS=10;"||,
        "SET VIDEO_FASTPASTE=1;"||,
        "SET EMS_MEMORY_LIMIT=0;"||,
        "SET XMS_MEMORY_LIMIT=0;"||,
        "SET DPMI_MEMORY_LIMIT=64;"||,
        "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
        "SET VIDEO_8514A_XGA_IOTRAP=0;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Organizer in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "Win 3.1 ^Seamless",,
        "<P75_APPLS>",,
        "EXENAME=C:\OS2\MDOS\WINOS2\PROGMAN.EXE;"||,
        "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"||,
        "STARTUPDIR=C:\OS2\MDOS\WINOS2;"||,
        "SET IDLE_SECONDS=10;"||,
        "SET EMS_MEMORY_LIMIT=0;"||,
        "SET XMS_MEMORY_LIMIT=0;"||,
        "SET DPMI_MEMORY_LIMIT=64;"||,
        "SET VIDEO_RETRACE_EMULATION=0;"||,
        "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
        "SET VIDEO_8514A_XGA_IOTRAP=0;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Win 3.1 ^Seamless in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "AmiPro 3.0",,
        "<P75_APPLS>",,
        "EXENAME=F:\AMIPRO\AMIPRO.EXE;"||,
        "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"||,
        "STARTUPDIR=F:\AMIPRO;"||,
        "SET IDLE_SECONDS=10;"||,
        "SET KBD_ALTHOME_BYPASS=1;"||,
        "SET DPMI_MEMORY_LIMIT=64;"||,
        "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
        "SET VIDEO_8514A_XGA_IOTRAP=0;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object AmiPro 3.0 in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "1-2-3 for OS/2",,
        "<P75_APPLS>",,
        "EXENAME=F:\LOTUS32\123G.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=F:\LOTUS32;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object 1-2-3 for OS/2 in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "Freelance Graphics",,
        "<P75_APPLS>",,
        "EXENAME=F:\LOTUS32\FLG.EXE;"||,
        "PARAMETERS=Presentation;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=F:\LOTUS32;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Freelance Graphics in the folder Appls"
  Call SysCreateObject,
        "WPProgram",,
        "Describe",,
        "<P75_APPLS>",,
        "EXENAME=F:\DESCRIBE\DESCRIBE.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=F:\DESCRIBE;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Describe in the folder Appls"

Call SysCreateObject,
      "WPFolder",,
      "Information",,
       "<WP_DESKTOP>",
      "OBJECTID=<WP_INFO>;"||,
      "ICONVIEW=NONGRID,NORMAL;"||,
      "ICONFONT=8.Helv;"||,
      "ICONFILE=D:\savefldr\F430F.ICO;",,
      "F"
If Result <> 1 Then Say "Unable to create the folder Information"
  Call SysCreateObject,
        "WPProgram",,
        "Tutorial",,
        "<WP_INFO>",,
        "EXENAME=C:\OS2\TUTORIAL.EXE;"||,
        "PROGTYPE=PM;"||,
        "STARTUPDIR=C:\OS2\HELP;"||,
        "OBJECTID=<WP_TUTOR>;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Tutorial in the folder Information"
  Call SysCreateObject,
        "WPProgram",,
        "Command Reference",,
        "<WP_INFO>",,
        "EXENAME=C:\OS2\VIEW.EXE;"||,
        "PARAMETERS=CMDREF.INF;"||,
        "PROGTYPE=PM;"||,
        "OBJECTID=<WP_CMDREF>;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object Command Reference in the folder Information"
  Call SysCreateObject,
        "WPProgram",,
        "REXX Information",,
        "<WP_INFO>",,
        "EXENAME=C:\OS2\VIEW.EXE;"||,
        "PARAMETERS=REXX.INF;"||,
        "PROGTYPE=PM;"||,
        "OBJECTID=<WP_REXREF>;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object REXX Information in the folder Information"
  Call SysCreateObject,
        "WPProgram",,
        "DrDialog Information",,
        "<WP_INFO>",,
        "EXENAME=C:\OS2\VIEW.EXE;"||,
        "PARAMETERS=DRDIALOG.INF;"||,
        "STARTUPDIR=D&colon.&bsl.DRDIALOG;"||,
        "PROGTYPE=PM;"||,
        "OBJECTID=<WP_REXREF>;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object DrDialog Information in the folder Information"
  Call SysCreateObject,
        "WPShadow",,
        "README",,
        "<WP_INFO>",,
        "SHADOWID=C:\README;",,
        "F"
  If Result <> 1 Then Say "Unable to create the object README in the folder Information"

Exit 0
:exmp.
:p.The above .CMD file accepts one parameter, a drive letter (for
example D&colon.), which is used when the folders have no ID.  This
allows you to create the folders on a different drive.
:p.Usually the .CMD file is quiet, that means that only error messages
are displayed. However, if the "/V" flag i set, you will receive also
messages if the object has been successfully created.
:p.If you run the above command you would receive a few error
messages.  For example, it can't create the "Information" folder, and
most of the objects in it.  This is normal, because the
SysCreateObject calls have the "FailIfExists" flag set, thet means it
will not re-create an object which already exists on your new desktop.
Only the object "DrDialog Information" will be created in the
"Information" folder of a newly installed system.
:p.&prod. also creates icon files, which are used when a folder is
restored. Those files are saved in the directory you specified in
:hdref refid=fdialog., and have the names "F*.ICO". If you want that
your restored folders have the same icon as the original, you have to
save those icon files as well, and have them available when you
re-create the folders.
:p.To assist you in keeping all files required to restore your folders
together, &prod. also creates a .FIL file, which has the same name as
the output .CMD file. This file contains a simple list of all .ICO
and .CMD files required to restore the folders. You may use this file
as an input for SAVERAM2 (availavle in the LOADRAM2 PACKAGE on
OS2TOOLS) or any other program which accepts a file list.  In the above
example the .CMD file would also require an icon file with the name
"FB3D0.ICO" to re-create the Information folder with the correct icon.
The .FIL file would contain:
:xmp.
F430F.ICO
MAKEFLDR.CMD
:exmp.
:p.If you want to save everything in one file using SAVERAM2, you
could use the following command:
:xmp.
D&colon.&bsl.SAVEFLDR&rbrk.saveram2 makefldr.fil myfolder.ram /l
:exmp.
:p.This would create a file called "MYFOLDER.RAM" which contains
the .ICO and the .CMD files.
:h1.Saving/Restoring Color Definitions and Schemes
:p.The &prod. package contains two additional REXX programs:
:ul.
:li.SAVECLR.CMD
:li.RESTCLR.CMD
:eul.
:p.To save the color definitions and schemes simply run SAVECLR from
an OS/2 command prompt.  This creates a file called "Colors.Dat" in
the current directory, which contains the definitions.  If this file
already exists, it will be overwritten unconditionally.
:p.To restore the colors and schemes run RESTCLR from an OS/2 command
prompt.
:lblbox.Important Note
:p.The font definitions of the schemes are not saved and restored.
:elblbox.
:h1.Summary of Changes
:dl.
:dthd.Date
:ddhd.Changes
:dt.92/12/18:dd.Version 1.0
:p.First release to OS2TOOLS
:dt.92/12/20:dd.Version 1.1
:p.Add open methods (minimized, etc.)
:p.Fix long lines in output
:dt.93/01/13:dd.Version 1.2
:p.Add panel support.
:dt.93/01/14:dd.Version 1.3
:p.Fix searching for the desktop directory
:dt.93/01/29:dd.Version 1.4
:p.Fix loop in node table
:p.Test it on OS/2 2.0 GA code (German version).
:dt.93/02/12:dd.Version 1.5
:p.Completely rewrite the "Parseobj" routine
:p.Add the OS/2 2.1 WIN-OS2 enhanced mode support
:dt.93/03/22:dd.Version 1.6
:p.Create User's Guide
:p.Add the output file dialog
:p.Change the WIN-OS2 enhanced mode support
:p.More fixes to "Parseobj"
:dt.93/04/30:dd.Version 1.7
:p.Show only folders which the user has allocated, not the OS/2 system
stuff.
:p.Add the "Save" Pushbutton
:p.Fix invalid quotes in the output.
:p.Fix invalid path for folder icons.
:p.Add the SAVECLR.CMD and RESTCLR.CMD to save/restore the color
definitions and schemes.
:p.Add the "Select all" pushbutton.
:p.Add a "Restrictions" topic to the documentation.
:p.Fix problems with multi-line object titles.
:dt.93/05/03:dd.Version 1.7a
:p.Add the /U command option to display only user folders.
:dt.93/05/04:dd.Version 1.7b
:p.Create the .FIL file.
:p.Document the creation of .ICO files.
:p.Add the /A flag to create the output with the commented commands.
:dt.93/05/10:dd.Version 1.8
:p.Fix trap if program name can't be determined (in Templates folder)
:p.Remove the /A flag, and the comments. Always create everything that
can be created, because otherwise migrated applications can't be
saved.
:dt.93/09/09:dd.Version 1.9
:p.Save parameter of ICONVIEW= and TREEVIEW=. Special thanks to Terry
A. Steilen for supplying this code.
:p.Save icons of program files. Also, thanks to Terry.
:p.Fix uppercase problem. Again, thanks to Terry.
:p.Use DrDialog instead of dBoxMgr2. (This is the only thing i did
myself...)
:dt.93/09/28:dd.Version 1.9a
:p.Make the program a .EXE file.
:p.Change the format of the output file.
:dt.93/09/30:dd.Version 1.9b
:p.Allow dropping of a folder on the SAVEFLDR object.
:dt.93/09/30:dd.Version 1.9c
:p.Sometimes a continuation comma is missing.
:dt.93/10/11:dd.Version 1.9d
:p.Everything is allocated on the desktop.
:p.Use SAVEFLDR.DLL instead of MYUTIL.
:dt.94/01/10:dd.Version 2.0
:p.Fix REXX trap when folder has never been opened.
:p.Add the /DBCS flag to set "OPTIONS EXMODE" to ensure DBCS character
integrity in file- and directory names.
:p.An invalid folder ID might be generated if it had no ID.
:p.The ICONFONT= parameter of a folder might be invalid.
:p.Improve performance.
:p.Add the "Save as" dialog.
:p.Save the information of empty folders.
:dt.94/03/18:dd.Version 2.1
:p.Fix REXX error 40 when the startupdir points to a drive.
:p.Fix upper/lower problem.
:p.Add some data to the trace for easier problem determination.
:p.Fix generated object IDs.
:p.Implement /s flag to show subdirectories, if folder dropped on
&prod..
:p.Add target drive parameter to output .CMD file.
:p.Add the /V flag.
:p.Erase the work files, if the output is not saved.
:dt.94/10/06:dd.Version 2.1a
:p.Build new .EXE file for OS/2 Warp.
:dt.94/10/18:dd.Version 2.1b
:p.Fix analyzing folders in OS/2 Warp Version 3.
:dt.94/12/01:dd.Version 2.1c
:p.Fix problem when DOS settings are longer than 256 characters.
:p.Make drive letter of desktop in output file a variable.
:edl.
:euserdoc.
