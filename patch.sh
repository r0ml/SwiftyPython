#!/bin/sh

#  patch.sh
#  SwiftyPython
#
#  Created by Robert M Lefkowitz on 2/1/24.
#  Copyright (c) 1868 Charles Babbage

cd cpython

# change the checksum so that the local version of ncurses will be used
sed -I '' "s/checksum='8cb9c412e5f2d96bc6f459aa8c6282a1',/checksum='1a29175f7c0135d0d44044b6b1108074',/" Mac/BuildScript/build-installer.py

# remove the reference to the patchscript -- since I'm using a snapshot
sed -I '' '/ftp\:\/\/ftp.invisible-island\.net\/ncurses\/\/5\.9/{N;d;}' Mac/BuildScript/build-installer.py

# if /tmp is not on the same volume as this directory, the rename will fail
sed -I '' 's/os.rename(htmlDir, docdir)/shutil.copytree(htmlDir, docdir)/' Mac/BuildScript/build-installer.py
