#!/bin/sh
DEEP_CLEAN=false

# In case we don't have an alias set.
if docker version; then
	cmd='docker'
elif podman version; then
	cmd='podman'
else
	echo "Please install podman and/or Docker."
	exit 1
fi

# The minica commit used, tag our image with it.
ver=$(git submodule status | cut -d ' ' -f2 | cut -c1-12)

clean() {
	rm Dockerfile
	$cmd rm -f minica-$ver
	$cmd rmi -f minica:$ver

	# Also remove the intermediate image, podman and Docker compatible.
	# There's only one here, so this ("sed -n 2p") is hopefully OK.
	id=$($cmd images --filter label=stage=intermediate | sed -n 2p | tr -s ' ' | cut -d ' ' -f3)
	$cmd rmi -f $id

	if [ $DEEP_CLEAN == true ]; then
		$cmd rmi -f golang:alpine
	fi
}

trap clean EXIT

# If we have something already, put it into our container - so minica reuses it.
# It's minica after all, but to state the obvious: DO NOT PUSH THIS IMAGE, it now contains
# secrets. Why do this? podman doesn't like bind mounts and they're ugly anyway (permissions).
cat Dockerfile.template > Dockerfile
if [ -d './out' ]; then
	cat << EOF >> Dockerfile
ADD out .
EOF
fi

# Never use cache, podman issue. See https://github.com/containers/libpod/issues/3110
# If we don't DEEP_CLEAN, this will still keep our base image.
$cmd build --rm \
	   --no-cache \
	   -t minica:$ver \
	   . || exit 1

$cmd run --name minica-$ver \
	 minica:$ver \
	 "$1" || exit 1

# Avoiding bind mounts again.
$cmd cp minica-$ver:/out .
