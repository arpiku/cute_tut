FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive


ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}
ENV CUDA_HOME=/usr/local/cuda
ENV CC=gcc-14
ENV CXX=g++-14
ENV HOME=/home/ubuntu
ENV PATH=/home/ubuntu/.local/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    wget \
    build-essential \
    cmake \
    ninja-build \
    gcc-14 \
    g++-14 \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100

# Python packaging tools are present for convenience, but system packages are installed via apt.

WORKDIR /workspace
USER ubuntu
CMD ["bash"]
