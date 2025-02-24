#!/usr/bin/env bash
set -e

# LIBRARY_PREFIX will only be available on Windows
if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

if [[ "${target_platform}" == win-* ]]; then
  EXTRA_FLAGS="--enable-msvc --with-coinutils-lib='${LIBRARY_PREFIX}/lib/libCoinUtils.lib ${LIBRARY_PREFIX}/lib/cblas.lib ${LIBRARY_PREFIX}/lib/lapack.lib' --with-coinutils-incdir=\${LIBRARY_PREFIX_COIN} --with-osi-lib=${LIBRARY_PREFIX}/lib/libOsi.lib --with-osi-incdir=\${LIBRARY_PREFIX_COIN}"
  BLAS_LIB="${LIBRARY_PREFIX}/lib/cblas.lib"
  LAPACK_LIB="${LIBRARY_PREFIX}/lib/lapack.lib"
else
# Get an updated config.sub and config.guess
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./Clp
  BLAS_LIB="-L${PREFIX}/lib -lblas"
  LAPACK_LIB="-L${PREFIX}/lib -llapack"
fi

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

./configure \
  --prefix="${USE_PREFIX}" \
  --exec-prefix="${USE_PREFIX}" \
  ${EXTRA_FLAGS} || cat Clp/config.log

make -j "${CPU_COUNT}"

# Tests are broken without Data folder: https://github.com/coin-or/Osi/issues/184
#if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
#  make test
#fi

make install
