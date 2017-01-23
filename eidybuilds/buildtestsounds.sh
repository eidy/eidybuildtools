#!/bin/bash

###### Options ######
GAMESDIR=/d/Dropbox/eidy/dev/eidy/eidy/games
TESTSOUNDSDIR=/d/Dropbox/eidy/dev/eidy/eidy/testsounds

if [ -n "$1" ] 
then
 GAMESDIR=$1
fi


if [ -n "$2" ] 
then
 TESTSOUNDSDIR=$2
fi


die () {
	echo "$1" >&2
	exit 1
}

collect_from () {
	echo "Processing media from: $1"
	FNDCMD="find"
	if [ -f /usr/bin/find ]
	then
		# On windows, the PATH may point to a screwy version of find.
		# if /usr/bin is there, use that one...
		FNDCMD="/usr/bin/find"
	fi
	$FNDCMD -L "$1" -type f -name "*.ogg"| while read f; do
		NAME=`basename "$f"`
		mv $f $TESTSOUNDSDIR/$NAME
	done
}


collect_from $GAMESDIR

echo "done"
