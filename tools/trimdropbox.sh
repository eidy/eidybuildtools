#!/bin/bash
DROPBOXLOC=/home/ubuntu/Dropbox/AndroidBuilds
cd $DROPBOXLOC
ls -tr eidy-??-debug???.apk | head -n -2 | xargs --no-run-if-empty rm
ls -tr eidy-??-debug??.apk | head -n -2 | xargs --no-run-if-empty rm
