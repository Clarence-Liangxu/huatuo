#!/usr/bin/env bash

program='build-gcc.sh'
version='(unvrsioned)'

declare -r PROJ_ROOT="$(cd `dirname $0`; pwd)"
declare -r GCC_INSTALL="${PROJ_ROOT}/gcc-install"
declare -r DEP_INSTALL="${GCC_INSTALL}"
declare -r DEP_DIR="${PROJ_ROOT}/dep"
declare -r logfile="${PROJ_ROOT}/build.log"
declare JOBS
declare Darwin_flags

base_url='https://mirrors.aliyun.com/gnu/'

OS="`uname`"
echo "[Info] running on $OS."

case $OS in
    'Darwin')
	JOBS="$(sysctl -n hw.ncpu)"
	Darwin_flags="--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX13.sdk"
	;;
    'Linux')
	JOBS="$(grep --count ^processor /proc/cpuinfo)"
	;;
    *)
	echo "[Error] not support on this platform. (Linux or Darwin)"
	exit 1
	;;
esac

echo "[Info] JOBS ${JOBS}"
GCC_PKG="gcc-12.2.0"
GCC_SUFFIX=".tar.gz"
GMP_PKG="gmp-6.2.1"
GMP_SUFFIX=".tar.bz2"
MPFR_PKG="mpfr-4.1.0"
MPFR_SUFFIX=".tar.bz2"
MPC_PKG="mpc-1.2.1"
MPC_SUFFIX=".tar.gz"
ISL_PKG="isl-0.24"
ISL_SUFFIX=".tar.bz2"

function help_msg()
{
    echo "hellp"
}

function build-gmp()
{
    cd ${DEP_DIR}
    rm -rf ${GMP_PKG}
    tar -xf ${GMP_PKG}${GMP_SUFFIX} || { echo "tar gmp failed"; return 1; }
    cd ${GMP_PKG}
    mkdir build
    cd build
    ../configure --prefix=${GCC_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build-isl()
{
    cd ${DEP_DIR}
    rm -rf ${ISL_PKG}
    tar -xf ${ISL_PKG}${ISL_SUFFIX} || { echo "tar isl failed"; return 1; }
    cd ${ISL_PKG}
    mkdir build
    cd build
    ../configure --prefix=${DEP_INSTALL} --with-gmp=${DEP_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build-mpc()
{
    cd ${DEP_DIR}
    rm -rf ${MPC_PKG}
    tar -xf ${MPC_PKG}${MPC_SUFFIX} || { echo "tar ${MPC_PKG}${MPC_SUFFIX} failed"; return 1; }
    cd ${MPC_PKG}
    mkdir build
    cd build
    ../configure --prefix=${DEP_INSTALL} \
	      --with-gmp=${DEP_INSTALL} \
	      --with-mpfr=${DEP_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build-mpfr()
{
    cd ${DEP_DIR}
    rm -rf ${MPFR_PKG}
    tar -xf ${MPFR_PKG}${MPFR_SUFFIX} || { echo "tar mpfr failed"; return 1; }
    cd ${MPFR_PKG}
    mkdir build
    cd build
    ../configure --prefix=${DEP_INSTALL} \
	       --with-gmp=${DEP_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build-gcc-prerequist()
{
    build-gmp || { echo "build gmp failed"; return 1; }
    build-mpfr || { echo "build mpfr failed"; return 1; }
    build-mpc || { echo "build mpc failed"; return 1; }
}

function build-gcc()
{
    cd ${DEP_DIR}
    rm -rf ${GCC_PKG}
    tar -xf ${GCC_PKG}${GCC_SUFFIX} || { echo "tar gcc failed"; return 1; }
    cd ${GCC_PKG}
    mkdir build
    cd build
    ../configure --disable-bootstrap \
		 --enable-languages=c,c++,lto \
		 --prefix="${GCC_INSTALL}" \
		 --mandir="${GCC_INSTALL}/share/man" \
		 --infodir="${GCC_INSTALL}/share/info" \
		 --enable-shared \
		 --disable-multilib \
		 --enable-__cxa_atexit \
		 --disable-libunwind-exceptions \
		 --with-gcc-major-version-only \
		 --enable-plugin \
		 --enable-lto \
		 --with-gmp=${DEP_INSTALL} \
		 --with-mpfr=${DEP_INSTALL} \
		 --with-mpc=${DEP_INSTALL} ${Darwin_flags} || { echo "gcc configure failed"; return 1; }
    make -j${JOBS} || { echo "gcc make failed"; return 1; }
    make install || return 1
    return 0
}

function main()
{
    build-gcc-prerequist || { echo "prerequist build failed."; exit 1; }
    build-gcc || { echo "build gcc failed"; exit 1; }
}

main "$@"
