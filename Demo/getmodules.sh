#!/bin/sh

#  getmodules.sh
#  CaerbannogSample
#
#  Created by Robert M Lefkowitz on 2/1/24.
#  Copyright (c) 1868 Charles Babbage

mkdir -p venv/site-packages

for i in certifi pillow boto3 dominate bing-image-downloader matplotlib numpy; do
  pip3 install --target venv/site-packages $i
done;


