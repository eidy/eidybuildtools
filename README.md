These are the build tools used on the Ubuntu build server.
 
Dependencies
------------

- Install the Android SDK and NDK
    
- Install imagemagick


Build Script
-----------
buildeidy.sh  

- These scripts "massage" a normal source install to provide various speed benefits for a singleplayer game
- The "TeamEidy" folder refer to a number of overlays (including a version of minetest_game called "eidy") 
  which are applied on top of the minetest install.  The script is modified from the original to copy
  the shipped version of "minetest_game" - This is provided as an example and has not been tested.  There are
  other useful things in TeamEidy, namely a swahili minetest translation. ( These artifacts are provided in a "TeamEidy" subfolder here.) 
- Currently it is hardcoded with these dependencies:    
  /develop/sdk - Where the android sdk is
  /develop/ndk - Where the android ndk is
  Create symbolic links or alter the script  
   
