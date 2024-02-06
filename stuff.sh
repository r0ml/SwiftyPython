#!/bin/sh



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

