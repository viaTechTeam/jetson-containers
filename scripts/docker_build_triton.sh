#!/usr/bin/env bash

set -e
CONTAINERS=${1:-"all"}


# select base image
source scripts/l4t_version.sh

version_error()
{
	echo "unsupported JetPack-L4T version:  r$L4T_VERSION"
	echo "Triton container requires JetPack 4.5 or newer"
	exit 1
}

if [ $L4T_RELEASE -eq 32 ]; then
	if [ $L4T_REVISION_MAJOR -eq 5 ]; then
		BASE_IMAGE="nvcr.io/nvidia/l4t-ml:r32.5.0-py3"
	else
		version_error
	fi
else
	version_error
fi


#
# Triton Inference Server
#
build_triton()
{
	local triton_url=$1
	local triton_tgz=$2
	local triton_whl=$3
	local triton_pytorch_backend_version=$4
	local triton_tag=$5

	echo "building $triton_tag from $triton_tgz"
	
	sh ./scripts/docker_build.sh $triton_tag Dockerfile.triton \
			--build-arg BASE_IMAGE=$BASE_IMAGE \
			--build-arg TRITON_URL=$triton_url \
			--build-arg TRITON_TGZ=$triton_tgz \
			--build-arg TRITON_WHL=$triton_whl \
			--build-arg TRITON_PYTORCH_BACKEND_VERSION=$triton_pytorch_backend_version

	echo "done building $triton_tag"
}

if [[ "$CONTAINERS" == "triton" || "$CONTAINERS" == "all" ]]; then

	# Triton 2.8.0
	build_triton "https://github.com/triton-inference-server/server/releases/download/v2.8.0/tritonserver2.8.0-jetpack4.5.tgz" \
				"tritonserver2.8.0-jetpack4.5.tgz" \
				"clients/python/tritonclient-2.8.0-py3-none-linux_aarch64.whl" \
				"r20.12" \
				"l4t-tritonserver:r$L4T_VERSION"
fi

