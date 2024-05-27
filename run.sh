#!/bin/bash

HEVC_ENCODING=0
AV1_ENCODING=0
BUILD_TARGET=x64
DOCKER_PLATFORM=linux/amd64

while test $# -gt 0; do
    case "$1" in
        --with-hevc-encoder)
            HEVC_ENCODING=1
            shift
            ;;
        --with-av1-encoder)
            AV1_ENCODING=1
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


docker buildx build . -t sharp-heif-lambda-layer \
    --platform $DOCKER_PLATFORM \
    --build-arg="BUILD_HEVC_ENCODER=$HEVC_ENCODING" \
    --build-arg="BUILD_AV1_ENCODER=$AV1_ENCODING" \
    --build-arg="BUILD_TARGET=$BUILD_TARGET"

CONTAINER=$(docker create sharp-heif-lambda-layer)

docker cp $CONTAINER:/tmp/sharp-heif-lambda-layer.zip .