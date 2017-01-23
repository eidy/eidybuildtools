#!/bin/bash
#
#  This script adds custom eidy artifacts over the top of
#  a basic minetest build,  and does someworkarounds, then 
#  initiates a normal make 
#
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTDIR

BUILDROOT=$1
if [ -z "$BUILDROOT" ]
then
	BUILDROOT=`realpath "../build"`
	mkdir -p $BUILDROOT
fi
BUILDNUM=$2
if [ -z "$BUILDNUM" ]
then
	BUILDNUM="1"
fi
BUILDIDENT='1.0.'$2
CUSTOMDIR="../custom"
SOUNDSDIR="sounds"
NDK=/develop/ndk
SDK=/develop/sdk
if [ -z "$MINETESTBRANCH" ]
then
	MINETESTBRANCH=eidy
fi
echo "Minetest Branch set to $MINETESTBRANCH"
if [ -z "$EIDYTEAMBRANCH" ]
then
	EIDYTEAMBRANCH=master
fi
echo "Minetest Branch set to $EIDYTEAMBRANCH"
echo "Sounds Dir is set to $SOUNDSDIR"
echo "Clearing eidy"
rm -rf $BUILDROOT/eidy

echo "Clearing TeamEidy"
rm -rf $BUILDROOT/TeamEidy

echo "Fetching eidy"
git clone -b $MINETESTBRANCH --single-branch https://github.com/eidy/minetest.git $BUILDROOT/eidy


mkdir -p $BUILDROOT/TeamEidy/games

# Copy custom files to the working folder
cp -r $CUSTOMDIR $BUILDROOT/TeamEidy

echo "Fetching Default Minetest Game"
git clone -b $EIDYTEAMBRANCH --single-branch https://github.com/minetest/minetest_game $BUILDROOT/TeamEidy/games/minetest_game
 
echo "Unpack TeamEidy mod packs"

function unpackmod {
 
MODDIR=$BUILDROOT/TeamEidy/games/eidy/mods/$1
mv $MODDIR $MODDIR.modpack
MODDIR=$MODDIR.modpack
ITEMS=$MODDIR/*
for fg in $ITEMS
	do
		NAMEG="${fg##*/}"
		if [ -d "$fg" ]; then
			echo "Unpacking mod $NAMEG"
			#rename the modpack
			cp -r $MODDIR/"$NAMEG" $BUILDROOT/TeamEidy/games/eidy/mods/
		fi
	done
rm -rf $MODDIR
}

# Add your modpacks to this list
unpackmod flight
unpackmod mesecons
unpackmod minetest-3d_armor
unpackmod mobs_water
unpackmod plantlife_modpack
unpackmod technic
unpackmod weatherpack
unpackmod hud_hunger


rm -rf $BUILDROOT/TeamEidy/games/minimal
cp -r $BUILDROOT/TeamEidy/games $BUILDROOT/eidy
cp -r $BUILDROOT/TeamEidy/worlds $BUILDROOT/eidy

echo "Updating build properties" 
echo "ndk.dir = $NDK" > $BUILDROOT/eidy/build/android/local.properties
echo "sdk.dir = $SDK" >> $BUILDROOT/eidy/build/android/local.properties
echo "" >> $BUILDROOT/eidy/build/android/local.properties
 

echo "Writing Build Info"
$SCRIPTDIR/createbuildinfo.sh $BUILDIDENT > $BUILDROOT/eidy/build/android/src/main/res/values/buildinfo.xml

echo "Overlay TeamEidy Custom items onto eidy"
#TODO: make all of these 'generic' in the sence of copying all files from the dirs
cp -f $BUILDROOT/TeamEidy/custom/builtin/mainmenu/* $BUILDROOT/eidy/builtin/mainmenu
cp -f $BUILDROOT/TeamEidy/custom/client/favoriteservers.txt $BUILDROOT/eidy/client/favoriteservers.txt
cp -f $BUILDROOT/TeamEidy/custom/textures/base/pack/* $BUILDROOT/eidy/textures/base/pack
cp -r $BUILDROOT/TeamEidy/custom/$SOUNDSDIR $BUILDROOT/eidy
cp -r $BUILDROOT/TeamEidy/custom/fonts $BUILDROOT/eidy
cp -r $BUILDROOT/TeamEidy/custom/cache $BUILDROOT/eidy

echo "Building mo files (will be moved to Makefile)"
mkdir $BUILDROOT/eidy/locale
$SCRIPTDIR/buildmo.sh $BUILDROOT/eidy/po $BUILDROOT/eidy/locale

echo "Overwriting custom swahili file (will be in next minetest version)"
cp -r $BUILDROOT/TeamEidy/custom/locale $BUILDROOT/eidy


echo "Reducing Color Depth on game PNGS"
find $BUILDROOT/eidy/games -name '*.png' -exec pngquant --ext .png --force 256 {} \;
echo "Moving eidy game graphics..."
$SCRIPTDIR/buildpack.sh $BUILDROOT/eidy/games $BUILDROOT/eidy/textures/base/pack

echo "Converting textures.... I love massaging those piccies..."
mkdir $BUILDROOT/eidy/textures/server
$SCRIPTDIR/buildtextures.sh $BUILDROOT/TeamEidy/textures/server $BUILDROOT/eidy/textures/base/pack

echo "Reorganising sounds..."
mkdir $BUILDROOT/eidy/$SOUNDSDIR
$SCRIPTDIR/buildtestsounds.sh $BUILDROOT/eidy/games $BUILDROOT/eidy/$SOUNDSDIR


echo "Building Cache..."
mkdir $BUILDROOT/eidy/cache
mkdir $BUILDROOT/eidy/cache/media
$SCRIPTDIR/buildmediacache.sh $BUILDROOT/eidy $BUILDROOT/eidy/cache/media

 

echo "Updating minetest.conf - English"
cp -f $BUILDROOT/TeamEidy/custom/minetest.android.conf $BUILDROOT/eidy/minetest.conf
echo "Launching build .... go make a coffee...."
cd $BUILDROOT/eidy/build/android
make
mv $BUILDROOT/eidy/build/android/build/outputs/apk/eidy-debug.apk $BUILDROOT/eidy/build/android/build/outputs/apk/eidy-en-debug.apk 
 
echo "Updating minetest.conf - Swahili"
cp -f $BUILDROOT/TeamEidy/custom/minetest.sw.android.conf $BUILDROOT/eidy/minetest.conf
echo "Launching build .... go make a coffee...."
cd $BUILDROOT/eidy/build/android
make
mv $BUILDROOT/eidy/build/android/build/outputs/apk/eidy-debug.apk $BUILDROOT/eidy/build/android/build/outputs/apk/eidy-sw-debug.apk 
 
 