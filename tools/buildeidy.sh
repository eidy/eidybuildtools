#!/bin/bash
#
#  This script adds custom eidy artifacts over the top of
#  a basic minetest vuild,  and does someworkarounds, then 
#  initiates a normal make
#
BUILDROOT=$1
BUILDNUM=$2
DEVONLY=$3
BUILDIDENT='1.0.'$2


DEPENDENCIES=/develop/deps
SOUNDSDIR="sounds"
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

echo "Fetching Minetest Game and Eidy Tools"
mkdir -p $BUILDROOT/TeamEidy
git clone -b https://github.com/eidy/eidybuildtools $BUILDROOT/TeamEidy 
git clone -b https://github.com/minetest/minetest_game $BUILDROOT/TeamEidy/games


 
if [ "$DEVONLY" = "DEVONLY" ] 
then
	echo "Tagging Release with Build ID"
	cd $BUILDROOT/TeamEidy
	git tag $BUILDIDENT
fi

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

echo "overlay dependencies"
cp $DEPENDENCIES/local.properties $BUILDROOT/eidy/build/android/local.properties
###cp $BUILDROOT/deps/path.cfg $BUILDROOT/eidy/build/android/path.cfg

echo "Writing Build Info"
/develop/eidybuilds/createbuildinfo.sh $BUILDIDENT > $BUILDROOT/eidy/build/android/src/main/res/values/buildinfo.xml

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
/develop/eidybuilds/buildmo.sh $BUILDROOT/eidy/po $BUILDROOT/eidy/locale

echo "Overwriting custom swahili file (will be in next minetest version)"
cp -r $BUILDROOT/TeamEidy/custom/locale $BUILDROOT/eidy


echo "Reducing Color Depth on game PNGS"
find $BUILDROOT/eidy/games -name '*.png' -exec pngquant --ext .png --force 256 {} \;
echo "Moving eidy game graphics..."
/develop/eidybuilds/buildpack.sh $BUILDROOT/eidy/games $BUILDROOT/eidy/textures/base/pack

echo "Converting textures.... I love massaging those piccies..."
mkdir $BUILDROOT/eidy/textures/server
/develop/eidybuilds/buildtextures.sh $BUILDROOT/TeamEidy/textures/server $BUILDROOT/eidy/textures/base/pack

echo "Reorganising sounds..."
/develop/eidybuilds/buildtestsounds.sh $BUILDROOT/eidy/games $BUILDROOT/eidy/$SOUNDSDIR


echo "Building Cache..."
mkdir $BUILDROOT/eidy/cache
mkdir $BUILDROOT/eidy/cache/media
/develop/eidybuilds/buildmediacache.sh $BUILDROOT/eidy $BUILDROOT/eidy/cache/media

 

echo "Updating minetest.conf - English"
cp -f $BUILDROOT/TeamEidy/custom/minetest.android.conf $BUILDROOT/eidy/minetest.conf
echo "Launching build .... go make a coffee...."
cd $BUILDROOT/eidy/build/android
make

 
echo "Updating minetest.conf - Swahili"
cp -f $BUILDROOT/TeamEidy/custom/minetest.sw.android.conf $BUILDROOT/eidy/minetest.conf
echo "Launching build .... go make a coffee...."
cd $BUILDROOT/eidy/build/android
make

 
 