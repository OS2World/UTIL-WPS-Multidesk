/********************************************************
* ÊDesk - Multiple desktops/users application for OS/2  *
*         Copyright 2000-2001 Cristiano Guadagnino      *
*********************************************************
* $Id: mudesk.c,v 1.7 2001/10/15 11:00:39 u570082 Exp $
********************************************************/

#include "mudesk.h"

int main(int argc, char *argv[])
{
    char    voidstring[2]="";
    char    nome[256]="", *cfg_nome;
    char    password[256]="", *cfg_passwd;

    char    *user_ini_path, *system_ini_path;
    char    *envfile_path;
    char    protshell_path[256];
    char    *runworkplace_path;

    FILE    *fhDat, *fhEnv;     // fhDat: file with definitions for the users
                                // fhEenv: file with user' environment settings

    FILE    *fhUIni, *fhSIni;   // fh[US]Ini: user/system_ini file

    FILE    *fhBootLog;         // fhBootLog: file with info on users' logins

    char    cfgline[2048], envline[2048];

    char    env_uini[1024];
    char    env_sini[1024];
    char    env_runwp[1024];
    char    env_gen[512][512];

    ULONG   BootDrive;
    char    cBootDrive[2];
    APIRET  rc;
    int     idx, p;
    BOOL    LoginFail;


#ifndef CRIS_DEBUG
    sigset_t    OldSet;

    // First of all let's block all signal: we don't want to let people
    // break out of login
    sigemptyset(&OldSet);
    OldSet = block_signals();
#endif

    // Initialize setup strings to sensible values
    CfgStr.default_user[0]  = '\0';
    CfgStr.du_timeout       = 0;
    CfgStr.log_users        = FALSE;
    CfgStr.lu_file[0]       = '\0';
    strcpy(CfgStr.root_name, "root");
    CfgStr.saver_delay      = 120;
    CfgStr.relaxed_security = FALSE;

    rc = DosQuerySysInfo(QSV_BOOT_DRIVE, QSV_BOOT_DRIVE, (PVOID)(&BootDrive), sizeof(ULONG));
    cBootDrive[0] = BootDrive + 64;
    cBootDrive[1] = '\0';

    strcpy(CfgStr.usr_tree, cBootDrive);
    strcat(CfgStr.usr_tree, ":\\Users");

    // Let's parse the setup file, so that we know what to do next
    parse_setup_file(getfilepath(argv[0], cfgfile), cBootDrive);

    // Initialize the pointer to cfg_passwd, or it will cause problems later
    cfg_passwd = voidstring;

    // Initialize the video library
    init_video();

    // Initialize the text-mode windowing library, and create the screen-saver
    // window (just a black-on-black big window to cover the entire screen).
    wm_init(2);
    wh = wm_create(0, 0, 100, 100, 0, B_BLACK|B_BLACK, B_BLACK|B_BLACK);

    // Install the timeout signal handler
    signal(SIGALRM, alarm_handler);

    // Start screen-saver counter
    alarm(CfgStr.saver_delay);

    // Open DAT file
    fhDat = _fsopen(getfilepath(argv[0], datfile), "r", SH_DENYRW);
    if (fhDat == NULL) {
        printf("Error opening 'DAT' file.\n");
        lockup();
    }

    // Display banner
    display_banner(argv[0]);

    // Process the pre-login rexx script
    pre_login_cmd(getfilepath(argv[0], cmdfile), cBootDrive);

    // Main login loop
    LoginFail = FALSE;
    p = 3;
    while(TRUE) {
        for(idx = 0; idx < 3; idx++) {

            start_time = time(NULL);
            printf("Login: ");
            getstr(nome, TRUE);

            // Is it the root that tries to log in?
            if(strcmp(CfgStr.root_name, nome) == 0)
                root_user = TRUE;
            else
                root_user = FALSE;

            if(((!default_logon)&&(!CfgStr.relaxed_security))||(root_user)) {
                printf("Password: ");
                getstr(password, FALSE);
            } else {
                if(default_logon)
                    printf("\n\nTimeout expired. Logging in with default user...\n");
                else // Must be CfgStr.relaxed_security = TRUE
                    if(strcmp("", nome) == 0) strcpy(nome, CfgStr.default_user);
            }

            // Past this point, I have a user name in every case.

            // Let's read the DAT string.
            while(fgets(cfgline, 2048, fhDat) != NULL) {
                cfg_nome = strtok(cfgline, ";");
                if (strcmp(cfg_nome, nome) == 0) {
                    cfg_passwd = strtok(NULL, ";");
                    runworkplace_path = strtok(NULL, ";");
                    user_ini_path = strtok(NULL, ";");
                    system_ini_path = strtok(NULL, ";");
                    envfile_path = strtok(NULL, ";\n");
                    break;
                }
            }

            // Does the user exists?
            if (strcmp(cfg_nome, nome) != 0) {
                LoginFail = TRUE;
                default_logon = FALSE;
            } else {
                LoginFail = FALSE;
            }

            if(((!default_logon)&&(!CfgStr.relaxed_security))||(root_user)) {
                // Is the password correct?
                if ((check_pass(cfg_passwd, password) != 0) || (LoginFail)) {
                    printf("Wrong user and/or password.\n\n");
                    LoginFail = TRUE;
                } else {
                    LoginFail = FALSE;
                    break;
                }
            } else
                if(!LoginFail) break;

            fseek(fhDat, 0L, SEEK_SET);
        }
        if(LoginFail) {
            sleep(p);
            p = p * 2;
            printf("\n\n\n");
            if(CfgStr.log_users) {
                char tmplog[256];
                fhBootLog = _fsopen(CfgStr.lu_file, "a", SH_DENYRW);
                if (fhBootLog != NULL) {
                    sprintf(tmplog, "Failed login for user %s", nome);
                    writelog(fhBootLog, tmplog);
                    fclose(fhBootLog);
                }
            }
        } else
            break;
    }

    printf("\n\n");

    // Does the user INI file exists?
    printf("Checking user INI file existence...");
    fhUIni = fopen(user_ini_path, "r");
    if (fhUIni == NULL) {
        printf("USER_INI file not found.\n");
        lockup();
    } else {
        fclose(fhUIni);
    }
    printf(" found.\n");

    // Let's set the USER_INI env variable
    printf("Setting USER_INI variable...");
    strcpy(env_uini, "USER_INI=");
    strcat(env_uini, user_ini_path);
    if (putenv(env_uini) != 0) {
        printf("Error setting environment variables.\n");
        lockup();
    }
    printf(" success.\n");

    // Does the system INI file exists?
    printf("Checking system INI file existence...");
    fhSIni = fopen(system_ini_path, "r");
    if (fhSIni == NULL) {
        printf("SYSTEM_INI file not found.\n");
        lockup();
    } else {
        fclose(fhSIni);
    }
    printf(" found.\n");

    // Let's set the SYSTEM_INI env variable
    printf("Setting SYSTEM_INI variable...");
    strcpy(env_sini, "SYSTEM_INI=");
    strcat(env_sini, system_ini_path);
    if (putenv(env_sini) != 0) {
        printf("Error setting environment variables.\n");
        lockup();
    }
    printf(" success.\n");

    // ..and set the RUNWORKPLACE env variable
    printf("Setting RUNWORKPLACE variable...");
    strcpy(env_runwp, "RUNWORKPLACE=");
    strcat(env_runwp, runworkplace_path);
    if (putenv(env_runwp) != 0) {
        printf("Error setting environment variables.\n");
        lockup();
    }
    printf(" success.\n");

    // Does the user-supplied environment file exists?
    printf("Checking user environment file existence...");
    fhEnv = fopen(envfile_path, "r");
    if (fhEnv != NULL) {
        printf(" found.\n");
        printf("Setting user environment variables...");
        for(idx = 0; fgets(envline, 2048, fhEnv) != NULL; idx++) {
            while(parse(strtok(envline, "\n")) != -1);
            strcpy(env_gen[idx], envline);
            if (putenv(env_gen[idx]) != 0) {
                printf("Error setting environment variables.\n");
                lockup();
            }
        }
        fclose(fhEnv);
        printf(" success.\n");
    } else {
        printf(" not found.\n");
    }

    // Set the PMSHELL (PROTSHELL) path
    strcpy(protshell_path, cBootDrive);
    strcat(protshell_path, ":\\OS2\\PMSHELL.EXE");

    // If the root user logged in, let's free all the files
    if(CfgStr.log_users) {
        if(root_user) {
            fcloseall();
            fhBootLog = _fsopen(CfgStr.lu_file, "a", SH_DENYNO);
        } else
            fhBootLog = _fsopen(CfgStr.lu_file, "a", SH_DENYRW);

        if (fhBootLog == NULL)
            CfgStr.log_users = FALSE;
    } else {
        if(root_user)
            fcloseall();
    }

    // Process the user-selectable locked files.
    printf("Locking custom files...");
    if (!root_user) process_locks(argv[0]);
    printf(" done.\n");

    // Process the post-login rexx script
    printf("Processing post-login script...");
    post_login_cmd(CfgStr.usr_tree, cBootDrive, nome, user_ini_path, system_ini_path);
    printf(" done.\n");

    // Write the "last" file
    create_last(argv[0], nome, root_user);

    // OK, we're done. Spawn the shell.
#ifdef CRIS_DEBUG
    printf("\nAll done. Starting the ProtShell.\n\n");
    if (spawnl(P_NOWAIT, "E:\\OS2\\CMD.EXE", "E:\\OS2\\CMD.EXE", (char *)NULL) == -1) {
        printf("Error spawning child program.");
        lockup();
    }
#else
    sigprocmask(SIG_SETMASK, &OldSet, NULL);

    printf("\nAll done. Starting the ProtShell.\n\n");
    if (spawnl(P_NOWAIT, protshell_path, protshell_path, (char *)NULL) == -1) {
        printf("Error spawning child program.");
        block_signals();
        lockup();
    }
#endif

    // We're now terminating. Let's write the log.
    if(CfgStr.log_users) {
        char tmplog[256];

        if(default_logon)
            sprintf(tmplog, "User %s logged in (auto-login at timeout)", nome);
        else
            sprintf(tmplog, "User %s logged in", nome);

        writelog(fhBootLog, tmplog);
    }

    exit(0);
}

void init_video(void)
{
    // Initialize the video library, then clear the screen and put the cursor
    // in the top left-hand corner. Finally get the height of the character box.
    v_init();
    v_clear();
    v_gotoxy(0, 1);

    switch(v_hardware()) {
        case V_MONOCHROME:
                printf("Unsupported video hardware.\n");
                lockup();
                break;

        case V_COLOR_8:
                cursor_max_line = 8;
                break;

        case V_COLOR_12:
                cursor_max_line = 12;
                break;
    }
}

void display_banner(char *fn)
{
    char  bnrline[80];
    FILE *fhBnr;        // fhBnr: "banner" shown just before the login prompt

    // Open banner file
    fhBnr = fopen(getfilepath(fn, bannerfile), "r");

    // Output the banner, if it exists
    if (fhBnr != NULL) {
        while(fgets(bnrline, 80, fhBnr) != NULL) {
            printf("%s", bnrline);
        }
        fclose(fhBnr);
    }
}

int parse(char *aLine)
{
    // This function parses an environment line from the user-supplied env file.
    // If it finds variable arguments (e.g.  PATH=G:\CRIS;%PATH%) it expands
    // them with the current environment.

    // Returns 0 (OK) or -1 (not found)

    int         i, j, prevchar;
    char        buildline[512];
    char        newline[512];
    char        tail[512];
    BOOL        invar, found;

    // Expand the environment variables
    invar = FALSE;
    found = FALSE;
    j = 0;

    for(i=0; i<=strlen(aLine); i++) {
        if(aLine[i] == '%') {
            invar = !invar;         // Flips the indicator

            if(invar) {             // A variable begins
                aLine[i] = '\0';
                strcpy(newline, aLine);
                aLine[i] = '%';
                j = 0;
                continue;
            }

            if(!invar) {            // A variable ends
                found = TRUE;
                buildline[j] = '\0';
                if(getenv(buildline) != NULL) {
                    strcat(newline, getenv(buildline));
                }
                strcpy(tail, &aLine[i+1]);
                strcpy(aLine, newline);
                if(tail[0] != ';')
                    strcat(aLine, ";");
                strcat(aLine, tail);
            }
        }

        if(aLine[i] == ';')
            invar = FALSE;          // Reset indicator

        if(invar) {
            buildline[j] = aLine[i];
            j++;
        }
    }


    // Remove double semicolons
    prevchar = ' ';
    j = 0;

    for(i=0; i<=strlen(aLine); i++) {
        if((aLine[i] == ';') && (aLine[i] == prevchar))
            ;
        else {
            buildline[j] = aLine[i];
            j++;
        }
        prevchar = aLine[i];
    }
    buildline[j] = '\0';
    strcpy(aLine, buildline);

    // Return to the calling function with result indicator
    if(found)
        return(0);
    else
        return(-1);
}

// Simple function to wait indefinitely for a user action.
void lockup(void)
{
    printf("\nCorrect the preceding errors and retry.\n\n");
    printf("Please reboot now, pressing CTRL+ALT+DEL.\n");
    while(TRUE)
        sleep(1);
}

// Blocks all interrupt signals, except SIGALARM,
// which is needed for the screen-saver.
sigset_t block_signals(void)
{
    sigset_t s, o;

    sigemptyset(&o);
    sigfillset(&s);
    sigdelset(&s, SIGALRM);
    sigprocmask(SIG_BLOCK, &s, &o);
    return(o);
}

// Manage the screen saver window
void alarm_handler(int sig)
{
    v_hidecursor();
    wm_open(wh);

    signal(sig, SIG_ACK);
    alarm(CfgStr.saver_delay);
}

// Get a string from the user, with various options.
char *getstr(char *buffer, BOOL echo)
{
    int tch = 0, bytepos = 0;


    v_ctype(cursor_max_line - 1, cursor_max_line);

    while(TRUE) {
        tch = _read_kbd(0, 0, 0);
        switch (tch) {
            case -1:
                _sleep2(50);
                if(CfgStr.du_timeout > 0)
                    if((time_t)(start_time + CfgStr.du_timeout) < time(NULL)) {
                        if(strcmp(CfgStr.default_user, "\0") != 0) {
                            default_logon = TRUE;
                            strcpy(buffer, CfgStr.default_user);
                            return buffer;
                        }
                    }
                break;
            case 0:
                start_time = time(NULL);
                _read_kbd(echo, 0, 0);
                wm_close(wh);
                v_ctype(cursor_max_line - 1, cursor_max_line);
                alarm(CfgStr.saver_delay);
                break;
            case 13:
                start_time = time(NULL);
                buffer[bytepos] = '\0';
                wm_close(wh);
                v_ctype(cursor_max_line - 1, cursor_max_line);
                printf("\n");
                alarm(CfgStr.saver_delay);
                return buffer;
            default:
                start_time = time(NULL);
                buffer[bytepos] = tch;
                bytepos++;
                wm_close(wh);
                v_ctype(cursor_max_line - 1, cursor_max_line);
                if(echo)
                    printf("%c", tch);
                else
                    printf("*");
                alarm(CfgStr.saver_delay);
                break;
        }
    }
}

// Returns the fully-qualified file name (FQFN) of
// a file in the startup dir of MuDesk.
char *getfilepath(char *fqfn, filetypes ftype)
{
    char drive[_MAX_DRIVE], dir[_MAX_DIR];
    char *filepath;

    filepath = malloc((size_t)_MAX_PATH);
    _splitpath(fqfn, drive, dir, NULL, NULL);

    switch(ftype) {
        case datfile:
            _makepath(filepath, drive, dir, "mudesk", "dat");
            break;
        case bannerfile:
            _makepath(filepath, drive, dir, "mudesk", "bnr");
            break;
        case cfgfile:
            _makepath(filepath, drive, dir, "mudesk", "cfg");
            break;
        case lockfile:
            _makepath(filepath, drive, dir, "mudesk", "lck");
            break;
        case cmdfile:
            _makepath(filepath, drive, dir, "mdstart", "cmd");
            break;
    }

    return(filepath);
}

void writelog(FILE *fhLog, char *logstring)
{
    time_t now;
    struct tm *now2;
    char log[255];
    char month[3];

    // get time and date and write it
    now = time(NULL);
    now2 = localtime(&now);

    switch(now2->tm_mon) {
        case 0:
            strcpy(month, "Jan");
            break;
        case 1:
            strcpy(month, "Feb");
            break;
        case 2:
            strcpy(month, "Mar");
            break;
        case 3:
            strcpy(month, "Apr");
            break;
        case 4:
            strcpy(month, "May");
            break;
        case 5:
            strcpy(month, "Jun");
            break;
        case 6:
            strcpy(month, "Jul");
            break;
        case 7:
            strcpy(month, "Aug");
            break;
        case 8:
            strcpy(month, "Sep");
            break;
        case 9:
            strcpy(month, "Oct");
            break;
        case 10:
            strcpy(month, "Nov");
            break;
        case 11:
            strcpy(month, "Dec");
            break;
    }

    sprintf(log,
            "+ %02d %s %02d:%02d:%02d - %s",
            now2->tm_mday,
            month,
            now2->tm_hour,
            now2->tm_min,
            now2->tm_sec,
            logstring);

    fprintf(fhLog, log);
    fprintf(fhLog, "\n");
}

void parse_setup_file(char *setuppath, char *boot)
{
    char    setupline[300];
    char    *firsttoken, *secondtoken;
    FILE    *fhSetup;   // fhSetup: file with operating settings


    // Open setup file
    fhSetup = _fsopen(setuppath, "r", SH_DENYRW);

    // Parse the setup file
    if (fhSetup != NULL) {
        while(fgets(setupline, 299, fhSetup) != NULL) {
            firsttoken = strtok(setupline, " =");

            if(strcmp(firsttoken, "default_user") == 0) {
                secondtoken = strtok(NULL, "\n\0");
                if(secondtoken == NULL)
                    strcpy(CfgStr.default_user, "\0");
                else
                    strcpy(CfgStr.default_user, secondtoken);
            }
            else if(strcmp(firsttoken, "default_user_timeout") == 0) {
                secondtoken = strtok(NULL, "\0");
                CfgStr.du_timeout = atoi(secondtoken);
            }
            else if(strcmp(firsttoken, "root_user") == 0) {
                secondtoken = strtok(NULL, "\n\0");
                if(secondtoken == NULL)
                    strcpy(CfgStr.root_name, "root");
                else
                    strcpy(CfgStr.root_name, secondtoken);
            }
            else if(strcmp(firsttoken, "relaxed_security") == 0) {
                secondtoken = strtok(NULL, "\n\0");
                if(stricmp(secondtoken, "yes") == 0)
                    CfgStr.relaxed_security = TRUE;
                else
                    CfgStr.relaxed_security = FALSE;
            }
            else if(strcmp(firsttoken, "ssaver_timeout") == 0) {
                secondtoken = strtok(NULL, "\0");
                CfgStr.saver_delay = atoi(secondtoken);
                if(CfgStr.saver_delay == 0)
                    CfgStr.saver_delay = SAVER_DELAY;
            }
            else if(strcmp(firsttoken, "log_users_file") == 0) {
                secondtoken = strtok(NULL, "\n\0");
                if(secondtoken == NULL)
                    strcpy(CfgStr.lu_file, "\0");
                else
                    strcpy(CfgStr.lu_file, secondtoken);
            }
            else if(strcmp(firsttoken, "log_users") == 0) {
                secondtoken = strtok(NULL, "\n\0");
                if(stricmp(secondtoken, "yes") == 0)
                    CfgStr.log_users = TRUE;
                else
                    CfgStr.log_users = FALSE;
            }
            else if(strcmp(firsttoken, "users_tree") == 0) {
                secondtoken = strtok(NULL, "\n\0");
                if(secondtoken == NULL) {
                    strcpy(CfgStr.usr_tree, boot);
                    strcat(CfgStr.usr_tree, ":\\Users");
                } else
                    strcpy(CfgStr.usr_tree, secondtoken);
            }
        }
        if(CfgStr.du_timeout == 0) {
            strcpy(CfgStr.default_user, "\0");
            CfgStr.du_timeout = 864000;
        }
        if(strcmp(CfgStr.root_name, CfgStr.default_user) == 0) {
            printf("Error in CFG file: root can't be the default user.\n");
            lockup();
        }
    }
}

void process_locks(char *fn)
{
    FILE    *fhLocks;
    int     idx;
    char    lckline[512];

    fhLocks = _fsopen(getfilepath(fn, lockfile), "r", SH_DENYRW);
    if (fhLocks != NULL) {
        //for(idx = 0; fgets(lckline, 512, fhLocks) != NULL; idx++) {
        for(idx = 0; fscanf(fhLocks, "%s", lckline) != EOF; idx++) {
#ifdef CRIS_DEBUG
            printf("Locking file %s.\n", lckline);
#endif
            if (_fsopen(lckline, "r", SH_DENYRW) == NULL)
                printf("Warning: could not lock file %s.\n", lckline);
        }
        if(root_user) fclose(fhLocks);
    }
}

void create_last(char *mudesk_dir, char *user, BOOL IsRoot)
{
    char drive[_MAX_DRIVE], dir[_MAX_DIR];
    char *filepath;
    FILE *fhLast;

    filepath = malloc((size_t)_MAX_PATH);
    _splitpath(mudesk_dir, drive, dir, NULL, NULL);
    _makepath(filepath, drive, dir, "last", NULL);

    fhLast = _fsopen(filepath, "w", SH_DENYRW);
    if (fhLast != NULL)
        fprintf(fhLast, "%s", user);

    if (IsRoot) fclose(fhLast);
}

void run_script(char *ScriptFile, long NumArgs, RXSTRING *argv)
{
    long      return_code;  // interpreter return code
    RXSTRING  retstr;       // program return value
    short     rc;           // converted return code

    retstr.strptr=(char *)malloc((size_t)1024);
    retstr.strlength=1024;

    return_code = RexxStart(NumArgs,      // # of arguments
                            argv,         // Arguments
                            ScriptFile,   // File name
                            NULL,         // NULL InStore
                            "CMD",        // Use the "CMD" command processor
                            RXCOMMAND,    // Execute as a command
                            NULL,         // No exit handlers
                            &rc,          // Return code from REXX routine
                            &retstr);     // Return string from REXX routine

    free(retstr.strptr);
}

void pre_login_cmd(char *prelogin_path, char *boot)
{
    char drive[_MAX_DRIVE], dir[_MAX_DIR];
    char *filepath;
    char last_user[256] = "";
    RXSTRING argv[2];       // program argument string
    FILE *fhPreLogin;
    FILE *fhPostLoginTemplate;
    FILE *fhLast;

    argv[0].strptr = boot;
    argv[0].strlength = strlen(boot);

    filepath = malloc((size_t)_MAX_PATH);
    _splitpath(prelogin_path, drive, dir, NULL, NULL);
    _makepath(filepath, drive, dir, "last", "");
    fhLast = fopen(filepath, "r");
    if (fhLast == NULL) {
        argv[1].strptr = NULL;
        argv[1].strlength = 0;
    } else {
        if (fscanf(fhLast, "%s", last_user) != EOF) {
            argv[1].strptr = last_user;
            argv[1].strlength = strlen(last_user);
        } else {
            argv[1].strptr = NULL;
            argv[1].strlength = 0;
        }
        fclose(fhLast);
    }

    _splitpath(prelogin_path, drive, dir, NULL, NULL);
    _makepath(filepath, drive, dir, "mdstart", "usr");
    fhPostLoginTemplate = _fsopen(filepath, "r", SH_DENYRW);

    fhPreLogin = fopen(prelogin_path, "r");
    if (fhPreLogin == NULL)
        return;
    else {
        fclose(fhPreLogin);
        run_script(prelogin_path, 2L, argv);
        fhPreLogin = _fsopen(prelogin_path, "r", SH_DENYRW);
    }
}

void post_login_cmd(char *usr_tree, char *boot, char *user, char *uini_path, char *sini_path)
{
    RXSTRING argv[5];       // program argument string
    char *filepath;
    FILE *fhCmd;

    argv[0].strptr = boot;
    argv[0].strlength = strlen(boot);

    argv[1].strptr = user;
    argv[1].strlength = strlen(user);

    argv[2].strptr = uini_path;
    argv[2].strlength = strlen(uini_path);

    argv[3].strptr = sini_path;
    argv[3].strlength = strlen(sini_path);

    argv[4].strptr = usr_tree;
    argv[4].strlength = strlen(usr_tree);

    filepath = malloc((size_t)_MAX_PATH);
    strcpy(filepath, usr_tree);
    if (filepath[strlen(filepath) - 1] != '\\') strcat(filepath, "\\");
    strcat(filepath, user);
    strcat(filepath, "\\mdstart.cmd");
#ifdef CRIS_DEBUG
    printf(" filepath: %s... ", filepath);
#endif

    fhCmd = fopen(filepath, "r");
    if (fhCmd == NULL)
        return;
    else {
        fclose(fhCmd);
        run_script(filepath, 5L, argv);
    }
}

int check_pass(char *cfg_passwd, char *password)
{
    char cfg_salt[3];

    strncpy(cfg_salt, cfg_passwd, 2);
    cfg_salt[2] = '\0';

    return strcmp(cfg_passwd, crypt(password, cfg_salt));
}

