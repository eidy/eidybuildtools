#!/bin/bash
POSOURCE=$1
OUTFOLDER=`realpath $2`
DOMAIN=minetest
# Go thoguh each folder
cd $POSOURCE
for P in `ls -d */ | cut -f1 -d/`
do
	mkdir $OUTFOLDER/$P
	mkdir $OUTFOLDER/$P/LC_MESSAGES
	echo "msgfmt -o $OUTFOLDER/$P/LC_MESSAGES/$DOMAIN.mo $P/$DOMAIN.po"
	msgfmt -o $OUTFOLDER/$P/LC_MESSAGES/$DOMAIN.mo $P/$DOMAIN.po
done
