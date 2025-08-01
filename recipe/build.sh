#!/usr/bin/env bash
set -e

# LIBRARY_PREFIX will only be available on Windows
if [ ! -z ${LIBRARY_PREFIX+x} ]; then
    USE_PREFIX=$LIBRARY_PREFIX
else
    USE_PREFIX=$PREFIX
fi

if [[ "${target_platform}" == win-* ]]; then
  COINUTILS_LIB=( --with-coinutils-lib='${LIBRARY_PREFIX}/lib/mkl_rt.lib ${LIBRARY_PREFIX}/lib/libCoinUtils.lib' )
  COINUTILS_INC=( --with-coinutils-incdir='${LIBRARY_PREFIX_COIN}' )
  OSI_LIB=( --with-osi-lib='${LIBRARY_PREFIX}/lib/libOsi.lib' )
  OSI_INC=( --with-osi-incdir='${LIBRARY_PREFIX_COIN}' )
  EXTRA_FLAGS=( --enable-msvc=MD ) 
else
  # Get an updated config.sub and config.guess (for mac arm and lnx aarch64)
  cp $BUILD_PREFIX/share/gnuconfig/config.* ./Clp 
  cp $BUILD_PREFIX/share/gnuconfig/config.* .
  COINUTLS_LIB=()
  COINUTILS_INC=()
  OSI_LIB=()
  OSI_INC=()
  EXTRA_FLAGS=()
fi

./configure \
  --prefix="${USE_PREFIX}" \
  --exec-prefix="${USE_PREFIX}" \
  "${COINUTILS_LIB[@]}" \
  "${COINUTILS_INC[@]}" \
  "${OSI_LIB[@]}" \
  "${OSI_INC[@]}" \
  "${EXTRA_FLAGS[@]}" || cat Clp/config.log

make -j "${CPU_COUNT}"

# Tests are broken without Data folder: https://github.com/coin-or/Osi/issues/184
#if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
#  make test
#fi

make install
