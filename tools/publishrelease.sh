#/bin.bash
echo "Exporting token and enterprise api to enable github-release tool"
 
export GITHUB_TOKEN=299e7a5dc20aa93449ae7678196846d4edd2d482
#export GITHUB_API=https://github.com/api/v3 # needed only for enterprise
export GITHUB_USER=eidy
export GITHUB_REPO=eidy
export VERSION_NAME=$1 
export FILE_PATH=$2
export DESCRIPTION=$3

echo "Update the release"
/develop/eidybuilds/updatereleasehistory.sh

echo "Deleting release from github before creating new one"
/home/ubuntu/go/bin/github-release -v delete --tag ${VERSION_NAME}

echo "Creating a new release in github"
/home/ubuntu/go/bin/github-release release --draft --pre-release --tag ${VERSION_NAME} --description "$DESCRIPTION" --name ${VERSION_NAME}

echo "Uploading the artifacts into github"
/home/ubuntu/go/bin/github-release upload --tag ${VERSION_NAME} --name eidy-en-debug${VERSION_NAME}.apk --file $FILE_PATH 
/home/ubuntu/go/bin/github-release upload --tag ${VERSION_NAME} --name eidy-sw-debug${VERSION_NAME}.apk --file $FILE_PATH 
