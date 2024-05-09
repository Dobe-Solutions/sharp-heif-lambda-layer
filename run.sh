#!/bin/bash

HEVC_ENCODING=0
AV1_ENCODING=0
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
        *)
            break
            ;;
    esac
done


docker build . -t sharp-heif-lambda-layer --build-arg="BUILD_HEVC_ENCODER=$HEVC_ENCODING" --build-arg="BUILD_AV1_ENCODER=$AV1_ENCODING"
CONTAINER=$(docker create sharp-heif-lambda-layer)

docker cp $CONTAINER:/tmp/sharp-heif-lambda-layer.zip .