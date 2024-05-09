#!/bin/bash
# shellcheck disable=SC2086
# This script is for users to build docker images locally. It is most useful for users wishing to edit the
# base-deps, ray-deps, or ray images. This script is *not* tested, so please look at the 
# ci/build/build-docker-images.py if there are problems with using this script.

set -x

GPU=""
BASE_IMAGE="nvcr.io/nvidia/pytorch:24.04-py3"
WHEEL_URL="https://files.pythonhosted.org/packages/37/0e/5e1c19ebe0d26328689a19d4360b51e670570366dbb9bde5deef5c1708c9/ray-2.9.3-cp310-cp310-manylinux2014_x86_64.whl"
PYTHON_VERSION="3.10.12"


while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --base-image)
    # Override for the base image.
    shift
    BASE_IMAGE=$1
    ;;
    --no-cache-build)
    NO_CACHE="--no-cache"
    ;;
    --shas-only)
    # output the SHA sum of each build. This is useful for scripting tests, 
    # especially when builds of different versions are running on the same machine. 
    # It also can facilitate cleanup.
    OUTPUT_SHA=YES
    ;;
    --wheel-to-use)
    # Which wheel to use. This defaults to the latest nightly on python 3.7
    echo "not implemented, just hardcode me :'("
    exit 1
    ;;
    --python-version)
    # Python version to install. e.g. 3.7.7.
    # Changing python versions may require a different wheel.
    # If not provided defaults to 3.7.7
    shift
    PYTHON_VERSION=$1
    ;;
    *)
    echo "Usage: build-docker.sh [ --gpu ] [ --base-image ] [ --no-cache-build ] [ --shas-only ] [ --wheel-to-use ] [ --python-version ]"
    exit 1
esac
shift
done

WHEEL_DIR=$(mktemp -d)
wget "$WHEEL_URL" -P "$WHEEL_DIR"
WHEEL="$WHEEL_DIR/$(basename "$WHEEL_DIR"/*.whl)"
# Build base-deps, ray-deps, and ray.
for IMAGE in "nvidia-pytorch-base-deps" "nvidia-pytorch-ray-deps" "nvidia-pytorch-ray"
do
    cp "$WHEEL" "$IMAGE/$(basename "$WHEEL")"
    if [ "$OUTPUT_SHA" ]; then
        IMAGE_SHA=$(docker build $NO_CACHE --build-arg GPU="$GPU" --build-arg BASE_IMAGE="$BASE_IMAGE" --build-arg WHEEL_PATH="$(basename "$WHEEL")" --build-arg PYTHON_VERSION="$PYTHON_VERSION" -q -t rayproject/$IMAGE:2.9.3-py310-gpu)
        echo "rayproject/$IMAGE:2.9.3-py310-gpu SHA:$IMAGE_SHA"
    else
        docker build $NO_CACHE --build-arg GPU="$GPU" --build-arg BASE_IMAGE="$BASE_IMAGE" --build-arg WHEEL_PATH="$(basename "$WHEEL")" --build-arg PYTHON_VERSION="$PYTHON_VERSION" -t "rayproject/$IMAGE:2.9.3-py310-gpu" "$IMAGE"
    fi
    rm "$IMAGE/$(basename "$WHEEL")"
done 

rm -rf "$WHEEL_DIR"
