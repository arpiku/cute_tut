#!/usr/bin/env bash
set -euo pipefail

CUTLASS_SRC="${CUTLASS_SRC:-/workspace/cutlass}"
BUILD_DIR="${BUILD_DIR:-${CUTLASS_SRC}/build}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
CUDA_ARCHS="${CUDA_ARCHS:-120}"
CC_BIN="${CC:-gcc-14}"
CXX_BIN="${CXX:-g++-14}"
JOBS="${BUILD_JOBS:-$(nproc)}"

cmake -S "${CUTLASS_SRC}" -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCHS}" \
  -DCUTLASS_NVCC_ARCHS="${CUDA_ARCHS}" \
  -DCMAKE_C_COMPILER="${CC_BIN}" \
  -DCMAKE_CXX_COMPILER="${CXX_BIN}"

cmake --build "${BUILD_DIR}" --parallel "${JOBS}"
