#!/bin/bash -x

# Build "latest"
docker build --no-cache . -t mikenye/youtube-dl:latest 
build_exit=$?


# Get version of latest container
# Repeat as running straight after the build can give a 'bad interpreter: Text file busy' error
n=0
until [ $n -ge 5 ]
do
    build_version=$(docker run --rm mikenye/youtube-dl --version) 
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
if [ $build_exit -eq 0 ]; then
    docker tag mikenye/youtube-dl:latest mikenye/youtube-dl:$build_version
    tag_exit=$?
fi

if [ $build_exit -eq 0 ]; then
    if [ $tag_exit -eq 0 ]; then
        # If building and tagging was successful, then push
        docker push mikenye/youtube-dl:latest
        docker push mikenye/youtube-dl:$build_version
        exit 0
    fi
fi

echo "Something went wrong..."
exit 1
