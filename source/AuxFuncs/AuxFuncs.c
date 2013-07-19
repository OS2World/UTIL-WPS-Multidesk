/********************************************************
* ÊDesk - Multiple desktops/users application for OS/2  *
*         Copyright 2000-2001 Cristiano Guadagnino      *
*********************************************************
* Auxiliary functions for the administration program.   *
*********************************************************
* $Id: AuxFuncs.c,v 1.4 2001/10/15 11:01:50 u570082 Exp $
********************************************************/

/* #define CRIS_DEBUG 1 */

#ifdef CRIS_DEBUG
#include    <share.h>
void TraceLog(char *);
#endif

#include    <sys/types.h>
#include    <dirent.h>
#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>

#define     INCL_REXXSAA
#define     INCL_RXFUNC
#define     INCL_WINWORKPLACE
#define     INCL_DOSMISC
#define     INCL_DOSFILEMGR
#define     INCL_DOSERRORS
#include    <os2.h>

#include    "AuxFuncs.h"

// Prototypes
int TraverseDir(char *);
int KillFiles(void);

extern char *crypt(char *pw, char *salt);

// Implementation

/*************************************************************************
* Function:  AFGetBootDrive                                              *
*************************************************************************/
ULONG AFGetBootDrive(PCSZ name,          /* Routine name */
                     ULONG numargs,      /* Number of arguments */
                     PRXSTRING args,     /* Null-terminated RXSTRINGs array */
                     PCSZ queuename,     /* Current external data queue name */
                     PRXSTRING retstr)   /* returning RXSTRING  */
{
    ULONG   BootDrive;
    char    cBootDrive[2];
    APIRET  rc;

    /* Check number of arguments */
    if (numargs != 0)
        return RETSTR_INVALID;

    rc = DosQuerySysInfo(QSV_BOOT_DRIVE, QSV_BOOT_DRIVE, (PVOID)(&BootDrive), sizeof(ULONG));
    cBootDrive[0] = BootDrive + 64;
    cBootDrive[1] = '\0';

    /* Copy the output string to the returned REXX string */
    strcpy(retstr->strptr,cBootDrive);
    retstr->strlength = strlen(cBootDrive);

    /* Success !!! */
    return RETSTR_OK;
}

/*************************************************************************
* Function:  AFGetObjectHandle                                           *
*************************************************************************/
ULONG AFGetObjectHandle(PCSZ name,          /* Routine name */
                        ULONG numargs,      /* Number of arguments */
                        PRXSTRING args,     /* Null-terminated RXSTRINGs array */
                        PCSZ queuename,     /* Current external data queue name */
                        PRXSTRING retstr)   /* returning RXSTRING  */
{
    char    string[50];
    HOBJECT ObjHandle;

    /* Check number of arguments */
    if (numargs != 1)
        return RETSTR_INVALID;

    /* The output string will be ERROR or the Handle value */
    ObjHandle = WinQueryObject(args[0].strptr);
    if(ObjHandle == NULLHANDLE)
        strcpy(string,"ERROR");
    else
        sprintf(string,"%lu",ObjHandle);

    /* Copy the output string to the returned REXX string */
    strcpy(retstr->strptr,string);
    retstr->strlength = strlen(string);

    /* Success !!! */
    return RETSTR_OK;
}

/*************************************************************************
* Function:  AFGetAbsPath                                                *
*************************************************************************/
ULONG AFGetAbsPath(PCSZ name,          /* Routine name */
                   ULONG numargs,      /* Number of arguments */
                   PRXSTRING args,     /* Null-terminated RXSTRINGs array */
                   PCSZ queuename,     /* Current external data queue name */
                   PRXSTRING retstr)   /* returning RXSTRING  */
{
    char    string[300];
    int     rc, i;

    /* Check number of arguments */
    if (numargs != 2)
        return RETSTR_INVALID;

    /* The output string will be ERROR or the Handle value */
    if(stricmp(args[1].strptr, "C") == 0)
        rc = _fullpath(string, args[0].strptr, 300);
    else
        rc = _abspath(string, args[0].strptr, 300);

    /* Now replace back all the forward slashes with backward ones */
    for(i = 0; i <= strlen(string); i++) {
        if(string[i] == '/')
            string[i] = '\\';
    }

    if(rc != 0)
        strcpy(string,"ERROR");

    /* Copy the output string to the returned REXX string */
    strcpy(retstr->strptr,string);
    retstr->strlength = strlen(string);

    /* Success !!! */
    return RETSTR_OK;
}

/*************************************************************************
* Function:  AFCrypt                                                     *
*************************************************************************/
ULONG AFCrypt(PCSZ name,          /* Routine name */
              ULONG numargs,      /* Number of arguments */
              PRXSTRING args,     /* Null-terminated RXSTRINGs array */
              PCSZ queuename,     /* Current external data queue name */
              PRXSTRING retstr)   /* returning RXSTRING  */
{
    if (numargs != 2)
        return RETSTR_INVALID;

    strcpy(retstr->strptr, crypt(args[0].strptr, args[1].strptr));
    retstr->strlength = strlen(retstr->strptr);
    return RETSTR_OK;
}

/*************************************************************************
* Function:  AFDelTree                                                   *
*************************************************************************/
ULONG AFDelTree(PCSZ name,          /* Routine name */
                ULONG numargs,      /* Number of arguments */
                PRXSTRING args,     /* Null-terminated RXSTRINGs array */
                PCSZ queuename,     /* Current external data queue name */
                PRXSTRING retstr)   /* returning RXSTRING  */
{
    char string[300];
    char curpath[512];

    /* Init string */
    strcpy(string, "");

    /* Check number of arguments */
    if (numargs != 1)
        return RETSTR_INVALID;

    /* Save current directory */
    if (_getcwd2(curpath, 512) == NULL) {
        strcpy(string, "ERROR");
    } else {
        if (TraverseDir(args[0].strptr) < 0)
            strcpy(string,"ERROR");
        else
            strcpy(string, "");
    }

    /* Reset the initial working directory */
    if (_chdir2(curpath) != 0)
        strcpy(string, "ERROR");

    /* Copy the output string to the returned REXX string */
    strcpy(retstr->strptr,string);
    retstr->strlength = strlen(string);

    /* Success !!! */
    return RETSTR_OK;
}

int KillFiles(void)
{
    DIR *d;
    struct dirent *s;
    int RetCode = 0;    /* 0 = OK; -1 = non-blocking error; -2 = blocking error */

    d = opendir(".");
    s = readdir(d);
    while (s != NULL) {
        if (((s->d_attr && A_DIR) == A_DIR) ||
            (strcmp(s->d_name, ".") == 0)   ||
            (strcmp(s->d_name, "..") == 0))
        {
            s = readdir(d);
        } else {
#ifdef CRIS_DEBUG
            if (remove(s->d_name) != 0) {
                TraceLog("KillFiles: error removing file");
                RetCode = -1;
            }
#else
            if (remove(s->d_name) != 0) RetCode = -1;
#endif
            s = readdir(d);
        }
    }
    closedir(d);

    return RetCode;
}

int TraverseDir(char *StartDir)
{
    DIR *d;
    struct dirent *s;
    int RetCode = 0;    /* 0 = OK; -1 = non-blocking error; -2 = blocking error */

    // Change directory
#ifdef CRIS_DEBUG
    if (_chdir2(StartDir) != 0) {
        char tmplog[256];

        sprintf(tmplog, "Could not enter directory %s.\n", StartDir);
        TraceLog(tmplog);
        return -2;
    }
#else
    if (_chdir2(StartDir) != 0) return -2;
#endif

    // Find all directories.
    d = opendir(".");
    s = readdir(d);
    while (s != NULL) {
        if ((s->d_attr & A_DIR) == A_DIR) {
            if ((strcmp(s->d_name, ".") == 0) || (strcmp(s->d_name, "..") == 0))
                s = readdir(d);
            else {
                if ((RetCode = TraverseDir(s->d_name)) < -1) {
                    closedir(d);
                    return -2;
                }
                s = readdir(d);
            }
        } else
            s = readdir(d);
    }

    // We have no more subdirs. Let's delete all files.
    if (KillFiles() < 0) RetCode = -1;

    _chdir2("..");
#ifdef CRIS_DEBUG
    if (rmdir(StartDir) != 0) {
        TraceLog("Could not remove directory");
        RetCode = -2;
    }
#else
    if (rmdir(StartDir) != 0) RetCode = -2;
#endif

    closedir(d);

    return RetCode;
}

#ifdef CRIS_DEBUG
void TraceLog(char *msg)
{
    FILE *fhLog;

    fhLog = _fsopen("f:\\afdbg.log", "a", SH_DENYNO);
    if (fhLog != NULL) {
        fprintf(fhLog, msg);
        fclose(fhLog);
    }
}
#endif


/*************************************************************************
* Function:  AFLoadFuncs                                                 *
*************************************************************************/
ULONG AFLoadFuncs(PCSZ name,          /* Routine name */
                  ULONG numargs,      /* Number of arguments */
                  PRXSTRING args,     /* Null-terminated RXSTRINGs array */
                  PCSZ queuename,     /* Current external data queue name */
                  PRXSTRING retstr)   /* returning RXSTRING  */
{
    int entries;                      /* Num of entries             */
    int j;                            /* Counter                    */

    retstr->strlength = 0;            /* set return value           */

    if (numargs > 0)                  /* check arguments            */
        return RETSTR_INVALID;

    entries = sizeof(RxFncTable)/sizeof(PSZ);

    for (j = 0; j < entries; j++) {
        RexxRegisterFunctionDll(RxFncTable[j],
                                "AUXFUNCS", RxFncTable[j]);
    }
    return RETSTR_OK;
}

/*************************************************************************
* Function:  AFDropFuncs                                                 *
*************************************************************************/
ULONG AFDropFuncs(PCSZ name,          /* Routine name */
                  ULONG numargs,      /* Number of arguments */
                  PRXSTRING args,     /* Null-terminated RXSTRINGs array */
                  PCSZ queuename,     /* Current external data queue name */
                  PRXSTRING retstr)   /* returning RXSTRING  */
{
    int entries;                      /* Num of entries             */
    int j;                            /* Counter                    */

    if (numargs != 0)                 /* no arguments for this      */
        return RETSTR_INVALID;        /* raise an error             */

    retstr->strlength = 0;            /* return a null string result*/

    entries = sizeof(RxFncTable)/sizeof(PSZ);

    for (j = 0; j < entries; j++)
        RexxDeregisterFunction(RxFncTable[j]);

    return RETSTR_OK;                 /* no error on call           */
}

