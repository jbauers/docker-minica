# Docker + minica

Using https://github.com/jsha/minica.

There's already an open [pull request](https://github.com/jsha/minica/pull/27) for a
Dockerfile in minica, but no activity. This just adds minica as a submodule, and keeps the
container stuff here.

## Requirements

- Docker or podman

## Usage

```
cd /tmp
git clone --recurse-submodules https://github.com/jbauers/docker-minica
cd docker-minica

./run.sh example.org
```

Please don't create a `Dockerfile`, `run.sh` does that. Adjust `run.sh` if you want different
behaviour.

The root and leaf certificates will land in `./out`.

## Notes

Nothing is left on your system, and you will rebuild fully from scratch, each time. This is
mostly due to a [bug](https://github.com/containers/libpod/issues/3110) in podman.

Alternatively: It's not a bug, it's a feature. Your system stays clean and it's always built
freshly from source. _Amazing_.

If you want to not even keep the base image, set `DEEP_CLEAN=true` in `run.sh`. Then we'll
need to pull `golang:alpine` for each build. If you're doing a one-time thing and/or are
tight on disk space, this might make sense. Or maybe you're paranoid and prefer fresh
environments each time.

## Why?

I needed a minica, containers are nice, Docker is fine, I'm trying out podman. Playground for
all of those:

- Both podman/Docker (OCI compliant, _just works_, blah - there's discrepancies between them).
- From source, using Golang base image
- Therefore probably works anywhere
- Cleans up after itself, I guess
