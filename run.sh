#!/bin/sh
docker build . -t sharp-heif-lambda-layer
CONTAINER=$(docker create sharp-heif-lambda-layer)

docker cp $CONTAINER:/tmp/sharp-heif-lambda-layer.zip .