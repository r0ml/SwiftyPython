#!/bin/sh

#  patch.sh
#  SwiftyPython
#
#  Created by Robert M Lefkowitz on 2/1/24.
#  Copyright (c) 1868 Charles Babbage

cd Products/Library/Frameworks

# to find these, run
# find . -name '*.so' | xargs otool -L
#     and
# find . -name '*.dylib' | xargs otool -L
# in Python.framework

install_name_tool -id "@loader_path/../Frameworks/Python.framework/Versions/3.12/Python" Python.framework/Python

# libssl
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libssl.3.dylib @loader_path/../../libssl.3.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so

install_name_tool -id '@loader_path/../../libssl.3.dylib' Python.framework/Versions/3.12/lib/libssl.3.dylib

# libcrypto
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @loader_path/../../libcrypto.3.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @loader_path/../../libcrypto.3.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_hashlib.cpython-312-darwin.so

#

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtcl8.6.dylib @loader_path/../../libtcl8.6.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_tkinter.cpython-312-darwin.so

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtk8.6.dylib @loader_path/../../libtk8.6.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_tkinter.cpython-312-darwin.so

# install_name_tool -id '@loader_path

# FIXME: do these
##################################
# the dylibs to fix:
###################################
# libncursesw.5.dylib
# libmenuw.5.dylib
# libtk8.6.dylib
# libtcl8.6.dylib
# libformw.5.dylib
# libcrypto.3.dylib
# libpanelw.5.dylib
# libssl.3.dylib
####################################


# FIXME: also, from venv need to load:
######################################
# PIL/.dylibs/*
# numpy/.dylibs/*
# matplotlib/backends/*.so
# matplotlib/*.so
# PIL/*.so
# numpy/core/*.so
# numpy/linalg/*.so
# numpy/fft/*.so
# numpy/random/*.so
# fontTools/*/*.so
#######################################


