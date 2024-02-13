#!/bin/sh

#  Copyright (c) 1868 Charles Babbage
#  Found amongst his effects by r0ml

# After checking out this repo and `git submodule update --init`
# running this script should build the binary framework for SwiftyPython

./patch.sh

cd cpython

cd Mac/BuildScript
python3 build-installer.py --universal-archs=universal2 --third-party=../../../other --dep-target=10.9

######

cd ../../..

mkdir -p Products
ditto /tmp/_py/_root Products

./ldpatch.sh

./finish.sh
