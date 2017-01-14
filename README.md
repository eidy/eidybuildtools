These are the build tools used on the Ubuntu build server.

These are notes are nowhere near comprehensive enough yet.  They will become so later.

Dependencies

- Currently they are hardcoded dependencies - So you need to create symbolic links for:
    - /develop/eidybuilds - where these scripts are stored
    - /develop/deps - The deps folder in this repository
    - /develop/sdk - Where the android sdk is
    - /develop/ndk - Where the android ndk is
    
- Install imagemagick

Main Build Script

buildeidy.sh <buildrootfolder> <buildno> 

- These scripts "massage" a normal source install
- The "TeamEidy" folder refer to a number of overlays (including a version of minetest_game called "eidy") 
  which are applied on top of the minetest install.  The script is modified from the original to copy
  the shipped version of "minetest_game" - This is provided as an example and has not been tested.  There are
  other useful things in TeamEidy, namely a swahili minetest translation. ( These artifacts are provided in a "TeamEidy" subfolder here.) 
 
 
