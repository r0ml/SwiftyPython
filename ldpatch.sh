#!/bin/sh
#
# Copyright (c) 1868 Charles Babbage
# Found amongst his effects by r0ml

cd Products/Library/Frameworks

# to find these, run
# find . -name '*.so' | xargs otool -L
#     and
# find . -name '*.dylib' | xargs otool -L
# in Python.framework

install_name_tool -id "@loader_path/../Frameworks/Python.framework/Versions/3.12/Python" Python.framework/Python

############################################################
# Fix the .so
############################################################
# libssl
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libssl.3.dylib @loader_path/../../libssl.3.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so

install_name_tool -id '@loader_path/../../libssl.3.dylib' Python.framework/Versions/3.12/lib/libssl.3.dylib

# libcrypto
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @loader_path/../../libcrypto.3.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @loader_path/../../libcrypto.3.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_hashlib.cpython-312-darwin.so

# tcl/tk

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtcl8.6.dylib @loader_path/../../libtcl8.6.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_tkinter.cpython-312-darwin.so

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtk8.6.dylib @loader_path/../../libtk8.6.dylib Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_tkinter.cpython-312-darwin.so

###############################################################
# fix the .dylibs?  
###############################################################

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

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/Python '@loader_path/../../../../Python' Python.framework/Versions/Current/Resources/Python.app/Contents/MacOS/Python

install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/Python '@loader_path/../../../Python' Python.framework/Versions/Current/bin/python3

cd Python.framework/Versions/Current/bin
# -- then:
./python3 -m ensurepip
./python3 -m pip install certifi numpy pillow boto3 matplotlib

# Pandas, Statsmodels, SciPy, SciKit-Learn, SciKit-Image, OpenCV

#################################################
# this is for demo
rm -rf ../../../../../../../Demo/venv/site-packages/*
./python3 -m pip install --target ../../../../../../../Demo/venv/site-packages dominate bing-image-downloader

