#!/bin/sh

#  finish.sh
#  CaerbannogSample
#
#  Created by Robert M Lefkowitz on 2/1/24.
#  Copyright (c) 1868 Charles Babbage

mkdir -p HandRolled
cd HandRolled
rm -rf Python.xcframework
xcodebuild -create-xcframework -framework ../Products/Library/Frameworks/Python.framework -output Python.xcframework
