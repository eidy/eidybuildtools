#!/bin/bash
sourcePath=$1
destPath=$2

exclusions=$(cat $sourcePath/dontresize.txt)

shouldBeExcluded ()
{
fileName=$1

if grep -q $fileName <<<$exclusions; 
then
	return 0 # True
fi

case "$fileName" in
	hud*)
	return 0
	;;
	mobs*)
	return 0
	;;
	senderman*)
	return 0
	;;
esac

return 1 # False

}

for f in $sourcePath/*.png
do
	baseFilename=$(basename $f)
        PICWIDTH=`identify -format "%w" $f`
        dest=$destPath/$baseFilename
	if shouldBeExcluded $baseFilename || [ $PICWIDTH -lt "17" ]; 
	then
	   echo $baseFilename " excluded - Width " $PICWIDTH
	   convert $f -strip $dest
	else
	   echo " Processing - $f to $dest"
	   convert $f -strip -resize 50% $dest
	fi
done
cd $destPath
pngquant *.png --ext .png --force
