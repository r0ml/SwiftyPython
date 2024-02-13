#!/bin/sh

# After cloning:
git submodule init
git submodule update

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
rm -rf ncurses-5.9
