#!/bin/sh

#####
# ncurses is no longer located where it used to be.
# so instead of ftp'ing the patches, one needs to check out the patched
# snapshots repo and check out the desired patch level.

# Then, the build-installer.py script needs to be modified to contain the
# md5 hash for the tar file created from that repo.
# The script checks the hash to validate the download, then uses the local file
# if the hash matches. Otherwise, it will download again.
                
git clone https://github.com/ThomasDickey/ncurses-snapshots

cd ncurses-snapshots
git checkout v5_9_20120616
cd ..

mv ncurses-snapshots ncurses-5.9

tar --exclude .git -zcvf ncurses-5.9.tar.gz ncurses-5.9

mv ncurses-5.9.tar.gz ~/Repositories/SwiftyPython/other/ncurses-5.9.tar.gz

CD ~/Repositories/SwiftyPython/other
md5 ncurses-5.9.tar.gz

cd ~Repositories/SwiftyPython/cpython/Mac/BuildScript
python3 build-installer.py --universal-archs=universal2 --third-party=../../../other --dep-target=10.9


###
# the framework winds up here:
# /tmp/_py/_root/Library/Frameworks/Python.framework/

