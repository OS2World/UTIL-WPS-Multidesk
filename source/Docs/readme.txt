
      MultiDesk 0.2.0 README
      (C) Cristiano Guadagnino, May 16, 2001
      Last updated May 16, 2001


      0. CONTENTS OF THIS FILE
      ========================

          1. INTRODUCTION
          2. INSTALLATION
          3. UPGRADE
          4. DEINSTALLATION
          5. LICENSE, COPYRIGHT, DISCLAIMER
          6. CREDITS
          7. CONTACT


      1. INTRODUCTION
      ===============

          Welcome to MultiDesk V0.2.0.

          MultiDesk is a program to enhance OS/2 (very) limited
          capabilities in managing multiple desktops and/or users.


          About this release
          ------------------

          This is a BETA version of MultiDesk, and as such it may
          include bugs or missing features.


      2. INSTALLATION
      ===============

          MultiDesk must be installed using WarpIN.

          ---> It is VERY important to MAKE A WPS BACKUP before
               installing and using.

          After installation, you can reboot to have MultiDesk started
          for the first time.

          MultiDesk will start with the current user configured as
          adminstrator ("root") user. Username and password are
          as follows:

            user: admin
            password: admin

          You'll find a "MultiDesk" folder on the desktop, and you
          can launch the administration program to start creating
          your new users/desktops!

          Please note that the administration program still has
          many unimplemented features.


          Note: Use WarpIN V0.9.8 or higher to install this archive.
          Version 0.9.6 had a nasty bug with target paths which was
          kind of annoying.


      3. UPGRADE
      ==========

          While it would be possible to upgrade to the new release, it
          is preferable to completely reinstall the package, due to the
          many differences and improvements in this release.

          To reinstall keeping your current desktops, follow the
          steps below:

          1) Backup your x:\Users directory (where x:\Users refers to
             the directory where you keep your users). This should not
             be necessary, but better safe than sorry.

          2) Reboot as root.

          3) Also backup your mudesk.cfg and mudesk.dat file.

          4) Remove MultiDesk with WarpIn (not necessary).
          
          5) If you've not removed MultiDesk, remove the read-only
             attribute from firstcfg.cmd (attrib -r firstcfg.cmd).

          6) Install the new release.

          7) Look if your users directories are all OK. If not,
             restore the wrong files from the backup. NOTE that
             there should be some new files and directories: this
             is OK.

          8) All users directories must have a WC subdirectory for
             multi-WarpCenter management. Add it as necessary.

             For the same reason, all users must have a mdstart.cmd
             file. The admin user should have this file automatically
             created; for the other users, copy the mdstart.usr 
             (NOTE the extension!!) file, and rename it to mdstart.cmd.

          9) Restore your mudesk.cfg and mudesk.dat files, if
             necessary (they shouldn't have been modified).

         10) Since this release features multi-WarpCenter management,
             it is advisable to backup you WarpCenter configuration,
             just to be sure. To do this, you can ZIP the DOCK*.CFG
             files in x:\OS2\DLL (where x: is your boot drive), and
             the SCENTER.CFG file in the same directory.

         11) You can now reboot.


      4. DEINSTALLATION
      =================

          Upon deinstallation with WarpIn, the "documentation" package
          does not get removed from the database.

          This is because WarpIn tries to remove the documentation
          objects after that it has removed the folder. Not finding
          those objects it fails, and doesn't remove the package.

          Rest assured that the objects have been removed from disk.
          You can safely remove the package from the database (using
          it's context-menu in WarpIn).


      5. LICENSE, COPYRIGHT, DISCLAIMER
      =================================

          Copyright (C) 2001 Cristiano Guadagnino.

          This program is free software; you can redistribute it,
          provided you don't ask a fee for it.

          The source code is NOT available (at least for now).

          This program is distributed in the hope that it will be useful,
          but WITHOUT ANY WARRANTY; without even the implied warranty of
          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


      6. CREDITS
      ==========

          I would like to say THANKS to a number of people that helped
          me during the development of MultiDesk. They're listed in no
          particular order. I've only a limited memory, and surely am
          forgetting some names. If you think I forgot to mention
          someone, plase write me.

          Yuri Dario    For many useful suggestions, and for pushing
                        me to implement some needed features.

          Georg Haschek For letting me have the sources of his invaluable
                        "SaveFolder" utility, and letting me use them at
                        my will. Georg, your sources have been a source
                        of inspiration, and an incredible learning tool.

          Paulo Dias    For taking the time to debug a tricky situation
                        where MultiDesk Administrator would not work.

          Netlabs       For their NOSA client interface to CVS.

          IBM           For a great operating system, and great
                        development tools.


      7. CONTACT
      ==========

          Cristiano Guadagnino

          TeamOS/2 Italy member
          OS/2 Warp Certified Engineer

          criguada@tin.it
          criguada@libero.it

