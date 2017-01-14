#!/bin/bash

###### Options ######
GAMESDIR=/d/Dropbox/eidy/dev/eidy/eidy/games
OUTPUTDIR=/d/Dropbox/eidy/dev/eidy/eidy/textures/base/pack

if [ -n "$1" ] 
then
 GAMESDIR=$1
fi


if [ -n "$2" ] 
then
 OUTPUTDIR=$2
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
	$FNDCMD -L "$1" -type f -name "*.png"| grep -v "signs_lib" | while read f; do
		NAME=`basename "$f"`
		mv $f $OUTPUTDIR/$NAME
	done
}


collect_from $GAMESDIR

echo "done"
