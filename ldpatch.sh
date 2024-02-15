#!/bin/sh -v -x

#  Copyright (c) 1868 Charles Babbage
#  Found amongst his effects by r0ml

cd Products/Library/Frameworks

# to find these, run
# find . -name '*.so' | xargs otool -L
#     and
# find . -name '*.dylib' | xargs otool -L
# in Python.framework

FF=Python.framework/Python
# install_name_tool -id "@rpath/../Frameworks/Python.framework/Versions/3.12/Python" -add_rpath '@loader_path/.' $FF
install_name_tool -id "@loader_path/../Frameworks/Python.framework/Versions/3.12/Python" $FF

############################################################
# Fix the .so
############################################################
# libssl
FF=Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_ssl.cpython-312-darwin.so
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libssl.3.dylib @rpath/../../libssl.3.dylib -add_rpath '@loader_path/.' $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libssl.3.dylib '@loader_path/../../libssl.3.dylib' $FF
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @rpath/../../libcrypto.3.dylib $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib '@loader_path/../../libcrypto.3.dylib' $FF

FF=Python.framework/Versions/3.12/lib/libssl.3.dylib
# install_name_tool -id '@rpath/../../libssl.3.dylib' -add_rpath '@loader_path/.' $FF
install_name_tool -id '@loader_path/../../libssl.3.dylib' $FF

# libcrypto
FF=Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_hashlib.cpython-312-darwin.so
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib @rpath/../../libcrypto.3.dylib -add_rpath '@loader_path/.' $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libcrypto.3.dylib '@loader_path/../../libcrypto.3.dylib' $FF

# tcl/tk

FF=Python.framework/Versions/3.12/lib/python3.12/lib-dynload/_tkinter.cpython-312-darwin.so
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtcl8.6.dylib @rpath/../../libtcl8.6.dylib -add_rpath '@loader_path/.' $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtcl8.6.dylib '@loader_path/../../libtcl8.6.dylib' $FF

# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtk8.6.dylib @rpath/../../libtk8.6.dylib -add_rpath '@loader_path/.' $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/lib/libtk8.6.dylib '@loader_path/../../libtk8.6.dylib' $FF

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

FF=Python.framework/Versions/3.12/Resources/Python.app/Contents/MacOS/Python
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/Python '@rpath/../../../../Python' -add_rpath '@loader_path/.' $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/Python 'loader_path/../../../../Python' $FF

FF=Python.framework/Versions/Current/bin/python3
# install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/Python '@rpath/../../../Python' -add_rpath '@loader_path/.' $FF
install_name_tool -change /Library/Frameworks/Python.framework/Versions/3.12/Python '@loader_path/../../../Python' $FF

cd Python.framework/Versions/Current/bin
# -- then:
./python3 -m ensurepip
./python3 -m pip install certifi numpy pillow boto3 matplotlib

# Pandas, Statsmodels, SciPy, SciKit-Learn, SciKit-Image, OpenCV
