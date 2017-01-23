#!/bin/bash

###### Options ######
MINETESTDIR=/home/username/minetest
GAMENAME=eidy
WORLDDIR=none
TEXTURESDIR=server
MEDIADIR=./media
LEGACY_SYMLINKS=0

if [ -n "$1" ] 
then
 MINETESTDIR=$1
 echo "Got :"$MINETESTDIR
fi


if [ -n "$2" ] 
then
 MEDIADIR=$2
fi

if [ -n "$3" ]
then
	GAMESDIR=$3
else
	GAMESDIR=$MINETESTDIR/games
fi

# When settings this up be aware that the Minetest client
# will send a POST request to index.mth. You need to configure
# your web server to serve the file on POST requests for this to work.
#####################

die () {
	echo "$1" >&2
	exit 1
}

collect_from () {
	echo "Processing media from: $1"
	find -L "$1" -type f -name "*.png" -o -name "*.ogg" -o -name "*.x" -o -name "*.b3d" -o -name "*.obj" -o -name "*.jpg" | while read f; do
		basename "$f"
		hash=`cat "$f" | openssl dgst -sha1 | cut -d " " -f 2`
		cp "$f" $MEDIADIR/$hash
		[ $LEGACY_SYMLINKS -eq 1 ] && ln -nsf $hash $MEDIADIR/`basename "$f"`
	done
}

[ -d $MINETESTDIR ] || die "Specify a valid Minetest directory! - "$MINETESTDIR
which openssl &>/dev/null || die "OpenSSL not installed."

mkdir -p $MEDIADIR

[ ! $GAMENAME == none ] && collect_from $GAMESDIR/$GAMENAME/mods
[ ! $WORLDDIR == none ] && collect_from $WORLDDIR/worldmods
[ -d $MINETESTDIR/mods ] && collect_from $MINETESTDIR/mods
[ ! $TEXTURESDIR == none ] && collect_from $MINETESTDIR/textures/$TEXTURESDIR

printf "Creating index.mth... "
printf "MTHS\x00\x01" >$MEDIADIR/index.mth
find $MEDIADIR -type f -not -name index.mth | while read f; do
	openssl dgst -binary -sha1 <$f >>$MEDIADIR/index.mth
done
echo "done"