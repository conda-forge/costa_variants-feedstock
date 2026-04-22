#!/bin/bash
set -ex

if [[ "${PKG_NAME}" == "costa-scalapack" ]]; then
  COSTA_SCALAPACK="CUSTOM"
else
  COSTA_SCALAPACK="OFF"
fi

export CC="mpicc"
export CXX="mpicxx"

# Run tests only if no cross-compiling is performed
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  cmake -B build_with_tests -S . \
    ${CMAKE_ARGS} \
    -GNinja \
    -DBUILD_SHARED_LIBS="OFF" \
    -DCOSTA_SCALAPACK="${COSTA_SCALAPACK}" \
    -DCOSTA_WITH_TESTS="ON"
  cmake --build build_with_tests --parallel "${CPU_COUNT}"
  ctest --test-dir build_with_tests --output-on-failure
fi

# Rebuild without tests to disable timers and make only API symbols visible
cmake -B build -S . \
    ${CMAKE_ARGS} \
    -GNinja \
    -DBUILD_SHARED_LIBS="OFF" \
    -DCOSTA_SCALAPACK="${COSTA_SCALAPACK}" \
    -DCOSTA_WITH_TESTS="OFF"
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
