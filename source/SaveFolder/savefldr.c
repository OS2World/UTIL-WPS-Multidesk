/**********************************************************************
*   SAVEFLDR.C                                                        *
*                                                                     *
*   To compile:    MAKE SAVEFLDR                                      *
*                                                                     *
**********************************************************************/
/* Include files */

#define  INCL_WINWORKPLACE
#define  INCL_REXXSAA
#define  INCL_BASE
#define  INCL_VIO
#define  _DLL
#define  _MT
#define  INCL_DOSPROCESS
#include <os2.h>
#include <rexxsaa.h>
#include <memory.h>
#include <malloc.h>
#include <fcntl.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#define  IDM_LOCKUP     0x2c1
#define  IDM_SHUTDOWN   0x2c0

/*********************************************************************/
/*  Declare all exported functions as REXX functions.                */
/*********************************************************************/
RexxFunctionHandler SavGetEA;
RexxFunctionHandler SavPutEA;
RexxFunctionHandler SavLockUp;
RexxFunctionHandler SavShutDown;
RexxFunctionHandler SavBootDrive;
RexxFunctionHandler SavSetPriority;
RexxFunctionHandler SavLoadFuncs;
RexxFunctionHandler SavDropFuncs;

/*********************************************************************/
/*  Various definitions used by various functions.                   */
/*********************************************************************/

#define  MAX_DIGITS     9          /* maximum digits in numeric arg  */
#define  MAX            256        /* temporary buffer length        */
#define  IBUF_LEN       4096       /* Input buffer length            */
#define  AllocFlag      PAG_COMMIT | PAG_WRITE  /* for DosAllocMem   */

/*********************************************************************/
/*  Defines used by SysDriveMap                                      */
/*********************************************************************/

#define  USED           0
#define  FREE           1
#define  DETACHED       2
#define  REMOTE         3
#define  LOCAL          4

/*********************************************************************/
/* Structures used throughout REXXUTIL.C                             */
/*********************************************************************/

/*********************************************************************/
/* RxStemData                                                        */
/*   Structure which describes as generic                            */
/*   stem variable.                                                  */
/*********************************************************************/

typedef struct RxStemData {
    SHVBLOCK shvb;                     /* Request block for RxVar    */
    CHAR ibuf[IBUF_LEN];               /* Input buffer               */
    CHAR varname[MAX];                 /* Buffer for the variable    */
                                       /* name                       */
    CHAR stemname[MAX];                /* Buffer for the variable    */
                                       /* name                       */
    ULONG stemlen;                     /* Length of stem.            */
    ULONG vlen;                        /* Length of variable value   */
    ULONG j;                           /* Temp counter               */
    ULONG tlong;                       /* Temp counter               */
    ULONG count;                       /* Number of elements         */
                                       /* processed                  */
} RXSTEMDATA;

/*********************************************************************/
/* RxFncTable                                                        */
/*   Array of names of the REXXUTIL functions.                       */
/*   This list is used for registration and deregistration.          */
/*********************************************************************/

static PSZ  RxFncTable[] =
   {
      "SavGetEA",
      "SavPutEA",
      "SavLockUp",
      "SavShutDown",
      "SavBootDrive",
      "SavSetPriority",
      "SavLoadFuncs",
      "SavDropFuncs",
   };

/*********************************************************************/
/* Numeric Error Return Strings                                      */
/*********************************************************************/

#define  NO_UTIL_ERROR    "0"          /* No error whatsoever        */
#define  ERROR_NOMEM      "2"          /* Insufficient memory        */
#define  ERROR_FILEOPEN   "3"          /* Error opening text file    */

/*********************************************************************/
/* Alpha Numeric Return Strings                                      */
/*********************************************************************/

#define  ERROR_RETSTR   "ERROR:"

/*********************************************************************/
/* Numeric Return calls                                              */
/*********************************************************************/

#define  INVALID_ROUTINE 40            /* Raise Rexx error           */
#define  VALID_ROUTINE    0            /* Successful completion      */

/*********************************************************************/
/* Some useful macros                                                */
/*********************************************************************/

#define BUILDRXSTRING(t, s) { \
  strcpy((t)->strptr,(s));\
  (t)->strlength = strlen((s)); \
}

/*************************************************************************
***             <<<<<< REXXUTIL Functions Follow >>>>>>>               ***
***             <<<<<< REXXUTIL Functions Follow >>>>>>>               ***
***             <<<<<< REXXUTIL Functions Follow >>>>>>>               ***
***             <<<<<< REXXUTIL Functions Follow >>>>>>>               ***
*************************************************************************/

/*************************************************************************
* Function:  SavGetEA                                                    *
*                                                                        *
* Syntax:    call SavGetEA file, EA_name, variable                       *
*                                                                        *
* Params:    file - file containing EA.                                  *
*            EA_name - name of EA to be retrieved                        *
*            name of variable EA is placed in                            *
*                                                                        *
* Return:    Return code from DosQueryPathInfo.                          *
*************************************************************************/

ULONG SavGetEA(CHAR *name, ULONG numargs, RXSTRING args[],
                       CHAR *queuename, RXSTRING *retstr)
{
  LONG rc;                             /* Ret code                   */
  UCHAR       geabuff[300];            /* buffer for GEA             */
  PVOID       fealist;                 /* fealist buffer             */
  EAOP2       eaop;                    /* eaop structure             */
  PGEA2       pgea;                    /* pgea structure             */
  PFEA2       pfea;                    /* pfea structure             */
  HFILE       handle;                  /* file handle                */
  ULONG       act;                     /* open action                */
  RXSTEMDATA  ldp;                     /* stem data                  */


  if (numargs != 3 ||                  /* wrong number of arguments? */
      !RXVALIDSTRING(args[0]) ||
      !RXVALIDSTRING(args[1]) ||
      !RXVALIDSTRING(args[2]))
    return INVALID_ROUTINE;            /* raise error condition      */

  ldp.count = 0;                       /* get the stem variable name */
  strcpy(ldp.varname, args[2].strptr);
  ldp.stemlen = args[2].strlength;
  strupr(ldp.varname);                 /* uppercase the name         */

  if (DosAllocMem((PPVOID)&fealist, 0x00010000L, AllocFlag)) {
    BUILDRXSTRING(retstr, ERROR_NOMEM);
    return VALID_ROUTINE;
  }
                                       /* FEA and GEA lists          */
  eaop.fpGEA2List = (PGEA2LIST)geabuff;
  eaop.fpFEA2List = (PFEA2LIST)fealist;
  eaop.oError = 0;                     /* no error occurred yet      */
  pgea = &eaop.fpGEA2List->list[0];    /* point to first GEA         */
  eaop.fpGEA2List->cbList = sizeof(ULONG) + sizeof(GEA2) +
      args[1].strlength;
  eaop.fpFEA2List->cbList = (ULONG)0xffff;

                                       /* fill in the EA name length */
  pgea->cbName = (BYTE)args[1].strlength;
  strcpy(pgea->szName, args[1].strptr);/* fill in the name           */
  pgea->oNextEntryOffset = 0;          /* fill in the next offset    */
                                       /* read the extended attribute*/
  rc = DosQueryPathInfo(args[0].strptr, 3, (PSZ)&eaop, sizeof(EAOP2));
  if (eaop.fpFEA2List->cbList <= sizeof(ULONG))
    rc = ERROR_EAS_NOT_SUPPORTED;      /* this is error also         */

  sprintf(retstr->strptr, "%d", rc);   /* format return code         */
  retstr->strlength = strlen(retstr->strptr);

  if (rc) {                            /* failure?                   */
    DosFreeMem(fealist);               /* error, get out             */
    return VALID_ROUTINE;
  }

  pfea = &(eaop.fpFEA2List->list[0]);  /* point to the first FEA     */
  ldp.shvb.shvnext = NULL;
  ldp.shvb.shvname.strptr = ldp.varname;
  ldp.shvb.shvname.strlength = ldp.stemlen;
  ldp.shvb.shvnamelen = ldp.stemlen;
  ldp.shvb.shvvalue.strptr = ((PSZ)pfea->szName+(pfea->cbName+1));
  ldp.shvb.shvvalue.strlength = pfea->cbValue;
  ldp.shvb.shvvaluelen = ldp.shvb.shvvalue.strlength;
  ldp.shvb.shvcode = RXSHV_SET;
  ldp.shvb.shvret = 0;
  if (RexxVariablePool(&ldp.shvb) == RXSHV_BADN) {
    DosFreeMem(fealist);               /* free our buffer            */
    return INVALID_ROUTINE;            /* error on non-zero          */
  }

  DosFreeMem(fealist);                 /* free our buffer            */
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavPutEA                                                    *
*                                                                        *
* Syntax:    call SavPutEA file, EA_name, value                          *
*                                                                        *
* Params:    file - file containing EA.                                  *
*            EA_name - name of EA to be written                          *
*            new value for the EA                                        *
*                                                                        *
* Return:    Return code from DosSetPathInfo.                            *
*************************************************************************/

ULONG SavPutEA(CHAR *name, ULONG numargs, RXSTRING args[],
                       CHAR *queuename, RXSTRING *retstr)
{
  LONG rc;                             /* Ret code                   */
  PVOID       fealist;                 /* fealist buffer             */
  EAOP2       eaop;                    /* eaop structure             */
  PFEA2       pfea;                    /* pfea structure             */
  HFILE       handle;                  /* file handle                */
  ULONG       act;                     /* open action                */


  if (numargs != 3 ||                  /* wrong number of arguments? */
      !RXVALIDSTRING(args[0]) ||
      !RXVALIDSTRING(args[1]))
    return INVALID_ROUTINE;            /* raise error condition      */

  if (DosAllocMem((PPVOID)&fealist, 0x00010000L, AllocFlag)) {
    BUILDRXSTRING(retstr, ERROR_NOMEM);
    return VALID_ROUTINE;
  }

  eaop.fpFEA2List = (PFEA2LIST)fealist;/* Set memory for the FEA     */
  eaop.fpGEA2List = NULL;              /* GEA is unused              */
  pfea = &eaop.fpFEA2List->list[0];    /* point to first FEA         */
  pfea->fEA = '\0';                    /* set the flags              */
                                       /* Size of FEA name field     */
  pfea->cbName = (BYTE)args[1].strlength;
                                       /* Size of Value for this one */
  pfea->cbValue = (SHORT)args[2].strlength;
                                       /* Set the name of this FEA   */
  strcpy((PSZ)pfea->szName, args[1].strptr);
                                       /* Set the EA value           */
  memcpy((PSZ)pfea->szName+(pfea->cbName+1), args[2].strptr,
      args[2].strlength);
  pfea->oNextEntryOffset = 0;          /* no next entry              */
  eaop.fpFEA2List->cbList =            /* Set the total size var     */
      sizeof(ULONG) + sizeof(FEA2) + pfea->cbName + pfea->cbValue;

                                       /* set the file info          */
  rc = DosSetPathInfo(args[0].strptr, 2, (PSZ)&eaop, sizeof(EAOP2),0);
  DosFreeMem(fealist);                 /* Free the memory            */
  sprintf(retstr->strptr, "%d", rc);   /* format return code         */
  retstr->strlength = strlen(retstr->strptr);
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavLockUp                                                   *
*                                                                        *
* Syntax:    result = SavLockUp()                                        *
*                                                                        *
* Params:    NONE                                                        *
*                                                                        *
* Return:    None                                                        *
*************************************************************************/

ULONG SavLockUp(CHAR *name, ULONG numargs, RXSTRING args[],
                  CHAR *queuename, RXSTRING *retstr)
{
HWND deskTop = WinQueryWindow(HWND_DESKTOP,QW_BOTTOM);
  BUILDRXSTRING(retstr, "");
  WinPostMsg(deskTop,WM_COMMAND,MPFROMSHORT(IDM_LOCKUP),
             MPFROM2SHORT(CMDSRC_MENU,TRUE));
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavShutDown                                                 *
*                                                                        *
* Syntax:    result = SavShutDown()                                      *
*                                                                        *
* Params:    NONE                                                        *
*                                                                        *
* Return:    None                                                        *
*************************************************************************/

ULONG SavShutDown(CHAR *name, ULONG numargs, RXSTRING args[],
                  CHAR *queuename, RXSTRING *retstr)
{
HWND deskTop = WinQueryWindow(HWND_DESKTOP,QW_BOTTOM);
  BUILDRXSTRING(retstr, "");
  WinPostMsg(deskTop,WM_COMMAND,MPFROMSHORT(IDM_SHUTDOWN),
             MPFROM2SHORT(CMDSRC_MENU,TRUE));
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavBootDrive                                                *
*                                                                        *
* Syntax:    result = SavBootDrive()                                     *
*                                                                        *
* Return:    OS/2 Boot drive.                                            *
*************************************************************************/

ULONG SavBootDrive(CHAR *name, ULONG numargs, RXSTRING args[],
                        CHAR *queuename, RXSTRING *retstr)
{
  ULONG  rc = 0;                       /* Return code of this func   */
  UCHAR  BootDrive[4] = "0";           /* Boot drive number          */
  UCHAR  Drives[] = " ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  rc = DosQuerySysInfo(QSV_BOOT_DRIVE,QSV_BOOT_DRIVE,BootDrive,(ULONG)sizeof(BootDrive));
  if (rc) {
    sprintf(retstr->strptr, "%d", rc);   /* format return code         */
    retstr->strlength = strlen(retstr->strptr);
    return VALID_ROUTINE;
  }
  sprintf(retstr->strptr, "%c:", Drives[BootDrive[0]]);
  retstr->strlength = strlen(retstr->strptr);
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavSetPriority                                              *
*                                                                        *
* Syntax:    call SavSetPriority(Scope,Class,Delta)                      *
*                                                                        *
* Params:    Scope, Class and Delta                                      *
*                                                                        *
* Return:    0 = ok, else DosSetPriority rc                              *
*************************************************************************/

ULONG SavSetPriority(CHAR *name, ULONG numargs, RXSTRING args[],
                           CHAR *queuename, RXSTRING *retstr)
{
  ULONG Scope;
  ULONG Class;
  LONG Delta;
  ULONG rc;
  ULONG id=0;

#ifdef DEBUG
  INT    i;
  printf("%s - NumArgs=[%d]\n",  name, numargs);
  for (i=0; i < numargs; i++) printf("\t[%d] = [%s]\n", i, args[i].strptr);
#endif

  if (numargs != 3 ||                  /* wrong number of arguments? */
    !RXVALIDSTRING(args[0]) ||
    !RXVALIDSTRING(args[1]) ||
    !RXVALIDSTRING(args[2]))
    return INVALID_ROUTINE;            /* raise error condition      */

  sscanf(args[0].strptr,"%i",&Scope);
  sscanf(args[1].strptr,"%i",&Class);
  sscanf(args[2].strptr,"%d",&Delta);

  rc = DosSetPriority(Scope,Class,Delta,id);

  sprintf(retstr->strptr, "%d", rc);   /* format return code         */
  retstr->strlength = strlen(retstr->strptr);
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavLoadFuncs                                                *
*                                                                        *
* Syntax:    call SavLoadFuncs [option]                                  *
*                                                                        *
* Params:    none                                                        *
*                                                                        *
* Return:    null string                                                 *
*************************************************************************/

ULONG SavLoadFuncs(CHAR *name, ULONG numargs, RXSTRING args[],
                           CHAR *queuename, RXSTRING *retstr)
{
  INT    entries;                      /* Num of entries             */
  INT    j;                            /* Counter                    */

  retstr->strlength = 0;               /* set return value           */
                                       /* check arguments            */
  if (numargs > 0)
    return INVALID_ROUTINE;

  entries = sizeof(RxFncTable)/sizeof(PSZ);

  for (j = 0; j < entries; j++) {
    RexxRegisterFunctionDll(RxFncTable[j],
          "SAVEFLDR", RxFncTable[j]);
  }
  return VALID_ROUTINE;
}

/*************************************************************************
* Function:  SavDropFuncs                                                *
*                                                                        *
* Syntax:    call SavDropFuncs                                           *
*                                                                        *
* Return:    NO_UTIL_ERROR - Successful.                                 *
*************************************************************************/

ULONG SavDropFuncs(CHAR *name, ULONG numargs, RXSTRING args[],
                          CHAR *queuename, RXSTRING *retstr)
{
  INT     entries;                     /* Num of entries             */
  INT     j;                           /* Counter                    */

  if (numargs != 0)                    /* no arguments for this      */
    return INVALID_ROUTINE;            /* raise an error             */

  retstr->strlength = 0;               /* return a null string result*/

  entries = sizeof(RxFncTable)/sizeof(PSZ);

  for (j = 0; j < entries; j++)
    RexxDeregisterFunction(RxFncTable[j]);

  return VALID_ROUTINE;                /* no error on call           */
}
