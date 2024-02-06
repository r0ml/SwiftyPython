#!/bin/sh

#  build.sh
#  SwiftyPython
#
#  Created by Robert M Lefkowitz on 2/1/24.
#  Copyright (c) 1868 Charles Babbage

./patch.sh

cd cpython

cd Mac/BuildScript
python3 build-installer.py --universal-archs=universal2 --third-party=../../../other --dep-target=10.9


###
# the framework winds up here:
# /tmp/_py/_root/Library/Frameworks/Python.framework/

cd ../../..

mkdir -p Products
ditto /tmp/_py/_root Products

./ldpatch.sh

./finish.sh
