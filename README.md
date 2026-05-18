# CUTLASS CUDA 12.8 Docker Dev Setup

This repository contains a Docker-based development environment for writing and running small CUTE demos against the CUTLASS repo mounted from:

- `/home/arpiku/cutlass`

The image is based on the official NVIDIA CUDA 12.8 devel image and installs the container toolchain with `gcc-14` / `g++-14` to avoid the host GCC 16 issue.
The base image already includes an `ubuntu` user with UID/GID `1000:1000`, so the container runs under that account instead of creating a new one.

## Files

- `Dockerfile` - CUDA 12.8 development image with build tools installed at build time
- `docker-compose.yml` - GPU-enabled compose service for CUTE demo work
- `Makefile` - build/run helper for the demo
- `main.cu` - simple CUTE layout printing example
- `scripts/build_cutlass.sh` - convenience build script for CMake + Ninja

## Prerequisites

- NVIDIA driver installed on the host
- NVIDIA Container Toolkit installed and configured
- CUTLASS repo available at `/home/arpiku/cutlass`

## Build the image

From this directory:

```sh
docker compose build
```

## Start an interactive shell

```sh
docker compose run --rm cutlass-dev
```

## Build and run the CUTE demo

Inside the container:

```sh
make run
```

Or from the host in one shot:

```sh
docker compose run --rm cutlass-dev make run
```

## What the demo does

`main.cu` creates a simple `2 x 3` CUTE layout and prints a LaTeX/TikZ representation using `cute::print_latex`.

## Notes

- The container runs with GPU access via `gpus: all`.
- The compose service builds from the official `nvidia/cuda:12.8.0-devel-ubuntu24.04` base image.
- GCC 14, CMake, and Ninja are installed via apt rather than pip to avoid Python's externally-managed-environment restriction.
- The CUTLASS repo is mounted read-only because you are using it as a dependency, not editing it.
- The working directory starts in this repo (`/workspace/dev-setup`).
- The runtime user is `1000:1000`, matching your host ownership, while the image defaults to the existing `ubuntu` user.
