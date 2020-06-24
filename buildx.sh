#!/bin/sh

VERSION=latest
IMAGE=mikenye/youtube-dl

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build latest
docker buildx build -t ${IMAGE}:${VERSION} --no-cache --progress=plain --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64 . || exit 1
docker pull mikenye/youtube-dl:latest
sleep 15
# Get version of latest container
# Repeat as running straight after the build can give a 'bad interpreter: Text file busy' error
n=0
until [ $n -ge 5 ]
do
    build_version=$(docker run --rm mikenye/youtube-dl:latest --version || exit 1)
    if [ $? -eq 0 ]; then
        build_version=$(echo $build_version | sed 's/\r$//')
        break
    fi
    n=$[$n+1]
    sleep 15
done
if [ $n -ge 5 ]; then
    echo "Failed when trying to get youtube-dl version in latest container :("
    exit 1
fi

# If the build was successful, then we can tag with current version
docker buildx build -t ${IMAGE}:${build_version} --progress=plain --compress --push --platform linux/amd64,linux/arm/v7,linux/arm64 . || exit 1
