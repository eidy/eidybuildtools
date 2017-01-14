BUILDMESSAGE="Build $BUILD_NUMBER"
echo $BUILDMESSAGE
rm -fr eidy-release
rmdir eidy-release
git clone https://eidybuild:1batteredterry@github.com/eidy/eidy eidy-release
date >> eidy-release/README.txt 
cd eidy-release
git add README.txt 
git commit README.txt -m "$BUILDMESSAGE"
git push origin master
cd ..
