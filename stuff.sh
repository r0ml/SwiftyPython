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

cd ~/Repositories/SwiftyPython/other
md5 ncurses-5.9.tar.gz

####################################################################
# the above was done and committed to SwiftyPython repo -- only need to possibly repeat for newer
# version of cpython
####################################################################

# After cloning:
git submodule init
git submodule update


########################################################

# stuff I haven't used
# xcodebuild -create-xcframework \
    -library build/simulators/libMyStaticLib.a \
    -library build/devices/libMyStaticLib.a \
    -output build/MyStaticLib.xcframework

# libssl
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libssl.3.dylib @loader_path/../../libssl.3.dylib /Users/r0ml/Library/Developer/Xcode/DerivedData/CaerbannogSample-cxekduypjjvbmpbscvretmxkqmdu/Build/Products/Debug/CaerbannogSample.app/Contents/Frameworks/Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so

# libcrypto
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @loader_path/../../libcrypto.3.dylib /Users/r0ml/Library/Developer/Xcode/DerivedData/CaerbannogSample-cxekduypjjvbmpbscvretmxkqmdu/Build/Products/Debug/CaerbannogSample.app/Contents/Frameworks/Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so

# in Products/Library/Frameworks
# install_name_tool -id "@loader_path/../Frameworks/Python.framework/Versions/3.12/Python" Python

############################################################
# problem created by attempting to cross device link the docs into /tmp
# OSError: [Errno 18] Cross-device link: 'build/html' -> '/tmp/_py/_root/pydocs'
# on build_installer.py 1764, 1725, 1119


#####################################################
# any app has to have "disable library validation" checked -- since the .so files are not signed.
#####################################################

/bin/ls *.so | xargs -I xx codesign -s '9EL3' xx

#####################################################################

export PYTHONHOME=/Volumes/Proton/Repositories/SwiftyPython/Products/Library/Frameworks/Python.framework/Versions/3.12

bin/python3 -m ensurepip
bin/python3 -m pip install asciify

