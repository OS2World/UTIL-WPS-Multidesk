/********************************************************
* ÊDesk - Multiple desktops/users application for OS/2  *
*         Copyright 2000-2001 Cristiano Guadagnino      *
*********************************************************
* $Id: mudesk.h,v 1.9 2001/10/15 11:00:39 u570082 Exp $
********************************************************/

#define     CRIS_DEBUG

#define     INCL_DOSMISC
#define     INCL_DOSPROCESS
#define     INCL_REXXSAA

#include    <os2.h>
#include    <stdio.h>
#include    <share.h>
#include    <string.h>
#include    <stdlib.h>
#include    <process.h>
#include    <signal.h>
#include    <pwd.h>
#include    <unistd.h>
#include    <time.h>
#include    <sys/video.h>
#include    <sys/kbdscan.h>
#include    <sys/winmgr.h>


// typedefs -------------------------------------------+
typedef struct _cfgstrings {
    char    default_user[256];
    int     du_timeout;
    BOOL    log_users;
    char    lu_file[256];
    char    root_name[256];
    BOOL    relaxed_security;
    int     saver_delay;
    char    usr_tree[_MAX_DIR];
} cfgstrings;

typedef enum _filetypes {
    datfile,
    bannerfile,
    cfgfile,
    lockfile,
    cmdfile
} filetypes;

// global constants -----------------------------------+
#ifdef CRIS_DEBUG
    const int SAVER_DELAY = 10;
#else
    const int SAVER_DELAY = 120;
#endif


// global variables -----------------------------------+
cfgstrings  CfgStr;
wm_handle   wh;
const int   cursor_max_line;
time_t      start_time;
BOOL        default_logon = FALSE;
BOOL        root_user = FALSE;


// prototypes -----------------------------------------+
     int   parse(char *aLine);
    void   lockup(void);
sigset_t   block_signals(void);
    void   alarm_handler(int sig);
    char  *getstr(char *buffer, BOOL echo);
    char  *getfilepath(char *fqfn, filetypes ftype);
    void   writelog(FILE *logfilehandle, char *logstring);
    void   parse_setup_file(char *setuppath, char *boot);
    void   init_video(void);
    void   display_banner(char *fn);
    void   process_locks(char *fn);
    void   create_last(char *mudesk_dir, char *user, BOOL IsRoot);
    void   run_script(char *ScriptFile, long NumArgs, RXSTRING *argv);
    void   pre_login_cmd(char *prelogin_path, char *boot);
    void   post_login_cmd(char *usr_tree, char *boot, char *user, char *uini_path, char *sini_path);
    int    check_pass(char *cfg_passwd, char *password);

    extern char *crypt(char *pw, char *salt);


// +-------------------------------------------------------------------+
// |            N O T E S   A N D   L I M I T A T I O N S              |
// +-------------------------------------------------------------------+
// |                                                                   |
// | 1) name and password are 256 chars max in length                  |
// |                                                                   |
// | 2) max length of cfg line: 2048 chars                             |
// |                                                                   |
// | 4) you can't have semicolons in the password or in the paths      |
// |                                                                   |
// | 5) max 512 lines of 512 chars max in the environment file         |
// |                                                                   |
// +-------------------------------------------------------------------+

