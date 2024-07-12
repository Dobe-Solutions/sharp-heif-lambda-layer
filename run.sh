#!/bin/bash

SHARP_VERSION=$(cat version)
HEVC_ENCODING=0
AV1_ENCODING=0
BUILD_TARGET=x64
DOCKER_PLATFORM=linux/amd64
FILE_POSTFIX=$BUILD_TARGET

while test $# -gt 0; do
    case "$1" in
        --with-hevc-encoder)
            HEVC_ENCODING=1
            FILE_POSTFIX=$FILE_POSTFIX-hevc
            shift
            ;;
        --with-av1-encoder)
            AV1_ENCODING=1
            FILE_POSTFIX=$FILE_POSTFIX-av1
            shift
            ;;
        --build-target-arm64)
            BUILD_TARGET=arm64
            DOCKER_PLATFORM=linux/arm64
            shift
            ;;
        *)
            break
            ;;
    esac
done


docker buildx build . --load -t sharp-heif-lambda-layer \
    --platform $DOCKER_PLATFORM \
    --build-arg="SHARP_VERION=$SHARP_VERSION" \
    --build-arg="BUILD_HEVC_ENCODER=$HEVC_ENCODING" \
    --build-arg="BUILD_AV1_ENCODER=$AV1_ENCODING" \
    --build-arg="BUILD_TARGET=$BUILD_TARGET"

CONTAINER=$(docker create sharp-heif-lambda-layer)

docker cp $CONTAINER:/tmp/sharp-heif-lambda-layer.zip .

mv sharp-heif-lambda-layer.zip sharp-heif-lambda-layer-v$SHARP_VERSION-$FILE_POSTFIX.zip