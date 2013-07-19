/********************************************************
* ÊDesk - Multiple desktops/users application for OS/2  *
*         Copyright 2000-2001 Cristiano Guadagnino      *
*********************************************************
* Auxiliary functions for the administration program.   *
*********************************************************
* $Id: AuxFuncs.h,v 1.4 2001/10/15 11:01:51 u570082 Exp $
********************************************************/

#define  RETSTR_INVALID  40
#define  RETSTR_OK        0

RexxFunctionHandler AFGetBootDrive;
RexxFunctionHandler AFGetObjectHandle;
RexxFunctionHandler AFGetAbsPath;
RexxFunctionHandler AFDelTree;
RexxFunctionHandler AFCrypt;
RexxFunctionHandler AFLoadFuncs;
RexxFunctionHandler AFDropFuncs;


/********************************************************
* RxFncTable                                            *
*   Array of names of the auxiliary functions.          *
*   This list is used for registration and              *
*   deregistration.                                     *
********************************************************/

static PSZ RxFncTable[] = {
    "AFGetBootDrive",
    "AFGetObjectHandle",
    "AFGetAbsPath",
    "AFDelTree",
    "AFCrypt",
    "AFLoadFuncs",
    "AFDropFuncs"
};

